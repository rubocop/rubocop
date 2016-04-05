# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::RaiseArgs, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    context 'with a raise with 2 args' do
      it 'reports an offense' do
        inspect_source(cop, 'raise RuntimeError, msg')
        expect(cop.offenses.size).to eq(1)
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'exploded')
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source(cop, 'raise RuntimeError, msg')
        expect(new_source).to eq('raise RuntimeError.new(msg)')
      end
    end

    context 'with correct + opposite' do
      it 'reports an offense' do
        inspect_source(cop, ['if a',
                             '  raise RuntimeError, msg',
                             'else',
                             '  raise Ex.new(msg)',
                             'end'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Provide an exception object as an argument to `raise`.'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source(cop, ['if a',
                                              '  raise RuntimeError, msg',
                                              'else',
                                              '  raise Ex.new(msg)',
                                              'end'])
        expect(new_source).to eq(['if a',
                                  '  raise RuntimeError.new(msg)',
                                  'else',
                                  '  raise Ex.new(msg)',
                                  'end'].join("\n"))
      end
    end

    context 'with a raise with 3 args' do
      it 'reports an offense' do
        inspect_source(cop, 'raise RuntimeError, msg, caller')
        expect(cop.offenses.size).to eq(1)
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source(cop,
                                        ['raise RuntimeError, msg, caller'])
        expect(new_source).to eq('raise RuntimeError.new(msg, caller)')
      end
    end

    it 'accepts a raise with msg argument' do
      inspect_source(cop, 'raise msg')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a raise with an exception argument' do
      inspect_source(cop, 'raise Ex.new(msg)')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when enforced style is exploded' do
    let(:cop_config) { { 'EnforcedStyle' => 'exploded' } }

    context 'with a raise with exception object' do
      it 'reports an offense' do
        inspect_source(cop, 'raise Ex.new(msg)')
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Provide an exception class and message ' \
                  'as arguments to `raise`.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'compact')
      end

      it 'auto-corrects to exploded style' do
        new_source = autocorrect_source(cop, ['raise Ex.new(msg)'])
        expect(new_source).to eq('raise Ex, msg')
      end
    end

    context 'with opposite + correct' do
      it 'reports an offense for opposite + correct' do
        inspect_source(cop, ['if a',
                             '  raise RuntimeError, msg',
                             'else',
                             '  raise Ex.new(msg)',
                             'end'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'auto-corrects to exploded style' do
        new_source = autocorrect_source(cop, ['if a',
                                              '  raise RuntimeError, msg',
                                              'else',
                                              '  raise Ex.new(msg)',
                                              'end'])
        expect(new_source).to eq(['if a',
                                  '  raise RuntimeError, msg',
                                  'else',
                                  '  raise Ex, msg',
                                  'end'].join("\n"))
      end
    end

    it 'accepts exception constructor with more than 1 argument' do
      inspect_source(cop, 'raise RuntimeError.new(a1, a2, a3)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a raise with 3 args' do
      inspect_source(cop, 'raise RuntimeError, msg, caller')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a raise with 2 args' do
      inspect_source(cop, 'raise RuntimeError, msg')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a raise with msg argument' do
      inspect_source(cop, 'raise msg')
      expect(cop.offenses).to be_empty
    end
  end
end
