module Less2Sass
  module Less
    module Tree
      class MixinCallNode < Node
        attr_accessor :selector
        attr_accessor :arguments
        attr_accessor :index
        attr_accessor :currentFileInfo
        attr_accessor :important
      end
    end
  end
end
