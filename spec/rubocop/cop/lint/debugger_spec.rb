# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::Debugger do
  subject(:cop) { described_class.new  }

  it 'reports an offense for a debugger call' do
    src = 'debugger'
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Remove debugger entry point `debugger`.'])
    expect(cop.highlights).to eq(['debugger'])
  end

  it 'reports an offense for a byebug call' do
    src = 'byebug'
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Remove debugger entry point `byebug`.'])
    expect(cop.highlights).to eq(['byebug'])
  end

  it 'reports an offense for pry bindings' do
    src = ['binding.pry',
           'binding.remote_pry',
           'binding.pry_remote']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(3)
    expect(cop.messages)
      .to eq(['Remove debugger entry point `binding.pry`.',
              'Remove debugger entry point `binding.remote_pry`.',
              'Remove debugger entry point `binding.pry_remote`.'])
    expect(cop.highlights).to eq(['binding.pry',
                                  'binding.remote_pry',
                                  'binding.pry_remote'])
  end

  it 'reports an offense for capybara debug methods' do
    src = %w(save_and_open_page save_and_open_screenshot)
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(2)
    expect(cop.messages)
      .to eq(['Remove debugger entry point `save_and_open_page`.',
              'Remove debugger entry point `save_and_open_screenshot`.'])
    expect(cop.highlights)
      .to eq(%w(save_and_open_page save_and_open_screenshot))
  end

  it 'does not report an offense for non-pry binding' do
    src = 'binding.pirate'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  %w(debugger byebug pry remote_pry pry_remote
     save_and_open_page save_and_open_screenshot).each do |comment|
    it "does not report an offense for #{comment} in comments" do
      src = "# #{comment}"
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  %w(debugger byebug pry remote_pry pry_remote
     save_and_open_page save_and_open_screenshot).each do |method_name|
    it "does not report an offense for a #{method_name} method" do
      src = "code.#{method_name}"
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end
end
