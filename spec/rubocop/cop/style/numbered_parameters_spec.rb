# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NumberedParameters, :config do
  context '>= Ruby 2.7', :ruby27 do
    context 'EnforcedStyle: allow_single_line' do
      let(:cop_config) { { 'EnforcedStyle' => 'allow_single_line' } }

      it 'registers an offense when using numbered parameters with multi-line blocks' do
        expect_offense(<<~RUBY)
          collection.each do
          ^^^^^^^^^^^^^^^^^^ Avoid using numbered parameters for multi-line blocks.
            puts _1
          end
        RUBY
      end

      it 'does not register an offense when using numbered parameters with single-line blocks' do
        expect_no_offenses(<<~RUBY)
          collection.each { puts _1 }
        RUBY
      end
    end

    context 'EnforcedStyle: disallow' do
      let(:cop_config) { { 'EnforcedStyle' => 'disallow' } }

      it 'does an offense when using numbered parameters even with single-line blocks' do
        expect_offense(<<~RUBY)
          collection.each { puts _1 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using numbered parameters.
        RUBY
      end
    end
  end
end
