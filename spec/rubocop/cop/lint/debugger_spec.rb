# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::Debugger do
  subject(:cop) { described_class.new  }

  it 'reports an offense for a debugger call' do
    src = ['debugger']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for a byebug call' do
    src = ['byebug']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for pry bindings' do
    src = ['binding.pry',
           'binding.remote_pry']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not report an offense for non-pry binding' do
    src = ['binding.pirate']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  %w(debugger byebug).each do |comment|
    it "does not report an offense for #{comment} in comments" do
      src = ["# #{comment}"]
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  %w(debugger byebug pry).each do |method_name|
    it "does not report an offense for a #{method_name} method" do
      src = ["code.#{method_name}"]
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end
end
