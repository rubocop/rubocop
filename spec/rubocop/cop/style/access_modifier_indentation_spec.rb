# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::AccessModifierIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    c = cop_config.merge('SupportedStyles' => %w(indent outdent))
    RuboCop::Config
      .new('Style/AccessModifierIndentation' => c,
           'Style/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }

  context 'when EnforcedStyle is set to indent' do
    let(:cop_config) { { 'EnforcedStyle' => 'indent' } }

    it 'registers an offense for misaligned private' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `private`.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'outdent')
    end

    it 'registers an offense for misaligned private in module' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      ' private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Indent access modifiers like `private`.'])
      # Not aligned according to `indent` or `outdent` style:
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for misaligned module_function in module' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      ' module_function',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `module_function`.'])
      # Not aligned according to `indent` or `outdent` style:
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for correct + opposite alignment' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      '  public',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Indent access modifiers like `private`.'])
      # No EnforcedStyle can allow both alignments:
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for opposite + correct alignment' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      'public',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Indent access modifiers like `public`.'])
      # No EnforcedStyle can allow both alignments:
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for misaligned private in singleton class' do
      inspect_source(cop,
                     ['class << self',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `private`.'])
    end

    it 'registers an offense for misaligned private in class ' \
       'defined with Class.new' do
      inspect_source(cop,
                     ['Test = Class.new do',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `private`.'])
    end

    it 'accepts misaligned private in blocks that are not recognized as ' \
       'class/module definitions' do
      inspect_source(cop,
                     ['Test = func do',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for misaligned private in module ' \
       'defined with Module.new' do
      inspect_source(cop,
                     ['Test = Module.new do',
                      '',
                      'private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `private`.'])
    end

    it 'registers an offense for misaligned protected' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `protected`.'])
    end

    it 'accepts properly indented private' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts properly indented protected' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty class' do
      inspect_source(cop,
                     ['class Test',
                      'end'])
      expect(cop.offenses).to be_empty
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
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Indent access modifiers like `private`.'])
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

    context 'when 4 spaces per indent level are used' do
      let(:indentation_width) { 4 }

      it 'accepts properly indented private' do
        inspect_source(cop,
                       ['class Test',
                        '',
                        '    private',
                        '',
                        '    def test; end',
                        'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'when indentation width is overridden for this cop only' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'indent', 'IndentationWidth' => 4 }
      end

      it 'accepts properly indented private' do
        inspect_source(cop,
                       ['class Test',
                        '',
                        '    private',
                        '',
                        '  def test; end',
                        'end'])
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when EnforcedStyle is set to outdent' do
    let(:cop_config) { { 'EnforcedStyle' => 'outdent' } }
    let(:indent_msg) { 'Outdent access modifiers like `private`.' }

    it 'registers offense for private indented to method depth in a class' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indent')
    end

    it 'registers offense for private indented to method depth in a module' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'registers offense for module fn indented to method depth in a module' do
      inspect_source(cop,
                     ['module Test',
                      '',
                      '  module_function',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers offense for private indented to method depth in singleton' \
       'class' do
      inspect_source(cop,
                     ['class << self',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'registers offense for private indented to method depth in class ' \
       'defined with Class.new' do
      inspect_source(cop,
                     ['Test = Class.new do',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([indent_msg])
    end

    it 'registers offense for private indented to method depth in module ' \
       'defined with Module.new' do
      inspect_source(cop,
                     ['Test = Module.new do',
                      '',
                      '  private',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
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
      expect(cop.offenses).to be_empty
    end

    it 'accepts protected indented to the containing class indent level' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      'protected',
                      '',
                      '  def test; end',
                      'end'])
      expect(cop.offenses).to be_empty
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
      expect(cop.offenses.size).to eq(1)
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
