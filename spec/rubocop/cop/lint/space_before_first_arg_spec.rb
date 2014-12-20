# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::SpaceBeforeFirstArg do
  subject(:cop) { described_class.new }

  context 'for method calls without parentheses' do
    it 'registers an offense for method call with no space before the ' \
       'first arg' do
      inspect_source(cop, ['something?x',
                           'a.something!y, z'])
      expect(cop.messages)
        .to eq(['Put space between the method name and the first ' \
                'argument.'] * 2)
      expect(cop.highlights).to eq(%w(x y))
    end

    it 'accepts a method call with space before the first arg' do
      inspect_source(cop, ['something? x',
                           'a.something! y, z'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts square brackets operator' do
      inspect_source(cop, 'something[:x]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a method call with space before a multiline arg' do
      inspect_source(cop, "something [\n  'foo',\n  'bar'\n]")
      expect(cop.offenses).to be_empty
    end

    it 'accepts an assignment without space before first arg' do
      inspect_source(cop, ['a.something=c',
                           'a.something,b=c,d'])
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects method call with no space before the first arg' do
      new_source = autocorrect_source(cop, ['something?x',
                                            'a.something!y, z'])
      expect(new_source).to eq(['something? x',
                                'a.something! y, z'].join("\n"))
    end
  end

  context 'for method calls with parentheses' do
    it 'accepts a method call without space' do
      inspect_source(cop, ['something?(x)',
                           'a.something(y, z)'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a method call with space after the left parenthesis' do
      inspect_source(cop, 'something?(  x  )')
      expect(cop.offenses).to be_empty
    end

    it 'accepts setter call' do
      inspect_source(cop, 'self.class.controller_path=(path)')
      expect(cop.offenses).to be_empty
    end
  end
end
