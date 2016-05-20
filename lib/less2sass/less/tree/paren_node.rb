module Less2Sass
  module Less
    module Tree
      class ParenNode < Node
        attr_accessor :value

        def to_sass
          paren = ['(']
          if @value.is_a?(RuleNode)
            paren << @value.name
            paren << ': '
            paren << @value.value.to_sass
          else
            paren << @value.to_sass
          end
          paren << ')'
          paren
        end
      end
    end
  end
end
