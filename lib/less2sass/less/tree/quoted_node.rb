module Less2Sass
  module Less
    module Tree
      # Represents a single or double-quoted string in Less.
      #
      # The Sass equivalent is a {::Sass::Script::Value::String}
      # wrapped in {::Sass::Script::Tree::Literal}.
      class QuotedNode < Node
        attr_accessor :escaped
        attr_accessor :value
        attr_accessor :quote
        attr_accessor :index
        attr_accessor :currentFileInfo

        # Returns the Sass equivalent for a quoted string.
        #
        # @return [::Sass::Script::Tree::Literal] simple string literal
        # @return [::Sass::Script::Tree::StringInterpolation] interpolation node,
        #   if the string contains interpolations
        # @see Node#to_sass
        def to_sass
          if string_interpolation?
            interpolation_node(@value)
          else
            node(::Sass::Script::Tree::Literal.new(::Sass::Script::Value::String.new(@value, :string)), line)
          end
        end

        # It is evaluable, since it can contain variable interpolations
        # that need to be evaluated in case of need.
        #
        # @see Node#evaluable?
        def evaluable?
          true
        end

        # Evaluates the variable interpolations and replaces them
        # with their real values.
        #
        # @see RuleNode#eval
        # @return [QuotedNode]
        def eval
          if string_interpolation?
            variables = @value.scan(VARIABLE_NAME).flatten
            values = variables.inject({}) do |hash, var|
              hash["@{#{var}}".to_sym] = @env.lookup("@#{var}").to_s
              hash
            end
            values.each { |k,v| @value.gsub!(k.to_s, v) }
          end
          self
        end

        # Returns the string's raw value without passing the type of quote.
        #
        # Sass has its own standards regarding the quotes, it should be in
        # Sass' competences to choose what type of quote to use.
        def to_s
          @value
        end

        # Checks, whether the quoted string contains an interpolation.
        #
        # @return [Boolean]
        def string_interpolation?(value = @value)
          !value.index(INTERPOLATION).nil?
        end

        private

        INTERPOLATION = /(@\{[\w_-]*\})/
        VARIABLE_NAME = /@\{([\w_-]*)\}/

        # Creates a {::Sass::Script::Tree::StringInterpolation} node.
        #
        # @param [String] value the string containing interpolation(s)
        # @return [::Sass::Script::Tree::StringInterpolation] the interpolation node
        def interpolation_node(value)
          parts = value.split(INTERPOLATION, 2) # Must be split maximally into 3 parts
          parts[2] = '' if parts.length == 2 # Always must have 3 parts
          before = node(::Sass::Script::Tree::Literal.new(::Sass::Script::Value::String.new(parts[0], :string)), line)
          mid = node(::Sass::Script::Tree::Variable.new(parts[1].match(VARIABLE_NAME)[1]), line)
          after = string_interpolation?(parts[2]) ? interpolation_node(parts[2]) : node(::Sass::Script::Tree::Literal.new(::Sass::Script::Value::String.new(parts[2], :string)), line)
          node(::Sass::Script::Tree::StringInterpolation.new(before, mid, after), line)
        end
      end
    end
  end
end
