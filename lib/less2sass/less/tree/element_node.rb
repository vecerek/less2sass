module Less2Sass
  module Less
    module Tree
      # Represents the elements of a {SelectorNode}.
      # These elements are usually separated by a
      # {CombinatorNode}.
      #
      # No equivalent in Sass.
      class ElementNode < Node
        # @return [Tree::CombinatorNode]
        attr_accessor :combinator
        # @return [String]
        attr_accessor :value
        # @return [Integer]
        attr_accessor :index
        # @return [Hash]
        attr_accessor :currentFileInfo

        # @see Node#to_sass
        def to_sass
          if @value.is_a?(VariableNode)
            @value.to_sass
          elsif @value.is_a?(String)
            @combinator.to_s + @value
          else
            raise FeatureConversionError, self
          end
        end
      end
    end
  end
end
