module Less2Sass
  module Less
    module Tree
      # A node representing a variable.
      # The Sass representation of it is {::Sass::Script::Tree:Variable}
      class VariableNode < Node
        # @return [String]
        attr_accessor :name
        # @return [Integer]
        attr_accessor :index
        # @return [Hash]
        attr_accessor :currentFileInfo

        # Returns the sass specific name property by
        # removing the starting @.
        #
        # Example:
        #   node.sass_name => "var1"
        #
        # @return [String]
        def sass_name
          @name[1..-1] if @name
        end

        # Checks, whether the variable node is an interpolation
        #
        # @return [Boolean]
        def interpolation?
          return false unless [ElementNode, RuleNode].include?(@parent.class)
          return !@parent.is_variable_definition? if @parent.is_a?(RuleNode)
          true
        end

        # @see Node#to_sass
        def to_sass
          variable = node(::Sass::Script::Tree::Variable.new(sass_name), line)
          variable = node(::Sass::Script::Tree::Interpolation.new(nil, variable, nil, false, false), line) if interpolation?
          variable
        end
      end
    end
  end
end
