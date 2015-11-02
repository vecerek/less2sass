module Less2Sass
  module Less
    # The lexical environment for Less.
    # Keeps track of variable and mixin definitions.
    # The environment differentiates between simple
    # and constructed(dynamic) variable definitions.
    #
    # A new environment is created for each level of Less nesting.
    # This allows variables to be lexically scoped.
    # Each environment refers to the environment in the upper scope,
    # unless it is the global environment, thus having access to
    # variables defined in enclosing scopes. New variables are defined
    # locally.
    class Environment
      # The enclosing environment, or nil if it's the
      # global environment.
      #
      # @return [Less2Sass::Less::Environment]
      attr_reader :parent

      # Ordered list of static variable definitions.
      # Examples:
      #   - @var: 50px;
      #
      # @return [Array<Less2Sass::Less::Tree::RuleNode>]
      attr_reader :static_var_def_rules

      # Ordered list of constructed variable definitions.
      # Examples:
      #   - @var: @var2;
      #   - @var1: @var2 + 10px;
      #
      # @return [Array<Less2Sass::Less::Tree::RuleNode>]
      attr_reader :dynamic_var_def_rules

      # A list of mixin calls.
      #
      # @return [Array<Less2Sass::Less::Tree::RuleNode>]
      attr_reader :mixin_call_rules

      # @param parent (see :parent)
      def initialize(parent = nil)
        @parent = parent
        @variables_to_reorder = {}
        @static_var_def_rules = {}
        @dynamic_var_def_rules = []
        @rules = []
        @rest = []
        @mixin_call_rules = []
      end

      # Places an array of nodes into this environment.
      #
      # @param [Array<Less2Sass::Less::Tree::Node>] objs
      #   child nodes of a context creator node
      # @see #put
      def set_environment(objs)
        objs.each { |obj| set(obj) }
      end

      # Builds the `dynamic_var_def_rules` ordered array.
      #
      # Processes lazy loaded variables by importing their definition
      # if they are overridden of this environment's scope. Furthermore,
      # it reorders the variable definitions.
      # The only rule is, that the referenced variables should be
      # placed before their first referral. If no variable definition
      # references the the current iteration's variable, it shall be
      # put at the end of the array, since it could reference any of the
      # previously defined variables.
      #
      # @note does not detect recursive variable definitions
      # @return [void]
      # @todo implement detection in future releases
      def build
        process_lazy_loading
        to_reorder = @variables_to_reorder.values
        unless to_reorder.empty?
          @dynamic_var_def_rules << to_reorder.shift
          to_reorder.each do |var|
            @dynamic_var_def_rules.each_with_index do |o_var, index|
              if o_var.references?(var.name)
                @dynamic_var_def_rules.insert(index, var)
                break
              end
              @dynamic_var_def_rules.insert(index + 1, var) if @dynamic_var_def_rules.last.eql?(o_var)
            end
          end
        end
      end

      # Reorders the child nodes of another node, that creates an
      # environment, resp. an execution context.
      #
      # The order should be:
      #
      #   1. Simple/static variables
      #   These do not reference any other variable(s) in their definition.
      #
      #   2. Complex/dynamic variables
      #   These can reference either the static variables in the same context,
      #   other variables from the outer environment, or each other without any
      #   cross-reference, also known as recursive reference.
      #
      #   TODO: maybe directives should be also sorted out and put before the mixin calls
      #   3. Other nodes (directives, rules, rule sets, etc.)
      #
      #   4. Rules (selector + declarations)
      #   The Sass rules (Less rule sets) create a new environment and could redefine
      #   the variables' used after their declaration.
      #
      #   5. Mixin calls
      #   These mixins can reference the rule sets created one step above.
      #
      # @return [Array<Less2Sass::Less::Tree::Node>] the reordered list of nodes
      def get_ordered_child_nodes
        @static_var_def_rules.values + @dynamic_var_def_rules + @rest + @rules + @mixin_call_rules
      end

      def variable_defined?(name)
        @static_var_def_rules[name] || @variables_to_reorder[name]
      end

      def find_variable_definition_if_dynamic(name)
        variable = @variables_to_reorder[name]
        return variable if variable
        @parent ? @parent.find_variable_definition_if_dynamic(name) : nil
      end

      private

      # Puts the nodes of this environment's scope into
      # the appropriate container.
      #
      # Sorts out the variable definitions and mixin calls
      # from the rest. The variable definitions are saved
      # into hashes under their names as keys. If a variable
      # is defined multiple times, only the last definition
      # will be kept.
      #
      # @param [Less2Sass::Less::Tree::Node] obj
      #   the rule to be placed into the environment
      # @return [void]
      def set(obj)
        if obj.is_a?(Less2Sass::Less::Tree::RulesetNode)
          @rules << obj
        elsif obj.is_a?(Less2Sass::Less::Tree::RuleNode)
          if obj.is_variable_definition?
            referenced_vars = obj.get_referenced_variable_names
            if referenced_vars.empty?
              @static_var_def_rules[obj.name] = obj
            else
              obj.ref_vars = referenced_vars
              @variables_to_reorder[obj.name] = obj
            end
          else
            @rest << obj
          end
        elsif obj.is_a?(Less2Sass::Less::Tree::MixinCallNode)
          @mixin_call_rules << obj
        elsif obj.is_a?(Less2Sass::Less::Tree::SelectorNode)
          return # ignore selectors
        else
          @rest << obj
        end
      end

      # Processes lazy loaded variables by importing their definition
      # if they are overridden of this environment's scope.
      #
      # Imports all those variable definitions, whose
      # members are overridden by the variable definitions
      # of the current scope.
      #
      # @return [Void]
      def process_lazy_loading
        rules_to_check = @dynamic_var_def_rules + @rules + @rest + @mixin_call_rules
        rules_to_check.each do |rule|
          rules_to_check += [rule.selectors].flatten if rule.is_a?(Less2Sass::Less::Tree::RulesetNode)
          rule.ref_vars.each do |variable|
            import_definitions_of(variable)
          end unless rule.creates_context?
        end
      end

      # Imports the appropriate variable definitions
      # into the current scope.
      #
      # Those definitions will be imported, that contain a
      # reference to a variable, that is redefined in
      # the current scope. If such a variable is not redefined,
      # its definition is looked for such a variable.
      # The process continues recursively just like the process
      # of lazy loading.
      #
      # @param [String] name the variable's name
      # @return [Void]
      def import_definitions_of(name)
        if @parent
          definition = @parent.find_variable_definition_if_dynamic(name)
          definition.ref_vars.each do |var|
            if variable_defined?(var)
              @variables_to_reorder[definition.name] = definition unless @variables_to_reorder[definition.name]
            else
              import_definitions_of(var)
            end
          end if definition
        end
      end
    end
  end
end
