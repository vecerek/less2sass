require 'less2sass/less/tree'
require 'json'

module Less2Sass
  module Less
    # The parser for Less.
    # It parses a Less project into a tree of {Less2Sass::Less::Tree::Node}s.
    # The project is meant as one or more files.
    class Parser
      # @param [File, IO] input The source project to parse.
      def initialize(input)
        @input = input
        @options = input == $stdin ? "-stdin \"#{Util.read_stdin_as_multiline_arg}\"" : File.expand_path(input)
      end

      # Checks, whether the Less project can be compiled.
      #
      # @return [void]
      # @raise [Less2Sass::LessCompilationError] if the project can't be compiled.
      def check_syntax
        response = `lessc --lint #{File.expand_path(@input)} 2>&1 >/dev/null`
        raise LessCompilationError, response unless response.empty?
      end

      # Parses a Less project.
      #
      # @return [Less2Sass::Less::Tree::Node] The root node of the project tree
      # @raise [Less2Sass::LessSyntaxError] if there's a syntax error in the document
      # @raise [Less2Sass::LessImportNotFoundError] if any of the imports can't be found
      def parse
        string_ast = `node #{Util.scope(PARSER)} #{@options}`
        json_ast = JSON.parse(string_ast)
        if json_ast['class'] == 'error'
          raise LessImportNotFoundError, json_ast if json_ast['type'] == 'File'
          raise LessSyntaxError, json_ast if json_ast['type'] == 'Parse'
        end
        build_tree(json_ast)
      end

      # Converts the parsed Less project from JSON object
      # to a {Less2Sass::Less::Tree::Node} representation.
      #
      # Note, that this method recursively calls itself.
      #
      # @param [Hash] json the JSON object representing the Less AST
      # @param [Less2Sass::Less::Tree::Node] parent the respective parent node
      #   of the currently processed node.
      # @return [Less2Sass::Less::Tree::Node] The root node of the project tree
      # @raise [Less2Sass::LessASTParserError] if something unexpected happens.
      def build_tree(json, parent = nil)
        node = create_node(json['class'], parent)

        json.each do |k, v|
          key = instance_var_sym(k)

          if v.is_a?(Hash)
            # Is the hash a node, or a simple value?
            if node?(v)
              # The node should be referenced under the original key, as well as
              # in the child nodes, so it's easier to handle conversion
              # and still be able to traverse the full tree. Since these would be
              # the same objects, the changes made during the transformation
              # process would be reflected at both places.
              subnode = build_tree(v, node)
              node.instance_variable_set(key, subnode)
              node << subnode
            else
              node.instance_variable_set(key, v)
            end
          elsif v.is_a?(Array)
            if node?(v[0])
              # It's an array of nodes
              subnodes = []
              v.each do |item|
                # Something is very wrong if the item is not another node
                raise LessASTParserError, item.class.to_s unless node?(item)
                subnode = build_tree(item, node)
                subnodes << subnode
                node << subnode
              end
              value = subnodes.length == 1 ? subnodes[0] : subnodes
              node.instance_variable_set(key, value)
            else
              # It's a simple array containing other values than nodes
              node.instance_variable_set(key, v)
            end
          else
            # Simple key-value pair
            next if k == 'class'
            node.instance_variable_set(key, v)
          end
        end

        node
      end

      private

      PARSER = 'lib/less2sass/js/less_parser.js'.freeze

      # Creates the node in a Ruby object-like representation.
      #
      # @param [String] class_name the classname of the node to be created
      # @param [Less2Sass::Less::Tree::Node] parent the parent node of the one
      #   currently being created
      # @return [Less2Sass::Less::Tree::Node] an AST node
      def create_node(class_name, parent)
        Tree.const_get(class_name.to_s + 'Node')
            .new(parent)
      end

      # Creates a symbol as reference to a member object,
      # so it can be set dynamically.
      #
      # @param [String] key the string representation
      #   of an object's member
      # @return [Symbol] the symbolic reference to an object's member
      def instance_var_sym(key)
        "@#{key}".to_sym
      end

      def node?(json)
        json.is_a?(Hash) && json.key?('class')
      end

      def hash_value?(hash)
        !hash.key?('class')
      end
    end
  end
end
