module Less2Sass
  module Less
    module Tree
      class UnitNode < Node
        attr_accessor :numerator
        attr_accessor :denominator
        attr_accessor :backupUnit

        def to_s
          val = @numerator[0].to_s
          val += @denominator[0] unless @denominator.nil? || @denominator.empty?
          val
        end
      end
    end
  end
end
