# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AccessControl do
        let(:a) { AccessControl.new }

        it 'registers an offence for misaligned private' do
          inspect_source(a,
                         ['class Test',
                           '',
                           'private',
                           '',
                           '  def test; end',
                           'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'private')])
        end

        it 'registers an offence for misaligned private in module' do
          inspect_source(a,
                         ['module Test',
                          '',
                          'private',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'private')])
        end

        it 'registers an offence for misaligned private in singleton class' do
          inspect_source(a,
                         ['class << self',
                           '',
                           'private',
                           '',
                           '  def test; end',
                           'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'private')])
        end

        it 'registers an offence for misaligned private in class ' +
           'defined with Class.new' do
          inspect_source(a,
                         ['Test = Class.new do',
                          '',
                          'private',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'private')])
        end

        it 'registers an offence for misaligned private in module ' +
           'defined with Module.new' do
          inspect_source(a,
                         ['Test = Module.new do',
                          '',
                          'private',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'private')])
        end

        it 'registers an offence for misaligned protected' do
          inspect_source(a,
                         ['class Test',
                          '',
                          'protected',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'protected')])
        end

        it 'accepts properly indented private' do
          inspect_source(a,
                         ['class Test',
                          '',
                          '  private',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences).to be_empty
        end

        it 'accepts properly indented protected' do
          inspect_source(a,
                         ['class Test',
                          '',
                          '  protected',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences).to be_empty
        end

        it 'handles properly nested classes' do
          inspect_source(a,
                         ['class Test',
                          '',
                          '  class Nested',
                          '',
                          '  private',
                          '',
                          '    def a; end',
                          '  end',
                          '',
                          '  protected',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::INDENT_MSG, 'private')])
        end

        it 'requires blank line before private/protected' do
          inspect_source(a,
                         ['class Test',
                          '  protected',
                          '',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::BLANK_MSG, 'protected')])
        end

        it 'requires blank line after private/protected' do
          inspect_source(a,
                         ['class Test',
                          '',
                          '  protected',
                          '  def test; end',
                          'end'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([format(AccessControl::BLANK_MSG, 'protected')])
        end

        it 'recognizes blank lines with DOS style line endings' do
          inspect_source(a,
                         ["class Test\r",
                          "\r",
                          "  protected\r",
                          "\r",
                          "  def test; end\r",
                          "end\r"])
          expect(a.offences.size).to eq(0)
        end
      end
    end
  end
end
