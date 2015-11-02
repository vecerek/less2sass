module Less2Sass
  module Less
    module Tree
      # The Ruleset node is the root node of every Less AST.
      # It also means a block of selector and its inner rules.
      #
      # Its Sass equivalent is a {::Sass::Tree::RootNode}, or
      # {::Sass::Tree::RuleNode}.
      class RulesetNode < Node
        attr_accessor :selectors, :rules, :_lookups,
                      :root, :firstRoot, :strictImports

        def initialize(options = nil)
          super
          @options = options unless options.nil?
        end

        # @see Node#creates_context?
        def creates_context?
          true
        end

        # Transforms the ruleset node by reordering the child nodes.
        #
        #   1. Creates a new environment and puts the child
        #      nodes into it.
        #
        #   2. Further traverses the tree of nodes and transforms them, as well.
        #
        #   3. Saves the re-ordered rules and child nodes.
        #
        # @param (see Node#transform)
        # @return [Void]
        def transform(env = nil)
          env = Less2Sass::Less::Environment.new(env)
          env.set_environment(@children)
          env.build
          super(env)
          @rules = env.get_ordered_child_nodes
          @children = @rules
        end

        # Converts node to {::Sass::Tree::RootNode} if it's root.
        # Otherwise it converts to {::Sass::Tree::RuleNode}.
        #
        # In case of root node, all the children nodes have to be
        # converted. Otherwise rule nodes only.
        #
        # @note I both cases the node is placed on a new line.
        # @return [::Sass::Tree::RootNode, ::Sass::Tree::RuleNode]
        # @see Node#to_sass
        def to_sass(options = nil)
          if @root
            node = node(::Sass::Engine.new('', options).to_tree, line(:new))
            children = @children
          else
            node = node(::Sass::Tree::RuleNode.new(get_full_selector), line(:new))
            children = @rules.is_a?(Array) ? @rules : [@rules]
          end
          children.each { |c| node << c.to_sass }
          node
        end

        private

        # Creates a list of selectors.
        #
        # @return [Array<String, Sass::Script::Tree::Node>] the list of selectors
        def get_full_selector
          raise UnknownError if @selectors.nil?
          if @selectors.is_a?(Array)
            # Creates a list of selectors {Array<String, Sass::Script::Tree::node>} separated by a comma
            # and returns the list without the last, trailing comma
            @selectors.inject([]) { |rule, selector| rule << [selector.to_sass, ','] }.flatten[0..-2]
          else
            [@selectors.to_sass].flatten
          end
        end
      end
    end
  end
end
