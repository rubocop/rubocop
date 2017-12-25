# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Severity do
  let(:refactor) { described_class.new(:refactor) }
  let(:convention) { described_class.new(:convention) }
  let(:warning) { described_class.new(:warning) }
  let(:error) { described_class.new(:error) }
  let(:fatal) { described_class.new(:fatal) }

  it 'has a few required attributes' do
    expect(convention.name).to eq(:convention)
  end

  it 'overrides #to_s' do
    expect(convention.to_s).to eq('convention')
  end

  it 'redefines == to compare severities' do
    expect(convention).to eq(:convention)
    expect(convention).to eq(described_class.new(:convention))
    expect(convention).not_to eq(:warning)
  end

  it 'is frozen' do
    expect(convention.frozen?).to be(true)
  end

  describe '#code' do
    describe 'refactor' do
      it { expect(refactor.code).to eq('R') }
    end

    describe 'convention' do
      it { expect(convention.code).to eq('C') }
    end

    describe 'warning' do
      it { expect(warning.code).to eq('W') }
    end

    describe 'error' do
      it { expect(error.code).to eq('E') }
    end

    describe 'fatal' do
      it { expect(fatal.code).to eq('F') }
    end
  end

  describe '#level' do
    describe 'refactor' do
      it { expect(refactor.level).to eq(1) }
    end

    describe 'convention' do
      it { expect(convention.level).to eq(2) }
    end

    describe 'warning' do
      it { expect(warning.level).to eq(3) }
    end

    describe 'error' do
      it { expect(error.level).to eq(4) }
    end

    describe 'fatal' do
      it { expect(fatal.level).to eq(5) }
    end
  end

  describe 'constructs from code' do
    describe 'R' do
      it { expect(described_class.new('R')).to eq(refactor) }
    end

    describe 'C' do
      it { expect(described_class.new('C')).to eq(convention) }
    end

    describe 'W' do
      it { expect(described_class.new('W')).to eq(warning) }
    end

    describe 'E' do
      it { expect(described_class.new('E')).to eq(error) }
    end

    describe 'F' do
      it { expect(described_class.new('F')).to eq(fatal) }
    end
  end

  describe 'Comparable' do
    describe 'refactor' do
      it { expect(refactor).to be < convention }
    end

    describe 'convention' do
      it { expect(convention).to be < warning }
    end

    describe 'warning' do
      it { expect(warning).to be < error }
    end

    describe 'error' do
      it { expect(error).to be < fatal }
    end
  end
end
