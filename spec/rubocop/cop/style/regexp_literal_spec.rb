# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RegexpLiteral, :config do
  subject(:cop) { described_class.new(config) }

  before { described_class.slash_count = nil }

  context 'when MaxSlashes is -1' do
    let(:cop_config) { { 'MaxSlashes' => -1 } }

    it 'fails' do
      expect { inspect_source(cop, 'x =~ /home/') }
        .to raise_error(RuntimeError)
    end
  end

  context 'when MaxSlashes is 0' do
    let(:cop_config) { { 'MaxSlashes' => 0 } }

    it 'registers an offense for one slash in // regexp' do
      inspect_source(cop, 'x =~ /home\//')
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 0 '/' characters."])
    end

    it 'accepts zero slashes in // regexp' do
      inspect_source(cop, 'z =~ /a/')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for zero slashes in %r regexp' do
      inspect_source(cop, 'y =~ %r(etc)')
      expect(cop.messages)
        .to eq(['Use %r only for regular expressions matching more ' \
                "than 0 '/' characters."])
    end

    it 'accepts %r regexp with one slash' do
      inspect_source(cop, 'x =~ %r(/home)')
      expect(cop.offenses).to be_empty
    end

    describe '--auto-gen-config' do
      subject(:cop) { described_class.new(config, auto_gen_config: true) }

      it 'sets MaxSlashes: 1 for one slash in // regexp' do
        inspect_source(cop, 'x =~ /home\//')
        expect(cop.config_to_allow_offenses).to eq('MaxSlashes' => 1)
      end

      it 'disables the cop for zero slashes in %r regexp' do
        inspect_source(cop, 'y =~ %r(etc)')
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'generates nothing if there are no offenses' do
        inspect_source(cop, 'x =~ %r(/home)')
        expect(cop.config_to_allow_offenses).to eq(nil)
      end
    end
  end

  context 'when MaxSlashes is 1' do
    let(:cop_config) { { 'MaxSlashes' => 1 } }

    it 'registers an offense for two slashes in // regexp' do
      inspect_source(cop, ['x =~ /home\/\//',
                           'y =~ /etc\/top\//'])
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 1 '/' character."] * 2)
    end

    it 'registers offenses for slashes with too many' do
      inspect_source(cop, 'x =~ /home\/\/\//')
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 1 '/' character."])
    end

    it 'registers offenses for %r with too few' do
      inspect_source(cop, ['x =~ /home\/\/\//',
                           'y =~ %r{home}'])
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 1 '/' character.",
                'Use %r only for regular expressions matching more ' \
                "than 1 '/' character."])
    end

    it 'accepts zero or one slash in // regexp' do
      inspect_source(cop, ['x =~ /\/home/',
                           'y =~ /\//',
                           'w =~ /\//m',
                           'z =~ /a/'])
      expect(cop.offenses).to be_empty
    end

    it 'ignores slashes do not belong // regexp' do
      inspect_source(cop, 'x =~ /\s{#{x[/\s+/].length}}/')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for zero or one slash in %r regexp' do
      inspect_source(cop, ['x =~ %r(/home)',
                           'y =~ %r(etc)'])
      expect(cop.messages)
        .to eq(['Use %r only for regular expressions matching more ' \
                "than 1 '/' character."] * 2)
    end

    it 'accepts %r regexp with two or more slashes' do
      inspect_source(cop, ['x =~ %r(/home/)',
                           'y =~ %r(/////)'])
      expect(cop.offenses).to be_empty
    end

    describe '--auto-gen-config' do
      subject(:cop) { described_class.new(config, auto_gen_config: true) }

      it 'sets MaxSlashes: 2 for two slashes in // and 3 in %r' do
        inspect_source(cop, ['x =~ /home\/\//',
                             'y =~ %r{/usr/lib/ext}'])
        expect(cop.config_to_allow_offenses).to eq('MaxSlashes' => 2)
      end

      it 'sets MaxSlashes: 0 for one slash in %r regexp' do
        inspect_source(cop, 'x =~ %r{/home}')
        expect(cop.config_to_allow_offenses).to eq('MaxSlashes' => 0)
      end

      it 'disables the cop for zero or one slash in %r regexp' do
        inspect_source(cop, ['x =~ %r(/home)',
                             'y =~ %r(etc)'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'disables the cop for // with too many and %r with too few' do
        inspect_source(cop, ['x =~ /home\/\/\//',
                             'y =~ %r{home}'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'disables the cop for %r with too few and // with too many' do
        inspect_source(cop, ['y =~ %r{home}',
                             'x =~ /home\/\//'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      context 'when Enabled has been set to false' do
        before do
          inspect_source(cop, ['x =~ /home\/\/\//',
                               'y =~ %r{/home/}'])
        end

        it 'does not change it' do
          inspect_source(cop, 'x =~ %r{/home}')
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end
      end
    end

    context 'when --auto-gen-config is not given' do
      subject(:cop) { described_class.new(config) }

      it 'does not set MaxSlashes' do
        inspect_source(cop, ['x =~ /home\/\//',
                             'y =~ %r{/usr/lib/ext}'])
        expect(cop.config_to_allow_offenses).to eq(nil)
      end
    end
  end

  context 'across multiple files (instances)' do
    let(:cop_config) { { 'MaxSlashes' => 0 } }

    it 'preserves slash count for --auto-gen-config' do
      2.times do |i|
        cop = described_class.new(config, auto_gen_config: true)
        inspect_source(cop, "/http:#{'\/' * (i + 1)}/")
      end
      expect(described_class.slash_count['/']).to eq(Set.new([0, 1, 2]))
    end
  end
end
