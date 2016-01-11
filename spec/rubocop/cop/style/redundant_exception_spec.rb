# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::RedundantException do
  subject(:cop) { described_class.new }

  it 'reports an offense for a raise with RuntimeError' do
    inspect_source(cop, 'raise RuntimeError, msg')
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for a fail with RuntimeError' do
    inspect_source(cop, 'fail RuntimeError, msg')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a raise with RuntimeError if it does not have 2 args' do
    inspect_source(cop, 'raise RuntimeError, msg, caller')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a fail with RuntimeError if it does not have 2 args' do
    inspect_source(cop, 'fail RuntimeError, msg, caller')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects a raise by removing RuntimeError' do
    src = 'raise RuntimeError, msg'
    result_src = 'raise msg'
    new_src = autocorrect_source(cop, src)
    expect(new_src).to eq(result_src)
  end

  it 'auto-corrects a fil by removing RuntimeError' do
    src = 'fail RuntimeError, msg'
    result_src = 'fail msg'
    new_src = autocorrect_source(cop, src)
    expect(new_src).to eq(result_src)
  end

  it 'does not modify raise w/ RuntimeError if it does not have 2 args' do
    src = 'raise runtimeError, msg, caller'
    new_src = autocorrect_source(cop, src)
    expect(new_src).to eq(src)
  end

  it 'does not modify fail w/ RuntimeError if it does not have 2 args' do
    src = 'fail RuntimeError, msg, caller'
    new_src = autocorrect_source(cop, src)
    expect(new_src).to eq(src)
  end

  it 'does not modify rescue w/ non redundant error' do
    src = 'fail OtherError, msg'
    new_src = autocorrect_source(cop, src)
    expect(new_src).to eq(src)
  end
end
