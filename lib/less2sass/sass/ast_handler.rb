module Less2Sass
  module Sass
    # Wrapped Sass AST
    class ASTHandler
      # Creates an empty Sass AST.
      #
      # @param [::Sass::Tree::Node] tree the Sass AST
      def initialize(tree)
        @tree = tree
      end

      # Appends child notes to the empty Sass AST.
      #
      # Note, that this should be called only once.
      #
      # @param [::Sass::Tree::Node] child the rest
      #   of the converted Less AST
      def <<(child)
        # TODO: check if child.is_a?(::Sass::Tree::Node) and raise some error, if not
        @tree << child
        self
      end

      def to_css
        @tree.render
      end

      # Outputs the transformed and converted AST
      # in the form of Sass code.
      #
      # @todo method cannot handle import nodes, yet - single files only
      #
      # @param [String, IO] destination the base directory
      #   or an IO Stream where the converted projects
      #   should be outputted.
      def code_gen(destination = nil)
        code = @tree.to_scss
        return code unless destination
        if destination.is_a?(String)
          open_file(destination, 'w') { |file| file.write(code) }
        else
          destination.write(code)
        end
      end

      def open_file(filename, flag = 'r')
        return if filename.nil?
        return File.open(filename, flag) unless block_given?
        yield File.open(filename, flag)
      end

      def to_yaml
        @tree.to_yaml
      end
    end
  end
end
