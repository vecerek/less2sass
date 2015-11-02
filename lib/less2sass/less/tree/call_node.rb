module Less2Sass
  module Less
    module Tree
      # Represents a function call node. It can be either
      # a CSS or a Less built-in function.
      #
      # Its Sass equivalent is {::Sass::Script::Tree::Funcall}.
      class CallNode < Node
        attr_accessor :name
        attr_accessor :args
        attr_accessor :index
        attr_accessor :currentFileInfo

        # TODO: Map Less built-in functions to Sass built-in functions, null if there is no equivalent

        MISC_FUNCTIONS = %w(color image-size image-width image-height
                            convert data-uri default unit get-unit svg-gradient).freeze

        STRING_FUNCTIONS = %w(escape e % replace).freeze

        LIST_FUNCTIONS = %w(length extract).freeze

        MATH_FUNCTIONS = %w(ceil floor percentage round sqrt abs sin
                            asin cos acos tan atan pi pow mod min max).freeze

        TYPE_FUNCTIONS = %w(isnumber isstring iscolor iskeyword isurl
                            ispixel isem ispercentage isunit isruleset).freeze

        COLOR_DEFINITION_FUNCTIONS = %w(rgb rgba argb hsl hsla hsv hsva).freeze

        COLOR_CHANNEL_FUNCTIONS = %w(hue saturation lightness hsvhue hsvsaturation
                                     hsvvalue red green blue alpha luma luminance).freeze

        COLOR_OPERATION_FUNCTIONS = %w(saturate desaturate lighten darken fadein
                                       fadeout fade spin mix tint shade greyscale contrast).freeze

        COLOR_BLENDING_FUNCTIONS = %w(multiply screen overlay softlight hardlight
                                      difference exclusion average negation).freeze

        # @todo built-in functions should be converted by the mapping
        #   if there is no equivalent, a custom conversion should be implemented.
        #   If the {Hash} does not contain the function, most probably, it's a
        #   CSS built-in function and it should be copied as it is.
        #
        # @note In its current version it could output unrecognizable functions
        #   by the Sass compiler and/or interpreter.
        # @return [::Sass::Script::Tree::Funcall]
        # @see Node#to_sass
        def to_sass
          node(::Sass::Script::Tree::Funcall.new(@name, get_args, ::Sass::Util::NormalizedMap.new, nil, nil), line)
        end

        private

        def get_args
          if @args.is_a?(Array)
            @args.inject([]) { |args, arg| args << arg.to_sass }.flatten
          else
            [@args.to_sass]
          end
        end
      end
    end
  end
end
