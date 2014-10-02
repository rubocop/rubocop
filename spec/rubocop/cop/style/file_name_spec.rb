# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::FileName do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      { 'AllCops' => { 'Include' => includes } },
      '/some/.rubocop.yml'
    )
  end

  let(:includes) { [] }
  let(:source) { ['print 1'] }
  let(:processed_source) { parse_source(source) }

  before do
    allow(processed_source.buffer)
      .to receive(:name).and_return(filename)
    _investigate(cop, processed_source)
  end

  context 'with camelCase file names ending in .rb' do
    let(:filename) { '/some/dir/testCase.rb' }

    it 'reports an offense' do
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'with camelCase file names without file extension' do
    let(:filename) { '/some/dir/testCase' }

    it 'reports an offense' do
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'with snake_case file names ending in .rb' do
    let(:filename) { '/some/dir/test_case.rb' }

    it 'reports an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'with snake_case file names without file extension' do
    let(:filename) { '/some/dir/test_case' }

    it 'does not report an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'with snake_case file names with non-rb extension' do
    let(:filename) { '/some/dir/some_task.rake' }

    it 'does not report an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'with snake_case file names with multiple extensions' do
    let(:filename) { 'some/dir/some_view.html.slim_spec.rb' }

    it 'does not report an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when the file is specified in AllCops/Include' do
    let(:includes) { ['**/Gemfile'] }

    context 'with a non-snake_case file name' do
      let(:filename) { '/some/dir/Gemfile' }

      it 'does not report an offense' do
        expect(cop.offenses).to be_empty
      end
    end
  end
end
