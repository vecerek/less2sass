# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubygems'
require 'less2sass/constants'

LESS2SASS_GEMSPEC = Gem::Specification.new do |spec|
  spec.name = 'less_to_sass'
  spec.summary = 'An easy to use AST-based Less to Sass converter.'
  spec.version = Less2Sass::VERSION
  spec.authors = ['Attila Večerek']
  spec.email = 'xvecer17@stud.fit.vutbr.cz'
  spec.description = <<-END
      Less2Sass is an easy to use converter between Less and
      Sass, respectively SCSS, dynamic stylesheet formats.
      It is based on abstract syntax tree transformation
      instead of the common string replacement methods
      using regular expressions. It does not support a lot
      of language features, yet. However, when finished,
      it will offer the developers an easy way to convert
      between these formats without the following manual
      conversion as it is today.
  END

  spec.required_ruby_version = '>= 2.0.0'

  readmes = Dir['*'].reject { |x| x =~ /(^|[^.a-z])[a-z]+/ || x == 'TODO' }
  spec.executables = %w(less2sass)
  spec.files = Dir['lib/**/*', 'bin/*'] + readmes
  spec.homepage = 'https://github.com/vecerek/less2sass/'
  spec.has_rdoc = false
  spec.test_files = Dir['spec/lib/**/*_spec.rb']
  spec.license = 'MIT'

  spec.add_dependency 'sass', '~> 3.4'

  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'css_compare', '~> 0.2'
end
