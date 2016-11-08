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

        # Less does not distinguish the @supports directive
        # from the others, as it does with @media, as opposed to Sass.
        #
        # 1. In case of the {DirectiveNode} represents a @supports directive,
        #    an {::Sass::Tree::SupportsNode} needs to be returned.
        #
        # 2. In case of @namespace directive, the child nodes need to be
        #    evaluated, since Sass does not support variable interpolations
        #    in @namespace directives, as opposed to Less.
        #
        # Less does not support variables inside the @supports condition,
        # so the node does not have to be evaluated. The condition
        # is just parsed using the Sass parser and a {::Sass::Tree::SupportsNode}
        # is created.
        #
        # @return [::Sass::Tree::DirectiveNode, ::Sass::Tree::SupportsNode]
        # @see Node#to_sass
        def to_sass
          if supports_directive?
            node = node(::Sass::Tree::SupportsNode.new('supports', condition), line(:new))
          else
            @value.eval if namespace_directive? && should_be_evald?
            node = node(::Sass::Tree::DirectiveNode.new(value), line(:new))
          end
          @rules.rules.each { |c| node << c.to_sass } unless @rules.nil? # Not all children should be passed
          node
        end

        # Returns formatted value.
        #
        # @return [Array<String>]
        def value
          empty? ? [@name] : [@name + ' ', @value.to_s]
        end

        # Checks, whether the DirectiveNode is a SupportsNode.
        #
        # @return [Boolean]
        def supports_directive?
          @name == '@supports'
        end

        # Checks, whether the DirectiveNode is a NamespaceNode.
        #
        # @return [Boolean]
        def namespace_directive?
          @name == '@namespace'
        end

        private

        # Parses the @supports directive's condition.
        #
        # @return [::Sass::Supports::Condition]
        def condition
          ::Sass::SCSS::Parser.new(@value.to_s, '', nil).parse_supports_condition
        end

        def should_be_evald?
          @value.evaluable? && @value.contains_variables?
        end
      end
    end
  end
end
