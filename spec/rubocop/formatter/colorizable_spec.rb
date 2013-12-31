# encoding: utf-8

require 'spec_helper'
require 'rubocop/formatter/colorizable'
require 'stringio'

module Rubocop
  module Formatter
    describe Colorizable do
      let(:formatter_class) do
        Class.new(BaseFormatter) do
          include Colorizable
        end
      end

      let(:formatter) do
        formatter_class.new(output)
      end

      let(:output) { double('output') }

      around do |example|
        original_state = Rainbow.enabled

        begin
          example.run
        ensure
          Rainbow.enabled = original_state
        end
      end

      describe '#colorize' do
        subject { formatter.colorize('foo', :red) }

        shared_examples 'does nothing' do
          it 'does nothing' do
            should == 'foo'
          end
        end

        context 'when the global Rainbow.enabled is true' do
          before do
            Rainbow.enabled = true
          end

          context "and the formatter's output is a tty" do
            before do
              allow(output).to receive(:tty?).and_return(true)
            end

            it 'colorize the passed string' do
              should == "\e[31mfoo\e[0m"
            end
          end

          context "and the formatter's output is not a tty" do
            before do
              allow(output).to receive(:tty?).and_return(false)
            end

            include_examples 'does nothing'
          end
        end

        context 'when the global Rainbow.enabled is false' do
          before do
            Rainbow.enabled = false
          end

          context "and the formatter's output is a tty" do
            before do
              allow(output).to receive(:tty?).and_return(true)
            end

            include_examples 'does nothing'
          end

          context "and the formatter's output is not a tty" do
            before do
              allow(output).to receive(:tty?).and_return(false)
            end

            include_examples 'does nothing'
          end
        end
      end

      [
        :black,
        :red,
        :green,
        :yellow,
        :blue,
        :magenta,
        :cyan,
        :white
      ].each do |color|
        describe "##{color}" do
          it "invokes #colorize(string, #{color}" do
            expect(formatter).to receive(:colorize).with('foo', color)
            formatter.send(color, 'foo')
          end
        end
      end
    end
  end
end
