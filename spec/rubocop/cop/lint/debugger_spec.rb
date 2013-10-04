# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::Debugger do
  subject(:cop) { described_class.new  }

  it 'reports an offence for a debugger call' do
    src = ['debugger']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end

  it 'reports an offence for pry bindings' do
    src = ['binding.pry',
           'binding.remote_pry']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(2)
  end

  it 'does not report an offence for non-pry binding' do
    src = ['binding.pirate']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'does not report an offence for debugger in comments' do
    src = ['# debugger']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'does not report an offence for a debugger or pry method' do
    src = ['code.debugger',
           'door.pry']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end
end
