# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe VoidOp do
      let(:void_op) { VoidOp.new }

      VoidOp::OPS.each do |op|
        it "registers an offence for void op #{op} if not on last line" do
          inspect_source(void_op,
                         ["a #{op} b",
                          "a #{op} b",
                          "a #{op} b"
                         ])
          expect(void_op.offences.size).to eq(2)
        end
      end

      VoidOp::OPS.each do |op|
        it "accepts void op #{op} if on last line" do
          inspect_source(void_op,
                         ['something',
                          "a #{op} b"
                         ])
          expect(void_op.offences).to be_empty
        end
      end

      VoidOp::OPS.each do |op|
        it "accepts void op #{op} by itself without a begin block" do
          inspect_source(void_op, ["a #{op} b"])
          expect(void_op.offences).to be_empty
        end
      end
    end
  end
end
