# frozen_string_literal: true

describe RuboCop::Cop::Rails::ScopeArgs do
  subject(:cop) { described_class.new }

  it 'registers an offense a scope with a method arg' do
    inspect_source(cop, 'scope :active, where(active: true)')

    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a non send argument' do
    inspect_source(cop, 'scope :active, "adsf"')

    expect(cop.offenses).to be_empty
  end

  it 'accepts a stabby lambda' do
    inspect_source(cop, 'scope :active, -> { where(active: true) }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts a stabby lambda with arguments' do
    inspect_source(cop, 'scope :active, ->(active) { where(active: active) }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts a lambda' do
    inspect_source(cop, 'scope :active, lambda { where(active: true) }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts a lambda with a block argument' do
    inspect_source(cop,
                   'scope :active, lambda { |active| where(active: active) }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts a lambda with a multiline block' do
    inspect_source(cop, <<-END.strip_indent)
      scope :active, (lambda do |active|
                       where(active: active)
                     end)
    END

    expect(cop.offenses).to be_empty
  end

  it 'accepts a proc' do
    inspect_source(cop, 'scope :active, proc { where(active: true) }')

    expect(cop.offenses).to be_empty
  end
end
