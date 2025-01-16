# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::SingleLineComplexity, :config do
  let(:cop_config) { { 'Max' => 2 } }

  context 'single line code' do
    it 'registers an offense when ABC per line > 2' do
      expect_offense(<<~RUBY)
        a ? b : c
        ^^^^^^^^^ Assignment Branch Condition size too high for line 1. [<0.0, 3.0, 1.0> 3.16/2]
      RUBY
    end
  end

  context 'multi line code' do
    it 'registers two offenses when 2 of 4 lines have ABC > 2' do
      expect_offense(<<~RUBY)
        a ? b : c
        ^^^^^^^^^ Assignment Branch Condition size too high for line 1. [<0.0, 3.0, 1.0> 3.16/2]
        x = 1
        c ? d : e
        ^^^^^^^^^ Assignment Branch Condition size too high for line 3. [<0.0, 3.0, 1.0> 3.16/2]
        y = 2
      RUBY
    end

    it 'accepts all lines when ABC per line always <= 2' do
      expect_no_offenses(<<~RUBY)
        x = 1 + 1
        y = 2
      RUBY
    end
  end

  context 'inline statements' do
    it 'rejects an offense when ABC > 2' do
      expect_offense(<<~RUBY)
        x = 1; y = 2; z = 3;
        ^^^^^^^^^^^^^^^^^^^ Assignment Branch Condition size too high for line 1. [<3.0, 0.0, 0.0> 3/2]
      RUBY
    end

    it 'accepts when ABC == 2' do
      expect_no_offenses(<<~RUBY)
        x = 1; y = 2;
      RUBY
    end
  end
end
