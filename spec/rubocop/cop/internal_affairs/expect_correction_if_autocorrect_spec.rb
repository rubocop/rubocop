# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::ExpectCorrectionIfAutocorrect, :config do
  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundBlockBody, :config do
        it 'registers an offense for block body starting with a blank' do
          expect_offense('')
          ^^^^^^^^^^^^^^^^^^ `expect_offense` must be followed by `expect_no_corrections` or `expect_correction`.
        end
      end
    RUBY
  end

  it 'registers no offense' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundBlockBody, :config do
        it 'registers an offense for block body starting with a blank' do
          expect_offense('')

          expect_correction('')
        end
      end
    RUBY
  end
end
