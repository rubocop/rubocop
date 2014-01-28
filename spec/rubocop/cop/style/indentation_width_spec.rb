# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::IndentationWidth do
  subject(:cop) { described_class.new }

  context 'with if statement' do
    it 'registers an offence for bad indentation of an if body' do
      inspect_source(cop,
                     ['if cond',
                      ' func',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation of an else body' do
      inspect_source(cop,
                     ['if cond',
                      '  func1',
                      'else',
                      ' func2',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation of an elsif body' do
      inspect_source(cop,
                     ['if a1',
                      '  b1',
                      'elsif a2',
                      ' b2',
                      'else',
                      '  c',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers offence for bad indentation of ternary inside else' do
      inspect_source(cop,
                     ['if a',
                      '  b',
                      'else',
                      '     x ? y : z',
                      'end'])
      expect(cop.messages)
        .to eq(['Use 2 (not 5) spaces for indentation.'])
    end

    it 'registers offence for bad indentation of modifier if in else' do
      inspect_source(cop,
                     ['if a',
                      '  b',
                      'else',
                      '   x if y',
                      'end'])
      expect(cop.messages)
        .to eq(['Use 2 (not 3) spaces for indentation.'])
    end

    it 'accepts a one line if statement' do
      inspect_source(cop,
                     ['if cond then func1 else func2 end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts a correctly aligned if/elsif/else/end' do
      inspect_source(cop,
                     ['if a1',
                      '  b1',
                      'elsif a2',
                      '  b2',
                      'else',
                      '  c',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts if/elsif/else/end laid out as a table' do
      inspect_source(cop,
                     ['if    @io == $stdout then str << "$stdout"',
                      'elsif @io == $stdin  then str << "$stdin"',
                      'elsif @io == $stderr then str << "$stderr"',
                      'else                      str << @io.class.to_s',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts if/then/else/end laid out as another table' do
      inspect_source(cop,
                     ["if File.exist?('config.save')",
                      'then ConfigTable.load',
                      'else ConfigTable.new',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an empty if' do
      inspect_source(cop,
                     ['if a',
                      'else',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if in assignment with end aligned with variable' do
      inspect_source(cop,
                     ['var = if a',
                      '  0',
                      'end',
                      '@var = if a',
                      '  0',
                      'end',
                      '$var = if a',
                      '  0',
                      'end',
                      'var ||= if a',
                      '  0',
                      'end',
                      'var &&= if a',
                      '  0',
                      'end',
                      'var -= if a',
                      '  0',
                      'end',
                      'VAR = if a',
                      '  0',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with variable' do
      inspect_source(cop,
                     ['var = if a',
                      '  0',
                      'else',
                      '  1',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with variable ' \
      'and chaining after the end' do
      inspect_source(cop,
                     ['var = if a',
                      '  0',
                      'else',
                      '  1',
                      'end.abc.join("")'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with variable ' \
      'and chaining with a block after the end' do
      inspect_source(cop,
                     ['var = if a',
                      '  0',
                      'else',
                      '  1',
                      'end.abc.tap {}'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if in assignment with end aligned with if' do
      inspect_source(cop,
                     ['var = if a',
                      '        0',
                      '      end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with if' do
      inspect_source(cop,
                     ['var = if a',
                      '        0',
                      '      else',
                      '        1',
                      '      end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if/else in assignment on next line with end aligned ' \
      'with if' do
      inspect_source(cop,
                     ['var =',
                      '  if a',
                      '    0',
                      '  else',
                      '    1',
                      '  end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an if/else branches with rescue clauses' do
      # Because of how the rescue clauses come out of Parser, these are
      # special and need to be tested.
      inspect_source(cop,
                     ['if a',
                      '  a rescue nil',
                      'else',
                      '  a rescue nil',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with unless' do
    it 'registers an offence for bad indentation of an unless body' do
      inspect_source(cop,
                     ['unless cond',
                      ' func',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'accepts an empty unless' do
      inspect_source(cop,
                     ['unless a',
                      'else',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with case' do
    it 'registers an offence for bad indentation in a case/when body' do
      inspect_source(cop,
                     ['case a',
                      'when b',
                      ' c',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation in a case/else body' do
      inspect_source(cop,
                     ['case a',
                      'when b',
                      '  c',
                      'when d',
                      '  e',
                      'else',
                      '   f',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
    end

    it 'accepts correctly indented case/when/else' do
      inspect_source(cop,
                     ['case a',
                      'when b',
                      '  c',
                      '  c',
                      'when d',
                      'else',
                      '  f',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts case/when/else laid out as a table' do
      inspect_source(cop,
                     ['case sexp.loc.keyword.source',
                      "when 'if'     then cond, body, _else = *sexp",
                      "when 'unless' then cond, _else, body = *sexp",
                      'else               cond, body = *sexp',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts case/when/else with then beginning a line' do
      inspect_source(cop,
                     ['case sexp.loc.keyword.source',
                      "when 'if'",
                      'then cond, body, _else = *sexp',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts indented when/else plus indented body' do
      # "Indent when as deep as case" is the job of another cop.
      inspect_source(cop,
                     ['case code_type',
                      "  when 'ruby', 'sql', 'plain'",
                      '    code_type',
                      "  when 'erb'",
                      "    'ruby; html-script: true'",
                      '  when "html"',
                      "    'xml'",
                      '  else',
                      "    'plain'",
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with while/until' do
    it 'registers an offence for bad indentation of a while body' do
      inspect_source(cop,
                     ['while cond',
                      ' func',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation of begin/end/while' do
      inspect_source(cop,
                     ['something = begin',
                      ' func1',
                      '   func2',
                      'end while cond'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation of an until body' do
      inspect_source(cop,
                     ['until cond',
                      ' func',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'accepts an empty while' do
      inspect_source(cop,
                     ['while a',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with for' do
    it 'registers an offence for bad indentation of a for body' do
      inspect_source(cop,
                     ['for var in 1..10',
                      ' func',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'accepts an empty for' do
      inspect_source(cop,
                     ['for var in 1..10',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with def/defs' do
    it 'registers an offence for bad indentation of a def body' do
      inspect_source(cop,
                     ['def test',
                      '    func1',
                      '     func2', # No offence registered for this.
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation of a defs body' do
      inspect_source(cop,
                     ['def self.test',
                      '   func',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
    end

    it 'accepts an empty def body' do
      inspect_source(cop,
                     ['def test',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an empty defs body' do
      inspect_source(cop,
                     ['def self.test',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with class' do
    it 'registers an offence for bad indentation of a class body' do
      inspect_source(cop,
                     ['class Test',
                      '    def func',
                      '    end',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
    end

    it 'accepts an empty class body' do
      inspect_source(cop,
                     ['class Test',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts indented public, protected, and private' do
      inspect_source(cop,
                     ['class Test',
                      '  public',
                      '',
                      '  def e',
                      '  end',
                      '',
                      '  protected',
                      '',
                      '  def f',
                      '  end',
                      '',
                      '  private',
                      '',
                      '  def g',
                      '  end',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with module' do
    it 'registers an offence for bad indentation of a module body' do
      inspect_source(cop,
                     ['module Test',
                      '    def func',
                      '    end',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
    end

    it 'accepts an empty module body' do
      inspect_source(cop,
                     ['module Test',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with block' do
    it 'registers an offence for bad indentation of a do/end body' do
      inspect_source(cop,
                     ['a = func do',
                      ' b',
                      'end'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
    end

    it 'registers an offence for bad indentation of a {} body' do
      inspect_source(cop,
                     ['func {',
                      '   b',
                      '}'])
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
    end

    it 'accepts a correctly indented block body' do
      inspect_source(cop,
                     ['a = func do',
                      '  b',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an empty block body' do
      inspect_source(cop,
                     ['a = func do',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end
end
