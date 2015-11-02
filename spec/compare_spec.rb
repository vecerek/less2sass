require 'pathname'
require_relative '../lib/less2sass'
require 'css_compare'

RSpec.describe 'compare LESS with generated SASS' do
  CONTEXTS = Pathname.new('spec/fixtures/less')
  PENDING = %w(bootstrap mixins).freeze

  Dir.foreach(CONTEXTS) do |feature|
    next if %w(. ..).include?(feature)
    context "feature #{feature}" do
      Dir.foreach(CONTEXTS + feature) do |variant|
        next if %w(. ..).include?(variant)
        it "variant #{variant.sub('.less', '')}" do
          if PENDING.include?(feature) || PENDING.include?(variant)
            pending('Not yet implemented')
            raise StandardError, 'Not yet implemented'
          else
            less = CONTEXTS + feature + variant
            less_css = `lessc #{less.realpath}`
            sass_css = Less2Sass::Less::ASTHandler.new(less.realpath, :scss)
                                                  .transform_tree
                                                  .to_sass
                                                  .to_css
            # puts less_css
            # puts sass_css
            opts = {
              :operands => [parse_css(less_css, less), parse_css(sass_css, less)]
            }
            equality = CssCompare::Engine.new(opts)
                                         .parse!
                                         .equal?

            expect(equality).to be true
          end
        end
      end
    end
  end
end

def parse_css(css, filename)
  tree = ::Sass::Engine.new(
    css, :syntax => :scss, :filename => filename
  ).to_tree
  ::Sass::Tree::Visitors::CheckNesting.visit(tree)
  ::Sass::Tree::Visitors::Perform.visit(tree)
end
