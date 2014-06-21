# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::UnneededPercentQ do
  subject(:cop) { described_class.new }

  context 'with %q strings' do
    it 'registers an offense for only single quotes' do
      inspect_source(cop, "%q('hi')")
      expect(cop.messages).to eq(['Use `%q` only for strings that contain ' \
                                  'both single quotes and double quotes.'])
    end

    it 'registers an offense for only double quotes' do
      inspect_source(cop, '%q("hi")')
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts a string with single quotes and double quotes' do
      inspect_source(cop, %Q(%q('"hi"')))
      expect(cop.offenses).to be_empty
    end

    it 'normally auto-corrects %q to single quotes' do
      new_source = autocorrect_source(cop, '%q(hi)')
      expect(new_source).to eq("'hi'")
    end

    it 'auto-corrects %q to double quotes if necessary' do
      new_source = autocorrect_source(cop, "%q('hi')")
      expect(new_source).to eq(%q("'hi'"))
    end
  end

  context 'with %Q strings' do
    it 'registers an offense for static string with only double quotes' do
      inspect_source(cop, '%Q("hi")')
      expect(cop.messages).to eq(['Use `%Q` only for strings that contain ' \
                                  'both single quotes and double quotes, or ' \
                                  'for dynamic strings that contain double ' \
                                  'quotes.'])
    end

    it 'accepts a string with single quotes and double quotes' do
      inspect_source(cop, %Q(%Q('"hi"')))
      expect(cop.offenses).to be_empty
    end

    it 'accepts a dynamic %Q string with double quotes' do
      inspect_source(cop, '%Q("hi#{4}")')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects static %Q to double quotes' do
      new_source = autocorrect_source(cop, '%Q(hi)')
      # One could argue that the double quotes are not necessary for a static
      # string, but that's the job of the StringLiterals cop to check.
      expect(new_source).to eq('"hi"')
    end

    it 'auto-corrects static %Q with inner double quotes to single quotes' do
      new_source = autocorrect_source(cop, '%Q("hi")')
      expect(new_source).to eq(%q('"hi"'))
    end

    it 'auto-corrects dynamic %Q to double quotes' do
      new_source = autocorrect_source(cop, '%Q(hi #{func})')
      expect(new_source).to eq('"hi #{func}"')
    end
  end
end
