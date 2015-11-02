module Less2Sass
  class Less2SassError < StandardError; end

  class ArgumentUnspecifiedError < ArgumentError
    def initialize(arg)
      @arg = arg
    end

    def message
      "Argument Error: #{@arg} can't be left unspecified. Choose sass or scss."
    end
  end

  class InvalidArgumentError < ArgumentError
    def initialize(arg, val)
      @arg = arg
      @val = val
    end

    def message
      "#{@val} is not a valid value for #{arg}"
    end
  end

  class JSLessParserError < Less2SassError
    def initialize(err)
      @err = err
    end

    def message
      "\n#{yield} #{@err['filename']}: #{@err['message']} on line #{@err['line']}, index #{@err['index']}. " +
        (@err['callLine'].nil? ? '' : "Called from line #{@err['callLine']}")
    end
  end

  class LessSyntaxError < JSLessParserError
    def message
      super { 'Syntax error found in' }
    end
  end

  class LessImportNotFoundError < JSLessParserError
    def message
      super { 'The specified import file has not been found in' }
    end
  end

  class LessASTParserError < Less2SassError
    def initialize(klass)
      @klass = klass
    end

    def message
      "Unexpected class type #{@klass} during Less' AST JSON parsing."
    end
  end

  class LessCompilationError < Less2SassError
    def message
      "\n" + super
    end
  end

  # Abstract error class for Less2Sass conversion errors
  class ConversionError < Less2SassError
    def initialize
      raise NotImplementedError
    end

    def message
      'Unsupported '
    end
  end

  class OperatorConversionError < ConversionError
    def initialize(operator)
      @op = operator
    end

    def message
      super + "operator #{@op}"
    end
  end

  class FeatureConversionError < ConversionError
    def initialize(obj)
      @klass = obj.class
    end

    def message
      super + "feature when converting #{@klass}"
    end
  end

  class UnknownError < Less2SassError
    def message
      "Something unexpected just happened.\n" + super
    end
  end
end
