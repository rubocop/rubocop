# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantLocationArgument do
  subject(:cop) { described_class.new }

  context 'when location argument is passed' do
    context 'when location argument is :expression' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent, 'example_cop.rb')
          add_offense(node, location: :expression)
                            ^^^^^^^^^^^^^^^^^^^^^ Redundant location argument to `#add_offense`.
        RUBY
      end

      context 'when there is a message argument' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent, 'example_cop.rb')
            add_offense(node, location: :expression, message: 'message')
                              ^^^^^^^^^^^^^^^^^^^^^ Redundant location argument to `#add_offense`.
          RUBY
        end
      end

      it 'removes default `location` when there are no other keywords' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          add_offense(node, location: :expression)
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          add_offense(node)
        RUBY
      end

      it 'removes default `location` when preceded by another keyword' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          add_offense(node, message: 'foo', location: :expression)
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          add_offense(node, message: 'foo')
        RUBY
      end

      it 'removes default `location` when followed by another keyword' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          add_offense(node, location: :expression, message: 'foo')
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          add_offense(node, message: 'foo')
        RUBY
      end

      it 'removes default `location` surrounded by other keywords' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          add_offense(
            node,
            severity: :error,
            location: :expression,
            message: 'message'
          )
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          add_offense(
            node,
            severity: :error,
            message: 'message'
          )
        RUBY
      end
    end

    context 'when location argument does not equal to :expression' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent, 'example_cop.rb')
          add_offense(node, location: :selector)
        RUBY
      end
    end
  end

  context 'when location argument is not passed' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent, 'example_cop.rb')
        add_offense(node)
      RUBY
    end
  end
end
