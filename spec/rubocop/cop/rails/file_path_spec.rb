# frozen_string_literal: true

describe RuboCop::Cop::Rails::FilePath do
  subject(:cop) { described_class.new }

  context 'when using Rails.root.join with some path strings' do
    let(:source) { "Rails.root.join('app', 'models', 'user.rb')" }

    it 'does not registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when using File.join with Rails.root' do
    let(:source) { "File.join(Rails.root, 'app', 'models')" }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when using Rails.root.join with slash separated path string' do
    let(:source) { "Rails.root.join('app/models/goober')" }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when using Rails.root without path called by double quoted string' do
    let(:source) { '"#{Rails.root}"' }

    it 'does not registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when interpolating Rails.root in a rm system call' do
    let :source do
      'system "rm -rf #{Rails.root.join(\'public\', \'system\')}"'
    end

    it 'does not registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when interpolating Rails.root in a wheneverize system call' do
    let :source do
      'system "wheneverize \'#{Rails.root}\'" unless File.exist? @filepath'
    end

    it 'does not registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when using Rails.root with path called by double quoted string' do
    let(:source) { '"#{Rails.root}/app/models/goober"' }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'Rails.root is used as a method argument' do
    let(:source) { 'foo(bar(File.join(Rails.root, "app", "models")))' }

    it 'registers an offense once' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'Rails.root.join used as an argument' do
    let(:source) { 'foo(Rails.root.join(\'app/models\'))' }

    it 'registers an offense once' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end
end
