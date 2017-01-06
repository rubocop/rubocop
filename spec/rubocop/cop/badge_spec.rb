# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Badge do
  subject(:badge) { described_class.new('Test', 'ModuleMustBeAClassCop') }

  it 'exposes department name' do
    expect(badge.department).to be(:Test)
  end

  it 'exposes cop name' do
    expect(badge.cop_name).to eql('ModuleMustBeAClassCop')
  end

  describe '.parse' do
    it 'parses Department/CopName syntax' do
      expect(described_class.parse('Foo/Bar'))
        .to eq(described_class.new('Foo', 'Bar'))
    end

    it 'parses unqualified badge references' do
      expect(described_class.parse('Bar'))
        .to eql(described_class.new(nil, 'Bar'))
    end
  end

  describe '.for' do
    it 'parses cop class name' do
      expect(described_class.for('RuboCop::Cop::Foo::Bar'))
        .to eq(described_class.new('Foo', 'Bar'))
    end
  end

  it 'compares by value' do
    badge1 = described_class.new('Foo', 'Bar')
    badge2 = described_class.new('Foo', 'Bar')

    expect(Set.new([badge1, badge2]).one?).to be(true)
  end

  it 'can be converted to a string with the Department/CopName format' do
    expect(described_class.new('Foo', 'Bar').to_s).to eql('Foo/Bar')
  end

  describe '#qualified?' do
    it 'says `CopName` is not qualified' do
      expect(described_class.parse('Bar')).not_to be_qualified
    end

    it 'says `Department/CopName` is qualified' do
      expect(described_class.parse('Department/Bar')).to be_qualified
    end
  end
end
