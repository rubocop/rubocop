# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::DefineMethod do
  subject(:cop) { described_class.new }

  it 'registers an offence when using module_eval' do
    inspect_source(cop, ['def self.def_methods(_methods)',
                         '  _methods.each do |method_name|',
                         '    module_eval %{',
                         '      def #{method_name}',
                         '        puts "win"',
                         '      end',
                         '    }',
                         '  end',
                         'end'].join("\n"))

    expect(cop.messages)
      .to eq(['Use `define_method` instead of `module_eval`.'])
  end

  it 'does not registers an offence when using define_method' do
    inspect_source(cop, ['def self.def_methods(_methods)',
                         '  _methods.each do |method_name|',
                         '    define_method method_name do',
                         '      puts "win"',
                         '    end',
                         '  end',
                         'end'].join("\n"))

    expect(cop.messages).to be_empty
  end
end
