# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ClassMethods do
      let(:cm) { ClassMethods.new }

      it 'registers an offence for methods using a class name' do
        inspect_source(cm, 'file.rb',
                       ['class Test',
                        '  def Test.some_method',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cm.offences.size).to eq(1)
      end

      it 'registers an offence for methods using a module name' do
        inspect_source(cm, 'file.rb',
                       ['module Test',
                        '  def Test.some_method',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cm.offences.size).to eq(1)
      end

      it 'does not register an offence for methods using self' do
        inspect_source(cm, 'file.rb',
                       ['module Test',
                        '  def self.some_method',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cm.offences).to be_empty
      end

      it 'does not register an offence outside class/module bodies' do
        inspect_source(cm, 'file.rb',
                       ['def self.some_method',
                        '  do_something',
                        'end'])
        expect(cm.offences).to be_empty
      end
    end
  end
end
