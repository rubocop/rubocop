# frozen_string_literal: true

describe RuboCop::Cop::Style::SafeNavigation, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'ConvertCodeThatCanStartToReturnNil' => false } }

  let(:message) do
    'Use safe navigation (`&.`) instead of checking if an object ' \
      'exists before calling the method.'
  end

  context 'target_ruby_version > 2.3', :ruby23 do
    it 'allows calls to methods not safeguarded by respond_to' do
      expect_no_offenses('foo.bar')
    end

    it 'allows calls using safe navigation' do
      expect_no_offenses('foo&.bar')
    end

    it 'allows calls on nil' do
      expect_no_offenses('nil&.bar')
    end

    it 'allows method calls that nil responds to safe guarded by ' \
      'an object check' do
      inspect_source(cop, 'foo.to_i if foo')

      expect(cop.offenses).to be_empty
    end

    it 'allows method calls that do not get called using . safe guarded by ' \
      'an object check' do
      inspect_source(cop, 'foo + bar if foo')

      expect(cop.offenses).to be_empty
    end

    it 'allows object checks in the condition of an elsif statement ' \
      'and a method call on that object in the body' do
      inspect_source(cop, <<-RUBY.strip_indent)
        if foo
          something
        elsif bar
          bar.baz
        end
      RUBY

      expect(cop.offenses).to be_empty
    end

    shared_examples 'all variable types' do |variable|
      context 'modifier if' do
        it 'registers an offense for a method call on an accessor ' \
          'safeguarded by a check for the accessed variable' do
          inspect_source(cop, "#{variable}[1].bar if #{variable}[1]")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call safeguarded with a check ' \
          'for the object' do
          inspect_source(cop, "#{variable}.bar if #{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) if #{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a check for the object' do
          inspect_source(cop, "#{variable}.bar { |e| e.qux } if #{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a check for the object' do
          inspect_source(cop,
                         "#{variable}.bar(baz) { |e| e.qux } if #{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call safeguarded with a ' \
          'negative check for the object' do
          inspect_source(cop, "#{variable}.bar unless !#{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a negative check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) unless !#{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a negative check for the object' do
          inspect_source(cop,
                         "#{variable}.bar { |e| e.qux } unless !#{variable}")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a negative check for the object' do
          source = "#{variable}.bar(baz) { |e| e.qux } unless !#{variable}"

          inspect_source(cop, source)

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call safeguarded with a nil ' \
          'check for the object' do
          inspect_source(cop, "#{variable}.bar unless #{variable}.nil?")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a nil check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) unless #{variable}.nil?")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a nil check for the object' do
          source = "#{variable}.bar { |e| e.qux } unless #{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a nil check for the object' do
          source = "#{variable}.bar(baz) { |e| e.qux } unless #{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call safeguarded with a ' \
          'negative nil check for the object' do
          inspect_source(cop, "#{variable}.bar if !#{variable}.nil?")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a negative nil check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) if !#{variable}.nil?")

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a negative nil check for the object' do
          source = "#{variable}.bar { |e| e.qux } if !#{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a negative nil check for the object' do
          source = "#{variable}.bar(baz) { |e| e.qux } if !#{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([message])
        end
      end

      context 'if expression' do
        it 'registers an offense for a single method call inside of a check ' \
          'for the object' do
          inspect_source(cop, <<-RUBY.strip_indent)
            if #{variable}
              #{variable}.bar
            end
          RUBY

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a single method call inside of a ' \
          'non-nil check for the object' do
          inspect_source(cop, <<-RUBY.strip_indent)
            if !#{variable}.nil?
              #{variable}.bar
            end
          RUBY

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a single method call inside of an ' \
          'unless nil check for the object' do
          inspect_source(cop, <<-RUBY.strip_indent)
            unless #{variable}.nil?
              #{variable}.bar
            end
          RUBY

          expect(cop.messages).to eq([message])
        end

        it 'registers an offense for a single method call inside of an ' \
          'unless negative check for the object' do
          inspect_source(cop, <<-RUBY.strip_indent)
            unless !#{variable}
              #{variable}.bar
            end
          RUBY

          expect(cop.messages).to eq([message])
        end

        it 'accepts a single method call inside of a check for the object ' \
           'with an else' do
          inspect_source(cop, <<-RUBY.strip_indent)
            if #{variable}
              #{variable}.bar
            else
              something
            end
          RUBY

          expect(cop.offenses).to be_empty
        end

        context 'ternary expression' do
          it 'accepts ternary expression' do
            source = "!#{variable}.nil? ? #{variable}.bar : something"
            inspect_source(cop, source)

            expect(cop.offenses).to be_empty
          end
        end
      end

      context 'object check before method call' do
        context 'ConvertCodeThatCanStartToReturnNil true' do
          let(:cop_config) { { 'ConvertCodeThatCanStartToReturnNil' => true } }

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call' do
            inspect_source(cop, "!#{variable}.nil? && #{variable}.bar")

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call with params' do
            inspect_source(cop, "!#{variable}.nil? && #{variable}.bar(baz)")

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call with a block' do
            source = "!#{variable}.nil? && #{variable}.bar { |e| e.qux }"

            inspect_source(cop, source)

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call with params and a block' do
            source = "!#{variable}.nil? && #{variable}.bar(baz) { |e| e.qux }"

            inspect_source(cop, source)

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for an object check followed by a ' \
            'method call' do
            inspect_source(cop, "#{variable} && #{variable}.bar")

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for an object check followed by a ' \
            'method call with params' do
            inspect_source(cop, "#{variable} && #{variable}.bar(baz)")

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for an object check followed by a ' \
            'method call with a block' do
            inspect_source(cop, "#{variable} && #{variable}.bar { |e| e.qux }")

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for an object check followed by a ' \
            'method call with params and a block' do
            source = "#{variable} && #{variable}.bar(baz) { |e| e.qux }"

            inspect_source(cop, source)

            expect(cop.messages).to eq([message])
          end

          it 'registers an offense for a check for the object followed by a ' \
            'method call in the condition for an if expression' do
            inspect_source(cop, <<-RUBY.strip_indent)
              if #{variable} && #{variable}.bar
                something
              end
            RUBY

            expect(cop.messages).to eq([message])
          end
        end

        context 'ConvertCodeThatCanStartToReturnNil false' do
          it 'registers an offense for a non-nil object check followed by a ' \
            'method call' do
            inspect_source(cop, "!#{variable}.nil? && #{variable}.bar")

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call with params' do
            inspect_source(cop, "!#{variable}.nil? && #{variable}.bar(baz)")

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call with a block' do
            source = "!#{variable}.nil? && #{variable}.bar { |e| e.qux }"

            inspect_source(cop, source)

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for a non-nil object check followed by a ' \
            'method call with params and a block' do
            source = "!#{variable}.nil? && #{variable}.bar(baz) { |e| e.qux }"

            inspect_source(cop, source)

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for an object check followed by a ' \
            'method call' do
            inspect_source(cop, "#{variable} && #{variable}.bar")

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for an object check followed by a ' \
            'method call with params' do
            inspect_source(cop, "#{variable} && #{variable}.bar(baz)")

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for an object check followed by a ' \
            'method call with a block' do
            inspect_source(cop, "#{variable} && #{variable}.bar { |e| e.qux }")

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for an object check followed by a ' \
            'method call with params and a block' do
            source = "#{variable} && #{variable}.bar(baz) { |e| e.qux }"

            inspect_source(cop, source)

            expect(cop.offenses).to be_empty
          end

          it 'registers an offense for a check for the object followed by a ' \
            'method call in the condition for an if expression' do
            inspect_source(cop, <<-RUBY.strip_indent)
              if #{variable} && #{variable}.bar
                something
              end
            RUBY

            expect(cop.offenses).to be_empty
          end
        end

        it 'allows a nil object check followed by a method call' do
          inspect_source(cop, "#{variable}.nil? || #{variable}.bar")

          expect(cop.offenses).to be_empty
        end

        it 'allows a nil object check followed by a method call with params' do
          inspect_source(cop, "#{variable}.nil? || #{variable}.bar(baz)")

          expect(cop.offenses).to be_empty
        end

        it 'allows a nil object check followed by a method call with a block' do
          source = "#{variable}.nil? || #{variable}.bar { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.offenses).to be_empty
        end

        it 'allows a nil object check followed by a method call with params ' \
          'and a block' do
          source = "#{variable}.nil? || #{variable}.bar(baz) { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.offenses).to be_empty
        end

        it 'allows a non object check followed by a method call' do
          inspect_source(cop, "!#{variable} || #{variable}.bar")

          expect(cop.offenses).to be_empty
        end

        it 'allows a non object check followed by a method call with params' do
          inspect_source(cop, "!#{variable} || #{variable}.bar(baz)")

          expect(cop.offenses).to be_empty
        end

        it 'allows a non object check followed by a method call with a block' do
          inspect_source(cop, "!#{variable} || #{variable}.bar { |e| e.qux }")

          expect(cop.offenses).to be_empty
        end

        it 'allows a non object check followed by a method call with params ' \
          'and a block' do
          source = "!#{variable} || #{variable}.bar(baz) { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.offenses).to be_empty
        end
      end
    end

    it_behaves_like('all variable types', 'foo')
    it_behaves_like('all variable types', 'FOO')
    it_behaves_like('all variable types', 'FOO::BAR')
    it_behaves_like('all variable types', '@foo')
    it_behaves_like('all variable types', '@@foo')
    it_behaves_like('all variable types', '$FOO')

    context 'respond_to?' do
      it 'allows method calls safeguarded by a respond_to check' do
        expect_no_offenses('foo.bar if foo.respond_to?(:bar)')
      end

      it 'allows method calls safeguarded by a respond_to check to a ' \
        'different method' do
        inspect_source(cop, 'foo.bar if foo.respond_to?(:foobar)')

        expect(cop.offenses).to be_empty
      end

      it 'allows method calls safeguarded by a respond_to check on a' \
        'different variable but the same method' do
        inspect_source(cop, 'foo.bar if baz.respond_to?(:bar)')

        expect(cop.offenses).to be_empty
      end

      it 'allows method calls safeguarded by a respond_to check on a' \
        'different variable and method' do
        inspect_source(cop, 'foo.bar if baz.respond_to?(:foo)')

        expect(cop.offenses).to be_empty
      end

      it 'allows enumerable accessor method calls safeguarded by ' \
        'a respond_to check' do
        inspect_source(cop, 'foo[0] if foo.respond_to?(:[])')

        expect(cop.offenses).to be_empty
      end
    end

    context 'auto-correct' do
      shared_examples 'all variable types' do |variable|
        context 'modifier if' do
          it 'corrects a method call safeguarded with a check for the object' do
            source = "#{variable}.bar if #{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a method call with params safeguarded with a check ' \
            'for the object' do
            source = "#{variable}.bar(baz) if #{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a method call with a block safeguarded with a check ' \
            'for the object' do
            source = "#{variable}.bar { |e| e.qux } if #{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a method call with params and a block safeguarded ' \
            'with a check for the object' do
            source = "#{variable}.bar(baz) { |e| e.qux } if #{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
          end

          it 'corrects a method call safeguarded with a negative check for ' \
            'the object' do
            source = "#{variable}.bar unless !#{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a method call with params safeguarded with a ' \
            'negative check for the object' do
            source = "#{variable}.bar(baz) unless !#{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a method call with a block safeguarded with a ' \
            'negative check for the object' do
            source = "#{variable}.bar { |e| e.qux } unless !#{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a method call with params and a block safeguarded ' \
            'with a negative check for the object' do
            source = "#{variable}.bar(baz) { |e| e.qux } unless !#{variable}"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
          end

          it 'corrects a method call safeguarded with a nil check for the ' \
            'object' do
            source = "#{variable}.bar unless #{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a method call with params safeguarded with a nil ' \
            'check for the object' do
            source = "#{variable}.bar(baz) unless #{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a method call with a block safeguarded with a nil ' \
            'check for the object' do
            source = "#{variable}.bar { |e| e.qux } unless #{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a method call with params and a block safeguarded ' \
            'with a nil check for the object' do
            source =
              "#{variable}.bar(baz) { |e| e.qux } unless #{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
          end

          it 'corrects a method call safeguarded with a negative nil check ' \
            'for the object' do
            source = "#{variable}.bar if !#{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a method call with params safeguarded with a ' \
            'negative nil check for the object' do
            source = "#{variable}.bar(baz) if !#{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a method call with a block safeguarded with a ' \
            'negative nil check for the object' do
            source = "#{variable}.bar { |e| e.qux } if !#{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a method call with params and a block safeguarded ' \
            'with a negative nil check for the object' do
            source = "#{variable}.bar(baz) { |e| e.qux } if !#{variable}.nil?"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
          end

          it 'corrects a method call on an accessor safeguarded by a check ' \
            'for the accessed variable' do
            source = "#{variable}[1].bar if #{variable}[1]"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}[1]&.bar")
          end
        end

        context 'if expression' do
          it 'corrects a single method call inside of a check for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              if #{variable}
                #{variable}.bar
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar\n")
          end

          it 'corrects a single method call with params inside of a check ' \
            'for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              if #{variable}
                #{variable}.bar(baz)
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar(baz)\n")
          end

          it 'corrects a single method call with a block inside of a check ' \
            'for the object' do
            source = <<-RUBY.strip_indent
              if #{variable}
                #{variable}.bar { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }\n")
          end

          it 'corrects a single method call with params and a block inside ' \
            'of a check for the object' do
            source = <<-RUBY.strip_indent
              if #{variable}
                #{variable}.bar(baz) { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }\n")
          end

          it 'corrects a single method call inside of a non-nil check for ' \
            'the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              if !#{variable}.nil?
                #{variable}.bar
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar\n")
          end

          it 'corrects a single method call with params inside of a non-nil ' \
            'check for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              if !#{variable}.nil?
                #{variable}.bar(baz)
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar(baz)\n")
          end

          it 'corrects a single method call with a block inside of a non-nil ' \
            'check for the object' do
            source = <<-RUBY.strip_indent
              if !#{variable}.nil?
                #{variable}.bar { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }\n")
          end

          it 'corrects a single method call with params and a block inside ' \
            'of a non-nil check for the object' do
            source = <<-RUBY.strip_indent
              if !#{variable}.nil?
                #{variable}.bar(baz) { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }\n")
          end

          it 'corrects a single method call inside of an unless nil check ' \
            'for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              unless #{variable}.nil?
                #{variable}.bar
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar\n")
          end

          it 'corrects a single method call with params inside of an unless ' \
            'nil check for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              unless #{variable}.nil?
                #{variable}.bar(baz)
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar(baz)\n")
          end

          it 'corrects a single method call with a block inside of an unless ' \
            'nil check for the object' do
            source = <<-RUBY.strip_indent
              unless #{variable}.nil?
                #{variable}.bar { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }\n")
          end

          it 'corrects a single method call with params and a block inside ' \
            'of an unless nil check for the object' do
            source = <<-RUBY.strip_indent
              unless #{variable}.nil?
                #{variable}.bar(baz) { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }\n")
          end

          it 'corrects a single method call inside of an unless negative ' \
            'check for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              unless !#{variable}
                #{variable}.bar
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar\n")
          end

          it 'corrects a single method call with params inside of an unless ' \
            'negative check for the object' do
            new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
              unless !#{variable}
                #{variable}.bar(baz)
              end
            RUBY

            expect(new_source).to eq("#{variable}&.bar(baz)\n")
          end

          it 'corrects a single method call with a block inside of an unless ' \
            'negative check for the object' do
            source = <<-RUBY.strip_indent
              unless !#{variable}
                #{variable}.bar { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }\n")
          end

          it 'corrects a single method call with params and a block inside ' \
            'of an unless negative check for the object' do
            source = <<-RUBY.strip_indent
              unless !#{variable}
                #{variable}.bar(baz) { |e| e.qux }
              end
            RUBY
            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }\n")
          end
        end

        context 'object check before method call' do
          context 'ConvertCodeThatCanStartToReturnNil true' do
            let(:cop_config) do
              { 'ConvertCodeThatCanStartToReturnNil' => true }
            end

            it 'corrects an object check followed by a method call' do
              source = "#{variable} && #{variable}.bar"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar")
            end

            it 'corrects an object check followed by a method call ' \
              'with params' do
              source = "#{variable} && #{variable}.bar(baz)"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar(baz)")
            end

            it 'corrects an object check followed by a method call with ' \
              'a block' do
              source = "#{variable} && #{variable}.bar { |e| e.qux }"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
            end

            it 'corrects an object check followed by a method call with ' \
              'params and a block' do
              source = "#{variable} && #{variable}.bar(baz) { |e| e.qux }"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
            end

            it 'corrects a non-nil object check followed by a method call' do
              source = "!#{variable}.nil? && #{variable}.bar"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar")
            end

            it 'corrects a non-nil object check followed by a method call ' \
              'with params' do
              source = "!#{variable}.nil? && #{variable}.bar(baz)"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar(baz)")
            end

            it 'corrects a non-nil object check followed by a method call ' \
              'with a block' do
              source = "!#{variable}.nil? && #{variable}.bar { |e| e.qux }"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
            end

            it 'corrects a non-nil object check followed by a method call ' \
              'with params and a block' do
              source = "!#{variable}.nil? && #{variable}.bar(baz) { |e| e.qux }"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
            end

            it 'corrects an object check followed by a method call and ' \
              'another check' do
              source = "#{variable} && #{variable}.bar && something"

              new_source = autocorrect_source(cop, source)

              expect(new_source).to eq("#{variable}&.bar && something")
            end
          end
        end
      end

      it_behaves_like('all variable types', 'foo')
      it_behaves_like('all variable types', 'FOO')
      it_behaves_like('all variable types', 'FOO::BAR')
      it_behaves_like('all variable types', '@foo')
      it_behaves_like('all variable types', '@@foo')
      it_behaves_like('all variable types', '$FOO')
    end
  end

  context 'target_ruby_version < 2.3', :ruby19 do
    it 'allows a method call safeguarded by a check for the variable' do
      expect_no_offenses('foo.bar if foo')
    end
  end
end
