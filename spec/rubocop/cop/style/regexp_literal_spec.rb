# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RegexpLiteral, :config do
  subject(:cop) { described_class.new(config) }

  context 'when AllowInnerSlashes is false' do
    let(:cop_config) { { 'AllowInnerSlashes' => false } }

    it 'registers an offense for one slash in // regexp' do
      inspect_source(cop, 'x =~ /home\//')
      expect(cop.messages).to eq(['Use `%r` around regular expression.'])
    end

    it 'accepts zero slashes in // regexp' do
      inspect_source(cop, 'z =~ /a/')
      expect(cop.offenses).to be_empty
    end

    it 'ignores slashes do not belong // regexp' do
      inspect_source(cop, 'x =~ /\s{#{x[/\s+/].length}}/')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when AllowInnerSlashes is true' do
    let(:cop_config) { { 'AllowInnerSlashes' => true } }

    it 'accepts zero, one or many slashes in // regexp' do
      inspect_source(cop, ['x =~ /\/home/',
                           'y =~ /\//',
                           'v =~ /\/etc\/hosts/',
                           'w =~ /\//m',
                           'z =~ /a/'])
      expect(cop.offenses).to be_empty
    end
  end
end
