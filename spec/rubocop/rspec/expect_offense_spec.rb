# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::ExpectOffense, :config do
  context 'with a cop that loops during autocorrection' do
    let(:cop_class) { RuboCop::Cop::Test::InfiniteLoopDuringAutocorrectCop }

    it '`expect_no_corrections` raises' do
      expect_offense(<<~RUBY)
        class Test
        ^^^^^^^^^^ Class must be a Module
        end
      RUBY

      expect { expect_no_corrections }.to raise_error(RuboCop::Runner::InfiniteCorrectionLoop)
    end
  end

  context 'with a cop that loops after autocorrecting something' do
    let(:cop_class) { RuboCop::Cop::Test::InfiniteLoopDuringAutocorrectWithChangeCop }

    it '`expect_correction` raises' do
      expect_offense(<<~RUBY)
        class Test
        ^^^^^^^^^^ Class must be a Module
        end
      RUBY

      expect do
        expect_correction(<<~RUBY)
          module Test
          end
        RUBY
      end.to raise_error(RuboCop::Runner::InfiniteCorrectionLoop)
    end
  end
end
