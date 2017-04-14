# frozen_string_literal: true

describe RuboCop::Cop::Rails::ApplicationJob do
  let(:msgs) { [described_class::MSG] }

  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'allows ApplicationJob to be defined' do
      source = "class ApplicationJob < ActiveJob::Base\nend"
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows jobs that subclass ActiveJob::Base' do
      source = "class MyJob < ActiveJob::Base\nend"
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows a single-line class definitions' do
      source = 'class MyJob < ActiveJob::Base; end'
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows namespaced jobs that subclass ActiveJob::Base' do
      source = "module Nested\n  class MyJob < ActiveJob::Base\n  end\nend"
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows jobs defined using nested constants' do
      source = "class Nested::MyJob < ActiveJob::Base\nend"
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows jobs defined using Class.new' do
      source = 'MyJob = Class.new(ActiveJob::Base)'
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows nested jobs defined using Class.new' do
      source = 'Nested::MyJob = Class.new(ActiveJob::Base)'
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows anonymous jobs' do
      source = 'Class.new(ActiveJob::Base) {}'
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'allows ApplicationJob defined using Class.new' do
      source = 'ApplicationJob = Class.new(ActiveJob::Base)'
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'rails 5', :rails5 do
    subject(:cop) { described_class.new }

    it 'allows ApplicationJob to be defined' do
      source = "class ApplicationJob < ActiveJob::Base\nend"
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'corrects jobs that subclass ActiveJob::Base' do
      source = "class MyJob < ActiveJob::Base\nend"
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq("class MyJob < ApplicationJob\nend")
    end

    it 'corrects single-line class definitions' do
      source = 'class MyJob < ActiveJob::Base; end'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('class MyJob < ApplicationJob; end')
    end

    it 'corrects namespaced jobs that subclass ActiveJob::Base' do
      source = "module Nested\n  class MyJob < ActiveJob::Base\n  end\nend"
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq("module Nested\n  class MyJob < ApplicationJob\n  end\nend")
    end

    it 'corrects jobs defined using nested constants' do
      source = "class Nested::MyJob < ActiveJob::Base\nend"
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq("class Nested::MyJob < ApplicationJob\nend")
    end

    it 'corrects jobs defined using Class.new' do
      source = 'MyJob = Class.new(ActiveJob::Base)'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('MyJob = Class.new(ApplicationJob)')
    end

    it 'corrects nested jobs defined using Class.new' do
      source = 'Nested::MyJob = Class.new(ActiveJob::Base)'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('Nested::MyJob = Class.new(ApplicationJob)')
    end

    it 'corrects anonymous jobs' do
      source = 'Class.new(ActiveJob::Base) {}'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveJob::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('Class.new(ApplicationJob) {}')
    end

    it 'allows ApplicationJob defined using Class.new' do
      source = 'ApplicationJob = Class.new(ActiveJob::Base)'
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end
end
