# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ModuleFunction do
  subject(:cop) { described_class.new }

  it 'registers an offense for extend self in module' do
    inspect_source(cop,
                   ['module Test',
                    '  extend self',
                    '  def test; end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts extend self in class' do
    inspect_source(cop,
                   ['class Test',
                    '  extend self',
                    'end'])
    expect(cop.offenses).to be_empty
  end
end
