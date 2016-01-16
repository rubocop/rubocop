# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::RedundantBlockCall do
  subject(:cop) { described_class.new }

  it 'autocorrects block.call without arguments' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call',
                                          'end'])
    expect(new_source).to eq(['def method(&block)',
                              '  yield',
                              'end'].join("\n"))
  end

  it 'autocorrects block.call with arguments' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call 1, 2',
                                          'end'])
    expect(new_source).to eq(['def method(&block)',
                              '  yield 1, 2',
                              'end'].join("\n"))
  end

  it 'autocorrects even when block arg has a different name' do
    new_source = autocorrect_source(cop, ['def method(&func)',
                                          '  func.call',
                                          'end'])
    expect(new_source).to eq(['def method(&func)',
                              '  yield',
                              'end'].join("\n"))
  end

  it "doesn't register an error when receiver of `call` was not block arg" do
    inspect_source(cop, ['def method(&block)',
                         ' something.call',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it "doesn't register an error when block arg is unused" do
    inspect_source(cop, ['def method(&block)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'formats the error message for func.call(1) correctly' do
    inspect_source(cop, ['def method(&func)',
                         '  func.call(1)',
                         'end'])
    expect(cop.messages).to eq(['Use `yield` instead of `func.call`.'])
  end
end
