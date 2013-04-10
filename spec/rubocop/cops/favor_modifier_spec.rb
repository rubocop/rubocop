# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe FavorModifier do
      let(:if_until) { IfUnlessModifier.new }
      let(:while_until) { WhileUntilModifier.new }

      it 'registers an offence for multiline if that fits on one line' do
        # This if statement fits exactly on one line if written as a modifier.
        inspect_source(if_until, 'file.rb',
                       ['if a_condition_that_is_just_short_enough',
                        '  some_long_metod_name(followed_by_args)',
                        'end'])
        expect(if_until.offences.map(&:message)).to eq(
          ['Favor modifier if/unless usage when you have a single-line body.' +
           ' Another good alternative is the usage of control flow and/or.'])
      end

      it "accepts multiline if that doesn't fit on one line" do
        check_too_long(if_until, 'if')
      end

      it 'accepts multiline if whose body is more than one line' do
        check_short_multiline(if_until, 'if')
      end

      it 'registers an offence for multiline unless that fits on one line' do
        inspect_source(if_until, 'file.rb', ['unless a',
                                        '  b',
                                        'end'])
        expect(if_until.offences.map(&:message)).to eq(
          ['Favor modifier if/unless usage when you have a single-line body.' +
           ' Another good alternative is the usage of control flow and/or.'])
      end

      it 'accepts code with EOL comment since user might want to keep it' do
        inspect_source(if_until, 'file.rb', ['unless a',
                                             '  b # A comment',
                                             'end'])
        expect(if_until.offences.map(&:message)).to be_empty
      end

      it 'accepts if-else-end' do
        inspect_source(if_until, 'file.rb',
                       ['if args.last.is_a? Hash then args.pop else ' +
                        'Hash.new end'])
        expect(if_until.offences.map(&:message)).to be_empty
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

      def check_really_short(cop, keyword)
        inspect_source(cop, 'file.rb', ["#{keyword} a",
                                        '  b',
                                        'end'])
        expect(cop.offences.map(&:message)).to eq(
          ['Favor modifier while/until usage when you have a single-line ' +
           'body.'])
      end

      def check_too_long(cop, keyword)
        inspect_source(cop, 'file.rb',
                       ["  #{keyword} a_lengthy_condition_that_goes_on_and_on",
                        '    some_long_metod_name(followed_by_args)',
                        '  end'])
        expect(cop.offences.map(&:message)).to be_empty
      end

      def check_short_multiline(cop, keyword)
        inspect_source(cop, 'file.rb',
                       ["#{keyword} ENV['COVERAGE']",
                        "  require 'simplecov'",
                        '  SimpleCov.start',
                        'end'])
        expect(cop.offences.map(&:message)).to be_empty
      end
    end
  end
end
