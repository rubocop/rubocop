# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::UnneededPercentQ do
  subject(:cop) { described_class.new }

  context 'with %q strings' do
    let(:source) do
      <<-END.strip_indent
        %q('hi') # line 1
        %q("hi")
        %q(hi)
        %q('"hi"')
        %q('hi\\t') # line 5
      END
    end
    let(:corrected) do
      <<-END.strip_indent
        "'hi'" # line 1
        '"hi"'
        'hi'
        %q('"hi"')
        %q('hi\\t') # line 5
      END
    end
    before { inspect_source(cop, source) }

    it 'registers an offense for only single quotes' do
      expect(cop.offenses.map(&:line)).to include(1)
      expect(cop.messages).to eq(['Use `%q` only for strings that contain ' \
                                  'both single quotes and double quotes.'] * 3)
    end

    it 'registers an offense for only double quotes' do
      expect(cop.offenses.map(&:line)).to include(2)
    end

    it 'registers an offense for no quotes' do
      expect(cop.offenses.map(&:line)).to include(3)
    end

    it 'accepts a string with single quotes and double quotes' do
      expect(cop.offenses.map(&:line)).not_to include(4)
    end

    it 'accepts a string with a tab character' do
      expect(cop.offenses.map(&:line)).not_to include(5)
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected)
    end
  end

  context 'with %Q strings' do
    let(:source) do
      <<-END.strip_indent
        %Q(hi) # line 1
        %Q("hi")
        %Q(hi\#{4})
        %Q('"hi"')
        %Q("\\thi")
        %Q("hi\#{4}")
        /%Q?/ # line 7
      END
    end
    let(:corrected) do
      <<-END.strip_indent
        "hi" # line 1
        '"hi"'
        "hi\#{4}"
        %Q('"hi"')
        %Q("\\thi")
        %Q("hi\#{4}")
        /%Q?/ # line 7
      END
    end
    before { inspect_source(cop, source) }

    it 'registers an offense for static string without quotes' do
      expect(cop.offenses.map(&:line)).to include(1)
      expect(cop.messages).to eq(['Use `%Q` only for strings that contain ' \
                                  'both single quotes and double quotes, or ' \
                                  'for dynamic strings that contain double ' \
                                  'quotes.'] * 3)
    end

    it 'registers an offense for static string with only double quotes' do
      expect(cop.offenses.map(&:line)).to include(2)
    end

    it 'registers an offense for dynamic string without quotes' do
      expect(cop.offenses.map(&:line)).to include(3)
    end

    it 'accepts a string with single quotes and double quotes' do
      expect(cop.offenses.map(&:line)).not_to include(4)
    end

    it 'accepts a string with double quotes and tab character' do
      expect(cop.offenses.map(&:line)).not_to include(5)
    end

    it 'accepts a dynamic %Q string with double quotes' do
      expect(cop.offenses.map(&:line)).not_to include(6)
    end

    it 'accepts regular expressions starting with %Q' do
      expect(cop.offenses.map(&:line)).not_to include(7)
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected)
    end
  end

  it 'accepts a heredoc string that contains %q' do
    inspect_source(cop, ['  s = <<END',
                         "%q('hi') # line 1",
                         '%q("hi")',
                         'END'])
    expect(cop.offenses).to be_empty
  end
end
