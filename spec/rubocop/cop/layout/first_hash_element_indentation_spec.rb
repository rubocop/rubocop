# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstHashElementIndentation, :config do
  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w[special_inside_parentheses consistent
                              align_braces]
    }
    RuboCop::Config.new('Layout/HashAlignment' => align_hash_config,
                        'Layout/FirstHashElementIndentation' =>
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
    it 'registers an offense and corrects incorrectly indented }' do
      expect_offense(<<~RUBY)
        a << {
          }
          ^ Indent the right brace the same as the start of the line where the left brace is.
      RUBY

      expect_correction(<<~RUBY)
        a << {
        }
      RUBY
    end
  end

  context 'when the HashAlignment style is separator for :' do
    let(:align_hash_config) do
      {
        'Enabled' => true,
        'EnforcedColonStyle' => 'separator',
        'EnforcedHashRocketStyle' => 'key'
      }
    end

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<~RUBY)
        a << {
            a: 1,
          aaa: 222
        }
      RUBY
    end

    it 'registers an offense and corrects incorrectly indented first pair with :' do
      expect_offense(<<~RUBY)
        a << {
               a: 1,
               ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
             aaa: 222
        }
      RUBY

      expect_correction(<<~RUBY)
        a << {
            a: 1,
             aaa: 222
        }
      RUBY
    end

    include_examples 'right brace'
  end

  context 'when the HashAlignment style is separator for =>' do
    let(:align_hash_config) do
      {
        'Enabled' => true,
        'EnforcedColonStyle' => 'key',
        'EnforcedHashRocketStyle' => 'separator'
      }
    end

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<~RUBY)
        a << {
            'a' => 1,
          'aaa' => 222
        }
      RUBY
    end

    it 'registers an offense and corrects incorrectly indented first pair with =>' do
      expect_offense(<<~RUBY)
        a << {
           'a' => 1,
           ^^^^^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
         'aaa' => 222
        }
      RUBY

      expect_correction(<<~RUBY)
        a << {
            'a' => 1,
         'aaa' => 222
        }
      RUBY
    end

    include_examples 'right brace'
  end

  context 'when hash is operand' do
    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<~RUBY)
        a << {
          a: 1
        }
      RUBY
    end

    it 'registers an offense and corrects incorrectly indented first pair' do
      expect_offense(<<~RUBY)
        a << {
         a: 1
         ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
        }
      RUBY

      expect_correction(<<~RUBY)
        a << {
          a: 1
        }
      RUBY
    end

    include_examples 'right brace'
  end

  context 'when hash is argument to setter' do
    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<~RUBY)
        config.rack_cache = {
          :metastore => "rails:/",
          :entitystore => "rails:/",
           :verbose => false
        }
      RUBY
    end

    it 'registers an offense and corrects incorrectly indented first pair' do
      expect_offense(<<~RUBY)
        config.rack_cache = {
        :metastore => "rails:/",
        ^^^^^^^^^^^^^^^^^^^^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
        :entitystore => "rails:/",
        :verbose => false
        }
      RUBY

      expect_correction(<<~RUBY)
        config.rack_cache = {
          :metastore => "rails:/",
        :entitystore => "rails:/",
        :verbose => false
        }
      RUBY
    end
  end

  context 'when hash is right hand side in assignment' do
    it 'registers an offense and corrects incorrectly indented first pair' do
      expect_offense(<<~RUBY)
        a = {
            a: 1,
            ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
          b: 2,
         c: 3
        }
      RUBY

      expect_correction(<<~RUBY)
        a = {
          a: 1,
          b: 2,
         c: 3
        }
      RUBY
    end

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<~RUBY)
        a = {
          a: 1
        }
      RUBY
    end

    it 'accepts several pairs per line' do
      expect_no_offenses(<<~RUBY)
        a = {
          a: 1, b: 2
        }
      RUBY
    end

    it 'accepts a first pair on the same line as the left brace' do
      expect_no_offenses(<<~RUBY)
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

      it 'registers an offense and corrects incorrectly indented first pair' do
        expect_offense(<<~RUBY)
          a = {
              a: 1,
              ^^^^ Use 3 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
            b: 2,
           c: 3
          }
        RUBY

        expect_correction(<<~RUBY)
          a = {
             a: 1,
            b: 2,
           c: 3
          }
        RUBY
      end

      it 'accepts correctly indented first pair' do
        expect_no_offenses(<<~RUBY)
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
          expect_no_offenses(<<~RUBY)
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

        it "registers an offense and corrects 'consistent' indentation" do
          expect_offense(<<~RUBY)
            func({
              a: 1
              ^^^^ Use 2 spaces for indentation in a hash, relative to the first position after the preceding left parenthesis.
            })
            ^ Indent the right brace the same as the first position after the preceding left parenthesis.
          RUBY

          expect_correction(<<~RUBY)
            func({
                   a: 1
                 })
          RUBY
        end

        context 'when using safe navigation operator' do
          it "registers an offense and corrects 'consistent' indentation" do
            expect_offense(<<~RUBY)
              receiver&.func({
                a: 1
                ^^^^ Use 2 spaces for indentation in a hash, relative to the first position after the preceding left parenthesis.
              })
              ^ Indent the right brace the same as the first position after the preceding left parenthesis.
            RUBY

            expect_correction(<<~RUBY)
              receiver&.func({
                               a: 1
                             })
            RUBY
          end
        end

        it "registers an offense and corrects 'align_braces' indentation" do
          expect_offense(<<~RUBY)
            var = {
                    a: 1
                    ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
                  }
                  ^ Indent the right brace the same as the start of the line where the left brace is.
          RUBY

          expect_correction(<<~RUBY)
            var = {
              a: 1
            }
          RUBY
        end

        it 'accepts special indentation for second argument' do
          expect_no_offenses(<<~'RUBY')
            body.should have_tag("input", :attributes => {
                                   :name => /q\[(id_eq)\]/ })
          RUBY
        end

        it 'accepts normal indentation for hash within hash' do
          expect_no_offenses(<<~RUBY)
            scope = scope.where(
              klass.table_name => {
                reflection.type => model.base_class.sti_name
              }
            )
          RUBY
        end

        it 'registers an offense for incorrectly indented hash that is the value of a single pair hash' do
          expect_offense(<<~RUBY)
            func(x: {
                  a: 1, b: 2 })
                  ^^^^ Use 2 spaces for indentation in a hash, relative to the first position after the preceding left parenthesis.
          RUBY

          expect_correction(<<~RUBY)
            func(x: {
                   a: 1, b: 2 })
          RUBY
        end

        it 'registers an offense for a hash that is a value of a multi pairs hash' \
           'when the indent of its elements is not based on the hash key' do
          expect_offense(<<~RUBY)
            func(x: {
              a: 1,
              ^^^^ Use 2 spaces for indentation in a hash, relative to the parent hash key.
                   b: 2
            },
            ^ Indent the right brace the same as the parent hash key.
                 y: {
                   c: 1,
                   d: 2
                 })
          RUBY

          expect_correction(<<~RUBY)
            func(x: {
                   a: 1,
                   b: 2
                 },
                 y: {
                   c: 1,
                   d: 2
                 })
          RUBY
        end

        it 'accepts indent based on the preceding left parenthesis' \
           'when the right brace and its following pair is on the same line' do
          expect_no_offenses(<<~RUBY)
            func(:x, y: {
                   a: 1,
                   b: 2
                 }, z: {
                   c: 1,
                   d: 2
                 })
          RUBY
        end

        it 'accepts indent based on the left brace when the outer hash key and ' \
           'the left brace is not on the same line' do
          expect_no_offenses(<<~RUBY)
            func(x:
                   {
                     a: 1,
                     b: 2
                   },
                 y: {
                   c: 1,
                   d: 2
                 })
          RUBY
        end
      end

      context 'and EnforcedStyle is consistent' do
        let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

        it 'accepts normal indentation for first argument' do
          expect_no_offenses(<<~RUBY)
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

        it 'registers an offense and corrects incorrect indentation' do
          expect_offense(<<~RUBY)
            func({
                   a: 1
                   ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
                 })
                 ^ Indent the right brace the same as the start of the line where the left brace is.
          RUBY

          expect_correction(<<~RUBY)
            func({
              a: 1
            })
          RUBY
        end

        it 'accepts normal indentation for second argument' do
          expect_no_offenses(<<~'RUBY')
            body.should have_tag("input", :attributes => {
              :name => /q\[(id_eq)\]/ })
          RUBY
        end

        it 'registers an offense for incorrectly indented hash that is the value of a single pair hash' do
          expect_offense(<<~RUBY)
            func(x: {
                  a: 1, b: 2 })
                  ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
          RUBY

          expect_correction(<<~RUBY)
            func(x: {
              a: 1, b: 2 })
          RUBY
        end

        it 'registers an offense for a hash that is a value of a multi pairs hash' \
           'when the indent of its elements is not based on the hash key' do
          expect_offense(<<~RUBY)
            func(x: {
              a: 1,
              ^^^^ Use 2 spaces for indentation in a hash, relative to the parent hash key.
                   b: 2
            },
            ^ Indent the right brace the same as the parent hash key.
                 y: {
                   c: 1,
                   d: 2
                 })
          RUBY

          expect_correction(<<~RUBY)
            func(x: {
                   a: 1,
                   b: 2
                 },
                 y: {
                   c: 1,
                   d: 2
                 })
          RUBY
        end

        it 'accepts indent based on the start of the line where the left brace is' \
           'when the right brace and its following pair is on the same line' do
          expect_no_offenses(<<~RUBY)
            func(:x, y: {
              a: 1,
              b: 2
            }, z: {
              c: 1,
              d: 2
            })
          RUBY
        end

        it 'accepts indent based on the left brace when the outer hash key and ' \
           'the left brace is not on the same line' do
          expect_no_offenses(<<~RUBY)
            func(x:
                   {
                     a: 1,
                     b: 2
                   },
                 y: {
                   c: 1,
                   d: 2
                 })
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
        expect_no_offenses(<<~RUBY)
          func x, {
            a: 1, b: 2 }
        RUBY
      end

      it 'registers an offense for incorrectly indented multi-line hash with braces' do
        expect_offense(<<~RUBY)
          func x, {
                 a: 1, b: 2 }
                 ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
        RUBY

        expect_correction(<<~RUBY)
          func x, {
            a: 1, b: 2 }
        RUBY
      end

      it 'registers an offense for the first inner hash member not based on the start of line ' \
         'when the outer hash pair has no following siblings' do
        expect_offense(<<~RUBY)
          func x: :foo, y: {
                          a: 1, b: 2 }
                          ^^^^ Use 2 spaces for indentation in a hash, relative to the start of the line where the left curly brace is.
        RUBY

        expect_correction(<<~RUBY)
          func x: :foo, y: {
            a: 1, b: 2 }
        RUBY
      end

      it 'registers an offense for a hash that is a value of a multi pairs hash' \
         'when the indent of its elements is not based on the hash key' do
        expect_offense(<<~RUBY)
          func x: {
            a: 1,
            ^^^^ Use 2 spaces for indentation in a hash, relative to the parent hash key.
                 b: 2
          },
          ^ Indent the right brace the same as the parent hash key.
               y: {
                 c: 1,
                 d: 2
               }
        RUBY

        expect_correction(<<~RUBY)
          func x: {
                 a: 1,
                 b: 2
               },
               y: {
                 c: 1,
                 d: 2
               }
        RUBY
      end

      it 'accepts indent based on the start of the line where the left brace is' \
         'when the right brace and its following pair is on the same line' do
        expect_no_offenses(<<~RUBY)
          func :x, y: {
            a: 1,
            b: 2
          }, z: {
            c: 1,
            d: 2
          }
        RUBY
      end

      it 'accepts indent based on the left brace when the outer hash key and ' \
         'the left brace is not on the same line' do
        expect_no_offenses(<<~RUBY)
          {
            x:
              {
                a: 1,
                b: 2
              },
            y: {
              c: 1,
              d: 2
            }
          }
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is align_braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'align_braces' } }

    it 'accepts correctly indented first pair' do
      expect_no_offenses(<<~RUBY)
        a = {
              a: 1
            }
      RUBY
    end

    it 'accepts several pairs per line' do
      expect_no_offenses(<<~RUBY)
        a = {
              a: 1, b: 2
            }
      RUBY
    end

    it 'accepts a first pair on the same line as the left brace' do
      expect_no_offenses(<<~RUBY)
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
      it 'registers an offense and corrects incorrect indentation' do
        expect_offense(<<~RUBY)
          func({
            a: 1
            ^^^^ Use 2 spaces for indentation in a hash, relative to the position of the opening brace.
          })
          ^ Indent the right brace the same as the left brace.
        RUBY

        expect_correction(<<~RUBY)
          func({
                 a: 1
               })
        RUBY
      end
    end

    context "when 'special_inside_parentheses' style is used" do
      it 'registers an offense and corrects incorrect indentation' do
        expect_offense(<<~RUBY)
          var = {
            a: 1
            ^^^^ Use 2 spaces for indentation in a hash, relative to the position of the opening brace.
          }
          ^ Indent the right brace the same as the left brace.
          func({
                 a: 1
               })
        RUBY

        expect_correction(<<~RUBY)
          var = {
                  a: 1
                }
          func({
                 a: 1
               })
        RUBY
      end
    end

    it 'registers an offense and corrects incorrectly indented }' do
      expect_offense(<<~RUBY)
        a << {
          }
          ^ Indent the right brace the same as the left brace.
      RUBY

      expect_correction(<<~RUBY)
        a << {
             }
      RUBY
    end

    it 'registers an offense for incorrectly indented hash that is the value of a single pair hash' do
      expect_offense(<<~RUBY)
        func x: {
                a: 1, b: 2 }
                ^^^^ Use 2 spaces for indentation in a hash, relative to the position of the opening brace.
      RUBY

      expect_correction(<<~RUBY)
        func x: {
                  a: 1, b: 2 }
      RUBY
    end

    it 'registers an offense for a hash that is a value of a multi pairs hash' \
       'when the indent of its elements is not based on the hash key' do
      expect_offense(<<~RUBY)
        func x: {
          a: 1,
          ^^^^ Use 2 spaces for indentation in a hash, relative to the position of the opening brace.
                  b: 2
        },
        ^ Indent the right brace the same as the left brace.
             y: {
                  c: 1,
                  d: 2
                }
      RUBY

      expect_correction(<<~RUBY)
        func x: {
                  a: 1,
                  b: 2
                },
             y: {
                  c: 1,
                  d: 2
                }
      RUBY
    end
  end
end
