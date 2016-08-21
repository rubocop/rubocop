# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe RuboCop::Cop::Style::SafeNavigation, :config do
  subject(:cop) { described_class.new(config) }

  it 'allows calls to methods not safeguarded by respond_to' do
    inspect_source(cop, 'foo.bar')

    expect(cop.offenses).to be_empty
  end

  context 'target_ruby_version > 2.3', :ruby23 do
    it 'allows calls using safe navigation' do
      inspect_source(cop, 'foo&.bar')

      expect(cop.offenses).to be_empty
    end

    it 'allows calls on nil' do
      inspect_source(cop, 'nil&.bar')

      expect(cop.offenses).to be_empty
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

    shared_examples 'all variable types' do |variable|
      context 'modifier if' do
        it 'registers an offense for a method call on an accessor ' \
          'safeguarded by a check for the accessed variable' do
          inspect_source(cop, "#{variable}[1].bar if #{variable}[1]")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call safeguarded with a check ' \
          'for the object' do
          inspect_source(cop, "#{variable}.bar if #{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) if #{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a check for the object' do
          inspect_source(cop, "#{variable}.bar { |e| e.qux } if #{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a check for the object' do
          inspect_source(cop,
                         "#{variable}.bar(baz) { |e| e.qux } if #{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call safeguarded with a ' \
          'negative check for the object' do
          inspect_source(cop, "#{variable}.bar unless !#{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a negative check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) unless !#{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a negative check for the object' do
          inspect_source(cop,
                         "#{variable}.bar { |e| e.qux } unless !#{variable}")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a negative check for the object' do
          source = "#{variable}.bar(baz) { |e| e.qux } unless !#{variable}"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call safeguarded with a nil ' \
          'check for the object' do
          inspect_source(cop, "#{variable}.bar unless #{variable}.nil?")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a nil check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) unless #{variable}.nil?")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a nil check for the object' do
          source = "#{variable}.bar { |e| e.qux } unless #{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a nil check for the object' do
          source = "#{variable}.bar(baz) { |e| e.qux } unless #{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call safeguarded with a ' \
          'negative nil check for the object' do
          inspect_source(cop, "#{variable}.bar if !#{variable}.nil?")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params safeguarded ' \
          'with a negative nil check for the object' do
          inspect_source(cop, "#{variable}.bar(baz) if !#{variable}.nil?")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with a block safeguarded ' \
          'with a negative nil check for the object' do
          source = "#{variable}.bar { |e| e.qux } if !#{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a method call with params and a block ' \
          'safeguarded with a negative nil check for the object' do
          source = "#{variable}.bar(baz) { |e| e.qux } if !#{variable}.nil?"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end
      end

      context 'object check before method call' do
        it 'registers an offense for an object check followed by a ' \
          'method call' do
          inspect_source(cop, "#{variable} && #{variable}.bar")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for an object check followed by a ' \
          'method call with params' do
          inspect_source(cop, "#{variable} && #{variable}.bar(baz)")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for an object check followed by a ' \
          'method call with a block' do
          inspect_source(cop, "#{variable} && #{variable}.bar { |e| e.qux }")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for an object check followed by a ' \
          'method call with params and a block' do
          source = "#{variable} && #{variable}.bar(baz) { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non nil object check followed by a ' \
          'method call' do
          inspect_source(cop, "!#{variable}.nil? && #{variable}.bar")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non nil object check followed by a ' \
          'method call with params' do
          inspect_source(cop, "!#{variable}.nil? && #{variable}.bar(baz)")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non nil object check followed by a ' \
          'method call with a block' do
          source = "!#{variable}.nil? && #{variable}.bar { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non nil object check followed by a ' \
          'method call with params and a block' do
          source = "!#{variable}.nil? && #{variable}.bar(baz) { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a nil object check followed by a ' \
          'method call' do
          inspect_source(cop, "#{variable}.nil? || #{variable}.bar")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a nil object check followed by a ' \
          'method call with params' do
          inspect_source(cop, "#{variable}.nil? || #{variable}.bar(baz)")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a nil object check followed by a ' \
          'method call with a block' do
          source = "#{variable}.nil? || #{variable}.bar { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a nil object check followed by a ' \
          'method call with params and a block' do
          source = "#{variable}.nil? || #{variable}.bar(baz) { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non object check followed by a ' \
          'method call' do
          inspect_source(cop, "!#{variable} || #{variable}.bar")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non object check followed by a ' \
          'method call with params' do
          inspect_source(cop, "!#{variable} || #{variable}.bar(baz)")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non object check followed by a ' \
          'method call with a block' do
          inspect_source(cop, "!#{variable} || #{variable}.bar { |e| e.qux }")

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for a non object check followed by a ' \
          'method call with params and a block' do
          source = "!#{variable} || #{variable}.bar(baz) { |e| e.qux }"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
        end

        it 'registers an offense for an object check followed by a ' \
          'method call and another check' do
          source = "#{variable} && #{variable}.bar && something"

          inspect_source(cop, source)

          expect(cop.messages).to eq([described_class::MSG])
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
        inspect_source(cop, 'foo.bar if foo.respond_to?(:bar)')

        expect(cop.offenses).to be_empty
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

        context 'object check before method call' do
          it 'corrects an object check followed by a method call' do
            source = "#{variable} && #{variable}.bar"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects an object check followed by a method call with params' do
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

          it 'corrects a non nil object check followed by a method call' do
            source = "!#{variable}.nil? && #{variable}.bar"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a non nil object check followed by a method call ' \
            'with params' do
            source = "!#{variable}.nil? && #{variable}.bar(baz)"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a non nil object check followed by a method call ' \
            'with a block' do
            source = "!#{variable}.nil? && #{variable}.bar { |e| e.qux }"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a non nil object check followed by a method call ' \
            'with params and a block' do
            source = "!#{variable}.nil? && #{variable}.bar(baz) { |e| e.qux }"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
          end

          it 'corrects a nil object check followed by a method call' do
            source = "#{variable}.nil? || #{variable}.bar"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a nil object check followed by a method call ' \
            'with params' do
            source = "#{variable}.nil? || #{variable}.bar(baz)"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a nil object check followed by a method call with ' \
            'a block' do
            source = "#{variable}.nil? || #{variable}.bar { |e| e.qux }"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a nil object check followed by a method call with ' \
            'params and a block' do
            source = "#{variable}.nil? || #{variable}.bar(baz) { |e| e.qux }"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz) { |e| e.qux }")
          end

          it 'corrects a non object check followed by a method call' do
            source = "!#{variable} || #{variable}.bar"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar")
          end

          it 'corrects a non object check followed by a method call ' \
            'with params' do
            source = "!#{variable} || #{variable}.bar(baz)"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar(baz)")
          end

          it 'corrects a non object check followed by a method call with ' \
            'a block' do
            source = "!#{variable} || #{variable}.bar { |e| e.qux }"

            new_source = autocorrect_source(cop, source)

            expect(new_source).to eq("#{variable}&.bar { |e| e.qux }")
          end

          it 'corrects a non object check followed by a method call with ' \
            'params and a block' do
            source = "!#{variable} || #{variable}.bar(baz) { |e| e.qux }"

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
      inspect_source(cop, 'foo.bar if foo')

      expect(cop.offenses).to be_empty
    end
  end
end
