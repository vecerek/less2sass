module Less2Sass
  module Less
    module Tree
      # Represents the CSS property names and
      # a little bit more.
      #
      # It can represent the name of a CSS rule,
      # or it can be a part of a variable definition's
      # value.
      #
      # In the latter case its Sass equivalents are:
      #   - {::Sass::Script::Value::Bool}
      #   - {::Sass::Script::Value::Null}
      class KeywordNode < Node
        attr_accessor :value

        def to_s
          @value.to_s
        end

        def empty?
          @value.empty?
        end

        # Returns a SassScript Value node.
        #
        # Usually will be called in case of a variable
        # definition and its parent node would be a
        # {ExpressionNode}, which would wrap it up into a
        # {::Sass::Script::Tree::Literal}.
        #
        # @raise FeatureConversionError if this node's value is not expected.
        # @return [::Sass::Script::Value::Base]
        # @see Node#to_sass
        def to_sass
          case @value
          when 'true' then ::Sass::Script::Value::Bool.new(true)
          when 'false' then ::Sass::Script::Value::Bool.new(false)
          when 'null' then ::Sass::Script::Value::Null.new
          else
            @value = add_spaces(@value) if ADD_SPACES.include?(@value)
            raise FeatureConversionError, self unless @value.respond_to?(:to_s)
            string = ::Sass::Script::Value::String.new(@value.to_s)
            node(::Sass::Script::Tree::Literal.new(string), line)
          end
        end

        def eval
          self
        end

        private

        ADD_SPACES = %w(and or)

        def add_spaces(val)
          " #{val} "
        end
      end
    end
  end
end
