# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousOperator do
  subject(:cop) { described_class.new }

  context 'with a splat operator in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        let(:source) do
          <<-RUBY.strip_indent
            array = [1, 2, 3]
            puts *array
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Ambiguous splat operator. ' \
            "Parenthesize the method arguments if it's surely a splat " \
            'operator, ' \
            'or add a whitespace to the right of the `*` if it should be a ' \
            'multiplication.'
          )
          expect(cop.highlights).to eq(['*'])
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'accepts' do
          expect_no_offenses(<<-RUBY.strip_indent)
            array = [1, 2, 3]
            puts * array
          RUBY
        end
      end
    end

    context 'with parentheses' do
      it 'accepts' do
        expect_no_offenses(<<-RUBY.strip_indent)
          array = [1, 2, 3]
          puts(*array)
        RUBY
      end
    end
  end

  context 'with a block ampersand in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        let(:source) do
          <<-RUBY.strip_indent
            process = proc { do_something }
            2.times &process
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Ambiguous block operator. ' \
            "Parenthesize the method arguments if it's surely a block " \
            'operator, ' \
            'or add a whitespace to the right of the `&` if it should be a ' \
            'binary AND.'
          )
          expect(cop.highlights).to eq(['&'])
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'accepts' do
          expect_no_offenses(<<-RUBY.strip_indent)
            process = proc { do_something }
            2.times & process
          RUBY
        end
      end
    end

    context 'with parentheses' do
      it 'accepts' do
        expect_no_offenses(<<-RUBY.strip_indent)
          process = proc { do_something }
          2.times(&process)
        RUBY
      end
    end
  end
end
