module Less2Sass
  module Less
    module Tree
      # Represents the value of any Less AST node.
      #
      # It has no individual representation in Sass,
      # so it returns its value node's Sass representation,
      # when {#to_sass} gets called.
      #
      # Sass equivalents:
      #   - {::Sass::Script::Tree::Literal} if part of property declaration
      #   - {::Sass::Script::Tree::ListLiteral} if part of variable definition
      #
      # @see Node
      class ValueNode < Node
        # @todo update Sass and check out a lately commit regarding the deprecated SassScript usage in CSS rules
        # @see https://github.com/sass/sass/commit/b671122234d2d4df088a6c6d4c54b64d6997d255

        # The ValueNode is not the final value of a variable
        # or a property.
        #
        # @return [Node, Array<Node>]
        attr_accessor :value

        # This node's value is either a single expression,
        # or an array of those. The array needs to be further
        # processed.
        #
        # @return [::Sass::Script::Tree::Literal, ::Sass::Script::Tree::ListLiteral]
        # @see Node#to_sass
        def to_sass
          if @value.is_a?(Array)
            # TODO: don't forget about interpolation. What if one of the expressions is a variable?
            if @parent.is_variable_definition? || contains_variables?
              elements = @value.inject([]) { |elements, elem| elements << elem.to_sass }
              node(::Sass::Script::Tree::ListLiteral.new(elements, :comma), line)
            else
              value = @value.inject([]) do |value, elem|
                substring = elem.to_sass
                # TODO: describe solution for '"Source Code Pro", Monaco, monospace'
                substring = substring.value.value if substring.is_a?(::Sass::Script::Tree::Literal)
                value << substring
              end.join(', ')
              node(::Sass::Script::Tree::Literal.new(::Sass::Script::Value::String.new(value)), line)
            end
          else
            @value.to_sass
          end
        end
      end
    end
  end
end
