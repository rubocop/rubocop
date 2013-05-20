# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AccessControl do
      let(:a) { AccessControl.new }

      it 'registers an offence for misaligned private' do
        inspect_source(a,
                       'file.rb',
                       ['class Test',
                         '',
                         'private',
                         '',
                         '  def test; end',
                         'end'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([AccessControl::INDENT_MSG])
      end

      it 'registers an offence for misaligned private in module' do
        inspect_source(a,
                       'file.rb',
                       ['module Test',
                        '',
                        'private',
                        '',
                        '  def test; end',
                        'end'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([AccessControl::INDENT_MSG])
      end

      it 'registers an offence for misaligned private in singleton class' do
        inspect_source(a,
                       'file.rb',
                       ['class << self',
                         '',
                         'private',
                         '',
                         '  def test; end',
                         'end'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([AccessControl::INDENT_MSG])
      end

      it 'registers an offence for misaligned protected' do
        inspect_source(a,
                       'file.rb',
                       ['class Test',
                        '',
                        'protected',
                        '',
                        '  def test; end',
                        'end'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([AccessControl::INDENT_MSG])
      end

      it 'accepts properly indented private' do
        inspect_source(a,
                       'file.rb',
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
                       'file.rb',
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
                       'file.rb',
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
        expect(a.offences.map(&:message))
          .to eq([AccessControl::INDENT_MSG])
      end

      it 'requires blank line before private/protected' do
        inspect_source(a,
                       'file.rb',
                       ['class Test',
                        '  protected',
                        '',
                        '  def test; end',
                        'end'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([AccessControl::BLANK_MSG])
      end

      it 'requires blank line after private/protected' do
        inspect_source(a,
                       'file.rb',
                       ['class Test',
                        '',
                        '  protected',
                        '  def test; end',
                        'end'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([AccessControl::BLANK_MSG])
      end
    end
  end
end
