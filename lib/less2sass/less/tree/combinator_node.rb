module Less2Sass
  module Less
    module Tree
      # Represents the separator between some nodes.
      # No equivalent in Sass.
      class CombinatorNode < Node
        # @return [String]
        attr_accessor :value
        # @return [Boolean]
        attr_accessor :emptyOrWhitespace

        def to_s
          @value
        end
      end
    end
  end
end
