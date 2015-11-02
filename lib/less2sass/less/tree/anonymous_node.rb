module Less2Sass
  module Less
    module Tree
      # Represents a CSS literal in Less.
      #
      # Its Sass equivalent is {::Sass::Script::Value::Base}
      # wrapped in {::Sass::Script::Tree::Literal}.
      class AnonymousNode < Node
        attr_accessor :value
        attr_accessor :index
        attr_accessor :mapLines
        attr_accessor :currentFileInfo
        attr_accessor :rulesetLike

        # Converts to a {::Sass::Script::Tree::Literal} that
        # encapsulates a {::Sass::Script::Value::Base}.
        #
        # @note Never seen a different equivalent than String
        #   or a Number but can't be sure.
        # @raise FeatureConversionError if `@value` not a String
        #   or a Numeric.
        # @return [::Sass::Script::Tree::Literal]
        # @see Node#to_sass
        def to_sass
          subnode ||=
            begin
              if @value.is_a?(String)
                # Always an :identifier - the default value of the 2nd param
                ::Sass::Script::Value::String.new(@value)
              elsif @value.is_a?(Numeric)
                # Anonymous nodes do not have a numerator nor a denominator
                ::Sass::Script::Value::Number.new(@value)
              else
                raise FeatureConversionError, self
              end
            end
          return subnode if subnode.is_a?(::Sass::Script::Tree::Literal)
          node(::Sass::Script::Tree::Literal.new(subnode), line)
        end
      end
    end
  end
end
