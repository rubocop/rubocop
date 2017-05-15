# frozen_string_literal: true

describe RuboCop::Cop::Style::EmptyLiteral do
  subject(:cop) { described_class.new }

  describe 'Empty Array' do
    it 'registers an offense for Array.new()' do
      expect_offense(<<-RUBY.strip_indent)
        test = Array.new()
               ^^^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY
    end

    it 'registers an offense for Array.new' do
      expect_offense(<<-RUBY.strip_indent)
        test = Array.new
               ^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY
    end

    it 'does not register an offense for Array.new(3)' do
      expect_no_offenses('test = Array.new(3)')
    end

    it 'auto-corrects Array.new to []' do
      new_source = autocorrect_source(cop, 'test = Array.new')
      expect(new_source).to eq('test = []')
    end

    it 'auto-corrects Array.new in block in block' do
      source = 'puts { Array.new }'
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq 'puts { [] }'
    end

    it 'does not registers an offense Array.new with block' do
      expect_no_offenses('test = Array.new { 1 }')
    end

    it 'does not register Array.new with block in other block' do
      expect_no_offenses('puts { Array.new { 1 } }')
    end
  end

  describe 'Empty Hash' do
    it 'registers an offense for Hash.new()' do
      expect_offense(<<-RUBY.strip_indent)
        test = Hash.new()
               ^^^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
    end

    it 'registers an offense for Hash.new' do
      expect_offense(<<-RUBY.strip_indent)
        test = Hash.new
               ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
    end

    it 'does not register an offense for Hash.new(3)' do
      expect_no_offenses('test = Hash.new(3)')
    end

    it 'does not register an offense for Hash.new { block }' do
      expect_no_offenses('test = Hash.new { block }')
    end

    it 'auto-corrects Hash.new to {}' do
      new_source = autocorrect_source(cop, 'Hash.new')
      expect(new_source).to eq('{}')
    end

    it 'auto-corrects Hash.new in block ' do
      source = 'puts { Hash.new }'
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq 'puts { {} }'
    end

    it 'auto-corrects Hash.new to {} in various contexts' do
      new_source =
        autocorrect_source(cop, <<-END.strip_indent)
          test = Hash.new
          Hash.new.merge("a" => 3)
          yadayada.map { a }.reduce(Hash.new, :merge)
        END
      expect(new_source)
        .to eq(<<-END.strip_indent)
          test = {}
          {}.merge("a" => 3)
          yadayada.map { a }.reduce({}, :merge)
        END
    end

    it 'auto-correct Hash.new to {} as the only parameter to a method' do
      source = 'yadayada.map { a }.reduce Hash.new'
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq('yadayada.map { a }.reduce({})')
    end

    it 'auto-correct Hash.new to {} as the first parameter to a method' do
      source = 'yadayada.map { a }.reduce Hash.new, :merge'
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq('yadayada.map { a }.reduce({}, :merge)')
    end
  end

  describe 'Empty String' do
    it 'registers an offense for String.new()' do
      expect_offense(<<-RUBY.strip_indent)
        test = String.new()
               ^^^^^^^^^^^^ Use string literal `''` instead of `String.new`.
      RUBY
    end

    it 'registers an offense for String.new' do
      expect_offense(<<-RUBY.strip_indent)
        test = String.new
               ^^^^^^^^^^ Use string literal `''` instead of `String.new`.
      RUBY
    end

    it 'does not register an offense for String.new("top")' do
      expect_no_offenses('test = String.new("top")')
    end

    it 'auto-corrects String.new to empty string literal' do
      new_source = autocorrect_source(cop, 'test = String.new')
      expect(new_source).to eq("test = ''")
    end

    context 'when double-quoted string literals are preferred' do
      let(:config) do
        RuboCop::Config.new(
          'Style/StringLiterals' =>
            {
              'EnforcedStyle' => 'double_quotes'
            }
        )
      end
      subject(:cop) { described_class.new(config) }

      it 'registers an offense for String.new' do
        expect_offense(<<-RUBY.strip_indent)
          test = String.new
                 ^^^^^^^^^^ Use string literal `""` instead of `String.new`.
        RUBY
      end

      it 'auto-corrects String.new to a double-quoted empty string literal' do
        new_source = autocorrect_source(cop, 'test = String.new')
        expect(new_source).to eq('test = ""')
      end
    end

    context 'when frozen string literals is enabled' do
      let(:ruby_version) { 2.3 }

      it 'does not register an offense for String.new' do
        expect_no_offenses(<<-END.strip_indent)
          # encoding: utf-8
          # frozen_string_literal: true
          test = String.new
        END
      end
    end
  end
end
