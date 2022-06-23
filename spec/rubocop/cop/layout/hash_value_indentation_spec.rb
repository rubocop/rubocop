# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::HashValueIndentation, :config do
  let(:config) do
    RuboCop::Config.new('Layout/ParameterAlignment' => cop_config,
                        'Layout/IndentationWidth' => { 'Width' => indentation_width },
                        'Layout/HashAlignment' => {
                          'EnforcedColonStyle' => hash_alignment_style,
                          'EnforcedHashRocketStyle' => hash_alignment_style
                        })
  end
  let(:indentation_width) { 2 }
  let(:hash_alignment_style) { 'key' }

  it 'does not register an offense when the value is on the right of the key' do
    expect_no_offenses(<<~RUBY)
      {
        key1: value1,
        key2: value2
      }
    RUBY
  end

  it 'does not register an offense when the value is indented relative to the key' do
    expect_no_offenses(<<~RUBY)
      {
        key1:
          value1,
        key2:
          value2
      }
    RUBY
  end

  it 'registers an offense when the value is not indented relative to the key' do
    expect_offense(<<~RUBY)
      {
        key1:
          value1,
        key2:
      value2,
      ^^^^^^ Indent the hash value relative to its key.
        key3:
        value3,
        ^^^^^^ Indent the hash value relative to its key.
        key4:
                   value4
                   ^^^^^^ Indent the hash value relative to its key.
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        key1:
          value1,
        key2:
          value2,
        key3:
          value3,
        key4:
          value4
      }
    RUBY
  end

  context "when Layout/HashAlignment is configured with 'table'" do
    let(:hash_alignment_style) { 'table' }

    it 'does not register an offense when the values in the second or later pairs are ' \
       'aligned with the value in the first pair' do
      expect_no_offenses(<<~RUBY)
        {
          short_key:     value1,
          loooooong_key:
                         value2
        }
        {
          short_key     => value1,
          loooooong_key =>
                           value2
        }
      RUBY
    end
  end

  context "when Layout/HashAlignment is configured with 'separator'" do
    let(:hash_alignment_style) { 'separator' }

    it 'does not register an offense when the values in the second or later pairs are ' \
       'aligned with the value in the first pair' do
      expect_no_offenses(<<~RUBY)
        {
              short_key: value1,
          loooooong_key:
                         value2
        }
        {
              short_key => value1,
          loooooong_key =>
                           value2
        }
      RUBY
    end
  end

  context "when Layout/HashAlignment is configured with a combination of 'key' and another style" do
    let(:hash_alignment_style) { %w[key table] }

    it 'does not register an offense even if the indenttation of the value is not relative to the key' do
      expect_no_offenses(<<~RUBY)
        {
          short_key:     value1,
          loooooong_key:
                         value2
        }
        {
          short_key     => value1,
          loooooong_key =>
                           value2
        }
      RUBY
    end
  end
end
