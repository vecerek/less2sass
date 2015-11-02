module Less2Sass
  module Less
    module Tree
      class AssignmentNode < Node
        attr_accessor :key
        attr_accessor :value
      end
    end
  end
end
