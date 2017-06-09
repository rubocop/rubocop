# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator do
  subject(:generator) { described_class.new('Style/FakeCop') }

  before do
    allow(File).to receive(:write)
  end

  it 'generates a helpful source file with the name filled in' do
    generated_source = <<-RUBY.strip_indent
      # frozen_string_literal: true

      # TODO: when finished, run `rake generate_cops_documentation` to update the docs
      module RuboCop
        module Cop
          module Style
            # TODO: Write cop description and example of bad / good code.
            #
            # @example
            #   # bad
            #   bad_method()
            #
            #   # bad
            #   bad_method(args)
            #
            #   # good
            #   good_method()
            #
            #   # good
            #   good_method(args)
            class FakeCop < Cop
              # TODO: Implement the cop into here.
              #
              # In many cases, you can use a node matcher for matching node pattern.
              # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
              #
              # For example
              MSG = 'Message of FakeCop'.freeze

              def_node_matcher :bad_method?, <<-PATTERN
                (send nil :bad_method ...)
              PATTERN

              def on_send(node)
                return unless bad_method?(node)
                add_offense(node)
              end
            end
          end
        end
      end
    RUBY

    generator.write_source

    expect(File)
      .to have_received(:write)
      .with('lib/rubocop/cop/style/fake_cop.rb', generated_source)
  end

  it 'generates a helpful starting spec file with the class filled in' do
    generated_source = <<-SPEC.strip_indent
      # frozen_string_literal: true

      describe RuboCop::Cop::Style::FakeCop do
        let(:config) { RuboCop::Config.new }
        subject(:cop) { described_class.new(config) }

        # TODO: Write test code
        #
        # For example
        it 'registers an offense when using `#bad_method`' do
          expect_offense(<<-RUBY.strip_indent)
            bad_method
            ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
          RUBY
        end

        it 'does not register an offense when using `#good_method`' do
          expect_no_offenses(<<-RUBY.strip_indent)
            good_method
          RUBY
        end
      end
    SPEC

    generator.write_spec

    expect(File)
      .to have_received(:write)
      .with('spec/rubocop/cop/style/fake_cop_spec.rb', generated_source)
  end

  it 'provides a checklist for implementing the cop' do
    expect(generator.todo).to eql(<<-TODO.strip_indent)
      created
      - lib/rubocop/cop/style/fake_cop.rb
      - spec/rubocop/cop/style/fake_cop_spec.rb

      Do 4 steps
      - Add an entry to `New feature` section in CHANGELOG.md
        - e.g. Add new `FakeCop` cop. ([@your_id][])
      - Add `require 'rubocop/cop/style/fake_cop'` into lib/rubocop.rb
      - Add an entry into config/enabled.yml or config/disabled.yml
      - Implement a new cop to the generated file!
    TODO
  end

  it 'does not accept an unqualified cop' do
    expect { described_class.new('FakeCop') }
      .to raise_error(ArgumentError)
      .with_message('Specify a cop name with Department/Name style')
  end

  it 'refuses to overwrite existing files' do
    new_cop = described_class.new('Layout/Tab')

    aggregate_failures('Overwrite checks') do
      expect { new_cop.write_source }
        .to raise_error('lib/rubocop/cop/layout/tab.rb already exists!')

      expect { new_cop.write_spec }
        .to raise_error('spec/rubocop/cop/layout/tab_spec.rb already exists!')
    end
  end
end
