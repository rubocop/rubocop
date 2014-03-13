# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FileName do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    Rubocop::Config.new('AllCops' => { 'Includes' => includes })
  end

  let(:includes) { [] }

  it 'reports offense for camelCase file names ending in .rb' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/testCase.rb')
    _investigate(cop, processed_source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports offense for camelCase file names without file extension' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/testCase')
    _investigate(cop, processed_source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts offense for snake_case file names ending in .rb' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/test_case.rb')
    _investigate(cop, processed_source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts offense for snake_case file names without file extension' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/test_case')
    _investigate(cop, processed_source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts offense for snake_case file names with non-rb extension' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/some/dir/some_task.rake')
    _investigate(cop, processed_source)
    expect(cop.offenses).to be_empty
  end

  context 'when the file is specified in AllCops/Includes' do
    let(:includes) { ['**/Gemfile'] }

    it 'accepts the file name even if it is not snake_case' do
      source = ['print 1']
      processed_source = parse_source(source)
      allow(processed_source.buffer)
        .to receive(:name).and_return('/some/dir/Gemfile')
      _investigate(cop, processed_source)
      expect(cop.offenses).to be_empty
    end
  end
end
