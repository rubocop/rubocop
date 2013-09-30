# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe ClassAndModuleCamelCase do
        subject(:cop) { ClassAndModuleCamelCase.new }

        it 'registers an offence for underscore in class and module name' do
          inspect_source(cop,
                         ['class My_Class',
                          'end',
                          '',
                          'module My_Module',
                          'end',
                         ])
          expect(cop.offences.size).to eq(2)
        end

        it 'is not fooled by qualified names' do
          inspect_source(cop,
                         ['class Top::My_Class',
                          'end',
                          '',
                          'module My_Module::Ala',
                          'end',
                         ])
          expect(cop.offences.size).to eq(2)
        end

        it 'accepts CamelCase names' do
          inspect_source(cop,
                         ['class MyClass',
                          'end',
                          '',
                          'module Mine',
                          'end',
                         ])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
