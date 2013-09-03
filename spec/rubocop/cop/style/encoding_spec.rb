# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Encoding do
        subject(:encoding) { Encoding.new }

        it 'registers an offence when no encoding present', ruby: 1.9 do
          inspect_source(encoding, ['def foo() end'])

          expect(encoding.messages).to eq(
            ['Missing utf-8 encoding comment.'])
        end

        it 'accepts encoding on first line', ruby: 1.9 do
          inspect_source(encoding, ['# encoding: utf-8',
                                    'def foo() end'])

          expect(encoding.offences).to be_empty
        end

        it 'accepts encoding on second line when shebang present', ruby: 1.9 do
          inspect_source(encoding, ['#!/usr/bin/env ruby',
                                    '# encoding: utf-8',
                                    'def foo() end'])

          expect(encoding.messages).to be_empty
        end

        it 'books an offence when encoding is in the wrong place', ruby: 1.9 do
          inspect_source(encoding, ['def foo() end',
                                    '# encoding: utf-8'])

          expect(encoding.messages).to eq(
            ['Missing utf-8 encoding comment.'])
        end

        it 'does not register an offence on Ruby 2.0', ruby: 2.0 do
          inspect_source(encoding, ['def foo() end'])

          expect(encoding.offences).to be_empty
        end

        it 'accepts encoding inserted by magic_encoding gem', ruby: 1.9 do
          inspect_source(encoding, ['# -*- encoding : utf-8 -*-',
                                    'def foo() end'])

          expect(encoding.messages).to be_empty
        end
      end
    end
  end
end
