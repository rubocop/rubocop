# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantSourceRange, :config do
  it 'registers an offense when using `node.source_range.source`' do
    expect_offense(<<~RUBY)
      node.source_range.source
           ^^^^^^^^^^^^ Remove the redundant `source_range`.
    RUBY

    expect_correction(<<~RUBY)
      node.source
    RUBY
  end

  it 'does not register an offense when using `node.source`' do
    expect_no_offenses(<<~RUBY)
      node.source
    RUBY
  end
end
