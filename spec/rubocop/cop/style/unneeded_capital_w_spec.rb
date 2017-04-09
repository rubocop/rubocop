# frozen_string_literal: true

describe RuboCop::Cop::Style::UnneededCapitalW do
  subject(:cop) { described_class.new }

  it 'registers no offense for normal arrays of strings' do
    inspect_source(cop, '["one", "two", "three"]')
    expect(cop.offenses).to be_empty
  end

  it 'registers no offense for normal arrays of strings with interpolation' do
    inspect_source(cop, '["one", "two", "th#{?r}ee"]')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for misused %W' do
    inspect_source(cop, '%W(cat dog)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers no offense for %W with interpolation' do
    inspect_source(cop, '%W(c#{?a}t dog)')
    expect(cop.offenses).to be_empty
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
    inspect_source(cop, '%w(cat dog)')
    expect(cop.offenses).to be_empty
  end

  it 'registers no offense for %w with interpolation-like syntax' do
    inspect_source(cop, '%w(c#{?a}t dog)')
    expect(cop.offenses).to be_empty
  end

  it 'registers no offense for arrays with character constants' do
    inspect_source(cop, '["one", ?\n]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array of non-words' do
    inspect_source(cop, '["one space", "two", "three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array containing non-string' do
    inspect_source(cop, '["one", "two", 3]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array with one element' do
    inspect_source(cop, '["three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array with empty strings' do
    inspect_source(cop, '["", "two", "three"]')
    expect(cop.offenses).to be_empty
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
