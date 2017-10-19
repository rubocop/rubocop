# frozen_string_literal: true

describe RuboCop::Cop::Layout::IndentHash do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w[special_inside_parentheses consistent
                              align_braces]
    }
    RuboCop::Config.new('Layout/AlignHash' => align_hash_config,
                        'Layout/IndentHash' =>
                        cop_config.merge(supported_styles).merge(
                          'IndentationWidth' => cop_indent
                        ),
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:align_hash_config) do
    {
      'Enabled' => true,
      'EnforcedColonStyle' => 'key',
      'EnforcedHashRocketStyle' => 'key'
    }
  end
  let(:cop_config) { { 'EnforcedStyle' => 'special_inside_parentheses' } }
  let(:cop_indent) { nil } # use indentation width from Layout/IndentationWidth

  shared_examples 'right brace' do
    it 'registers an offense for incorrectly indented }' do
      inspect_source(<<-RUBY.strip_indent)
        a << {
          }
      RUBY
      expect(cop.highlights).to eq(['}'])
      expect(cop.messages)
        .to eq(['Indent the right brace the same as the start of the line ' \
                'where the left brace is.'])
      expect(cop.config_to_allow_offenses.empty?).to be(true)
    end
  end

  context 'when the AlignHash style is separator for :' do
    let(:align_hash_config) do
      {
        'Enabled' => true,
        'EnforcedColonStyle' => 'separator',
        'EnforcedHashRocketStyle' => 'key'
      }
    end

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a << {
            a: 1,
          aaa: 222
        }
      RUBY
    end

    it 'registers an offense for incorrectly indented first pair with :' do
      inspect_source(<<-RUBY.strip_indent)
        a << {
               a: 1,
             aaa: 222
        }
      RUBY
      expect(cop.highlights).to eq(['a: 1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    include_examples 'right brace'
  end

  context 'when the AlignHash style is separator for =>' do
    let(:align_hash_config) do
      {
        'Enabled' => true,
        'EnforcedColonStyle' => 'key',
        'EnforcedHashRocketStyle' => 'separator'
      }
    end

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a << {
            'a' => 1,
          'aaa' => 222
        }
      RUBY
    end

    it 'registers an offense for incorrectly indented first pair with =>' do
      inspect_source(<<-RUBY.strip_indent)
        a << {
           'a' => 1,
         'aaa' => 222
        }
      RUBY
      expect(cop.highlights).to eq(["'a' => 1"])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    include_examples 'right brace'
  end

  context 'when hash is operand' do
    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a << {
          a: 1
        }
      RUBY
    end

    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(<<-RUBY.strip_indent)
        a << {
         a: 1
        }
      RUBY
      expect(cop.highlights).to eq(['a: 1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects incorrectly indented first pair' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a << {
         a: 1
        }
      RUBY
      expect(corrected).to eq <<-RUBY.strip_indent
        a << {
          a: 1
        }
      RUBY
    end

    include_examples 'right brace'
  end

  context 'when hash is argument to setter' do
    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<-RUBY.strip_indent)
           config.rack_cache = {
             :metastore => "rails:/",
             :entitystore => "rails:/",
             :verbose => false
           }
      RUBY
    end

    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(<<-RUBY.strip_margin('|'))
        |   config.rack_cache = {
        |   :metastore => "rails:/",
        |   :entitystore => "rails:/",
        |   :verbose => false
        |   }
      RUBY
      expect(cop.highlights).to eq([':metastore => "rails:/"'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end
  end

  context 'when hash is right hand side in assignment' do
    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(<<-RUBY.strip_indent)
        a = {
            a: 1,
          b: 2,
         c: 3
        }
      RUBY
      expect(cop.messages)
        .to eq(['Use 2 spaces for indentation in a hash, relative to the ' \
                'start of the line where the left curly brace is.'])
      expect(cop.highlights).to eq(['a: 1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects incorrectly indented first pair' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a = {
            a: 1,
          b: 2,
         c: 3
        }
      RUBY
      expect(corrected).to eq <<-RUBY.strip_indent
        a = {
          a: 1,
          b: 2,
         c: 3
        }
      RUBY
    end

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = {
          a: 1
        }
      RUBY
    end

    it 'accepts several pairs per line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = {
          a: 1, b: 2
        }
      RUBY
    end

    it 'accepts a first pair on the same line as the left brace' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = { "a" => 1,
              "b" => 2 }
      RUBY
    end

    it 'accepts single line hash' do
      expect_no_offenses('a = { a: 1, b: 2 }')
    end

    it 'accepts an empty hash' do
      expect_no_offenses('a = {}')
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 3 }

      it 'auto-corrects incorrectly indented first pair' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          a = {
              a: 1,
            b: 2,
           c: 3
          }
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          a = {
             a: 1,
            b: 2,
           c: 3
          }
        RUBY
      end

      it 'accepts correctly indented first pair' do
        expect_no_offenses(<<-RUBY.strip_indent)
          a = {
             a: 1
          }
        RUBY
      end
    end
  end

  context 'when hash is method argument' do
    context 'and arguments are surrounded by parentheses' do
      context 'and EnforcedStyle is special_inside_parentheses' do
        it 'accepts special indentation for first argument' do
          expect_no_offenses(<<-RUBY.strip_indent)
            h = {
              a: 1
            }
            func({
                   a: 1
                 })
            func(x, {
                   a: 1
                 })
            h = { a: 1
            }
            func({ a: 1
                 })
            func(x, { a: 1
                 })
          RUBY
        end

        it "registers an offense for 'consistent' indentation" do
          inspect_source(<<-RUBY.strip_indent)
            func({
              a: 1
            })
          RUBY
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                    ' first position after the preceding left parenthesis.',
                    'Indent the right brace the same as the first position ' \
                    'after the preceding left parenthesis.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'consistent')
        end

        it "registers an offense for 'align_braces' indentation" do
          inspect_source(<<-RUBY.strip_indent)
            var = {
                    a: 1
                  }
          RUBY
          # since there are no parens, warning message is for 'consistent' style
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                    ' start of the line where the left curly brace is.',
                    'Indent the right brace the same as the start of the ' \
                    'line where the left brace is.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'align_braces')
        end

        it 'auto-corrects incorrectly indented first pair' do
          corrected = autocorrect_source(<<-RUBY.strip_indent)
            func({
              a: 1
            })
          RUBY
          expect(corrected).to eq <<-RUBY.strip_indent
            func({
                   a: 1
                 })
          RUBY
        end

        it 'accepts special indentation for second argument' do
          expect_no_offenses(<<-'RUBY'.strip_indent)
            body.should have_tag("input", :attributes => {
                                   :name => /q\[(id_eq)\]/ })
          RUBY
        end

        it 'accepts normal indentation for hash within hash' do
          expect_no_offenses(<<-RUBY.strip_indent)
            scope = scope.where(
              klass.table_name => {
                reflection.type => model.base_class.sti_name
              }
            )
          RUBY
        end
      end

      context 'and EnforcedStyle is consistent' do
        let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

        it 'accepts normal indentation for first argument' do
          expect_no_offenses(<<-RUBY.strip_indent)
            h = {
              a: 1
            }
            func({
              a: 1
            })
            func(x, {
              a: 1
            })
            h = { a: 1
            }
            func({ a: 1
            })
            func(x, { a: 1
            })
          RUBY
        end

        it 'registers an offense for incorrect indentation' do
          inspect_source(<<-RUBY.strip_indent)
            func({
                   a: 1
                 })
          RUBY
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                    ' start of the line where the left curly brace is.',

                    'Indent the right brace the same as the start of the ' \
                    'line where the left brace is.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'special_inside_parentheses')
        end

        it 'accepts normal indentation for second argument' do
          expect_no_offenses(<<-'RUBY'.strip_indent)
            body.should have_tag("input", :attributes => {
              :name => /q\[(id_eq)\]/ })
          RUBY
        end
      end
    end

    context 'and argument are not surrounded by parentheses' do
      it 'accepts braceless hash' do
        expect_no_offenses('func a: 1, b: 2')
      end

      it 'accepts single line hash with braces' do
        expect_no_offenses('func x, { a: 1, b: 2 }')
      end

      it 'accepts a correctly indented multi-line hash with braces' do
        expect_no_offenses(<<-RUBY.strip_indent)
          func x, {
            a: 1, b: 2 }
        RUBY
      end

      it 'registers an offense for incorrectly indented multi-line hash ' \
         'with braces' do
        inspect_source(<<-RUBY.strip_indent)
          func x, {
                 a: 1, b: 2 }
        RUBY
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in a hash, relative to the ' \
                  'start of the line where the left curly brace is.'])
        expect(cop.highlights).to eq(['a: 1'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end
    end
  end

  context 'when EnforcedStyle is align_braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'align_braces' } }

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = {
              a: 1
            }
      RUBY
    end

    it 'accepts several pairs per line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = {
              a: 1, b: 2
            }
      RUBY
    end

    it 'accepts a first pair on the same line as the left brace' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = { "a" => 1,
              "b" => 2 }
      RUBY
    end

    it 'accepts single line hash' do
      expect_no_offenses('a = { a: 1, b: 2 }')
    end

    it 'accepts an empty hash' do
      expect_no_offenses('a = {}')
    end

    context "when 'consistent' style is used" do
      it 'registers an offense for incorrect indentation' do
        inspect_source(<<-RUBY.strip_indent)
          func({
            a: 1
          })
        RUBY
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                  ' position of the opening brace.',
                  'Indent the right brace the same as the left brace.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'consistent')
      end

      it 'auto-corrects incorrectly indented first pair' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          var = {
            a: 1
          }
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          var = {
                  a: 1
                }
        RUBY
      end
    end

    context "when 'special_inside_parentheses' style is used" do
      it 'registers an offense for incorrect indentation' do
        inspect_source(<<-RUBY.strip_indent)
          var = {
            a: 1
          }
          func({
                 a: 1
               })
        RUBY
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                  ' position of the opening brace.',
                  'Indent the right brace the same as the left brace.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'special_inside_parentheses')
      end
    end

    it 'registers an offense for incorrectly indented }' do
      inspect_source(<<-RUBY.strip_indent)
        a << {
          }
      RUBY
      expect(cop.highlights).to eq(['}'])
      expect(cop.messages)
        .to eq(['Indent the right brace the same as the left brace.'])
      expect(cop.config_to_allow_offenses.empty?).to be(true)
    end
  end
end
