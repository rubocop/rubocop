# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AccessControl do
  subject(:cop) { described_class.new }

  it 'registers an offence for misaligned private' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    'private',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent private as deep as method definitions.'])
  end

  it 'registers an offence for misaligned private in module' do
    inspect_source(cop,
                   ['module Test',
                    '',
                    'private',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent private as deep as method definitions.'])
  end

  it 'registers an offence for misaligned private in singleton class' do
    inspect_source(cop,
                   ['class << self',
                    '',
                    'private',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent private as deep as method definitions.'])
  end

  it 'registers an offence for misaligned private in class ' +
     'defined with Class.new' do
    inspect_source(cop,
                   ['Test = Class.new do',
                    '',
                    'private',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent private as deep as method definitions.'])
  end

  it 'registers an offence for misaligned private in module ' +
     'defined with Module.new' do
    inspect_source(cop,
                   ['Test = Module.new do',
                    '',
                    'private',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent private as deep as method definitions.'])
  end

  it 'registers an offence for misaligned protected' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    'protected',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent protected as deep as method definitions.'])
  end

  it 'accepts properly indented private' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  private',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts properly indented protected' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  protected',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'handles properly nested classes' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  class Nested',
                    '',
                    '  private',
                    '',
                    '    def a; end',
                    '  end',
                    '',
                    '  protected',
                    '',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Indent private as deep as method definitions.'])
  end

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
