module Less2Sass
  module Less
    module Tree
      # CSS color representation.
      #
      # Usually appears at variable definitions.
      # Example:
      #   - `@color: #fff;` rule contains ColorNode
      #   - `color: #fff;` property declaration does
      #     not contain ColorNode
      #
      # The Sass equivalent is {::Sass::Script::Value::Color}.
      class ColorNode < Node
        attr_accessor :rgb
        attr_accessor :alpha
        attr_accessor :value

        # @return [::Sass::Script::Value::Color]
        # @see Node#to_sass
        def to_sass
          color = node(::Sass::Script::Value::Color.new(@rgb, @value), nil)
          node(::Sass::Script::Tree::Literal.new(color), line)
        end
      end
    end
  end
end
