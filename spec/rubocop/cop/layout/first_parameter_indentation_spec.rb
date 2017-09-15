# frozen_string_literal: true

describe RuboCop::Cop::Layout::FirstParameterIndentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config
      .new('Layout/FirstParameterIndentation' => {
             'EnforcedStyle' => style,
             'SupportedStyles' =>
               %w[consistent special_for_inner_method_call
                  special_for_inner_method_call_in_parentheses]
           },
           'Layout/IndentationWidth' => { 'Width' => indentation_width })
  end

  shared_examples 'common behavior' do
    context 'when IndentationWidth:Width is 2' do
      let(:indentation_width) { 2 }

      it 'registers an offense for an over-indented first parameter' do
        inspect_source(<<-RUBY.strip_indent)
          run(
              :foo,
              bar: 3
          )
        RUBY
        expect(cop.messages).to eq(['Indent the first parameter one step ' \
                                    'more than the start of the ' \
                                    'previous line.'])
        expect(cop.highlights).to eq([':foo'])
      end

      it 'registers an offense for an under-indented first parameter' do
        inspect_source(<<-RUBY.strip_indent)
          run(
           :foo,
              bar: 3
          )
        RUBY
        expect(cop.highlights).to eq([':foo'])
      end

      it 'registers an offense on lines affected by another offense' do
        inspect_source(<<-RUBY.strip_indent)
          foo(
           bar(
            7
          )
          )
        RUBY

        expect(cop.highlights).to eq([['bar(',
                                       '  7',
                                       ')'].join("\n"),
                                      '7'])

        expect(cop.messages)
          .to eq(['Indent the first parameter one step more than ' \
                  'the start of the previous line.',
                  'Bad indentation of the first parameter.'])
      end

      it 'auto-corrects nested offenses' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(
           bar(
            7
          )
          )
        RUBY

        # The first `)` Will be corrected by IndentationConsistency.
        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(
            bar(
             7
           )
          )
        RUBY
      end

      context 'for assignment' do
        it 'accepts a correctly indented first parameter and does not care ' \
           'about the second parameter' do
          inspect_source(<<-RUBY.strip_indent)
            x = run(
              :foo,
                bar: 3
            )
          RUBY
          expect(cop.offenses).to be_empty
        end

        context 'with line break' do
          it 'accepts a correctly indented first parameter' do
            expect_no_offenses(<<-RUBY.strip_indent)
              x =
                run(
                  :foo)
            RUBY
          end

          it 'registers an offense for an under-indented first parameter' do
            inspect_source(<<-RUBY.strip_indent)
              @x =
                run(
                :foo)
            RUBY
            expect(cop.highlights).to eq([':foo'])
          end
        end
      end

      it 'accepts a first parameter that is not preceded by a line break' do
        expect_no_offenses(<<-RUBY.strip_indent)
          run :foo,
              bar: 3
        RUBY
      end

      context 'when the receiver contains a line break' do
        it 'accepts a correctly indented first parameter' do
          expect_no_offenses(<<-RUBY.strip_indent)
            puts x.
              merge(
                b: 2
              )
          RUBY
        end

        it 'registers an offense for an over-indented first parameter' do
          inspect_source(<<-RUBY.strip_indent)
            puts x.
              merge(
                  b: 2
              )
          RUBY
          expect(cop.messages).to eq(['Indent the first parameter one step ' \
                                      'more than the start of the ' \
                                      'previous line.'])
          expect(cop.highlights).to eq(['b: 2'])
        end

        it 'accepts a correctly indented first parameter preceded by an ' \
           'empty line' do
          inspect_source(<<-RUBY.strip_indent)
            puts x.
              merge(

                b: 2
              )
          RUBY
          expect(cop.offenses).to be_empty
        end

        context 'when preceded by a comment line' do
          it 'accepts a correctly indented first parameter' do
            expect_no_offenses(<<-RUBY.strip_indent)
              puts x.
                merge( # EOL comment
                  # comment
                  b: 2
                )
            RUBY
          end

          it 'registers an offense for an under-indented first parameter' do
            inspect_source(<<-RUBY.strip_indent)
              puts x.
                merge(
                # comment
                b: 2
                )
            RUBY
            expect(cop.messages).to eq(['Indent the first parameter one step ' \
                                        'more than the start of the previous ' \
                                        'line (not counting the comment).'])
            expect(cop.highlights).to eq(['b: 2'])
          end
        end
      end

      it 'accepts method calls with no parameters' do
        expect_no_offenses(<<-RUBY.strip_indent)
          run()
          run_again
        RUBY
      end

      it 'accepts operator calls' do
        expect_no_offenses(<<-RUBY.strip_indent)
          params = default_cfg.keys - %w(Description) -
                   cfg.keys
        RUBY
      end

      it 'does not view []= as an outer method call' do
        expect_no_offenses(<<-RUBY.strip_indent)
          @subject_results[subject] = original.update(
            mutation_results: (dup << mutation_result),
            tests:            test_result.tests
          )
        RUBY
      end

      it 'does not view chained call as an outer method call' do
        inspect_source(<<-'RUBY'.strip_margin('|'))
          |  A = Regexp.union(
          |    /[A-Za-z_][A-Za-z\d_]*[!?=]?/,
          |    *AST::Types::OPERATOR_METHODS.map(&:to_s)
          |  ).freeze
        RUBY
        expect(cop.offenses).to be_empty
      end

      it 'auto-corrects an under-indented first parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          x =
            run(
            :foo,
              bar: 3
          )
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          x =
            run(
              :foo,
              bar: 3
          )
        RUBY
      end
    end

    context 'when IndentationWidth:Width is 4' do
      let(:indentation_width) { 4 }

      it 'auto-corrects an over-indented first parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          run(
                  :foo,
              bar: 3)
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          run(
              :foo,
              bar: 3)
        RUBY
      end
    end

    context 'when indentation width is overridden for this cop only' do
      let(:config) do
        RuboCop::Config
          .new('Layout/FirstParameterIndentation' => {
                 'EnforcedStyle' => style,
                 'SupportedStyles' =>
                   %w[consistent special_for_inner_method_call
                      special_for_inner_method_call_in_parentheses],
                 'IndentationWidth' => 4
               },
               'Layout/IndentationWidth' => { 'Width' => 2 })
      end

      it 'accepts a correctly indented first parameter' do
        expect_no_offenses(<<-RUBY.strip_indent)
          run(
              :foo,
              bar: 3
          )
        RUBY
      end

      it 'auto-corrects an over-indented first parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          run(
                  :foo,
              bar: 3)
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          run(
              :foo,
              bar: 3)
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is special_for_inner_method_call' do
    let(:style) { 'special_for_inner_method_call' }
    let(:indentation_width) { 2 }

    include_examples 'common behavior'

    context 'for method calls within method calls' do
      context 'with outer parentheses' do
        it 'registers an offense for an over-indented first parameter' do
          expect_offense(<<-RUBY.strip_indent)
            run(:foo, defaults.merge(
                                    bar: 3))
                                    ^^^^^^ Indent the first parameter one step more than `defaults.merge(`.
          RUBY
        end
      end

      context 'without outer parentheses' do
        it 'accepts a first parameter with special indentation' do
          expect_no_offenses(<<-RUBY.strip_indent)
            run :foo, defaults.merge(
                        bar: 3)
          RUBY
        end
      end

      it 'auto-corrects an over-indented first parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
                                  bar: 3))
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
                      bar: 3))
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is ' \
          'special_for_inner_method_call_in_parentheses' do
    let(:style) { 'special_for_inner_method_call_in_parentheses' }
    let(:indentation_width) { 2 }

    include_examples 'common behavior'

    context 'for method calls within method calls' do
      context 'with outer parentheses' do
        it 'registers an offense for an over-indented first parameter' do
          expect_offense(<<-RUBY.strip_indent)
            run(:foo, defaults.merge(
                                    bar: 3))
                                    ^^^^^^ Indent the first parameter one step more than `defaults.merge(`.
          RUBY
        end

        it 'registers an offense for an under-indented first parameter' do
          expect_offense(<<-RUBY.strip_indent)
            run(:foo, defaults.
                      merge(
              bar: 3))
              ^^^^^^ Indent the first parameter one step more than the start of the previous line.
          RUBY
        end

        it 'accepts a correctly indented first parameter in interpolation' do
          expect_no_offenses(<<-'RUBY'.strip_indent)
            puts %(
              <p>
                #{Array(
                  42
                )}
              </p>
            )
          RUBY
        end

        it 'accepts a correctly indented first parameter with fullwidth ' \
           'characters' do
          inspect_source(<<-RUBY.strip_indent)
            puts('Ｒｕｂｙ', f(
                               a))
          RUBY
          expect(cop.offenses).to be_empty
        end
      end

      context 'without outer parentheses' do
        it 'accepts a first parameter with consistent style indentation' do
          expect_no_offenses(<<-RUBY.strip_indent)
            run :foo, defaults.merge(
              bar: 3)
          RUBY
        end
      end

      it 'auto-corrects an over-indented first parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
                                  bar: 3))
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
                      bar: 3))
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is consistent' do
    let(:style) { 'consistent' }
    let(:indentation_width) { 2 }

    include_examples 'common behavior'

    context 'for method calls within method calls' do
      it 'registers an offense for an over-indented first parameter' do
        expect_offense(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
                      bar: 3))
                      ^^^^^^ Indent the first parameter one step more than the start of the previous line.
        RUBY
      end

      it 'accepts first parameter indented relative to previous line' do
        expect_no_offenses(<<-RUBY.strip_indent)
            @diagnostics.process(Diagnostic.new(
              :error, :token, { :token => name }, location))
        RUBY
      end

      it 'auto-corrects an over-indented first parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
                                  bar: 3))
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          run(:foo, defaults.merge(
            bar: 3))
        RUBY
      end
    end
  end
end
