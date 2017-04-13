# frozen_string_literal: true

describe RuboCop::Cop::Lint::ReturnInVoidContext do
  subject(:cop) { described_class.new }

  shared_examples 'registers an offense' do |message|
    it 'registers an offense' do
      inspect_source(cop, source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([message])
    end
  end

  shared_examples 'does not registers an offense' do
    it 'does not registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'with an initialize method containing a return with a value' do
    let(:source) do
      ['class A',
       '  def initialize',
       '    return :qux if bar?',
       '  end',
       'end']
    end
    it_behaves_like 'registers an offense',
                    'Do not return a value in `initialize`.'
  end

  context 'with an initialize method containing a return without a value' do
    let(:source) do
      ['class A',
       '  def initialize',
       '    return if bar?',
       '  end',
       'end']
    end

    it_behaves_like 'does not registers an offense'
  end

  context 'with a setter method containing a return with a value' do
    let(:source) do
      ['class A',
       '  def foo=(bar)',
       '    return 42',
       '  end',
       'end']
    end

    it_behaves_like 'registers an offense',
                    'Do not return a value in `foo=`.'
  end

  context 'with a setter method containing a return without a value' do
    let(:source) do
      ['class A',
       '  def foo=(bar)',
       '    return',
       '  end',
       'end']
    end

    it_behaves_like 'does not registers an offense'
  end

  context 'with a non initialize method containing a return' do
    let(:source) do
      ['class A',
       '  def bar',
       '    foo',
       '    return :qux if bar?',
       '    foo',
       '  end',
       'end']
    end
    it_behaves_like 'does not registers an offense'
  end

  context 'with a class method called initialize containing a return' do
    let(:source) do
      ['class A',
       '  def self.initialize',
       '    foo',
       '    return :qux if bar?',
       '    foo',
       '  end',
       'end']
    end
    it_behaves_like 'does not registers an offense'
  end
end
