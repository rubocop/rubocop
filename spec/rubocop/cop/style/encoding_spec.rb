# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Encoding do
  subject(:cop) { described_class.new }

  it 'registers an offence when no encoding present', ruby: 1.9 do
    inspect_source(cop, ['def foo() end'])

    expect(cop.messages).to eq(
      ['Missing utf-8 encoding comment.'])
  end

  it 'accepts encoding on first line', ruby: 1.9 do
    inspect_source(cop, ['# encoding: utf-8',
                         'def foo() end'])

    expect(cop.offences).to be_empty
  end

  it 'accepts encoding on second line when shebang present', ruby: 1.9 do
    inspect_source(cop, ['#!/usr/bin/env ruby',
                         '# encoding: utf-8',
                         'def foo() end'])

    expect(cop.messages).to be_empty
  end

  it 'books an offence when encoding is in the wrong place', ruby: 1.9 do
    inspect_source(cop, ['def foo() end',
                         '# encoding: utf-8'])

    expect(cop.messages).to eq(
      ['Missing utf-8 encoding comment.'])
  end

  it 'does not register an offence on Ruby 2.0', ruby: 2.0 do
    inspect_source(cop, ['def foo() end'])

    expect(cop.offences).to be_empty
  end

  it 'accepts encoding inserted by magic_encoding gem', ruby: 1.9 do
    inspect_source(cop, ['# -*- encoding : utf-8 -*-',
                         'def foo() end'])

    expect(cop.messages).to be_empty
  end

  it 'accepts vim-style encoding comments', ruby: 1.9 do
    inspect_source(cop, ['# vim:fileencoding=utf-8',
                         'def foo() end'])
    expect(cop.messages).to be_empty
  end
end
