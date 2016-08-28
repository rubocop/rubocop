# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::ShadowedException do
  subject(:cop) { described_class.new }

  context 'modifier rescue' do
    it 'accepts rescue in its modifier form' do
      inspect_source(cop, 'foo rescue nil')

      expect(cop.offenses).to be_empty
    end
  end

  context 'single rescue' do
    it 'accepts an empty rescue' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a single exception' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a single custom exception' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NonStandardException',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a custom exception and a standard exception' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Error, NonStandardException',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing multiple custom exceptions' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue CustomError, NonStandardException',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense rescuing Exception with any other error or ' \
       'exception' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NonStandardError, Exception',
                           '  handle_exception',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
    end

    it 'accepts rescuing a single exception that is assigned to a variable' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception => e',
                           '  handle_exception(e)',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a single exception that has an ensure' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception',
                           '  handle_exception',
                           'ensure',
                           '  everything_is_ok',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a single exception that has an else' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception',
                           '  handle_exception',
                           'else',
                           '  handle_non_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a multiple exceptions that are not ancestors that ' \
       'have an else' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NoMethodError, ZeroDivisionError',
                           '  handle_exception',
                           'else',
                           '  handle_non_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    context 'when there are multiple levels of exceptions in the same rescue' do
      it 'registers an offense for two exceptions' do
        inspect_source(cop, ['begin',
                             '  something',
                             'rescue StandardError, NameError',
                             '  foo',
                             'end'])

        expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
        expect(cop.highlights).to eq(['rescue StandardError, NameError'])
      end

      it 'registers an offense for more than two exceptions' do
        inspect_source(cop, ['begin',
                             '  something',
                             'rescue StandardError, NameError, NoMethodError',
                             '  foo',
                             'end'])

        expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
        expect(cop.highlights)
          .to eq(['rescue StandardError, NameError, NoMethodError'])
      end
    end

    it 'registers an offense for the same exception multiple times' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NameError, NameError',
                           '  foo',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
      expect(cop.highlights)
        .to eq(['rescue NameError, NameError'])
    end

    it 'accepts splat arguments passed to rescue' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue *FOO',
                           '  b',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing nil' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue nil',
                           '  b',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing nil and another exception' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue nil, Exception',
                           '  b',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense when rescuing nil multiple exceptions of ' \
       'different levels' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue nil, StandardError, Exception',
                           '  b',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
      expect(cop.highlights).to eq(['rescue nil, StandardError, Exception'])
    end
  end

  context 'multiple rescues' do
    it 'registers an offense when a higher level exception is rescued before' \
       ' a lower level exception' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception',
                           '  handle_exception',
                           'rescue StandardError',
                           '  handle_standard_error',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
      expect(cop.highlights).to eq([['rescue Exception',
                                     '  handle_exception',
                                     'rescue StandardError'].join("\n")])
    end

    it 'registers an offense when a higher level exception is rescued before ' \
       'a lower level exception when there are multiple exceptions ' \
       'rescued in a group' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception',
                           '  handle_exception',
                           'rescue NoMethodError, ZeroDivisionError',
                           '  handle_standard_error',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
      expect(cop.highlights).to eq([['rescue Exception',
                                     '  handle_exception',
                                     'rescue NoMethodError, ZeroDivisionError']
                                     .join("\n")])
    end

    it 'registers an offense rescuing out of order exceptions when there ' \
       'is an ensure' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue Exception',
                           '  handle_exception',
                           'rescue StandardError',
                           '  handle_standard_error',
                           'ensure',
                           '  everything_is_ok',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
      expect(cop.highlights).to eq([['rescue Exception',
                                     '  handle_exception',
                                     'rescue StandardError'].join("\n")])
    end

    it 'accepts rescuing exceptions in order of level' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue StandardError',
                           '  handle_standard_error',
                           'rescue Exception',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts many (>= 7) rescue groups' do
      ErrorA = Class.new(RuntimeError)
      ErrorB = Class.new(RuntimeError)
      ErrorC = Class.new(RuntimeError)
      ErrorD = Class.new(RuntimeError)
      ErrorE = Class.new(RuntimeError)
      ErrorF = Class.new(RuntimeError)
      ErrorG = Class.new(RuntimeError)
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue ErrorA',
                           '  handle_error',
                           'rescue ErrorB',
                           '  handle_error',
                           'rescue ErrorC',
                           '  handle_error',
                           'rescue ErrorD',
                           '  handle_error',
                           'rescue ErrorE',
                           '  handle_error',
                           'rescue ErrorF',
                           '  handle_error',
                           'rescue ErrorG',
                           '  handle_error',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing exceptions in order of level with multiple ' \
       'exceptions in a group' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NoMethodError, ZeroDivisionError',
                           '  handle_standard_error',
                           'rescue Exception',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing exceptions in order of level with multiple ' \
       'exceptions in a group with custom exceptions' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NonStandardError, NoMethodError',
                           '  handle_standard_error',
                           'rescue Exception',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing custom exceptions in multiple rescue groups' do
      inspect_source(cop, ['begin',
                           '  something',
                           'rescue NonStandardError, OtherError',
                           '  handle_standard_error',
                           'rescue CustomError',
                           '  handle_exception',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    context 'splat arguments' do
      it 'accepts splat arguments passed to multiple rescues' do
        inspect_source(cop, ['begin',
                             '  a',
                             'rescue *FOO',
                             '  b',
                             'rescue *BAR',
                             '  c',
                             'end'])

        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for splat arguments rescued after ' \
         'rescuing a known exception' do
        inspect_source(cop, ['begin',
                             '  a',
                             'rescue StandardError',
                             '  b',
                             'rescue *BAR',
                             '  c',
                             'end'])

        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for splat arguments rescued after ' \
         'rescuing Exception' do
        inspect_source(cop, ['begin',
                             '  a',
                             'rescue Exception',
                             '  b',
                             'rescue *BAR',
                             '  c',
                             'end'])

        expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
        expect(cop.highlights).to eq([['rescue Exception',
                                       '  b',
                                       'rescue *BAR'].join("\n")])
      end
    end

    context 'exceptions from different ancestry chains' do
      it 'accepts rescuing exceptions in one order' do
        inspect_source(cop, ['begin',
                             '  a',
                             'rescue ArgumentError',
                             '  b',
                             'rescue Interrupt',
                             '  c',
                             'end'])

        expect(cop.offenses).to be_empty
      end

      it 'accepts rescuing exceptions in another order' do
        inspect_source(cop, ['begin',
                             '  a',
                             'rescue Interrupt',
                             '  b',
                             'rescue ArgumentError',
                             '  c',
                             'end'])

        expect(cop.offenses).to be_empty
      end
    end

    it 'accepts rescuing nil before another exception' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue nil',
                           '  b',
                           'rescue',
                           '  c',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing nil after another exception' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue',
                           '  b',
                           'rescue nil',
                           '  c',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a known exception after an unknown exceptions' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue UnknownException',
                           '  b',
                           'rescue StandardError',
                           '  c',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a known exception before an unknown exceptions' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue StandardError',
                           '  b',
                           'rescue UnknownException',
                           '  c',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts rescuing a known exception between unknown exceptions' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue UnknownException',
                           '  b',
                           'rescue StandardError',
                           '  c',
                           'rescue AnotherUnknownException',
                           '  d',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense rescuing Exception before an unknown exceptions' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue Exception',
                           '  b',
                           'rescue UnknownException',
                           '  c',
                           'end'])

      expect(cop.messages).to eq(['Do not shadow rescued Exceptions'])
      expect(cop.highlights).to eq([['rescue Exception',
                                     '  b',
                                     'rescue UnknownException'].join("\n")])
    end

    it 'ignores expressions of non-const' do
      inspect_source(cop, ['begin',
                           '  a',
                           'rescue foo',
                           '  b',
                           'rescue [bar]',
                           '  c',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    context 'last rescue does not specify exception class' do
      let(:source) do
        ['begin',
         'rescue A, B',
         '  do_something',
         'rescue C',
         '  do_something',
         'rescue',
         '  do_something',
         'end']
      end

      it 'does not raise error' do
        expect { inspect_source(cop, source) }.not_to raise_error
      end

      it 'highlights range ending at rescue keyword' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end
end
