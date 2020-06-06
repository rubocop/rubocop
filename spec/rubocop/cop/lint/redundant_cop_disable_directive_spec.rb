# frozen_string_literal: true

require 'rubocop/cop/legacy/corrector'

RSpec.describe RuboCop::Cop::Lint::RedundantCopDisableDirective, :config do
  describe '.check' do
    subject(:resulting_offenses) { cop.send(:complete_investigation).offenses }

    let(:offenses) { [] }
    let(:cop) { cop_class.new(config, cop_options, offenses) }

    before { $stderr = StringIO.new } # rubocop:disable RSpec/ExpectOutput

    context 'when there are no disabled lines' do
      let(:source) { '' }

      it 'returns no offense' do
        expect_no_offenses(source)
      end
    end

    context 'when there are disabled lines' do
      context 'and there are no offenses' do
        context 'and a comment disables' do
          context 'one cop' do
            it 'returns an offense' do
              expect_offense(<<~RUBY)
                # rubocop:disable Metrics/MethodLength
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Metrics/MethodLength`.
              RUBY
              expect_correction('')
            end
          end

          context 'an unknown cop' do
            it 'returns an offense' do
              expect_offense(<<~RUBY)
                # rubocop:disable UnknownCop
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `UnknownCop` (unknown cop).
              RUBY
              expect_correction('')
            end
          end

          context 'itself and another cop' do
            context 'disabled on the same range' do
              it 'returns no offense' do
                expect_no_offenses(<<~RUBY)
                  # rubocop:disable Lint/RedundantCopDisableDirective, Metrics/ClassLength
                RUBY
              end
            end

            context 'disabled on different ranges' do
              it 'returns no offense' do
                expect_no_offenses(<<~RUBY)
                  # rubocop:disable Lint/RedundantCopDisableDirective
                  # rubocop:disable Metrics/ClassLength
                RUBY
              end
            end

            context 'and the other cop is disabled a second time' do
              let(:source) do
                ['# rubocop:disable Lint/RedundantCopDisableDirective',
                 '# rubocop:disable Metrics/ClassLength',
                 '# rubocop:disable Metrics/ClassLength'].join("\n")
              end

              it 'returns no offense' do
                expect_no_offenses(source)
              end
            end
          end

          context 'multiple cops' do
            it 'returns an offense' do
              expect_offense(<<~RUBY.gsub("<\n", '')) # Wrap lines & avoid issue with JRuby
                # rubocop:disable Metrics/MethodLength, Metrics/ClassLength
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ <
                Unnecessary disabling of `Metrics/ClassLength`, `Metrics/MethodLength`.
              RUBY
            end
          end

          context 'multiple cops, and one of them has offenses' do
            let(:offenses) do
              [
                RuboCop::Cop::Offense.new(:convention,
                                          OpenStruct.new(line: 7, column: 0),
                                          'Class has too many lines.',
                                          'Metrics/ClassLength')
              ]
            end

            it 'returns an offense' do
              expect_offense(<<~RUBY.gsub("<\n", '')) # Wrap lines & avoid issue with JRuby
                # rubocop:disable Metrics/MethodLength, Metrics/ClassLength, Lint/Debugger, <
                Lint/AmbiguousOperator
                                  ^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Metrics/MethodLength`.
                                                                             ^^^^^^^^^^^^^ Unnecessary disabling of `Lint/Debugger`.
                                                                                            <
                ^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Lint/AmbiguousOperator`.
              RUBY
              expect_correction(<<~RUBY)
                # rubocop:disable Metrics/ClassLength
              RUBY
            end
          end

          context 'multiple cops, and the leftmost one has no offenses' do
            let(:offenses) do
              [
                RuboCop::Cop::Offense.new(:convention,
                                          OpenStruct.new(line: 7, column: 0),
                                          'Method has too many lines.',
                                          'Metrics/MethodLength')
              ]
            end

            it 'returns an offense' do
              expect_offense(<<~RUBY)
                # rubocop:disable Metrics/ClassLength, Metrics/MethodLength
                                  ^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Metrics/ClassLength`.
              RUBY
              expect_correction(<<~RUBY)
                # rubocop:disable Metrics/MethodLength
              RUBY
            end
          end

          context 'multiple cops, with abbreviated names' do
            context 'one of them has offenses' do
              let(:offenses) do
                [
                  RuboCop::Cop::Offense.new(:convention,
                                            OpenStruct.new(line: 4, column: 0),
                                            'Method has too many lines.',
                                            'Metrics/MethodLength')
                ]
              end

              it 'returns an offense' do
                expect_offense(<<~RUBY)
                  puts 1
                  # rubocop:disable MethodLength, ClassLength, Debugger
                                                  ^^^^^^^^^^^ Unnecessary disabling of `Metrics/ClassLength`.
                                                               ^^^^^^^^ Unnecessary disabling of `Lint/Debugger`.
                  #
                  # offense here
                RUBY

                expect($stderr.string).to eq(<<~OUTPUT)
                  (string): Warning: no department given for MethodLength.
                  (string): Warning: no department given for ClassLength.
                  (string): Warning: no department given for Debugger.
                OUTPUT
              end
            end
          end

          context 'comment is not at the beginning of the file' do
            context 'and not all cops have offenses' do
              let(:offenses) do
                [
                  RuboCop::Cop::Offense.new(:convention,
                                            OpenStruct.new(line: 4, column: 0),
                                            'Method has too many lines.',
                                            'Metrics/MethodLength')
                ]
              end

              it 'returns an offense' do
                expect_offense(<<~RUBY)
                  puts 1
                  # rubocop:disable Metrics/MethodLength, Metrics/ClassLength
                                                          ^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Metrics/ClassLength`.
                  #
                  # offense here
                RUBY
              end
            end
          end

          context 'misspelled cops' do
            it 'returns an offense' do
              message = 'Unnecessary disabling of `KlassLength` (unknown ' \
                        'cop), `Metrics/MethodLenght` (did you mean ' \
                        '`Metrics/MethodLength`?).'

              expect_offense(<<~RUBY)
                # rubocop:disable Metrics/MethodLenght, KlassLength
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
              RUBY
            end
          end

          context 'all cops' do
            it 'returns an offense' do
              expect_offense(<<~RUBY)
                # rubocop : disable all
                ^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of all cops.
              RUBY
            end
          end

          context 'itself and all cops' do
            context 'disabled on different ranges' do
              let(:source) do
                ['# rubocop:disable Lint/RedundantCopDisableDirective',
                 '# rubocop:disable all'].join("\n")
              end

              it 'returns no offense' do
                expect_no_offenses(source)
              end
            end
          end
        end
      end

      context 'and there are two offenses' do
        let(:message) do
          'Replace class var @@class_var with a class instance var.'
        end
        let(:cop_name) { 'Style/ClassVars' }
        let(:offenses) do
          offense_lines.map do |line|
            RuboCop::Cop::Offense.new(:convention,
                                      OpenStruct.new(line: line, column: 3),
                                      message,
                                      cop_name)
          end
        end

        context 'and a comment disables' do
          context 'one cop twice' do
            let(:offense_lines) { [3, 8] }

            it 'returns an offense' do
              expect_offense(<<~RUBY)
                class One
                  # rubocop:disable Style/ClassVars
                  @@class_var = 1  # offense here
                end

                class Two
                  # rubocop:disable Style/ClassVars
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Style/ClassVars`.
                  @@class_var = 2  # offense and here
                  # rubocop:enable Style/ClassVars
                end
              RUBY
            end
          end

          context 'one cop and then all cops' do
            let(:offense_lines) { [4] }

            it 'returns an offense' do
              expect_offense(<<~RUBY)
                class One
                  # rubocop:disable Style/ClassVars
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Style/ClassVars`.
                  # rubocop:disable all
                  @@class_var = 1
                  # offense here
                end
              RUBY
            end
          end
        end
      end

      context 'and there is an offense' do
        let(:offenses) do
          [
            RuboCop::Cop::Offense.new(:convention,
                                      OpenStruct.new(line: 3, column: 0),
                                      'Tab detected.',
                                      'Layout/IndentationStyle')
          ]
        end

        context 'and a comment disables' do
          context 'that cop' do
            let(:source) { '# rubocop:disable Layout/IndentationStyle' }

            it 'returns no offense' do
              expect_no_offenses(source)
            end
          end

          context 'that cop but on other lines' do
            it 'returns an offense' do
              expect_offense(<<~RUBY)
                # 1
                # 2
                # 3, offense here
                # 4
                # rubocop:disable Layout/IndentationStyle
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary disabling of `Layout/IndentationStyle`.
                #
                # rubocop:enable Layout/IndentationStyle
              RUBY
            end
          end

          context 'all cops' do
            let(:source) { '# rubocop : disable all' }

            it 'returns no offense' do
              expect_no_offenses(source)
            end
          end
        end
      end
    end
  end
end
