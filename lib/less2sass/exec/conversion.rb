require 'less2sass/less'
require 'yaml'

module Less2Sass
  module Exec
    # TODO: rethink the concept, rather use 2 classes - Less2Sass and SassToLess instead of one (Conversion)
    class Conversion < Base
      attr_reader :conversion

      def initialize(args, conversion)
        super(args)
        @options[:target_syntax] = :scss
        @conversion = conversion
      end

      # Tells optparse how to parse the arguments.
      #
      # @param opts [OptionParser]
      def set_opts(opts)
        opts.banner = <<END
Usage: #{conversion} [options] [INPUT] [OUTPUT]

Description:
#{get_banner_desc}
END

        common_options(opts)
        input_and_output(opts)
        miscellaneous(opts)
      end

      private

      def get_banner_desc
        'Converts ' + (conversion == :less2sass ?
            'Less project to Sass' : 'Sass project to Less')
      end

      def common_options(opts)
        opts.on('-?', '-h', '--help', 'Show this help message.') do
          puts opts
          exit
        end

        opts.on('-v', '--version', 'Print the Sass version.') do
          puts("Less2Sass #{Less2Sass.version[:string]}")
          exit
        end
      end

      def input_and_output(opts)
        opts.separator ''
        opts.separator 'Input and Output:'

        if conversion == :less2sass
          opts.on(:OPTIONAL, '--target-syntax SYNTAX',
                  'Which Sass syntax should the Less project be converted to.',
                  '  - scss (default):  Use the CSS-superset SCSS syntax.',
                  '  - sass:            Use the indented Sass syntax.'
                 ) do |syntax|
            if syntax.nil?
              raise ArgumentUnspecifiedError, '--target-syntax'
            elsif syntax && !%w(scss sass).include?(syntax)
              raise InvalidArgumentError, '--target-syntax', syntax
            end
            @options[:target_syntax] = (syntax || :scss).to_sym
          end
        end

        opts.on('-s', '--stdin', :NONE,
                'Read input from standard input instead of an input file.',
                'This is the default if no input file is specified.') do
          @options[:input] = $stdin
        end
      end

      def miscellaneous(opts)
        opts.on('--trace', :NONE, 'Show a full Ruby stack trace on error.') do
          @options[:trace] = true
        end

        opts.on('-q', '--quiet', 'Silence warnings and status messages during conversion.') do
          @options[:for_engine][:quiet] = true
        end
      end

      # Runs the appropriate conversion (parse, transform, code gen)
      def run
        if conversion == :less2sass
          sass = Less2Sass::Less::ASTHandler.new(@options[:input], @options[:target_syntax])
                                            .transform_tree
                                            .to_sass

          sass.code_gen(@options[:output])
        elsif conversion == :sass2less
          # TODO: Implement Sass to Less conversion
          # Raise some error but this line should never be reached
        end
      end
    end
  end
end
