# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MutableConstant, :config do
  subject(:cop) { described_class.new(config) }

  let(:prefix) { nil }

  shared_examples 'mutable objects' do |o|
    context 'when assigning with =' do
      it "registers an offense for #{o} assigned to a constant" do
        source = [prefix, "CONST = #{o}"].compact.join("\n")
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'auto-corrects by adding .freeze' do
        source = [prefix, "CONST = #{o}"].compact.join("\n")
        new_source = autocorrect_source(source)
        expect(new_source).to eq("#{source}.freeze")
      end
    end

    context 'when assigning with ||=' do
      it "registers an offense for #{o} assigned to a constant" do
        source = [prefix, "CONST ||= #{o}"].compact.join("\n")
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'auto-corrects by adding .freeze' do
        source = [prefix, "CONST ||= #{o}"].compact.join("\n")
        new_source = autocorrect_source(source)
        expect(new_source).to eq("#{source}.freeze")
      end
    end
  end

  shared_examples 'immutable objects' do |o|
    it "allows #{o} to be assigned to a constant" do
      source = [prefix, "CONST = #{o}"].compact.join("\n")
      expect_no_offenses(source)
    end

    it "allows #{o} to be ||= to a constant" do
      source = [prefix, "CONST ||= #{o}"].compact.join("\n")
      expect_no_offenses(source)
    end
  end

  context 'Strict: false' do
    let(:cop_config) { { 'EnforcedStyle' => 'literals' } }

    it_behaves_like 'mutable objects', '[1, 2, 3]'
    it_behaves_like 'mutable objects', '%w(a b c)'
    it_behaves_like 'mutable objects', '{ a: 1, b: 2 }'
    it_behaves_like 'mutable objects', "'str'"
    it_behaves_like 'mutable objects', '"top#{1 + 2}"'

    it_behaves_like 'immutable objects', '1'
    it_behaves_like 'immutable objects', '1.5'
    it_behaves_like 'immutable objects', ':sym'
    it_behaves_like 'immutable objects', 'FOO + BAR'
    it_behaves_like 'immutable objects', 'FOO - BAR'
    it_behaves_like 'immutable objects', "'foo' + 'bar'"
    it_behaves_like 'immutable objects', "ENV['foo']"

    it 'allows method call assignments' do
      expect_no_offenses('TOP_TEST = Something.new')
    end

    context 'splat expansion' do
      context 'expansion of a range' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            FOO = *1..10
                  ^^^^^^ Freeze mutable objects assigned to constants.
          RUBY
        end

        it 'correct to use to_a.freeze' do
          new_source = autocorrect_source('FOO = *1..10')

          expect(new_source).to eq('FOO = (1..10).to_a.freeze')
        end

        context 'with parentheses' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              FOO = *(1..10)
                    ^^^^^^^^ Freeze mutable objects assigned to constants.
            RUBY
          end

          it 'correct to use to_a.freeze' do
            new_source = autocorrect_source('FOO = *(1..10)')

            expect(new_source).to eq('FOO = (1..10).to_a.freeze')
          end
        end
      end
    end

    context 'when assigning an array without brackets' do
      it 'adds brackets when auto-correcting' do
        new_source = autocorrect_source('XXX = YYY, ZZZ')
        expect(new_source).to eq 'XXX = [YYY, ZZZ].freeze'
      end

      it 'does not add brackets to %w() arrays' do
        new_source = autocorrect_source('XXX = %w(YYY ZZZ)')
        expect(new_source).to eq 'XXX = %w(YYY ZZZ).freeze'
      end
    end

    context 'when assigning a range (irange) without parenthesis' do
      it 'adds parenthesis when auto-correcting' do
        new_source = autocorrect_source('XXX = 1..99')
        expect(new_source).to eq 'XXX = (1..99).freeze'
      end

      it 'does not add parenthesis to range enclosed in parentheses' do
        new_source = autocorrect_source('XXX = (1..99)')
        expect(new_source).to eq 'XXX = (1..99).freeze'
      end
    end

    context 'when assigning a range (erange) without parenthesis' do
      it 'adds parenthesis when auto-correcting' do
        new_source = autocorrect_source('XXX = 1...99')
        expect(new_source).to eq 'XXX = (1...99).freeze'
      end

      it 'does not add parenthesis to range enclosed in parentheses' do
        new_source = autocorrect_source('XXX = (1...99)')
        expect(new_source).to eq 'XXX = (1...99).freeze'
      end
    end

    context 'when the constant is a frozen string literal' do
      if RuboCop::Config::KNOWN_RUBIES.include?(3.0)
        context 'when the target ruby version >= 3.0' do
          let(:ruby_version) { 3.0 }

          context 'when the frozen string literal comment is missing' do
            it_behaves_like 'immutable objects', '"#{a}"'
          end

          context 'when the frozen string literal comment is true' do
            let(:prefix) { '# frozen_string_literal: true' }

            it_behaves_like 'immutable objects', '"#{a}"'
          end

          context 'when the frozen string literal comment is false' do
            let(:prefix) { '# frozen_string_literal: false' }

            it_behaves_like 'immutable objects', '"#{a}"'
          end
        end
      end

      context 'when the target ruby version >= 2.3' do
        let(:ruby_version) { 2.3 }

        context 'when the frozen string literal comment is missing' do
          it_behaves_like 'mutable objects', '"#{a}"'
        end

        context 'when the frozen string literal comment is true' do
          let(:prefix) { '# frozen_string_literal: true' }

          it_behaves_like 'immutable objects', '"#{a}"'
        end

        context 'when the frozen string literal comment is false' do
          let(:prefix) { '# frozen_string_literal: false' }

          it_behaves_like 'mutable objects', '"#{a}"'
        end
      end
    end
  end

  context 'Strict: true' do
    let(:cop_config) { { 'EnforcedStyle' => 'strict' } }

    it_behaves_like 'mutable objects', '[1, 2, 3]'
    it_behaves_like 'mutable objects', '%w(a b c)'
    it_behaves_like 'mutable objects', '{ a: 1, b: 2 }'
    it_behaves_like 'mutable objects', "'str'"
    it_behaves_like 'mutable objects', '"top#{1 + 2}"'
    it_behaves_like 'mutable objects', 'Something.new'

    it_behaves_like 'immutable objects', '1'
    it_behaves_like 'immutable objects', '1.5'
    it_behaves_like 'immutable objects', ':sym'
    it_behaves_like 'immutable objects', "ENV['foo']"
    it_behaves_like 'immutable objects', 'OTHER_CONST'
    it_behaves_like 'immutable objects', 'Namespace::OTHER_CONST'
    it_behaves_like 'immutable objects', 'Struct.new'
    it_behaves_like 'immutable objects', 'Struct.new(:a, :b)'
    it_behaves_like 'immutable objects', <<-RUBY.strip_indent
      Struct.new(:node) do
        def assignment?
          true
        end
      end
    RUBY

    it 'allows calls to freeze' do
      expect_no_offenses(<<-RUBY.strip_indent)
        CONST = [1].freeze
      RUBY
    end

    context 'splat expansion' do
      context 'expansion of a range' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            FOO = *1..10
                  ^^^^^^ Freeze mutable objects assigned to constants.
          RUBY
        end

        it 'correct to use to_a.freeze' do
          new_source = autocorrect_source('FOO = *1..10')

          expect(new_source).to eq('FOO = (1..10).to_a.freeze')
        end

        context 'with parentheses' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              FOO = *(1..10)
                    ^^^^^^^^ Freeze mutable objects assigned to constants.
            RUBY
          end

          it 'correct to use to_a.freeze' do
            new_source = autocorrect_source('FOO = *(1..10)')

            expect(new_source).to eq('FOO = (1..10).to_a.freeze')
          end
        end
      end
    end

    context 'when assigning with an operator' do
      shared_examples 'operator methods' do |o|
        it 'registers an offense' do
          inspect_source("CONST = FOO #{o} BAR")

          expect(cop.offenses.size).to eq(1)
          expect(cop.highlights).to eq(["FOO #{o} BAR"])
        end

        it 'corrects by wrapping in parentheses and calling freeze' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            CONST = FOO #{o} BAR
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            CONST = (FOO #{o} BAR).freeze
          RUBY
        end
      end

      it_behaves_like 'operator methods', '+'
      it_behaves_like 'operator methods', '-'
      it_behaves_like 'operator methods', '*'
      it_behaves_like 'operator methods', '/'
      it_behaves_like 'operator methods', '%'
      it_behaves_like 'operator methods', '**'
    end

    context 'when assigning with multiple operator calls' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          FOO = [1].freeze
          BAR = [2].freeze
          BAZ = [3].freeze
          CONST = FOO + BAR + BAZ
                  ^^^^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
        RUBY
      end

      it 'corrects by wrapping in parens and calling freeze' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          FOO = [1].freeze
          BAR = [2].freeze
          BAZ = [3].freeze
          CONST = FOO + BAR + BAZ
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          FOO = [1].freeze
          BAR = [2].freeze
          BAZ = [3].freeze
          CONST = (FOO + BAR + BAZ).freeze
        RUBY
      end
    end

    context 'methods and operators that produce frozen objects' do
      it 'accepts assigning to an environment variable with a fallback' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = ENV['foo'] || 'foo'
        RUBY
      end

      it 'accepts operating on a constant and an interger' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = FOO + 2
        RUBY
      end

      it 'accepts operating on multiple integers' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = 1 + 2
        RUBY
      end

      it 'accepts operating on a constant and a float' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = FOO + 2.1
        RUBY
      end

      it 'accepts operating on multiple floats' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = 1.2 + 2.1
        RUBY
      end

      it 'accepts comparison operators' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = FOO == BAR
        RUBY
      end

      it 'accepts checking fixed size' do
        expect_no_offenses(<<-RUBY.strip_indent)
          CONST = 'foo'.count
          CONST = 'foo'.count('f')
          CONST = [1, 2, 3].count { |n| n > 2 }
          CONST = [1, 2, 3].count(2) { |n| n > 2 }
          CONST = 'foo'.length
          CONST = 'foo'.size
        RUBY
      end
    end

    context 'operators that produce unfrozen objects' do
      it 'registers an offense when operating on a constant and a string' do
        expect_offense(<<-RUBY.strip_indent)
          CONST = FOO + 'bar'
                  ^^^^^^^^^^^ Freeze mutable objects assigned to constants.
        RUBY
      end

      it 'registers an offense when operating on multiple strings' do
        expect_offense(<<-RUBY.strip_indent)
          CONST = 'foo' + 'bar' + 'baz'
                  ^^^^^^^^^^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
        RUBY
      end
    end

    context 'when assigning an array without brackets' do
      it 'adds brackets when auto-correcting' do
        new_source = autocorrect_source('XXX = YYY, ZZZ')
        expect(new_source).to eq 'XXX = [YYY, ZZZ].freeze'
      end

      it 'does not add brackets to %w() arrays' do
        new_source = autocorrect_source('XXX = %w(YYY ZZZ)')
        expect(new_source).to eq 'XXX = %w(YYY ZZZ).freeze'
      end
    end

    it 'freezes a heredoc' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        FOO = <<-HERE
          SOMETHING
        HERE
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        FOO = <<-HERE.freeze
          SOMETHING
        HERE
      RUBY
    end

    context 'when the target ruby version >= 2.3' do
      let(:ruby_version) { 2.3 }

      context 'when the frozen string literal comment is missing' do
        it_behaves_like 'mutable objects', '"#{a}"'
      end

      context 'when the frozen string literal comment is true' do
        let(:prefix) { '# frozen_string_literal: true' }

        it_behaves_like 'immutable objects', '"#{a}"'
      end

      context 'when the frozen string literal comment is false' do
        let(:prefix) { '# frozen_string_literal: false' }

        it_behaves_like 'mutable objects', '"#{a}"'
      end
    end
  end
end
