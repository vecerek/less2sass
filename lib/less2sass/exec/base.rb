require 'optparse'

module Less2Sass
  module Exec
    # The abstract base class for Less2Sass executables.
    class Base
      # @param args [Array<String>] command-line arguments
      def initialize(args)
        @args = args
        @options = {}
      end

      # Parses the command-line arguments and runs the executable.
      # Calls `Kernel#exit` at the end, so it never returns.
      #
      # @see #parse
      def parse!
        begin
          parse
        rescue Exception => e
          raise e if @options[:trace] || e.is_a?(SystemExit)
          $stderr.puts "#{e.class}: " + e.message.to_s
          exit 1
        end
        exit 0
      end

      # Parses the command-line arguments and runs the executable.
      def parse
        # @opts = OptionParser.new(&method(:set_opts))
        OptionParser.new do |opts|
          set_opts(opts)
        end.parse!(@args)

        process_args

        @options
      end

      protected

      # Tells optparse how to parse the arguments
      # available for all executables.
      #
      # The method is being overridden by subclasses
      # to add their own options.
      #
      # @param opts [OptionParser]
      def set_opts(_opts = nil)
        raise NotImplementedError.new("#{obj.class} must implement ##{caller_info[2]}")
      end

      def open_file(filename, flag = 'r')
        return if filename.nil?
        File.open(filename, flag)
      end

      # Processes the options set by the command-line arguments -
      # `@options[:input]` and `@options[:output]` are being set
      # to appropriate IO streams.
      #
      # This method is being overridden by subclasses
      # to run their respective programs.
      def process_args
        input = @options[:input]
        output = @options[:output]
        args = @args.dup
        input ||=
          begin
            filename = args.shift
            @options[:input_filename] = filename
            open_file(filename) || $stdin
          end
        @options[:output_filename] = args.shift
        output ||= @options[:output_filename] || $stdout
        @options[:input] = input
        @options[:output] = output

        run
      end
    end
  end
end
