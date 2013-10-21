# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EmptyLinesAroundAccessModifier do
  subject(:cop) { described_class.new }

  it 'requires blank line before private/protected' do
    inspect_source(cop,
                   ['class Test',
                    '  protected',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Keep a blank line before and after protected.'])
  end

  it 'requires blank line after private/protected' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  protected',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Keep a blank line before and after protected.'])
  end

  it 'recognizes blank lines with DOS style line endings' do
    inspect_source(cop,
                   ["class Test\r",
                    "\r",
                    "  protected\r",
                    "\r",
                    "  def test; end\r",
                    "end\r"])
    expect(cop.offences.size).to eq(0)
  end
end
