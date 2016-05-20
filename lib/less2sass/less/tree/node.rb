require 'less2sass/less/environment'

module Less2Sass
  module Less
    module Tree
      # The base node class of the Less AST.
      class Node
        include Enumerable

        # The parent node of this node.
        #
        # @return [Less2Sass::Less::Tree::Node]
        attr_accessor :parent

        # Whether or not this node has parent node.
        #
        # @return [Boolean]
        attr_reader :has_parent

        # The child nodes of this node.
        #
        # @return [Array<Less2Sass::Less::Tree::Node>]
        attr_accessor :children

        # Whether or not this node has child nodes.
        #
        # @return [Boolean]
        attr_reader :has_children

        # Sets the line number of the node
        #
        # @return [Void]
        attr_writer :line

        # This member gets set if the node's children contain
        # referenced {VariableNode}s.
        #
        # @return [Array<String>] referenced variable names
        attr_accessor :ref_vars

        # The environment, where the node sits lexically.
        #
        # @return [Less2Sass::Less::Environment]
        attr_reader :env

        # The current line number the conversion process is at
        @@lines = 0

        def initialize(parent = nil)
          @children = []
          @parent = parent
          @creates_new_line = false
        end

        # @private
        def parent=(parent)
          @has_parent ||= !parent.nil?
          @parent = parent
        end

        # @private
        def children=(children)
          @has_children ||= !children.empty?
          @children = children
        end

        # @private
        def ref_vars
          @ref_vars || get_referenced_variable_names
        end

        # Tells, whether the node creates a new context
        # or variable environment.
        #
        # @return [Boolean]
        def creates_context?
          false
        end

        # Appends a child to the node.
        #
        # @param [Less2Sass::Less::Tree::Node, Array<Less2Sass::Less::Tree::Node>] child
        #   The child node or nodes
        def <<(child)
          return if child.nil?
          if child.is_a?(Array)
            child.each { |c| self << c }
          else
            @has_children = true
            child.parent = self
            @children << child
          end
        end

        # Compares this node and another object (only other {Less2Sass::Less::Tree::Node}s will be equal).
        #
        # @param [Object] other The object to compare with
        # @return [Boolean] Whether or not this node and the other object
        #   are the same
        def ==(other)
          self.class == other.class && other.children == children
        end

        # Iterates through each node in the tree rooted at this node
        # in a pre-order walk.
        #
        # @yield node
        # @yieldparam node [Less2Sass::Less::Tree::Node] a node in the tree
        def each
          yield self
          children.each { |c| c.each { |n| yield n } }
        end

        # The base implementation of transform.
        #
        # Transforms the tree by its traversal. Each respective node type
        # should implement the specific transformation and calling `#super`.
        # The position, where `#super` is called determines the walking order.
        # The standard should be post-order walk - transforming the child nodes
        # first and self as last.
        # Sets a reference to the environment of the node. Can be nil, if sits
        # in the global scope.
        #
        # Should be overridden by subclasses adding specific implementation.
        #
        # @param [Less2Sass::Less::Environment] env parent environment
        # @return [Void]
        def transform(env = nil)
          @env = env
          @children.each { |c| c.transform(env) }
        end

        # Returns the line number and sets the class level
        # current line number based on the passed option.
        #
        # @param [Symbol] opt the line number option
        # @option opt [Symbol] :new tells the method to
        #   return the next line and increments @@lines
        # @option opt [Symbol] :current tells the method to
        #   return the current line the converter is "processing"
        #
        # @return [Fixnum] the line number based on the given option
        def line(opt = :current)
          case opt
          when :current
            @@lines
          when :new
            @@lines = @@lines.next
          else
            raise StandardError, "Option can't be other than :current or :new"
          end
        end

        # Converts this node to the equivalent Sass node
        #
        # Should be overwritten by subclasses.
        # All subclasses should also set the line number
        # of the resulting Sass node.
        #
        # @raise NotImplementedError if called on the base node object
        #   or subclass method not implemented, yet.
        def to_sass
          raise NotImplementedError
        end

        # Loops through the children nodes and
        # searches for variable occurrences.
        #
        # @return [Array<String>] list of variable names
        #   contained in the value's expressions
        # @note Use on {Less2Sass::Less::Tree::RuleNode}s. It's a good practice
        #   to check first if it's a variable definition.
        #   See (Less2Sass::Less::Tree::RuleNode#is_variable_definition?)
        def get_referenced_variable_names
          if is_a?(VariableNode)
            [@name]
          else
            @children.inject([]) { |vars, c| vars + c.get_referenced_variable_names }
          end
        end

        # Checks, whether a variable is referenced in the scope of the node.
        #
        # @return [Boolean]
        def contains_variables?
          variables = nil
          each do |child|
            if child.is_a?(VariableNode)
              variables = true
              break
            end
          end
          variables
        end

        # Checks, whether a node can be evaluable.
        # Useful when replacing variable nodes with their real value.
        # E.g.: The features (i.e.: tv, screen, etc.) of a media node
        # cannot be variables in Sass, as opposed to Less.
        #
        # @return [Boolean]
        def evaluable?
          false
        end

        protected

        # Sets up a node with the mandatory options (line, options).
        #
        # @param [::Sass::Tree::Node, ::Sass::Script::Tree::Node] node
        #   the node to be set up
        # @param [Fixnum] line the line number, where the node sits lexically
        # @param [Hash] options the options to pass to the node
        # @return [::Sass::Tree::Node, ::Sass::Script::Tree::Node] the set up node
        def node(node, line, options = { :style => :nested })
          node.line = line if line
          node.options = options if node.class.method_defined?(:options=)
          node
        end

        def dimension_node(value, unit)
          dimension = DimensionNode.new
          dimension.value = value
          dimension.unit = unit
          dimension
        end

        def env(parent = nil, children = @children)
          children = [children] unless children.is_a?(Array)
          env = Less2Sass::Less::Environment.new(parent)
          env.set_environment(children).build
        end
      end
    end
  end
end
