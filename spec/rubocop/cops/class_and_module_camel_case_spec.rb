# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ClassAndModuleCamelCase do
      let(:camel_case) { ClassAndModuleCamelCase.new }

      it 'registers an offence for underscore in class and module name' do
        inspect_source(camel_case,
                       ['class My_Class',
                        'end',
                        '',
                        'module My_Module',
                        'end',
                       ])
        expect(camel_case.offences.size).to eq(2)
      end

      it 'is not fooled by qualified names' do
        inspect_source(camel_case,
                       ['class Top::My_Class',
                        'end',
                        '',
                        'module My_Module::Ala',
                        'end',
                       ])
        expect(camel_case.offences.size).to eq(2)
      end

      it 'accepts CamelCase names' do
        inspect_source(camel_case,
                       ['class MyClass',
                        'end',
                        '',
                        'module Mine',
                        'end',
                       ])
        expect(camel_case.offences).to be_empty
      end
    end
  end
end
