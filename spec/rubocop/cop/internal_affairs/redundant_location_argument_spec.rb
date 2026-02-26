# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantLocationArgument, :config do
  context 'when location argument is passed' do
    context 'when location argument is :expression' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'example_cop.rb')
          add_offense(node, location: :expression)
                            ^^^^^^^^^^^^^^^^^^^^^ Redundant location argument to `#add_offense`.
        RUBY

        expect_correction(<<~RUBY)
          add_offense(node)
        RUBY
      end

      context 'when there is a message argument' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, 'example_cop.rb')
            add_offense(node, location: :expression, message: 'message')
                              ^^^^^^^^^^^^^^^^^^^^^ Redundant location argument to `#add_offense`.
          RUBY

          expect_correction(<<~RUBY)
            add_offense(node, message: 'message')
          RUBY
        end
      end

      it 'removes default `location` when preceded by another keyword' do
        expect_offense(<<~RUBY)
          add_offense(node, message: 'foo', location: :expression)
                                            ^^^^^^^^^^^^^^^^^^^^^ Redundant location argument to `#add_offense`.
        RUBY

        expect_correction(<<~RUBY)
          add_offense(node, message: 'foo')
        RUBY
      end

      it 'removes default `location` surrounded by other keywords' do
        expect_offense(<<~RUBY)
          add_offense(
            node,
            severity: :error,
            location: :expression,
            ^^^^^^^^^^^^^^^^^^^^^ Redundant location argument to `#add_offense`.
            message: 'message'
          )
        RUBY

        expect_correction(<<~RUBY)
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
        expect_no_offenses(<<~RUBY, 'example_cop.rb')
          add_offense(node, location: :selector)
        RUBY
      end
    end
  end

  context 'when location argument is not passed' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'example_cop.rb')
        add_offense(node)
      RUBY
    end
  end
end
