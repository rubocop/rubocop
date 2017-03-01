# frozen_string_literal: true

describe RuboCop::Cop::Style::Alias, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is prefer_alias_method' do
    let(:cop_config) { { 'EnforcedStyle' => 'prefer_alias_method' } }

    it 'registers an offense for alias with symbol args' do
      inspect_source(cop, 'alias :ala :bala')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `alias_method` instead of `alias`.'])
    end

    it 'autocorrects alias with symbol args' do
      corrected = autocorrect_source(cop, 'alias :ala :bala')
      expect(corrected).to eq 'alias_method :ala, :bala'
    end

    it 'registers an offense for alias with bareword args' do
      inspect_source(cop, 'alias ala bala')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `alias_method` instead of `alias`.'])
    end

    it 'autocorrects alias with bareword args' do
      corrected = autocorrect_source(cop, 'alias ala bala')
      expect(corrected).to eq 'alias_method :ala, :bala'
    end

    it 'does not register an offense for alias_method' do
      inspect_source(cop, 'alias_method :ala, :bala')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for alias with gvars' do
      inspect_source(cop, 'alias $ala $bala')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for alias in an instance_eval block' do
      inspect_source(cop, ['module M',
                           '  def foo',
                           '    instance_eval {',
                           '      alias bar baz',
                           '    }',
                           '  end',
                           'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is prefer_alias' do
    let(:cop_config) { { 'EnforcedStyle' => 'prefer_alias' } }

    it 'registers an offense for alias with symbol args' do
      inspect_source(cop, 'alias :ala :bala')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `alias ala bala` instead of `alias :ala :bala`.'])
    end

    it 'autocorrects alias with symbol args' do
      corrected = autocorrect_source(cop, ['alias :ala :bala'])
      expect(corrected).to eq 'alias ala bala'
    end

    it 'does not register an offense for alias with bareword args' do
      inspect_source(cop, 'alias ala bala')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for alias_method at the top level' do
      inspect_source(cop, 'alias_method :ala, :bala')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `alias` instead of `alias_method` at the top level.'])
    end

    it 'autocorrects alias_method at the top level' do
      corrected = autocorrect_source(cop, 'alias_method :ala, :bala')
      expect(corrected).to eq 'alias ala bala'
    end

    it 'registers an offense for alias_method in a class block' do
      inspect_source(cop, ['class C',
                           '  alias_method :ala, :bala',
                           'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `alias` instead of `alias_method` in a class body.'])
    end

    it 'autocorrects alias_method in a class block' do
      corrected = autocorrect_source(cop, ['class C',
                                           '  alias_method :ala, :bala',
                                           'end'])
      expect(corrected).to eq(['class C',
                               '  alias ala bala',
                               'end'].join("\n"))
    end

    it 'registers an offense for alias_method in a module block' do
      inspect_source(cop, ['module M',
                           '  alias_method :ala, :bala',
                           'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `alias` instead of `alias_method` in a module body.'])
    end

    it 'autocorrects alias_method in a module block' do
      corrected = autocorrect_source(cop, ['module M',
                                           '  alias_method :ala, :bala',
                                           'end'])
      expect(corrected).to eq(['module M',
                               '  alias ala bala',
                               'end'].join("\n"))
    end

    it 'does not register an offense for alias_method with explicit receiver' do
      inspect_source(cop, ['class C',
                           '  receiver.alias_method :ala, :bala',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for alias_method in a method def' do
      inspect_source(cop, ['def method',
                           '  alias_method :ala, :bala',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for alias_method in self.method def' do
      inspect_source(cop, ['def self.method',
                           '  alias_method :ala, :bala',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for alias_method in a block' do
      inspect_source(cop, ['dsl_method do',
                           '  alias_method :ala, :bala',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for alias in an instance_eval block' do
      inspect_source(cop, ['module M',
                           '  def foo',
                           '    instance_eval {',
                           '      alias bar baz',
                           '    }',
                           '  end',
                           'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
