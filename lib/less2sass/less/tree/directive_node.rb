module Less2Sass
  module Less
    module Tree
      # Represents a static CSS directive.
      #
      # Examples:
      #   - @charset
      #   - @namespace
      #   - @keyframes
      #   - @counter-style
      #   - @document
      #   - @supports
      #
      # The Sass equivalent is {::Sass::Tree::DirectiveNode}.
      # @note - Sits on a new line.
      #       - Its value(s) can't be variables - if variables
      #         are specified, Less treats them as they were
      #         {AnonymousNodes}.
      # @see Node
      class DirectiveNode < Node
        attr_accessor :name
        attr_accessor :value
        attr_accessor :rules
        attr_accessor :index
        attr_accessor :currentFileInfo
        attr_accessor :debugInfo
        attr_accessor :isRooted

        # @return [::Sass::Tree::DirectiveNode]
        # @see Node#to_sass
        def to_sass
          node = node(::Sass::Tree::DirectiveNode.new(value), line(:new))
          @rules.rules.each { |c| node << c.to_sass } # Not all children should be passed
          node
        end

        def value
          empty? ? [@name] : [@name + ' ', @value.to_s]
        end
      end
    end
  end
end
