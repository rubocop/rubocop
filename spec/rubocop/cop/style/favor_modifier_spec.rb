# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe FavorModifier do
        describe IfUnlessModifier do
          subject(:if_unless) { IfUnlessModifier.new(config) }
          let(:config) do
            hash = { 'LineLength' => { 'Max' => 79 } }
            Rubocop::Config.new(hash)
          end

          it 'registers an offence for multiline if that fits on one line' do
            # This if statement fits exactly on one line if written as a
            # modifier.
            condition = 'a' * 38
            body = 'b' * 35
            expect("  #{body} if #{condition}".length).to eq(79)

            inspect_source(if_unless,
                           ["  if #{condition}",
                            "    #{body}",
                            '  end'])
            expect(if_unless.messages).to eq(
              ['Favor modifier if/unless usage when you have a single-line' +
               ' body. Another good alternative is the usage of control flow' +
               ' &&/||.'])
          end

          it 'registers an offence for short multiline if near an else etc' do
            inspect_source(if_unless,
                           ['if x',
                            '  y',
                            'elsif x1',
                            '  y1',
                            'else',
                            '  z',
                            'end',
                            'n = a ? 0 : 1',
                            'm = 3 if m0',
                            '',
                            'if a',
                            '  b',
                            'end'])
            expect(if_unless.offences.size).to eq(1)
          end

          it "accepts multiline if that doesn't fit on one line" do
            check_too_long(if_unless, 'if')
          end

          it 'accepts multiline if whose body is more than one line' do
            check_short_multiline(if_unless, 'if')
          end

          it 'registers an offence for multiline unless that fits on one line' do
            inspect_source(if_unless, ['unless a',
                                       '  b',
                                       'end'])
            expect(if_unless.messages).to eq(
              ['Favor modifier if/unless usage when you have a single-line' +
               ' body. Another good alternative is the usage of control flow' +
               ' &&/||.'])
          end

          it 'accepts code with EOL comment since user might want to keep it' do
            inspect_source(if_unless, ['unless a',
                                       '  b # A comment',
                                       'end'])
            expect(if_unless.offences).to be_empty
          end

          it 'accepts if-else-end' do
            inspect_source(if_unless,
                           ['if args.last.is_a? Hash then args.pop else ' +
                            'Hash.new end'])
            expect(if_unless.messages).to be_empty
          end

          it 'accepts an empty condition' do
            check_empty(if_unless, 'if')
            check_empty(if_unless, 'unless')
          end

          it 'accepts if/elsif' do
            inspect_source(if_unless, ['if test',
                                       '  something',
                                       'elsif test2',
                                       '  something_else',
                                       'end'])
            expect(if_unless.offences).to be_empty
          end
        end

        describe WhileUntilModifier do
          subject(:while_until) { WhileUntilModifier.new(config) }
          let(:config) do
            hash = { 'LineLength' => { 'Max' => 79 } }
            Rubocop::Config.new(hash)
          end

          it "accepts multiline unless that doesn't fit on one line" do
            check_too_long(while_until, 'unless')
          end

          it 'accepts multiline unless whose body is more than one line' do
            check_short_multiline(while_until, 'unless')
          end

          it 'registers an offence for multiline while that fits on one line' do
            check_really_short(while_until, 'while')
          end

          it "accepts multiline while that doesn't fit on one line" do
            check_too_long(while_until, 'while')
          end

          it 'accepts multiline while whose body is more than one line' do
            check_short_multiline(while_until, 'while')
          end

          it 'registers an offence for multiline until that fits on one line' do
            check_really_short(while_until, 'until')
          end

          it "accepts multiline until that doesn't fit on one line" do
            check_too_long(while_until, 'until')
          end

          it 'accepts multiline until whose body is more than one line' do
            check_short_multiline(while_until, 'until')
          end

          it 'accepts an empty condition' do
            check_empty(while_until, 'while')
            check_empty(while_until, 'until')
          end

          it 'accepts modifier while' do
            inspect_source(while_until, ['ala while bala'])
            expect(while_until.offences).to be_empty
          end

          it 'accepts modifier until' do
            inspect_source(while_until, ['ala until bala'])
            expect(while_until.offences).to be_empty
          end
        end

        def check_empty(cop, keyword)
          inspect_source(cop, ["#{keyword} cond",
                               'end'])
          expect(cop.offences).to be_empty
        end

        def check_really_short(cop, keyword)
          inspect_source(cop, ["#{keyword} a",
                               '  b',
                               'end'])
          expect(cop.messages).to eq(
            ['Favor modifier while/until usage when you have a single-line ' +
             'body.'])
          expect(cop.offences.map { |o| o.location.source }).to eq([keyword])
        end

        def check_too_long(cop, keyword)
          # This statement is one character too long to fit.
          condition = 'a' * (40 - keyword.length)
          body = 'b' * 36
          expect("  #{body} #{keyword} #{condition}".length).to eq(80)

          inspect_source(cop,
                         ["  #{keyword} #{condition}",
                          "    #{body}",
                          '  end'])

          expect(cop.offences).to be_empty
        end

        def check_short_multiline(cop, keyword)
          inspect_source(cop,
                         ["#{keyword} ENV['COVERAGE']",
                          "  require 'simplecov'",
                          '  SimpleCov.start',
                          'end'])
          expect(cop.messages).to be_empty
        end
      end
    end
  end
end
