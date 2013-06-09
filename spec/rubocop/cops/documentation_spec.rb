# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Documentation, broken: true do
      let(:documentation) { Documentation.new }

      it 'registers an offence for non-empty class' do
        inspect_source(documentation,
                       ['class My_Class',
                        '  TEST = 20',
                        'end'
                       ])
        expect(documentation.offences.size).to eq(1)
      end

      it 'registers an offence for non-namespace' do
        inspect_source(documentation,
                       ['module My_Class',
                        '  TEST = 20',
                        'end'
                       ])
        expect(documentation.offences.size).to eq(1)
      end

      it 'accepts non-empty class with documentation' do
        inspect_source(documentation,
                       ['# class comment',
                        'class My_Class',
                        '  TEST = 20',
                        'end'
                       ])
        expect(documentation.offences).to be_empty
      end

      it 'accepts non-empty module with documentation' do
        inspect_source(documentation,
                       ['# class comment',
                        'module My_Class',
                        '  TEST = 20',
                        'end'
                       ])
        expect(documentation.offences).to be_empty
      end

      it 'accepts empty class without documentation' do
        inspect_source(documentation,
                       ['class My_Class',
                        'end'
                       ])
        expect(documentation.offences).to be_empty
      end

      it 'accepts namespace module without documentation' do
        inspect_source(documentation,
                       ['module Test',
                        '  class A; end',
                        '  class B; end',
                        'end'
                       ])
        expect(documentation.offences).to be_empty
      end
    end
  end
end
