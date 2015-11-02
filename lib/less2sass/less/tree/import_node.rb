module Less2Sass
  module Less
    module Tree
      class ImportNode < Node
        attr_accessor :options
        attr_accessor :index
        attr_accessor :path
        attr_accessor :features
        attr_accessor :currentFileInfo
        attr_accessor :css
      end
    end
  end
end
