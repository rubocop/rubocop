# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AccessModifierIndentation, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is set to indent' do
    let(:cop_config) { { 'EnforcedStyle' => 'indent' } }

    it 'registers an offence for misaligned private' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like private.'])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'outdent')
    end

    it 'registers an offence for misaligned private in module' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      ' private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq(['Indent access modifiers like private.'])
      # Not aligned according to `indent` or `outdent` style:
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'registers an offence for correct + opposite alignment' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      '  public',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq(['Indent access modifiers like private.'])
      # No EnforcedStyle can allow both aligments:
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'registers an offence for opposite + correct alignment' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      'public',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq(['Indent access modifiers like public.'])
      # No EnforcedStyle can allow both aligments:
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'registers an offence for misaligned private in singleton class' do
      inspect_source(cop,
                     ['class << self',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like private.'])
    end

    it 'registers an offence for misaligned private in class ' \
       'defined with Class.new' do
      inspect_source(cop,
                     ['Test = Class.new do',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like private.'])
    end

    it 'registers an offence for misaligned private in module ' \
       'defined with Module.new' do
      inspect_source(cop,
                     ['Test = Module.new do',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like private.'])
    end

    it 'registers an offence for misaligned protected' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like protected.'])
    end

    it 'accepts properly indented private' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts properly indented protected' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an empty class' do
      inspect_source(cop,
                     ['class Test',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'handles properly nested classes' do
      inspect_source(cop,
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
      expect(cop.offences.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like private.'])
    end

    it 'auto-corrects incorrectly indented access modifiers' do
      corrected = autocorrect_source(cop, ['class Test',
                                           '',
                                           'public',
                                           ' private',
                                           '   protected',
                                           '',
                                           '  def test; end',
                                           'end'])
      expect(corrected).to eq(['class Test',
                               '',
                               '  public',
                               '  private',
                               '  protected',
                               '',
                               '  def test; end',
                               'end'].join("\n"))
    end
  end

  context 'when EnforcedStyle is set to outdent' do
    let(:cop_config) { { 'EnforcedStyle' => 'outdent' } }
    let(:indent_msg) { 'Outdent access modifiers like private.' }

    it 'registers offence for private indented to method depth in a class' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'indent')
    end

    it 'registers offence for private indented to method depth in a module' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'registers offence for private indented to method depth in singleton' \
       'class' do
      inspect_source(cop,
                     ['class << self',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'registers offence for private indented to method depth in class ' \
       'defined with Class.new' do
      inspect_source(cop,
                     ['Test = Class.new do',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'registers offence for private indented to method depth in module ' \
       'defined with Module.new' do
      inspect_source(cop,
                     ['Test = Module.new do',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'accepts private indented to the containing class indent level' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts protected indented to the containing class indent level' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'handles properly nested classes' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  class Nested',
                      '',
                      '    private',
                      '',
                      '    def a; end',
                      '  end',
                      '',
                      'protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'auto-corrects incorrectly indented access modifiers' do
      corrected = autocorrect_source(cop, ['module M',
                                           '  class Test',
                                           '',
                                           'public',
                                           ' private',
                                           '     protected',
                                           '',
                                           '    def test; end',
                                           '  end',
                                           'end'])
      expect(corrected).to eq(['module M',
                               '  class Test',
                               '',
                               '  public',
                               '  private',
                               '  protected',
                               '',
                               '    def test; end',
                               '  end',
                               'end'].join("\n"))
    end

    it 'auto-corrects private in complicated case' do
      corrected = autocorrect_source(cop, ['class Hello',
                                           '  def foo',
                                           "    'hi'",
                                           '  end',
                                           '',
                                           '  def bar',
                                           '    Module.new do',
                                           '',
                                           '     private',
                                           '',
                                           '      def hi',
                                           "        'bye'",
                                           '      end',
                                           '    end',
                                           '  end',
                                           'end'])
      expect(corrected).to eq(['class Hello',
                               '  def foo',
                               "    'hi'",
                               '  end',
                               '',
                               '  def bar',
                               '    Module.new do',
                               '',
                               '    private',
                               '',
                               '      def hi',
                               "        'bye'",
                               '      end',
                               '    end',
                               '  end',
                               'end'].join("\n"))
    end
  end
end
