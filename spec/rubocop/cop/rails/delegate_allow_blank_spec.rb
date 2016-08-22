# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::DelegateAllowBlank do
  subject(:cop) { described_class.new }

  it 'registers an offense when using allow_blank' do
    inspect_source(cop, 'delegate :foo, to: :bar, allow_blank: true')

    msg = '`allow_blank` is not a valid option, use `allow_nil`.'
    expect(cop.messages).to eq([msg])
  end

  it 'does not register an offense when using allow_nil' do
    inspect_source(cop, 'delegate :foo, to: :bar, allow_nil: true')

    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when no extra options given' do
    inspect_source(cop, 'delegate :foo, to: :bar')

    expect(cop.messages).to be_empty
  end

  it 'autocorrects allow_blank to allow_nil' do
    source = 'delegate :foo, to: :bar, allow_blank: true'
    new_source = autocorrect_source(cop, source)

    expect(new_source).to eq('delegate :foo, to: :bar, allow_nil: true')
  end
end
