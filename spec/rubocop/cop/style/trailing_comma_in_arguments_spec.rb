# frozen_string_literal: true

describe RuboCop::Cop::Style::TrailingCommaInArguments, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'single line lists' do |extra_info|
    it 'registers an offense for trailing comma in a method call' do
      inspect_source(cop, 'some_method(a, b, c, )')
      expect(cop.messages)
        .to eq(['Avoid comma after the last parameter of a method ' \
                "call#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'registers an offense for trailing comma in a method call with hash' \
       ' parameters at the end' do
      inspect_source(cop, 'some_method(a, b, c: 0, d: 1, )')
      expect(cop.messages)
        .to eq(['Avoid comma after the last parameter of a method ' \
                "call#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'accepts method call without trailing comma' do
      expect_no_offenses('some_method(a, b, c)')
    end

    it 'accepts method call without trailing comma with single element hash' \
        ' parameters at the end' do
      inspect_source(cop, 'some_method(a: 1)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts method call without parameters' do
      expect_no_offenses('some_method')
    end

    it 'accepts chained single-line method calls' do
      expect_no_offenses(<<-END.strip_indent)
        target
          .some_method(a)
      END
    end

    it 'auto-corrects unwanted comma in a method call' do
      new_source = autocorrect_source(cop, 'some_method(a, b, c, )')
      expect(new_source).to eq('some_method(a, b, c )')
    end

    it 'auto-corrects unwanted comma in a method call with hash parameters at' \
       ' the end' do
      new_source = autocorrect_source(cop, 'some_method(a, b, c: 0, d: 1, )')
      expect(new_source).to eq('some_method(a, b, c: 0, d: 1 )')
    end
  end

  context 'with single line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }
      include_examples 'single line lists', ''
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }
      include_examples 'single line lists',
                       ', unless each item is on its own line'
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }
      include_examples 'single line lists',
                       ', unless items are split onto multiple lines'
    end
  end

  context 'with multi-line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      it 'registers an offense for trailing comma in a method call with ' \
         'hash parameters at the end' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,)
        END
        expect(cop.highlights).to eq([','])
      end

      it 'accepts a method call with ' \
         'hash parameters at the end and no trailing comma' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(a,
                      b,
                      c: 0,
                      d: 1
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts comma inside a heredoc parameter at the end' do
        expect_no_offenses(<<-END.strip_indent)
          route(help: {
            'auth' => <<-HELP.chomp
          ,
          HELP
          })
        END
      end

      it 'auto-corrects unwanted comma in a method call with hash parameters' \
         ' at the end' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,)
        END
        expect(new_source).to eq(<<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1)
        END
      end
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'accepts a method call with Hash as last parameter split on ' \
           'multiple lines' do
          inspect_source(cop, <<-END.strip_indent)
            some_method(a: "b",
                        c: "d")
          END
          expect(cop.offenses).to be_empty
        end
      end

      it 'registers an offense for no trailing comma in a method call with' \
         ' hash parameters at the end' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
        END
        expect(cop.messages)
          .to eq(['Put a comma after the last parameter of a multiline ' \
                  'method call.'])
        expect(cop.highlights).to eq(['d: 1'])
      end

      it 'accepts a method call with two parameters on the same line' do
        expect_no_offenses(<<-END.strip_indent)
          some_method(a, b
                     )
        END
      end

      it 'accepts trailing comma in a method call with hash' \
         ' parameters at the end' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts no trailing comma in a method call with a multiline' \
         ' braceless hash at the end with more than one parameter on a line' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b: 0,
                        c: 0, d: 1
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts a trailing comma in a method call with single ' \
         'line hashes' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
           { a: 0, b: 1 },
           { a: 1, b: 0 },
          )
        END

        expect(cop.offenses).to be_empty
      end

      it 'accepts an empty hash being passed as a method argument' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Foo.new([
                   ])
        RUBY
      end

      it 'auto-corrects missing comma in a method call with hash parameters' \
         ' at the end' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
        END
        expect(new_source).to eq(<<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        END
      end

      it 'accepts a multiline call with a single argument and trailing comma' do
        expect_no_offenses(<<-END.strip_indent)
          method(
            1,
          )
        END
      end
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'registers an offense for a method call, with a Hash as the ' \
           'last parameter, split on multiple lines' do
          inspect_source(cop, <<-END.strip_indent)
            some_method(a: "b",
                        c: "d")
          END
          expect(cop.messages)
            .to eq(['Put a comma after the last parameter of a ' \
                    'multiline method call.'])
        end
      end

      it 'registers an offense for no trailing comma in a method call with' \
         ' hash parameters at the end' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
        END
        expect(cop.messages)
          .to eq(['Put a comma after the last parameter of a multiline ' \
                  'method call.'])
        expect(cop.highlights).to eq(['d: 1'])
      end

      it 'registers an offense for no trailing comma in a method call with' \
          'two parameters on the same line' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(a, b
                     )
        END
        expect(cop.messages)
          .to eq(['Put a comma after the last parameter of a multiline ' \
                  'method call.'])
      end

      it 'accepts trailing comma in a method call with hash' \
         ' parameters at the end' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts a trailing comma in a method call with ' \
         'a single hash parameter' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a: 0,
                        b: 1,
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts a trailing comma in a method call with single ' \
         'line hashes' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
           { a: 0, b: 1 },
           { a: 1, b: 0 },
          )
        END

        expect(cop.offenses).to be_empty
      end

      # this is a sad parse error
      it 'accepts no trailing comma in a method call with a block' \
         ' parameter at the end' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                        &block
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts missing comma after a heredoc' do
        # A heredoc that's the last item in a literal or parameter list can not
        # have a trailing comma. It's a syntax error.
        expect_no_offenses(<<-END.strip_indent)
          route(1, <<-HELP.chomp
          ...
          HELP
          )
        END
      end

      it 'auto-corrects missing comma in a method call with hash parameters' \
         ' at the end' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
        END
        expect(new_source).to eq(<<-END.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        END
      end

      it 'accepts a multiline call with a single argument and trailing comma' do
        expect_no_offenses(<<-END.strip_indent)
          method(
            1,
          )
        END
      end

      it 'accepts a multiline call with arguments on a single line and' \
         ' trailing comma' do
        inspect_source(cop, <<-END.strip_indent)
          method(
            1, 2,
          )
        END
        expect(cop.offenses).to be_empty
      end
    end
  end
end
