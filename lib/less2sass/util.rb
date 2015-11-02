module Less2Sass
  module Util
    extend self

    # Returns a file's path relative to the Less2Sass root directory.
    #
    # @param file [String] The filename relative to the Less2Sass root
    # @return [String] The filename relative to the the working directory
    def scope(file)
      File.join(Less2Sass::ROOT_DIR, file)
    end

    # Formats a multiline console input, so it can be passed as an argument
    # to a console application.
    #
    # @return [String] properly formatted multiline argument
    def read_stdin_as_multiline_arg
      str = ''
      puts 'Write your code below, so it can be converted for you.'
      while line = gets
        line["\n"] = "\\\n"
        str << line
      end
      str
    end

    # Formats class names properly.
    #
    # @return [String] formatted class name
    # @example formats dashed class name
    #   "anonymous_node".classify #=> "AnonymousNode"
    def classify(str)
      str.split('_').collect!(&:capitalize).join
    end
  end
end
