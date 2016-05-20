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
          @query = @features.value
          #@query = [@query] unless @query.is_a?(Array)
          perform_query
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
            query << ', '
          end
          node = node(::Sass::Tree::MediaNode.new(query), line(:new))
          @rules.each { |c| node << c.to_sass }
          node
        end

        private

        def perform_query
          query = @query.collect do |x|
            to_eval = x.is_a?(ValueNode) && x.contains_variables?
            to_eval ? x.eval : x
          end
          @query = query[0..-2]
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
