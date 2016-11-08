module Less2Sass
  module Less
    module Tree
      # Represents the expression in the Less AST.
      #
      # Sass does not have an Expression node. It is usually
      # represented as the `expr` member of the {::Sass::Tree::VariableNode},
      # that represents a variable definition.
      #
      # The Sass equivalent is either {::Sass::Script::Value::Base}
      # wrapped in {::Sass::Script::Tree::Literal} or {::Sass::Tree::Node}.
      class ExpressionNode < Node
        attr_accessor :value

        # @return [Array<String,::Sass::Script::Tree::Node>, ::Sass::Script::Tree::Node, ::Sass::Tree::Node]
        # @see Node#to_sass
        def to_sass
          if @value.is_a?(Array)
            # TODO: document solution of: method to_sass is invoked on "to right":String, deal with it
            if is_multiword_keyword?
              multiword_keyword_argument
            elsif should_be_literal?
              @value.inject([]) { |value, elem| value << elem.to_s }.join(' ')
            elsif media_condition?
              @value.collect { |x| x.to_sass }
            else
              elements = @value.inject([]) do |value, elem|
                node = elem.to_sass
                node = node(::Sass::Script::Tree::Literal.new(node), line) if node.is_a?(::Sass::Script::Value::Base)
                value << node
              end
              node(::Sass::Script::Tree::ListLiteral.new(elements, :space), line)
            end
          else
            value = @value.to_sass
            return value unless value.is_a?(::Sass::Script::Value::Base)
            node(::Sass::Script::Tree::Literal.new(value), line)
          end
        end

        def evaluable?
          true
        end

        # Evaluates the {ExpressionNode}'s into depth = 1.
        # May change later, we need this behavior for {MediaNode} feature
        # evaluation.
        #
        # @see Node#eval
        # @return [ExpressionNode]
        def eval
          if @value.kind_of?(Array)
            @value.each_with_index do |node, i|
              @value[i] = node.eval if node.evaluable?
            end
          else
            @value = @value.eval if @value.evaluable?
          end
          self
        end

        def to_s
          if @value.kind_of?(Array)
            @value.inject([]) { |arr, node| arr << node.to_s }.join(' ')
          else
            @value.to_s
          end
        end

        private

        LITERAL_PROPERTIES = %w(font transition).freeze

        # @todo: should be checked once more
        def is_multiword_keyword?
          @value.select { |elem| !elem.is_a?(KeywordNode) }.empty?
        end

        # Checks, whether the expression contains a {VariableNode}.
        # Some properties in Less store their values as string literals
        # instead of list literals.
        #
        # @return [Boolean] true if the expression should be converted
        #                   to {::Sass::Script::Tree::Literal}
        def should_be_literal?
          grandparent = @parent.parent
          return false unless grandparent.is_a?(RuleNode)
          LITERAL_PROPERTIES.include?(grandparent.name.value) && !contains_variables?
        end

        # Checks, whether the expression is a {MediaNode} feature
        # list.
        #
        # @return [Boolean]
        def media_condition?
          grandparent = @parent.parent
          grandparent.is_a?(MediaNode) && (grandparent.features.eql?(@parent) || grandparent.features.include?(@parent))
        end

        # Creates a {::Sass::Script::Tree::ListLiteral} out of
        # multiple keywords - usually referencing a complex CSS keyword.
        #
        # Example (`to right` is an example of multiword keyword):
        #   `list-style-image: linear-gradient(to right, rgba(255,0,0,0), rgba(255,0,0,1));`
        #
        def multiword_keyword_argument
          keywords = @value.inject([]) { |value, elem| value << elem.to_sass }
          node(::Sass::Script::Tree::ListLiteral.new(keywords, :space), line)
        end
      end
    end
  end
end
