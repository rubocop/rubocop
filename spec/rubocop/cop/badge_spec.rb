# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Badge do
  subject(:badge) { described_class.new(%w[Test ModuleMustBeAClassCop]) }

  it 'exposes department name' do
    expect(badge.department).to be(:Test)
  end

  it 'exposes cop name' do
    expect(badge.cop_name).to eql('ModuleMustBeAClassCop')
  end

  describe '.new' do
    shared_examples 'assignment of department and name' do |class_name_parts, department, name|
      it 'assigns department' do
        expect(described_class.new(class_name_parts).department).to eq(department)
      end

      it 'assigns name' do
        expect(described_class.new(class_name_parts).cop_name).to eq(name)
      end
    end

    include_examples 'assignment of department and name', %w[Foo], nil, 'Foo'
    include_examples 'assignment of department and name', %w[Foo Bar], :Foo, 'Bar'
    include_examples 'assignment of department and name', %w[Foo Bar Baz], :'Foo/Bar', 'Baz'
    include_examples 'assignment of department and name', %w[Foo Bar Baz Qux], :'Foo/Bar/Baz', 'Qux'
  end

  describe '.parse' do
    shared_examples 'cop identifier parsing' do |identifier, class_name_parts|
      it 'parses identifier' do
        expect(described_class.parse(identifier)).to eq(described_class.new(class_name_parts))
      end
    end

    include_examples 'cop identifier parsing', 'Bar', %w[Bar]
    include_examples 'cop identifier parsing', 'Foo/Bar', %w[Foo Bar]
    include_examples 'cop identifier parsing', 'Foo/Bar/Baz', %w[Foo Bar Baz]
    include_examples 'cop identifier parsing', 'Foo/Bar/Baz/Qux', %w[Foo Bar Baz Qux]
  end

  describe '.for' do
    shared_examples 'cop class name parsing' do |class_name, class_name_parts|
      it 'parses cop class name' do
        expect(described_class.for(class_name)).to eq(described_class.new(class_name_parts))
      end
    end

    include_examples 'cop class name parsing', 'Foo', %w[Foo]
    include_examples 'cop class name parsing', 'Foo::Bar', %w[Foo Bar]
    include_examples 'cop class name parsing', 'RuboCop::Cop::Foo', %w[Cop Foo]
    include_examples 'cop class name parsing', 'RuboCop::Cop::Foo::Bar', %w[Foo Bar]
    include_examples 'cop class name parsing', 'RuboCop::Cop::Foo::Bar::Baz', %w[Foo Bar Baz]
  end

  it 'compares by value' do
    badge1 = described_class.new(%w[Foo Bar])
    badge2 = described_class.new(%w[Foo Bar])

    expect(Set.new([badge1, badge2]).one?).to be(true)
  end

  it 'can be converted to a string with the Department/CopName format' do
    expect(described_class.new(%w[Foo Bar]).to_s).to eql('Foo/Bar')
  end

  describe '#qualified?' do
    it 'says `CopName` is not qualified' do
      expect(described_class.parse('Bar').qualified?).to be(false)
    end

    it 'says `Department/CopName` is qualified' do
      expect(described_class.parse('Department/Bar').qualified?).to be(true)
    end

    it 'says `Deep/Department/CopName` is qualified' do
      expect(described_class.parse('Deep/Department/Bar').qualified?).to be(true)
    end
  end
end
