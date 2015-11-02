module Less2Sass
  module Less
    module Tree
      # Representation of a number and a unit.
      # The Sass equivalent is the {::Sass::Script::Value::Number}
      # or {::Sass::Script::Tree::Literal} if the dimension is a part
      # of an {ExpressionNode}'s {OperationNode}.
      class DimensionNode < Node
        attr_accessor :value
        attr_accessor :unit

        # @see Node#to_sass
        def to_sass
          numerator = @unit.is_a?(UnitNode) ? @unit.numerator : @unit['numerator']
          denominator = @unit.is_a?(UnitNode) ? @unit.denominator : @unit['denominator']
          dimension = ::Sass::Script::Value::Number.new(@value, numerator, denominator)
          node(::Sass::Script::Tree::Literal.new(dimension), line)
        end

        def to_s
          @value.to_s + @unit.to_s
        end
      end
    end
  end
end
