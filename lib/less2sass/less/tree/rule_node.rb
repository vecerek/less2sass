module Less2Sass
  module Less
    module Tree
      # A RuleNode in Less can be a CSS rule, or a
      # variable definition.
      #
      # Examples:
      #   - color: @var;
      #   - @var: 50px;
      #
      # The Sass equivalent is {::Sass::Tree::VariableNode}
      # or {::Sass::Tree::RuleNode}.
      class RuleNode < Node
        attr_accessor :name
        attr_accessor :value
        attr_accessor :important
        attr_accessor :merge
        attr_accessor :index
        attr_accessor :currentFileInfo
        attr_accessor :inline
        attr_accessor :variable

        attr_accessor :guarded
        attr_accessor :global

        # @see VariableNode#sass_name
        def sass_name
          @name[1..-1] if @name
        end

        # Returns whether the node is a variable definition.
        #
        # @return [Boolean]
        def variable_definition?
          @variable
        end

        # Checks, if the given variable is referenced by the variable's definition
        #
        # @param [Less2Sass::Less::Tree:RuleNode] variable the variable
        # @param [String] variable the variable's name
        # @return [Boolean]
        def references?(variable)
          if variable.is_a?(String)
            @ref_vars.include?(variable)
          else
            @ref_vars.include?(variable.name)
          end
        end

        # Converts this node to {::Sass::Tree::VariableNode}, if
        # it's a variable definition. Otherwise it must be a CSS
        # property declaration and gets converted to {::Sass::Tree::PropNode}.
        #
        # The 3rd param of `::Sass::Tree::PropNode` refers to the CSS
        # syntax to be outputted. Its value can be:
        #   - `:new` using `a: b`-style syntax
        #   - `:old` using `:a b`-style syntax
        #
        # For the sake of simplicity, we'll use the new syntax only.
        # Later could be set in cli arguments as option.
        #
        # @note Always put on a new line.
        # @return [::Sass::Tree::VariableNode, ::Sass::Tree::PropNode]
        # @see Node#to_sass
        def to_sass
          node ||=
            begin
              if variable_definition?
                ::Sass::Tree::VariableNode.new(
                  sass_name, @value.to_sass, @guarded, @global
                )
              else
                ::Sass::Tree::PropNode.new(
                  process_property_name, @value.to_sass, :new
                )
              end
            end
          node(node, line(:new))
        end

        # Evaluates the variable definition according to the environment
        # it is a part of.
        #
        # @raise EvaluationError if not a variable definition
        # @return [Node, String, Number] the value of the defined variable
        def eval
          raise EvaluationError, PropNode unless variable_definition?
          result = @value.eval
          return result.to_sass if result.is_a?(Node) # i.e. DimensionNode
          result
        end

        private

        # Creates the Sass representation of the property name.
        #
        # @return [Array<String, ::Sass::Script::Tree::Node>]
        def process_property_name
          return [create_name] unless @name.is_a?(Array)
          @name.inject([]) do |name, part|
            name << create_name(part)
          end
        end

        # Returns a part of the property name.
        #
        # @param [VariableNode, #to_s] name part of the property name
        # @return [String, ::Sass::Script::Tree::Node] converted
        #   part of property name
        def create_name(name = @name)
          if name.is_a?(VariableNode)
            create_interpolation(name)
          else
            name.to_s
          end
        end

        # Creates a Sass interpolation node
        #
        # @param [VariableNode] variable_node the variable node to convert
        # @return [::Sass::Script::Tree::Interpolation] a Sass Interpolation node
        def create_interpolation(variable_node)
          var = ::Sass::Script::Tree::Variable.new(variable_node.name[1..-1])
          node(::Sass::Script::Tree::Interpolation.new(nil, var, nil, false, false), line)
        end
      end
    end
  end
end
