# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'parser/current'

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  def to_snake(str)
    str
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  def prefix_lines_with(string, prefix)
    string.gsub(/^/, prefix)
  end

  def indent(string, spaces)
    prefix_lines_with(string, ' ' * spaces)
  end

  cop_name = args[:cop] # Department/Name
  raise ArgumentError, 'One argument is required' unless cop_name

  badge = RuboCop::Cop::Badge.parse(cop_name)

  unless badge.qualified?
    raise ArgumentError, 'Specify a cop name with Department/Name style'
  end

  puts <<-END.strip_indent
    Provide an example of code that you would like RuboCop to register an offense for.
    For example, if you wanted to enforce using fail instead of raise:

        raise
        ^^^^^ Use `fail` instead of `raise` to signal exceptions.

    Hit CTRL-d when you are done:

  END

  example = $stdin.read.chomp

  indented_example = indent(example, 10)
  annotated        =
    RuboCop::RSpec::ExpectOffense::AnnotatedSource.parse(example)
  plain_source     = indent(annotated.plain_source, 3).chomp
  comment_example  = indent(prefix_lines_with(plain_source, '#'), 10)
  node_pattern     = indent(Parser::CurrentRuby.parse(plain_source).to_s, 14)

  cop_code = <<-END.strip_indent
    # frozen_string_literal: true

    # TODO: when finished, run `rake generate_cops_documentation` to update the docs
    module RuboCop
      module Cop
        module #{badge.department}
          # TODO: Write cop description and example of bad / good code.
          #
          # @example
          #   # bad
#{comment_example}
          #
          #   # good
          #   good_method()
          #
          #   # good
          #   good_method(args)
          class #{badge.cop_name} < Cop
            # TODO: Implement the cop into here.
            #
            # In many cases, you can use a node matcher for matching node pattern.
            # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
            #
            # For example
            MSG = 'Message of #{badge.cop_name}'.freeze

            def_node_matcher :bad_method?, <<-PATTERN
#{node_pattern}
            PATTERN

            def on_send(node)
              return unless bad_method?(node)
              add_offense(node, :expression)
            end
          end
        end
      end
    end
  END

  cop_path = "lib/rubocop/cop/#{to_snake(badge.to_s)}.rb"
  raise "#{cop_path} already exists!" if File.exist?(cop_path)
  File.write(cop_path, cop_code)

  spec_code = <<-END.strip_indent
    # frozen_string_literal: true

    describe RuboCop::Cop::#{badge.department}::#{badge.cop_name} do
      let(:config) { RuboCop::Config.new }
      subject(:cop) { described_class.new(config) }

      # TODO: Write test code
      #
      # For example
      it 'registers an offense for offending code' do
        expect_offense(<<-RUBY.strip_indent)
#{indented_example}
        RUBY
      end

      it 'accepts' do
        inspect_source(cop, 'good_method')
        expect(cop.offenses).to be_empty
      end
    end
  END

  spec_path = "spec/rubocop/cop/#{to_snake(cop_name)}_spec.rb"
  raise "#{spec_path} already exists!" if File.exist?(spec_path)
  File.write(spec_path, spec_code)

  puts <<-END.strip_indent
    created
    - #{cop_path}
    - #{spec_path}

    Do 4 steps
    - Add an entry to `New feature` section in CHANGELOG.md
      - e.g. Add new `#{badge.cop_name}` cop. ([@your_id][])
    - Add `require '#{cop_path.gsub(/\.rb$/, '').gsub(%r{^lib/}, '')}'` into lib/rubocop.rb
    - Add an entry into config/enabled.yml or config/disabled.yml
    - Implement a new cop to the generated file!
  END
end
