# frozen_string_literal: true

describe RuboCop::Cop::Rails::FindBy do
  subject(:cop) { described_class.new }
  let(:warning_message) { 'Use `find_by` instead of `where.first`.' }

  shared_examples 'registers_offense' do |selector|
    it "when using where.#{selector}" do
      inspect_source(cop, "User.where(id: x).#{selector}")

      expect(cop.messages)
        .to eq(["Use `find_by` instead of `where.#{selector}`."])
    end
  end

  it_behaves_like('registers_offense', 'first')
  it_behaves_like('registers_offense', 'take')

  it 'does not register an offense when using find_by' do
    inspect_source(cop, 'User.find_by(id: x)')

    expect(cop.messages).to be_empty
  end

  context 'with one param' do
    it 'does not register an offense for a method' do
      inspect_source(cop, 'User.where(complex_query).first')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for an instance variable' do
      inspect_source(cop, 'User.where(@complex_query).first')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for a local variable' do
      inspect_source(cop, 'query = foo; User.where(query).first')

      expect(cop.messages).to be_empty
    end
  end

  context 'with method call in params hash' do
    it 'registers an offense' do
      inspect_source(cop, 'User.where(status: complex_query).first')

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first).to eq(warning_message)
    end
  end

  context 'with method call and other params in params hash' do
    it 'registers an offense' do
      inspect_source(cop, 'User.where(status: query, deleted_at: nil).first')

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first).to eq(warning_message)
    end
  end

  it 'autocorrects where.take to find_by' do
    new_source = autocorrect_source(cop, 'User.where(id: x).take')

    expect(new_source).to eq('User.find_by(id: x)')
  end

  it 'does not autocorrect where.first' do
    new_source = autocorrect_source(cop, 'User.where(id: x).first')

    expect(new_source).to eq('User.where(id: x).first')
  end
end
