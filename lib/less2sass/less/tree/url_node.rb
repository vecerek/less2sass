module Less2Sass
  module Less
    module Tree
      # Represents the CSS `url` function call.
      #
      # The Sass equivalent is {::Sass::Script::Tree::Funcall}.
      class UrlNode < Node
        attr_accessor :value
        attr_accessor :currentFileInfo
        attr_accessor :index
        attr_accessor :isEvald

        # @return [::Sass::Script::Tree::Funcall]
        # @see https://github.com/sass/sass/blob/stable/lib/sass/script/tree/funcall.rb#L42-46
        # @see Node#to_sass
        def to_sass
          node(::Sass::Script::Tree::Funcall.new('url', [@value.to_sass], ::Sass::Util::NormalizedMap.new, nil, nil), line)
        end

        def evaluable?
          true
        end

        # Evaluates the url node's argument, which can be a quoted string
        # containing variable interpolations that may be needed to evaluate.
        #
        # @see RuleNode#eval
        # @return [UrlNode]
        def eval
          @value.eval
          self
        end

        def to_s
          "url(#{@value.to_s})"
        end
      end
    end
  end
end
