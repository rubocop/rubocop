# frozen_string_literal: true

describe RuboCop::Cop::Style::ArrayJoin do
  subject(:cop) { described_class.new }

  it 'registers an offense for an array followed by string' do
    expect_offense(<<-RUBY.strip_indent)
      %w(one two three) * ", "
                        ^ Favor `Array#join` over `Array#*`.
    RUBY
  end

  it "autocorrects '*' to 'join' when there are spaces" do
    corrected =
      autocorrect_source(cop,
                         '%w(one two three) * ", "')
    expect(corrected).to eq '%w(one two three).join(", ")'
  end

  it "autocorrects '*' to 'join' when there are no spaces" do
    corrected =
      autocorrect_source(cop,
                         '%w(one two three)*", "')
    expect(corrected).to eq '%w(one two three).join(", ")'
  end

  it "autocorrects '*' to 'join' when setting to a variable" do
    corrected =
      autocorrect_source(cop,
                         'foo = %w(one two three)*", "')
    expect(corrected).to eq 'foo = %w(one two three).join(", ")'
  end

  it 'does not register an offense for numbers' do
    expect_no_offenses('%w(one two three) * 4')
  end

  it 'does not register an offense for ambiguous cases' do
    expect_no_offenses('%w(one two three) * test')
  end
end
