module Less2Sass
  module Less
    module Tree
      class MediaNode < Node
        attr_accessor :index
        attr_accessor :currentFileInfo
        attr_accessor :features
        attr_accessor :rules
      end
    end
  end
end
