module Less2Sass
  module Less
    module Tree
      class MixinDefinitionNode < Node
        attr_accessor :name
        attr_accessor :selectors
        attr_accessor :params
        attr_accessor :condition
        attr_accessor :variadic
        attr_accessor :arity
        attr_accessor :rules
        attr_accessor :_lookups
        attr_accessor :required
        attr_accessor :optionalParameters
        attr_accessor :frames

        # @see Node#creates_environment?
        def creates_environment?
          true
        end
      end
    end
  end
end
