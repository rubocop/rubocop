# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EmptyLinesAroundAccessModifier do
  subject(:cop) { described_class.new }

  %w(private protected public).each do |access_modifier|
    it "requires blank line before #{access_modifier}" do
      inspect_source(cop,
                     ['class Test',
                      '  something',
                      "  #{access_modifier}",
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(["Keep a blank line before and after #{access_modifier}."])
    end

    it 'requires blank line after #{access_modifier}' do
      inspect_source(cop,
                     ['class Test',
                      '  something',
                      '',
                      "  #{access_modifier}",
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(["Keep a blank line before and after #{access_modifier}."])
    end

    it 'accepts missing blank line when at the beginning of class/module' do
      inspect_source(cop,
                     ['class Test',
                      "  #{access_modifier}",
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'recognizes blank lines with DOS style line endings' do
      inspect_source(cop,
                     ["class Test\r",
                      "\r",
                      "  #{access_modifier}\r",
                      "\r",
                      "  def test; end\r",
                      "end\r"])
      expect(cop.offences.size).to eq(0)
    end
  end
end
