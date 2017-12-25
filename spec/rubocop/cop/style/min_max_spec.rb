# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MinMax, :config do
  subject(:cop) { described_class.new(config) }

  context 'with an array literal containing calls to `#min` and `#max`' do
    context 'when the expression stands alone' do
      it 'registers an offense if the receivers match' do
        expect_offense(<<-RUBY.strip_indent)
          [foo.min, foo.max]
          ^^^^^^^^^^^^^^^^^^ Use `foo.minmax` instead of `[foo.min, foo.max]`.
        RUBY
      end

      it 'does not register an offense if the receivers do not match' do
        expect_no_offenses(<<-RUBY.strip_indent)
          [foo.min, bar.max]
        RUBY
      end

      it 'does not register an offense if there are additional elements' do
        expect_no_offenses(<<-RUBY.strip_indent)
          [foo.min, foo.baz, foo.max]
        RUBY
      end

      it 'does not register an offense if the receiver is implicit' do
        expect_no_offenses(<<-RUBY.strip_indent)
          [min, max]
        RUBY
      end

      it 'auto-corrects an offense to use `#minmax`' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          [foo.bar.min, foo.bar.max]
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          foo.bar.minmax
        RUBY
      end
    end

    context 'when the expression is used in a parallel assignment' do
      it 'registers an offense if the receivers match' do
        expect_offense(<<-RUBY.strip_indent)
          bar = foo.min, foo.max
                ^^^^^^^^^^^^^^^^ Use `foo.minmax` instead of `foo.min, foo.max`.
        RUBY
      end

      it 'does not register an offense if the receivers do not match' do
        expect_no_offenses(<<-RUBY.strip_indent)
          baz = foo.min, bar.max
        RUBY
      end

      it 'does not register an offense if there are additional elements' do
        expect_no_offenses(<<-RUBY.strip_indent)
          bar = foo.min, foo.baz, foo.max
        RUBY
      end

      it 'does not register an offense if the receiver is implicit' do
        expect_no_offenses(<<-RUBY.strip_indent)
          bar = min, max
        RUBY
      end

      it 'auto-corrects an offense to use `#minmax`' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          baz = foo.bar.min, foo.bar.max
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          baz = foo.bar.minmax
        RUBY
      end
    end

    context 'when the expression is used as a return value' do
      it 'registers an offense if the receivers match' do
        expect_offense(<<-RUBY.strip_indent)
          return foo.min, foo.max
                 ^^^^^^^^^^^^^^^^ Use `foo.minmax` instead of `foo.min, foo.max`.
        RUBY
      end

      it 'does not register an offense if the receivers do not match' do
        expect_no_offenses(<<-RUBY.strip_indent)
          return foo.min, bar.max
        RUBY
      end

      it 'does not register an offense if there are additional elements' do
        expect_no_offenses(<<-RUBY.strip_indent)
          return foo.min, foo.baz, foo.max
        RUBY
      end

      it 'does not register an offense if the receiver is implicit' do
        expect_no_offenses(<<-RUBY.strip_indent)
          return min, max
        RUBY
      end

      it 'auto-corrects an offense to use `#minmax`' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          return foo.bar.min, foo.bar.max
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          return foo.bar.minmax
        RUBY
      end
    end
  end
end
