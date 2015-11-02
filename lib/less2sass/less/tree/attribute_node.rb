module Less2Sass
  module Less
    module Tree
      class AttributeNode < Node
        attr_accessor :key
        attr_accessor :op
        attr_accessor :value
      end
    end
  end
end
