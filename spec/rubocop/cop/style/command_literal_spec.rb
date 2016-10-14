# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::CommandLiteral, :config do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w[backticks percent_x mixed]
    }
    RuboCop::Config.new('Style/PercentLiteralDelimiters' =>
                          percent_literal_delimiters_config,
                        'Style/CommandLiteral' =>
                          cop_config.merge(supported_styles))
  end
  let(:percent_literal_delimiters_config) do
    { 'PreferredDelimiters' => { '%x' => '()' } }
  end

  describe '%x commands with other delimiters than parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'backticks' } }

    it 'registers an offense' do
      inspect_source(cop, '%x$ls$')
      expect(cop.messages).to eq(['Use backticks around command string.'])
    end
  end

  describe 'when PercentLiteralDelimiters is configured with curly braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_x' } }
    let(:percent_literal_delimiters_config) do
      { 'PreferredDelimiters' => { '%x' => '[]' } }
    end

    it 'respects the configuration when auto-correcting' do
      new_source = autocorrect_source(cop, '`ls`')
      expect(new_source).to eq('%x[ls]')
    end
  end

  describe 'heredoc commands' do
    let(:cop_config) { { 'EnforcedStyle' => 'backticks' } }

    it 'is ignored' do
      inspect_source(cop, ['<<`COMMAND`',
                           '  ls',
                           'COMMAND'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is set to backticks' do
    let(:cop_config) { { 'EnforcedStyle' => 'backticks' } }

    describe 'a single-line ` string without backticks' do
      let(:source) { 'foo = `ls`' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a single-line ` string with backticks' do
      let(:source) { 'foo = `echo \`ls\``' }

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'is accepted' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    describe 'a multi-line ` string without backticks' do
      let(:source) do
        ['foo = `',
         '  ls',
         '  ls -l',
         '`']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line ` string with backticks' do
      let(:source) do
        ['foo = `',
         '  echo \`ls\`',
         '  echo \`ls -l\`',
         '`']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source.join("\n"))
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'is accepted' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    describe 'a single-line %x string without backticks' do
      let(:source) { 'foo = %x(ls)' }

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use backticks around command string.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq('foo = `ls`')
      end
    end

    describe 'a single-line %x string with backticks' do
      let(:source) { 'foo = %x(echo `ls`)' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Use backticks around command string.'])
        end

        it 'cannot auto-correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source)
        end
      end
    end

    describe 'a multi-line %x string without backticks' do
      let(:source) do
        ['foo = %x(',
         '  ls',
         '  ls -l',
         ')']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use backticks around command string.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("foo = `\n  ls\n  ls -l\n`")
      end
    end

    describe 'a multi-line %x string with backticks' do
      let(:source) do
        ['foo = %x(',
         '  echo `ls`',
         '  echo `ls -l`',
         ')']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Use backticks around command string.'])
        end

        it 'cannot auto-correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source.join("\n"))
        end
      end
    end
  end

  context 'when EnforcedStyle is set to percent_x' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_x' } }

    describe 'a single-line ` string without backticks' do
      let(:source) { 'foo = `ls`' }

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq('foo = %x(ls)')
      end
    end

    describe 'a single-line ` string with backticks' do
      let(:source) { 'foo = `echo \`ls\``' }

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end
    end

    describe 'a multi-line ` string without backticks' do
      let(:source) do
        ['foo = `',
         '  ls',
         '  ls -l',
         '`']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("foo = %x(\n  ls\n  ls -l\n)")
      end
    end

    describe 'a multi-line ` string with backticks' do
      let(:source) do
        ['foo = `',
         '  echo \`ls\`',
         '  echo \`ls -l\`',
         '`']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source.join("\n"))
      end
    end

    describe 'a single-line %x string without backticks' do
      let(:source) { 'foo = %x(ls)' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a single-line %x string with backticks' do
      let(:source) { 'foo = %x(echo `ls`)' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line %x string without backticks' do
      let(:source) do
        ['foo = %x(',
         '  ls',
         '  ls -l',
         ')']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line %x string with backticks' do
      let(:source) do
        ['foo = %x(',
         '  echo `ls`',
         '  echo `ls -l`',
         ')']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when EnforcedStyle is set to mixed' do
    let(:cop_config) { { 'EnforcedStyle' => 'mixed' } }

    describe 'a single-line ` string without backticks' do
      let(:source) { 'foo = `ls`' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a single-line ` string with backticks' do
      let(:source) { 'foo = `echo \`ls\``' }

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'is accepted' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    describe 'a multi-line ` string without backticks' do
      let(:source) do
        ['foo = `',
         '  ls',
         '  ls -l',
         '`']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("foo = %x(\n  ls\n  ls -l\n)")
      end
    end

    describe 'a multi-line ` string with backticks' do
      let(:source) do
        ['foo = `',
         '  echo \`ls\`',
         '  echo \`ls -l\`',
         '`']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%x` around command string.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source.join("\n"))
      end
    end

    describe 'a single-line %x string without backticks' do
      let(:source) { 'foo = %x(ls)' }

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use backticks around command string.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq('foo = `ls`')
      end
    end

    describe 'a single-line %x string with backticks' do
      let(:source) { 'foo = %x(echo `ls`)' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Use backticks around command string.'])
        end

        it 'cannot auto-correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source)
        end
      end
    end

    describe 'a multi-line %x string without backticks' do
      let(:source) do
        ['foo = %x(',
         '  ls',
         '  ls -l',
         ')']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line %x string with backticks' do
      let(:source) do
        ['foo = %x(',
         '  echo `ls`',
         '  echo `ls -l`',
         ')']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end
end
