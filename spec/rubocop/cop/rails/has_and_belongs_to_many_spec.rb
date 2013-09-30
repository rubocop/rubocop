# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::HasAndBelongsToMany do
  subject(:cop) { described_class.new }

  it 'registers an offence for has_and_belongs_to_many' do
    inspect_source(cop,
                   ['has_and_belongs_to_many :groups'])
    expect(cop.offences.size).to eq(1)
  end
end
