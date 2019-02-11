# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MemorizationWithParameters do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }
  let(:error_message) do
    'Use an instance variable such as a Hash to store method returns called ' \
    'with parameter(s).'
  end

  before do
    inspect_source(source)
  end

  context 'with a valid assignment' do
    subject(:source) do
      <<-RUBY.strip_indent
        def foo(bar)
          @foo ||= {}
          @foo[bar] ||= baz(bar)
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(0) }
  end

  context 'when the assignment isn\'t used' do
    subject(:source) do
      <<-RUBY.strip_indent
        def foo(bar)
          @foo ||= baz
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(0) }
  end

  context 'with a simple assignment' do
    subject(:source) do
      <<-RUBY.strip_indent
        def foo(bar)
          @foo ||= baz(bar)
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(1) }
    it { expect(cop.offenses.first.message).to eq error_message }
  end

  context 'with multiple parameters' do
    subject(:source) do
      <<-RUBY.strip_indent
        def foo(bar, qux)
          @foo ||= baz(bar, qux)
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(1) }
    it { expect(cop.offenses.first.message).to eq error_message }
  end

  context 'with a named parameter' do
    subject(:source) do
      <<-RUBY.strip_indent
        def foo(bar:)
          @foo ||= baz(bar)
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(1) }
    it { expect(cop.offenses.first.message).to eq error_message }
  end

  context 'with a string interpolation' do
    subject(:source) do
      <<-'RUBY'.strip_indent
        def foo(bar)
          @foo ||= "Test #{bar}"
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(1) }
    it { expect(cop.offenses.first.message).to eq error_message }
  end

  context 'with a begin/end block' do
    subject(:source) do
      <<-RUBY.strip_indent
        def foo(bar)
          @foo ||= begin
            bar
          end
        end
      RUBY
    end

    it { expect(cop.offenses.size).to eq(1) }
    it { expect(cop.offenses.first.message).to eq error_message }
  end
end
