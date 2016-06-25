# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MethodMissing do
  subject(:cop) { described_class.new }

  it 'registers an offense for method_missing' do
    inspect_source(cop, ['class Test',
                         '  def method_missing; end',
                         'end'])

    expect(cop.messages).to eq(['Avoid using `method_missing`. '\
      'Instead use `delegation`, `proxy` or `define_method`.'])
    expect(cop.offenses.empty?).to eq(false)
  end
end
