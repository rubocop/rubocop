# frozen_string_literal: true

describe RuboCop::Cop::Rails::Delegate do
  subject(:cop) { described_class.new }

  it 'finds trivial delegate' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
      ^^^ Use `delegate` to define delegations.
        bar.foo
      end
    RUBY
  end

  it 'finds trivial delegate with arguments' do
    expect_offense(<<-RUBY.strip_indent)
      def foo(baz)
      ^^^ Use `delegate` to define delegations.
        bar.foo(baz)
      end
    RUBY
  end

  it 'finds trivial delegate with prefix' do
    expect_offense(<<-RUBY.strip_indent)
      def bar_foo
      ^^^ Use `delegate` to define delegations.
        bar.foo
      end
    RUBY
  end

  it 'ignores class methods' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.fox
        new.fox
      end
    RUBY
  end

  it 'ignores non trivial delegate' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def fox
        bar.foo.fox
      end
    RUBY
  end

  it 'ignores trivial delegate with mismatched arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def fox(baz)
        bar.fox(foo)
      end
    RUBY
  end

  it 'ignores trivial delegate with optional argument with a default value' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def fox(foo = nil)
        bar.fox(foo || 5)
      end
    RUBY
  end

  it 'ignores trivial delegate with mismatched number of arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def fox(a, baz)
        bar.fox(a)
      end
    RUBY
  end

  it 'ignores trivial delegate with other prefix' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def fox_foo
        bar.foo
      end
    RUBY
  end

  it 'ignores methods with arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def fox(bar)
        bar.fox
      end
    RUBY
  end

  it 'ignores private delegations' do
    expect_no_offenses(<<-RUBY.strip_indent)
        private def fox # leading spaces are on purpose
          bar.fox
        end

          private

        def fox
          bar.fox
        end
    RUBY
  end

  it 'ignores protected delegations' do
    expect_no_offenses(<<-RUBY.strip_indent)
        protected def fox # leading spaces are on purpose
          bar.fox
        end

        protected

        def fox
          bar.fox
        end
    RUBY
  end

  it 'ignores delegation with assignment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def new
        @bar = Foo.new
      end
    RUBY
  end

  it 'ignores delegation to constant' do
    expect_no_offenses(<<-RUBY.strip_indent)
      FOO = []
      def size
        FOO.size
      end
    RUBY
  end

  describe '#autocorrect' do
    context 'trivial delegation' do
      let(:source) do
        <<-RUBY.strip_indent
          def bar
            foo.bar
          end
        RUBY
      end

      let(:corrected_source) do
        <<-RUBY.strip_indent
          delegate :bar, to: :foo
        RUBY
      end

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end

    context 'trivial delegation with prefix' do
      let(:source) do
        <<-RUBY.strip_indent
          def foo_bar
            foo.bar
          end
        RUBY
      end

      let(:corrected_source) do
        <<-RUBY.strip_indent
          delegate :bar, to: :foo, prefix: true
        RUBY
      end

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end
  end
end
