module Less2Sass
  module Less
    module Tree
      class DetachedRulesetNode < Node
        attr_accessor :ruleset
        attr_accessor :frames
      end
    end
  end
end
