# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::CaseIndentation, :config do
  let(:config) do
    merged = RuboCop::ConfigLoader.default_configuration['Layout/CaseIndentation'].merge(cop_config)
    RuboCop::Config.new('Layout/CaseIndentation' => merged,
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end

  context 'with EnforcedStyle: case' do
    context 'with IndentOneStep: false' do
      let(:cop_config) { { 'EnforcedStyle' => 'case', 'IndentOneStep' => false } }

      describe '`case` ... `when`' do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; when :bar then 1; else 0; end')
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                       when 'value1'
                         'output1'
                       else
                         'output2'
                       end
            RUBY
          end

          it 'registers an offense and corrects assignment indented as end' do
            expect_offense(<<~RUBY)
              output = case variable
              when 'value1'
              ^^^^ Indent `when` as deep as `case`.
                'output1'
              else
                'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       when 'value1'
                'output1'
              else
                'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                when 'value1'
                ^^^^ Indent `when` as deep as `case`.
                  'output1'
                else
                  'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       when 'value1'
                  'output1'
                else
                  'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects correct + opposite style' do
            expect_offense(<<~RUBY)
              output = case variable
                       when 'value1'
                         'output1'
                       else
                         'output2'
                       end
              output = case variable
              when 'value1'
              ^^^^ Indent `when` as deep as `case`.
                'output1'
              else
                'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       when 'value1'
                         'output1'
                       else
                         'output2'
                       end
              output = case variable
                       when 'value1'
                'output1'
              else
                'output2'
              end
            RUBY
          end
        end

        it 'registers an offense and corrects a `when` clause that is indented deeper than `case`' do
          expect_offense(<<~RUBY)
            case a
                when 0 then return
                ^^^^ Indent `when` as deep as `case`.
                else
                    case b
                     when 1 then return
                     ^^^^ Indent `when` as deep as `case`.
                    end
            end
          RUBY

          expect_correction(<<~RUBY)
            case a
            when 0 then return
                else
                    case b
                    when 1 then return
                    end
            end
          RUBY
        end

        it "accepts a `when` clause that's equally indented with `case`" do
          expect_no_offenses(<<~RUBY)
            y = case a
                when 0 then break
                when 0 then return
                else
                  z = case b
                      when 1 then return
                      when 1 then break
                      end
                end
            case c
            when 2 then encoding
            end
          RUBY
        end

        it "doesn't get confused by strings with `case` in them" do
          expect_no_offenses(<<~RUBY)
            a = "case"
            case x
            when 0
            end
          RUBY
        end

        it "doesn't get confused by symbols named `case` or `when`" do
          expect_no_offenses(<<~RUBY)
            KEYWORDS = { :case => true, :when => true }
            case type
            when 0
              ParameterNode
            when 1
              MethodCallNode
            end
          RUBY
        end

        it 'accepts correctly indented whens in complex combinations' do
          expect_no_offenses(<<~RUBY)
            each {
              case state
              when 0
                case name
                when :a
                end
              when 1
                loop {
                  case name
                  when :b
                  end
                }
              end
            }
            case s
            when Array
            end
          RUBY
        end
      end

      describe '`case` ... `in`', :ruby27 do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; in pattern then 1; else 0; end')
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                       in pattern
                         'output1'
                       else
                         'output2'
                       end
            RUBY
          end

          it 'registers an offense and corrects assignment indented as `end`' do
            expect_offense(<<~RUBY)
              output = case variable
              in pattern
              ^^ Indent `in` as deep as `case`.
                'output1'
              else
                'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       in pattern
                'output1'
              else
                'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                in pattern
                ^^ Indent `in` as deep as `case`.
                  'output1'
                else
                  'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       in pattern
                  'output1'
                else
                  'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects correct + opposite style' do
            expect_offense(<<~RUBY)
              output = case variable
                       in pattern
                         'output1'
                       else
                         'output2'
                       end
              output = case variable
              in pattern
              ^^ Indent `in` as deep as `case`.
                'output1'
              else
                'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       in pattern
                         'output1'
                       else
                         'output2'
                       end
              output = case variable
                       in pattern
                'output1'
              else
                'output2'
              end
            RUBY
          end
        end

        it 'registers an offense and corrects an `in` clause that is indented deeper than `case`' do
          expect_offense(<<~RUBY)
            case a
                in 0 then return
                ^^ Indent `in` as deep as `case`.
                else
                    case b
                     in 1 then return
                     ^^ Indent `in` as deep as `case`.
                    end
            end
          RUBY

          expect_correction(<<~RUBY)
            case a
            in 0 then return
                else
                    case b
                    in 1 then return
                    end
            end
          RUBY
        end

        it "accepts an `in` clause that's equally indented with `case`" do
          expect_no_offenses(<<~RUBY)
            y = case a
                in 0 then break
                in 0 then return
                else
                  z = case b
                      in 1 then return
                      in 1 then break
                      end
                end
            case c
            in 2 then encoding
            end
          RUBY
        end

        it "doesn't get confused by strings with `case` in them" do
          expect_no_offenses(<<~RUBY)
            a = "case"
            case x
            when 0
            end
          RUBY
        end

        it "doesn't get confused by symbols named `case` or `in`" do
          expect_no_offenses(<<~RUBY)
            KEYWORDS = { :case => true, :in => true }
            case type
            in 0
              ParameterNode
            in 1
              MethodCallNode
            end
          RUBY
        end

        it 'accepts correctly indented whens in complex combinations' do
          expect_no_offenses(<<~RUBY)
            each {
              case state
              in 0
                case name
                in :a
                end
              in 1
                loop {
                  case name
                  in :b
                  end
                }
              end
            }
            case s
            in Array
            end
          RUBY
        end
      end
    end

    context 'with IndentOneStep: true' do
      let(:cop_config) { { 'EnforcedStyle' => 'case', 'IndentOneStep' => true } }

      describe '`case` ... `when`' do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; when :bar then 1; else 0; end')
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                         when 'value1'
                           'output1'
                         else
                           'output2'
                       end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                       when 'value1'
                       ^^^^ Indent `when` one step more than `case`.
                         'output1'
                       else
                         'output2'
                       end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                         when 'value1'
                         'output1'
                       else
                         'output2'
                       end
            RUBY
          end
        end

        it "accepts a `when` clause that's 2 spaces deeper than `case`" do
          expect_no_offenses(<<~RUBY)
            case a
              when 0 then return
              else
                    case b
                      when 1 then return
                    end
            end
          RUBY
        end

        it 'registers an offense and corrects a `when` clause that is equally indented with `case`' do
          expect_offense(<<~RUBY)
            y = case a
                when 0 then break
                ^^^^ Indent `when` one step more than `case`.
                when 0 then return
                ^^^^ Indent `when` one step more than `case`.
                  z = case b
                      when 1 then return
                      ^^^^ Indent `when` one step more than `case`.
                      when 1 then break
                      ^^^^ Indent `when` one step more than `case`.
                      end
                end
            case c
            when 2 then encoding
            ^^^^ Indent `when` one step more than `case`.
            end
          RUBY

          expect_correction(<<~RUBY)
            y = case a
                  when 0 then break
                  when 0 then return
                  z = case b
                        when 1 then return
                        when 1 then break
                      end
                end
            case c
              when 2 then encoding
            end
          RUBY
        end

        context 'when indentation width is overridden for this cop only' do
          let(:cop_config) do
            {
              'EnforcedStyle' => 'case',
              'IndentOneStep' => true,
              'IndentationWidth' => 5
            }
          end

          it 'respects cop-specific IndentationWidth' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                            when 'value1'
                           'output1'
                            else
                           'output2'
                       end
            RUBY
          end
        end
      end

      describe '`case` ... `in`', :ruby27 do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; in pattern then 1; else 0; end')
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                         in pattern
                           'output1'
                         else
                           'output2'
                       end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                       in pattern
                       ^^ Indent `in` one step more than `case`.
                         'output1'
                       else
                         'output2'
                       end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                         in pattern
                         'output1'
                       else
                         'output2'
                       end
            RUBY
          end
        end

        it "accepts an `in` clause that's 2 spaces deeper than `case`" do
          expect_no_offenses(<<~RUBY)
            case a
              in 0 then return
              else
                    case b
                      in 1 then return
                    end
            end
          RUBY
        end

        it 'registers an offense and corrects an `in` clause that is equally indented with `case`' do
          expect_offense(<<~RUBY)
            y = case a
                in 0 then break
                ^^ Indent `in` one step more than `case`.
                in 0 then return
                ^^ Indent `in` one step more than `case`.
                  z = case b
                      in 1 then return
                      ^^ Indent `in` one step more than `case`.
                      in 1 then break
                      ^^ Indent `in` one step more than `case`.
                      end
                end
            case c
            in 2 then encoding
            ^^ Indent `in` one step more than `case`.
            end
          RUBY

          expect_correction(<<~RUBY)
            y = case a
                  in 0 then break
                  in 0 then return
                  z = case b
                        in 1 then return
                        in 1 then break
                      end
                end
            case c
              in 2 then encoding
            end
          RUBY
        end

        context 'when indentation width is overridden for this cop only' do
          let(:cop_config) do
            {
              'EnforcedStyle' => 'case',
              'IndentOneStep' => true,
              'IndentationWidth' => 5
            }
          end

          it 'respects cop-specific IndentationWidth' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                            in pattern
                           'output1'
                            else
                           'output2'
                       end
            RUBY
          end
        end
      end
    end
  end

  context 'with EnforcedStyle: end' do
    context 'with IndentOneStep: false' do
      let(:cop_config) { { 'EnforcedStyle' => 'end', 'IndentOneStep' => false } }

      describe '`case` ... `when`' do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; when :bar then 1; else 0; end')
          end
        end

        context '`else` and `end` same line' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              case variable
              when 'value1'
              when 'value2'
              else 'value3' end
            RUBY
          end
        end

        context '`when` and `end` same line' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              case variable
              when 'value1' then 'then1'
              when 'value2' then 'then2' end
            RUBY
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
              when 'value1'
                'output1'
              else
                'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                when 'value1'
                ^^^^ Indent `when` as deep as `end`.
                  'output1'
                else
                  'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
              when 'value1'
                  'output1'
                else
                  'output2'
              end
            RUBY
          end
        end
      end

      describe '`case` ... `in`', :ruby27 do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; in pattern then 1; else 0; end')
          end
        end

        context '`in` and `end` same line' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              case variable
              in pattern then 'output1'
              in pattern then 'output2' end
            RUBY
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
              in pattern
                'output1'
              else
                'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                in pattern
                ^^ Indent `in` as deep as `end`.
                  'output1'
                else
                  'output2'
              end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
              in pattern
                  'output1'
                else
                  'output2'
              end
            RUBY
          end
        end
      end
    end

    context 'with IndentOneStep: true' do
      let(:cop_config) { { 'EnforcedStyle' => 'end', 'IndentOneStep' => true } }

      describe '`case` ... `when`' do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; when :bar then 1; else 0; end')
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                when 'value1'
                  'output1'
                else
                  'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented as `case`' do
            expect_offense(<<~RUBY)
              output = case variable
                       when 'value1'
                       ^^^^ Indent `when` one step more than `end`.
                         'output1'
                       else
                         'output2'
                       end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                         when 'value1'
                         'output1'
                       else
                         'output2'
                       end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                     when 'value1'
                     ^^^^ Indent `when` one step more than `end`.
                       'output1'
                     else
                       'output2'
                     end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       when 'value1'
                       'output1'
                     else
                       'output2'
                     end
            RUBY
          end
        end
      end

      describe '`case` ... `in`', :ruby27 do
        context 'with everything on a single line' do
          it 'does not register an offense' do
            expect_no_offenses('case foo; in pattern then 1; else 0; end')
          end
        end

        context 'regarding assignment where the right hand side is a `case`' do
          it 'accepts a correctly indented assignment' do
            expect_no_offenses(<<~RUBY)
              output = case variable
                in pattern
                  'output1'
                else
                  'output2'
              end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented as `case`' do
            expect_offense(<<~RUBY)
              output = case variable
                       in pattern
                       ^^ Indent `in` one step more than `end`.
                         'output1'
                       else
                         'output2'
                       end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                         in pattern
                         'output1'
                       else
                         'output2'
                       end
            RUBY
          end

          it 'registers an offense and corrects an assignment indented some other way' do
            expect_offense(<<~RUBY)
              output = case variable
                     in pattern
                     ^^ Indent `in` one step more than `end`.
                       'output1'
                     else
                       'output2'
                     end
            RUBY

            expect_correction(<<~RUBY)
              output = case variable
                       in pattern
                       'output1'
                     else
                       'output2'
                     end
            RUBY
          end
        end
      end
    end
  end

  context 'when `when` is on the same line as `case`' do
    let(:cop_config) { {} }

    it 'registers an offense but does not autocorrect' do
      expect_offense(<<~RUBY)
        case test when something
                  ^^^^ Indent `when` as deep as `case`.
        end
      RUBY

      expect_no_corrections
    end
  end
end
