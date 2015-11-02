module Less2Sass
  module Less
    module Tree
      class ExtendNode < Node
        attr_accessor :selector
        attr_accessor :option
        attr_accessor :index
        attr_accessor :object_id
        attr_accessor :parent_ids
        attr_accessor :currentFileInfo
      end
    end
  end
end
