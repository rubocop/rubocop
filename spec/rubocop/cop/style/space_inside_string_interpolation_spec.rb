# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceInsideStringInterpolation do
  subject(:cop) { described_class.new }

  context 'for ill-formatted string interpolations' do
    let(:source) do
      ['"#{ var}"',
       '"#{ var }"',
       '"#{var }"',
       '"#{   var   }"',
       '"#{var	}"',
       '"#{	var	}"',
       '"#{	var}"',
       '"#{ 	 var 	 	}"']
    end

    let(:corrected_source) { '"#{var}"' }

    it 'registers an offense for any variation of spaces inside the braces' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(['Space inside string interpolation detected.'] * 8)
    end

    it 'auto-corrects spacing within a string interpolation' do
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(([corrected_source] * 8).join("\n"))
    end
  end

  context 'for well-formatted string interpolations' do
    let(:source) do
      ['"Variable is    #{var}      "',
       '"  Variable is  #{var}"']
    end

    it 'does not register an offense for excess literal spacing' do
      inspect_source(cop, source)
      expect(cop.messages).to be_empty
    end

    it 'does not correct valid string interpolations' do
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(source.join("\n"))
    end
  end
end
