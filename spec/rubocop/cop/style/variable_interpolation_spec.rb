# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::VariableInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for interpolated global variables' do
    inspect_source(cop,
                   ['puts "this is a #$test"'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace interpolated var $test' \
              ' with expression #{$test}.'])
  end

  it 'registers an offense for interpolated regexp back references' do
    inspect_source(cop,
                   ['puts "this is a #$1"'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace interpolated var $1 with expression #{$1}.'])
  end

  it 'registers an offense for interpolated instance variables' do
    inspect_source(cop,
                   ['puts "this is a #@test"'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace interpolated var @test' \
              ' with expression #{@test}.'])
  end

  it 'registers an offense for interpolated class variables' do
    inspect_source(cop,
                   ['puts "this is a #@@t"'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace interpolated var @@t with expression #{@@t}.'])
  end

  it 'does not register an offense for variables in expressions' do
    inspect_source(cop,
                   ['puts "this is a #{@test} #{@@t} #{$t} #{$1}"'])
    expect(cop.offenses).to be_empty
  end
end
