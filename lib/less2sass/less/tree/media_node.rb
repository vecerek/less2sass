module Less2Sass
  module Less
    module Tree
      class MediaNode < Node
        attr_accessor :index
        attr_accessor :currentFileInfo
        attr_accessor :features
        attr_accessor :rules

        def transform(parent_env)
          env = env(parent_env, @rules.rules)
          optimize_rules(env.get_ordered_child_nodes)
          super(env)
          @query = eval_features
          self
        end

        def to_sass
          query = []
          @query.each do |x|
            item = x.to_sass
            if item.is_a?(Array)
              query += item.flatten
            else
              query << item
            end
            query << ', ' unless @query.last === x
          end
          node = node(::Sass::Tree::MediaNode.new(query), line(:new))
          @rules.each { |c| node << c.to_sass }
          node
        end

        private

        def cleaned_features
          @features.value.kind_of?(Array) ? @features.value : [@features.value]
        end

        def eval_features
          cleaned_features.collect do |node|
            node.eval if node.evaluable?
          end
        end

        def optimize_rules(rules)
          index = @children.index(@rules)
          @children.delete_at(index)
          rules.reverse.each { |x| @children.insert(index, x) }
          @rules = rules
        end
      end
    end
  end
end
