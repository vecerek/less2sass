require 'less2sass/less/parser'

module Less2Sass
  module Less
    # Handler of the Less AST.
    class ASTHandler
      # @param [File, IO] input the root file of the Less project
      # @param [Symbol] target_syntax the specified Sass syntax
      #   for the conversion.
      def initialize(input, target_syntax)
        @target_syntax = target_syntax
        parser = Parser.new(input)
        # TODO: check syntax only if specified in the command-line options
        # parser.check_syntax unless input == $stdin
        @tree = parser.parse
      end

      # Transforms the Less AST, so it can be converted to
      # an equivalent Sass AST representation.
      def transform_tree
        @tree.transform
        self
      end

      # Converts the transformed Less AST to Sass AST.
      #
      # @return [Less2Sass::Sass::ASTHandler] a wrapped Sass AST
      def to_sass
        Less2Sass::Sass::ASTHandler.new(@tree.to_sass(:syntax => @target_syntax))
      end
    end
  end
end
