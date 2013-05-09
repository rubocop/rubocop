# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceInsideHashLiteralBraces do
      let(:sihlb) { SpaceInsideHashLiteralBraces.new }
      before do
        SpaceInsideHashLiteralBraces.config = {
          'EnforcedStyleIsWithSpaces' => true
        }
      end

      it 'registers an offence for hashes with no spaces by default' do
        inspect_source(sihlb, '',
                       ['h = {a: 1, b: 2}',
                        'h = {a => 1 }'])
        expect(sihlb.offences.map(&:message)).to eq(
          ['Space inside hash literal braces missing.'] * 3)
      end

      it 'registers an offence for hashes with no spaces if so configured' do
        inspect_source(sihlb, '',
                       ['h = {a: 1, b: 2}',
                        'h = {a => 1 }'])
        expect(sihlb.offences.map(&:message)).to eq(
          ['Space inside hash literal braces missing.'] * 3)
      end

      it 'registers an offence for hashes with spaces if so configured' do
        SpaceInsideHashLiteralBraces.config['EnforcedStyleIsWithSpaces'] =
          false
        inspect_source(sihlb, '',
                       ['h = { a: 1, b: 2 }'])
        expect(sihlb.offences.map(&:message)).to eq(
          ['Space inside hash literal braces detected.'] * 2)
      end

      it 'accepts hashes with spaces by default' do
        inspect_source(sihlb, '',
                       ['h = { a: 1, b: 2 }',
                        'h = { a => 1 }'])
        expect(sihlb.offences.map(&:message)).to be_empty
      end

      it 'accepts hashes with no spaces if so configured' do
        SpaceInsideHashLiteralBraces.config['EnforcedStyleIsWithSpaces'] =
          false
        inspect_source(sihlb, '',
                       ['h = {a: 1, b: 2}',
                        'h = {a => 1}'])
        expect(sihlb.offences.map(&:message)).to be_empty
      end

      it 'accepts empty hashes without spaces by default' do
        inspect_source(sihlb, '', ['h = {}'])
        expect(sihlb.offences).to be_empty
      end

      it 'accepts empty hashes without spaces if configured false' do
        SpaceInsideHashLiteralBraces.config['EnforcedStyleIsWithSpaces'] =
          false
        inspect_source(sihlb, '', ['h = {}'])
        expect(sihlb.offences).to be_empty
      end

      it 'accepts empty hashes without spaces even if configured true' do
        inspect_source(sihlb, '', ['h = {}'])
        expect(sihlb.offences).to be_empty
      end
    end
  end
end
