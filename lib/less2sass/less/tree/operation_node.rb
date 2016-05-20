module Less2Sass
  module Less
    module Tree
      # Node representing the operation with 2 operands.
      #
      # Converts to {::Sass::Script::Tree::Operation}.
      class OperationNode < Node
        attr_accessor :op
        attr_accessor :operands
        attr_accessor :isSpaced

        def to_s
          @operands[0].to_s + @op + @operands[1].to_s
        end

        # @see Node#to_sass
        def to_sass
          node(::Sass::Script::Tree::Operation.new(@operands[0].to_sass, @operands[1].to_sass, sass_operator), line)
        end

        # @see RuleNode#eval
        # @note Dimensions should be evaluated according to Less' rules.
        # @return [::Sass::Script::Tree::Literal, DimensionNode]
        def eval
          ops = [@operands[0].eval, @operands[1].eval]
          unit = ops[0].dimension if ops[0].is_a?(DimensionNode)
          unit ||= ops[1].dimension if ops[1].is_a?(DimensionNode)
          result = begin
            case @op
              when '+' then ops[0] + ops[1]
              when '-' then ops[0] - ops[1]
              when '*' then ops[0] * ops[1]
              when '/' then ops[0] / ops[1]
              when '%' then ops[0] % ops[1]
              when 'and' then ops[0] && ops[1]
              when 'or' then ops[0] || ops[1]
              when '==' then ops[0] == ops[1]
              when '!=' then ops[0] != ops[1]
              when '>=' then ops[0] >= ops[1]
              when '<=' then ops[0] <= ops[1]
              when '>' then ops[0] > ops[1]
              when '<' then ops[0] < ops[1]
              else
               raise EvaluationError, "operator #{@op}"
            end
          end
          return result unless unit
          dimension_node(result, unit)
        end

        private

        # A hash from operator strings to the corresponding token types.
        #
        # Copied from Sass' lexer
        # @see https://github.com/sass/sass/blob/stable/lib/sass/script/lexer.rb#L44-L69
        OPERATORS = {
          '+' => :plus,
          '-' => :minus,
          '*' => :times,
          '/' => :div,
          '%' => :mod,
          '=' => :single_eq,
          ':' => :colon,
          '(' => :lparen,
          ')' => :rparen,
          ',' => :comma,
          'and' => :and,
          'or' => :or,
          'not' => :not,
          '==' => :eq,
          '!=' => :neq,
          '>=' => :gte,
          '<=' => :lte,
          '>' => :gt,
          '<' => :lt,
          '#{' => :begin_interpolation,
          '}' => :end_interpolation,
          ';' => :semicolon,
          '{' => :lcurly,
          '...' => :splat
        }.freeze

        # Returns the sass operator symbol, that is used internally.
        #
        # @param [String] op the operator to look for
        # @return [Symbol] the operator symbol
        def sass_operator(op = @op)
          raise Less2Sass::OperatorConversionError, op unless OPERATORS[op]
          OPERATORS[op]
        end
      end
    end
  end
end
