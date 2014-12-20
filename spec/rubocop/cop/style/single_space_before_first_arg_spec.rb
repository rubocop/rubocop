# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SingleSpaceBeforeFirstArg do
  subject(:cop) { described_class.new }

  context 'for method calls without parentheses' do
    it 'registers an offense for method call with two spaces before the ' \
       'first arg' do
      inspect_source(cop, ['something  x',
                           'a.something  y, z'])
      expect(cop.messages)
        .to eq(['Put one space between the method name and the first ' \
                'argument.'] * 2)
      expect(cop.highlights).to eq(['  ', '  '])
    end

    it 'auto-corrects extra space' do
      new_source = autocorrect_source(cop, ['something  x',
                                            'a.something   y, z'])
      expect(new_source).to eq(['something x',
                                'a.something y, z'].join("\n"))
    end

    it 'accepts a method call with one space before the first arg' do
      inspect_source(cop, ['something x',
                           'a.something y, z'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts + operator' do
      inspect_source(cop, ['something +',
                           '  x'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts setter call' do
      inspect_source(cop, ['something.x =',
                           '  y'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts multiple space containing line break' do
      inspect_source(cop, ['something \\',
                           '  x'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'for method calls with parentheses' do
    it 'accepts a method call without space' do
      inspect_source(cop, ['something(x)',
                           'a.something(y, z)'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a method call with space after the left parenthesis' do
      inspect_source(cop, 'something(  x  )')
      expect(cop.offenses).to be_empty
    end
  end
end
