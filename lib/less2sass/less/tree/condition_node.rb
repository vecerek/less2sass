module Less2Sass
  module Less
    module Tree
      class ConditionNode < Node
        attr_accessor :op
        attr_accessor :lvalue
        attr_accessor :rvalue
        attr_accessor :index
        attr_accessor :negate
      end
    end
  end
end
