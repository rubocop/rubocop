# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::RedundantLocationArgument do
  subject(:cop) { described_class.new }

  context 'when location argument is passed' do
    context 'when location argument is :expression' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'example_cop.rb')
          add_offense(node, :expression)
                            ^^^^^^^^^^^ Redundant location argument to `#add_offense`.
        RUBY
      end

      it 'auto-corrects an offense' do
        new_source = autocorrect_source('add_offense(node, :expression)')

        expect(new_source).to eq('add_offense(node)')
      end

      context 'when there is a message argument' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY, 'example_cop.rb')
            add_offense(node, :expression, "message")
          RUBY
        end
      end
    end

    context 'when location argument does not equal to :expression' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY, 'example_cop.rb')
          add_offense(node, :selector)
        RUBY
      end
    end
  end

  context 'when location argument is not passed' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY, 'example_cop.rb')
        add_offense(node)
      RUBY
    end
  end
end
