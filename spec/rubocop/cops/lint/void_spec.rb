# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe Void do
        let(:void_op) { Void.new }

        Void::OPS.each do |op|
          it "registers an offence for void op #{op} if not on last line" do
            inspect_source(void_op,
                           ["a #{op} b",
                            "a #{op} b",
                            "a #{op} b"
                           ])
            expect(void_op.offences.size).to eq(2)
          end
        end

        Void::OPS.each do |op|
          it "accepts void op #{op} if on last line" do
            inspect_source(void_op,
                           ['something',
                            "a #{op} b"
                           ])
            expect(void_op.offences).to be_empty
          end
        end

        Void::OPS.each do |op|
          it "accepts void op #{op} by itself without a begin block" do
            inspect_source(void_op, ["a #{op} b"])
            expect(void_op.offences).to be_empty
          end
        end

        %w(var @var @@var VAR).each do |var|
          it "registers an offence for void var #{var} if not on last line" do
            inspect_source(void_op,
                           ["#{var} = 5",
                            "#{var}",
                            'top'
                           ])
            expect(void_op.offences.size).to eq(1)
          end
        end

        %w(1 2.0 /test/ [1] {}).each do |lit|
          it "registers an offence for void lit #{lit} if not on last line" do
            inspect_source(void_op,
                           ["#{lit}",
                            'top'
                           ])
            expect(void_op.offences.size).to eq(1)
          end
        end

      end
    end
  end
end
