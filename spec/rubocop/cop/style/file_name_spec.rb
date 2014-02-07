# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FileName do
  subject(:cop) { described_class.new }

  it 'reports offence for camelCase file names ending in .rb' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/testCase.rb')
    _investigate(cop, processed_source)
    expect(cop.offences.size).to eq(1)
  end

  it 'reports offence for camelCase file names without file extension' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/testCase')
    _investigate(cop, processed_source)
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts offence for snake_case file names ending in .rb' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/test_case.rb')
    _investigate(cop, processed_source)
    expect(cop.offences).to be_empty
  end

  it 'accepts offence for snake_case file names without file extension' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/test_case')
    _investigate(cop, processed_source)
    expect(cop.offences).to be_empty
  end
end
