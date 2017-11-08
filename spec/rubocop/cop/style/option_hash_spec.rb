# frozen_string_literal: true

describe RuboCop::Cop::Style::OptionHash, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'SuspiciousParamNames' => suspicious_names } }
  let(:suspicious_names) { ['options'] }

  it 'registers an offense' do
    expect_offense(<<-RUBY.strip_indent)
      def some_method(options = {})
                      ^^^^^^^^^^^^ Prefer keyword arguments to options hashes.
        puts some_arg
      end
    RUBY
  end

  context 'when the last argument is an options hash named something else' do
    let(:source) do
      <<-RUBY.strip_indent
        def steep(flavor, duration, config={})
          mug = config.fetch(:mug)
          prep(flavor, duration, mug)
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def steep(flavor, duration, config={})
          mug = config.fetch(:mug)
          prep(flavor, duration, mug)
        end
      RUBY
    end

    context 'when the argument name is in the list of suspicious names' do
      let(:suspicious_names) { %w[options config] }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          def steep(flavor, duration, config={})
                                      ^^^^^^^^^ Prefer keyword arguments to options hashes.
            mug = config.fetch(:mug)
            prep(flavor, duration, mug)
          end
        RUBY
      end
    end
  end

  context 'when there are no arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def meditate
          puts true
          puts true
        end
      RUBY
    end
  end

  context 'when the last argument is a non-options-hash optional hash' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def cook(instructions, ingredients = { hot: [], cold: [] })
          prep(ingredients)
        end
      RUBY
    end
  end
end
