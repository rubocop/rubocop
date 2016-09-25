# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::HasAndBelongsToMany do
  subject(:cop) { described_class.new }

  it 'registers an offense for has_and_belongs_to_many' do
    inspect_source(cop,
                   'has_and_belongs_to_many :groups')
    expect(cop.offenses.size).to eq(1)
  end
end
