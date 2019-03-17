# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentArray do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w[special_inside_parentheses consistent
                              align_brackets]
    }
    RuboCop::Config.new('Layout/IndentArray' =>
                        cop_config.merge(supported_styles).merge(
                          'IndentationWidth' => cop_indent
                        ),
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_config) { { 'EnforcedStyle' => 'special_inside_parentheses' } }
  let(:cop_indent) { nil } # use indent from Layout/IndentationWidth

  context 'when array is operand' do
    it 'accepts correctly indented first element' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a << [
          1
        ]
      RUBY
    end

    it 'registers an offense for incorrectly indented first element' do
      expect_offense(<<-RUBY.strip_indent)
        a << [
         1
         ^ Use 2 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
        ]
      RUBY
    end

    it 'auto-corrects incorrectly indented first element' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a << [
         1
        ]
      RUBY
      expect(corrected).to eq <<-RUBY.strip_indent
        a << [
          1
        ]
      RUBY
    end

    it 'registers an offense for incorrectly indented ]' do
      expect_offense(<<-RUBY.strip_indent)
        a << [
          ]
          ^ Indent the right bracket the same as the start of the line where the left bracket is.
      RUBY
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 4 }

      it 'accepts correctly indented first element' do
        expect_no_offenses(<<-RUBY.strip_indent)
          a << [
              1
          ]
        RUBY
      end

      it 'registers an offense for incorrectly indented first element' do
        expect_offense(<<-RUBY.strip_indent)
          a << [
            1
            ^ Use 4 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
          ]
        RUBY
      end
    end
  end

  context 'when array is argument to setter' do
    it 'accepts correctly indented first element' do
      expect_no_offenses(<<-RUBY.strip_indent)
           config.rack_cache = [
             "rails:/",
             "rails:/",
             false
           ]
      RUBY
    end

    it 'registers an offense for incorrectly indented first element' do
      expect_offense(<<-RUBY.strip_indent)
        config.rack_cache = [
        "rails:/",
        ^^^^^^^^^ Use 2 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
        "rails:/",
        false
        ]
      RUBY
    end
  end

  context 'when array is right hand side in assignment' do
    it 'registers an offense for incorrectly indented first element' do
      expect_offense(<<-RUBY.strip_indent)
        a = [
            1,
            ^ Use 2 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
          2,
         3
        ]
      RUBY
    end

    it 'auto-corrects incorrectly indented first element' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a = [
            1,
          2,
         3
        ]
      RUBY
      expect(corrected).to eq <<-RUBY.strip_indent
        a = [
          1,
          2,
         3
        ]
      RUBY
    end

    it 'accepts correctly indented first element' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
          1
        ]
      RUBY
    end

    it 'accepts several elements per line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
          1, 2
        ]
      RUBY
    end

    it 'accepts a first element on the same line as the left bracket' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [1,
             2]
      RUBY
    end

    it 'accepts single line array' do
      expect_no_offenses('a = [1, 2]')
    end

    it 'accepts an empty array' do
      expect_no_offenses('a = []')
    end

    it 'accepts multi-assignments with brackets' do
      expect_no_offenses('a, b = [b, a]')
    end

    it 'accepts multi-assignments with no brackets' do
      expect_no_offenses('a, b = b, a')
    end
  end

  context 'when array is method argument' do
    context 'and arguments are surrounded by parentheses' do
      context 'and EnforcedStyle is special_inside_parentheses' do
        it 'accepts special indentation for first argument' do
          expect_no_offenses(<<-RUBY.strip_indent)
            h = [
              1
            ]
            func([
                   1
                 ])
            func(x, [
                   1
                 ])
            h = [1
            ]
            func([1
                 ])
            func(x, [1
                 ])
          RUBY
        end

        it "registers an offense for 'consistent' indentation" do
          expect_offense(<<-RUBY.strip_indent)
            func([
              1
              ^ Use 2 spaces for indentation in an array, relative to the first position after the preceding left parenthesis.
            ])
            ^ Indent the right bracket the same as the first position after the preceding left parenthesis.
          RUBY
        end

        context 'when using safe navigation operator', :ruby23 do
          it "registers an offense for 'consistent' indentation" do
            expect_offense(<<-RUBY.strip_indent)
              receiver&.func([
                1
                ^ Use 2 spaces for indentation in an array, relative to the first position after the preceding left parenthesis.
              ])
              ^ Indent the right bracket the same as the first position after the preceding left parenthesis.
            RUBY
          end
        end

        it "registers an offense for 'align_brackets' indentation" do
          expect_offense(<<-RUBY.strip_indent)
            var = [
                    1
                    ^ Use 2 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
                  ]
                  ^ Indent the right bracket the same as the start of the line where the left bracket is.
          RUBY
        end

        it 'auto-corrects incorrectly indented first element' do
          corrected = autocorrect_source(<<-RUBY.strip_indent)
            func([
              1
            ])
          RUBY
          expect(corrected).to eq <<-RUBY.strip_indent
            func([
                   1
                 ])
          RUBY
        end

        it 'accepts special indentation for second argument' do
          expect_no_offenses(<<-RUBY.strip_indent)
            body.should have_tag("input", [
                                   :name])
          RUBY
        end

        it 'accepts normal indentation for array within array' do
          expect_no_offenses(<<-RUBY.strip_indent)
            puts(
              [
                [1, 2]
              ]
            )
          RUBY
        end
      end

      context 'and EnforcedStyle is consistent' do
        let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

        it 'accepts normal indentation for first argument' do
          expect_no_offenses(<<-RUBY.strip_indent)
            h = [
              1
            ]
            func([
              1
            ])
            func(x, [
              1
            ])
            h = [1
            ]
            func([1
            ])
            func(x, [1
            ])
          RUBY
        end

        it 'registers an offense for incorrect indentation' do
          expect_offense(<<-RUBY.strip_indent)
            func([
                   1
                   ^ Use 2 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
                 ])
                 ^ Indent the right bracket the same as the start of the line where the left bracket is.
          RUBY
        end

        it 'accepts normal indentation for second argument' do
          expect_no_offenses(<<-RUBY.strip_indent)
            body.should have_tag("input", [
              :name])
          RUBY
        end
      end
    end

    context 'and argument are not surrounded by parentheses' do
      it 'accepts bracketless array' do
        expect_no_offenses('func 1, 2')
      end

      it 'accepts single line array with brackets' do
        expect_no_offenses('func x, [1, 2]')
      end

      it 'accepts a correctly indented multi-line array with brackets' do
        expect_no_offenses(<<-RUBY.strip_indent)
          func x, [
            1, 2]
        RUBY
      end

      it 'registers an offense for incorrectly indented multi-line array ' \
         'with brackets' do
        expect_offense(<<-RUBY.strip_indent)
          func x, [
                 1, 2]
                 ^ Use 2 spaces for indentation in an array, relative to the start of the line where the left square bracket is.
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is align_brackets' do
    let(:cop_config) { { 'EnforcedStyle' => 'align_brackets' } }

    it 'accepts correctly indented first element' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
              1
            ]
      RUBY
    end

    it 'accepts several elements per line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
              1, 2
            ]
      RUBY
    end

    it 'accepts a first element on the same line as the left bracket' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [1,
             2]
      RUBY
    end

    it 'accepts single line array' do
      expect_no_offenses('a = [1, 2]')
    end

    it 'accepts an empty array' do
      expect_no_offenses('a = []')
    end

    it 'accepts multi-assignments with brackets' do
      expect_no_offenses('a, b = [b, a]')
    end

    it 'accepts multi-assignments with no brackets' do
      expect_no_offenses('a, b = b, a')
    end

    context "when 'consistent' style is used" do
      it 'registers an offense for incorrect indentation' do
        expect_offense(<<-RUBY.strip_indent)
          func([
            1
            ^ Use 2 spaces for indentation in an array, relative to the position of the opening bracket.
          ])
          ^ Indent the right bracket the same as the left bracket.
        RUBY
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'consistent')
      end

      it 'auto-corrects incorrectly indented first element' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          var = [
            1
          ]
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          var = [
                  1
                ]
        RUBY
      end
    end

    context "when 'special_inside_parentheses' style is used" do
      it 'registers an offense for incorrect indentation' do
        expect_offense(<<-RUBY.strip_indent)
          var = [
            1
            ^ Use 2 spaces for indentation in an array, relative to the position of the opening bracket.
          ]
          ^ Indent the right bracket the same as the left bracket.
          func([
                 1
               ])
        RUBY
      end
    end

    it 'registers an offense for incorrectly indented ]' do
      expect_offense(<<-RUBY.strip_indent)
        a << [
          ]
          ^ Indent the right bracket the same as the left bracket.
      RUBY
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 4 }

      it 'accepts correctly indented first element' do
        expect_no_offenses(<<-RUBY.strip_indent)
          a = [
                  1
              ]
        RUBY
      end

      it 'autocorrects indentation which does not match IndentationWidth' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          a = [
                1
              ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          a = [
                  1
              ]
        RUBY
      end
    end
  end
end
