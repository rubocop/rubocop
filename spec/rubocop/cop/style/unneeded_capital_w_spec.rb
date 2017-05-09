# frozen_string_literal: true

describe RuboCop::Cop::Style::UnneededCapitalW do
  subject(:cop) { described_class.new }

  it 'registers no offense for normal arrays of strings' do
    expect_no_offenses('["one", "two", "three"]')
  end

  it 'registers no offense for normal arrays of strings with interpolation' do
    expect_no_offenses('["one", "two", "th#{?r}ee"]')
  end

  it 'registers an offense for misused %W' do
    expect_offense(<<-RUBY.strip_indent)
      %W(cat dog)
      ^^^^^^^^^^^ Do not use `%W` unless interpolation is needed. If not, use `%w`.
    RUBY
  end

  it 'registers no offense for %W with interpolation' do
    expect_no_offenses('%W(c#{?a}t dog)')
  end

  it 'registers no offense for %W with special characters' do
    source = <<-'END'.strip_indent
      def dangerous_characters
        %W(\000) +
        %W(\001) +
        %W(\027) +
        %W(\002) +
        %W(\003) +
        %W(\004) +
        %W(\005) +
        %W(\006) +
        %W(\007) +
        %W(\00) +
        %W(\a)
        %W(\s)
        %W(\n)
        %W(\!)
      end
    END
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'registers no offense for %w without interpolation' do
    expect_no_offenses('%w(cat dog)')
  end

  it 'registers no offense for %w with interpolation-like syntax' do
    expect_no_offenses('%w(c#{?a}t dog)')
  end

  it 'registers no offense for arrays with character constants' do
    expect_no_offenses('["one", ?\n]')
  end

  it 'does not register an offense for array of non-words' do
    expect_no_offenses('["one space", "two", "three"]')
  end

  it 'does not register an offense for array containing non-string' do
    expect_no_offenses('["one", "two", 3]')
  end

  it 'does not register an offense for array with one element' do
    expect_no_offenses('["three"]')
  end

  it 'does not register an offense for array with empty strings' do
    expect_no_offenses('["", "two", "three"]')
  end

  it 'auto-corrects an array of words' do
    new_source = autocorrect_source(cop, '%W(one two three)')
    expect(new_source).to eq('%w(one two three)')
  end

  it 'auto-corrects an array of words with different bracket' do
    new_source = autocorrect_source(cop, '%W[one two three]')
    expect(new_source).to eq('%w[one two three]')
  end
end
