module Less2Sass
  module Less
    module Tree
      # Represents the full selector of a given {RulesetNode}.
      #
      # No equivalent node is present in Sass, it's the `rule`
      # member of {::Sass::Tree::PropNode}, instead.
      class SelectorNode < Node
        # @return [Array<Tree::ElementNode>]
        attr_accessor :elements
        attr_accessor :extendList
        attr_accessor :condition
        # @return [Hash]
        attr_accessor :currentFileInfo
        # @return [Boolean]
        attr_accessor :evaldCondition

        # see Node#to_sass
        def to_sass
          raise UnknownError if @elements.nil?
          return @elements.to_sass unless @elements.is_a?(Array)
          @elements.inject([]) { |selector, element| selector << element.to_sass }
        end
      end
    end
  end
end
