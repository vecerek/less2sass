module Less2Sass
  module Less
    module Tree
      # Represents either a single-line or a block comment
      # Unfortunately, there is no way to find out, whether
      # the comment has been put on a new line or it just
      # continues on the same line as a rule, for instance.
      #
      # Examples:
      #   color: #fff; //line comment
      #   or
      #   color: #fff;
      #   //line comment
      #
      # The AST will be absolutely identical in both cases.
      # So let's come up with a convention:
      #   - line comments will be put on the same line as
      #     the previous node
      #   - block comments will be put on new lines
      class CommentNode < Node
        attr_accessor :value
        attr_accessor :isLineComment
        attr_accessor :currentFileInfo

        def to_sass
          line = line(@isLineComment ? :current : :new)
          node(::Sass::Tree::CommentNode.new([@value], type), line)
        end

        private

        # Specifies the type of the comment.
        #
        # There are 3 types of comments in Sass:
        #   - :normal (output to CSS except in :compressed mode)
        #   - :silent (never output to CSS)
        #   - :loud (output to CSS even in :compressed mode)
        #
        # To evaluate the type correctly, the original implementation
        # needs to be used.
        # @see https://github.com/sass/sass/blob/63586f1e51c0aec47a7afcc8cd17aa03f32f0a29/lib/sass/engine.rb#L764-765
        #
        # @return [Symbol] the type of Sass comment
        def type
          silent = @value[1] == ::Sass::Engine::SASS_COMMENT_CHAR
          loud = !silent && @value[2] == ::Sass::Engine::SASS_LOUD_COMMENT_CHAR
          if silent
            :silent
          elsif loud
            :loud
          else
            :normal
          end
        end
      end
    end
  end
end
