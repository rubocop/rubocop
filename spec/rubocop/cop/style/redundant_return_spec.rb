# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantReturn, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'AllowMultipleReturnValues' => false } }

  it 'reports an offense for def with only a return' do
    src = <<-RUBY.strip_indent
      def func
        return something
      end
    RUBY
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs with only a return' do
    src = <<-RUBY.strip_indent
      def Test.func
        return something
      end
    RUBY
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for def ending with return' do
    src = <<-RUBY.strip_indent
      def func
        one
        two
        return something
      end
    RUBY
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs ending with return' do
    src = <<-RUBY.strip_indent
      def self.func
        one
        two
        return something
      end
    RUBY
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts return in a non-final position' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func
        return something if something_else
      end
    RUBY
  end

  it 'does not blow up on empty method body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func
      end
    RUBY
  end

  it 'does not blow up on empty if body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func
        if x
        elsif y
        else
        end
      end
    RUBY
  end

  it 'auto-corrects by removing redundant returns' do
    src = <<-RUBY.strip_indent
      def func
        one
        two
        return something
      end
    RUBY
    result_src = <<-RUBY.strip_indent
      def func
        one
        two
        something
      end
    RUBY
    new_source = autocorrect_source(src)
    expect(new_source).to eq(result_src)
  end

  context 'when return has no arguments' do
    shared_examples 'common behavior' do |ret|
      let(:src) do
        <<-RUBY.strip_indent
          def func
            one
            two
            #{ret}
            # comment
          end
        RUBY
      end

      it "registers an offense for #{ret}" do
        inspect_source(src)
        expect(cop.offenses.size).to eq(1)
      end

      it "auto-corrects by replacing #{ret} with nil" do
        new_source = autocorrect_source(src)
        expect(new_source).to eq(<<-RUBY.strip_indent)
          def func
            one
            two
            nil
            # comment
          end
        RUBY
      end
    end

    it_behaves_like 'common behavior', 'return'
    it_behaves_like 'common behavior', 'return()'
  end

  context 'when multi-value returns are not allowed' do
    it 'reports an offense for def with only a return' do
      src = <<-RUBY.strip_indent
        def func
          return something, test
        end
      RUBY
      inspect_source(src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'reports an offense for defs with only a return' do
      src = <<-RUBY.strip_indent
        def Test.func
          return something, test
        end
      RUBY
      inspect_source(src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'reports an offense for def ending with return' do
      src = <<-RUBY.strip_indent
        def func
          one
          two
          return something, test
        end
      RUBY
      inspect_source(src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'reports an offense for defs ending with return' do
      src = <<-RUBY.strip_indent
        def self.func
          one
          two
          return something, test
        end
      RUBY
      inspect_source(src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers a helpful message for defs with multiple returns' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
      RUBY
    end

    it 'auto-corrects by making implicit arrays explicit' do
      src = <<-RUBY.strip_indent
        def func
          return  1, 2
        end
      RUBY
      # Just 1, 2 is not valid Ruby.
      result_src = <<-RUBY.strip_indent
        def func
          [1, 2]
        end
      RUBY
      new_source = autocorrect_source(src)
      expect(new_source).to eq(result_src)
    end

    it 'auto-corrects removes return when using an explicit hash' do
      src = <<-RUBY.strip_indent
        def func
          return {:a => 1, :b => 2}
        end
      RUBY
      # :a => 1, :b => 2 is not valid Ruby
      result_src = <<-RUBY.strip_indent
        def func
          {:a => 1, :b => 2}
        end
      RUBY
      new_source = autocorrect_source(src)
      expect(new_source).to eq(result_src)
    end

    it 'auto-corrects by making an implicit hash explicit' do
      src = <<-RUBY.strip_indent
        def func
          return :a => 1, :b => 2
        end
      RUBY
      # :a => 1, :b => 2 is not valid Ruby
      result_src = <<-RUBY.strip_indent
        def func
          {:a => 1, :b => 2}
        end
      RUBY
      new_source = autocorrect_source(src)
      expect(new_source).to eq(result_src)
    end
  end

  context 'when multi-value returns are allowed' do
    let(:cop_config) { { 'AllowMultipleReturnValues' => true } }

    it 'accepts def with only a return' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
          return something, test
        end
      RUBY
    end

    it 'accepts defs with only a return' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def Test.func
          return something, test
        end
      RUBY
    end

    it 'accepts def ending with return' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
          one
          two
          return something, test
        end
      RUBY
    end

    it 'accepts defs ending with return' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.func
          one
          two
          return something, test
        end
      RUBY
    end

    it 'does not auto-correct' do
      src = <<-RUBY.strip_indent
        def func
          return  1, 2
        end
      RUBY
      new_source = autocorrect_source(src)
      expect(new_source).to eq(src)
    end
  end

  context 'when return is inside an if-branch' do
    let(:src) do
      <<-RUBY.strip_indent
        def func
          if x
            return 1
          elsif y
            return 2
          else
            return 3
          end
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          if x
            return 1
            ^^^^^^ Redundant `return` detected.
          elsif y
            return 2
            ^^^^^^ Redundant `return` detected.
          else
            return 3
            ^^^^^^ Redundant `return` detected.
          end
        end
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(src)
      expect(corrected).to eq <<-RUBY.strip_indent
        def func
          if x
            1
          elsif y
            2
          else
            3
          end
        end
      RUBY
    end
  end

  context 'when return is inside a when-branch' do
    let(:src) do
      <<-RUBY.strip_indent
        def func
          case x
          when y then return 1
          when z then return 2
          when q
          else
            return 3
          end
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          case x
          when y then return 1
                      ^^^^^^ Redundant `return` detected.
          when z then return 2
                      ^^^^^^ Redundant `return` detected.
          when q
          else
            return 3
            ^^^^^^ Redundant `return` detected.
          end
        end
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(src)
      expect(corrected).to eq <<-RUBY.strip_indent
        def func
          case x
          when y then 1
          when z then 2
          when q
          else
            3
          end
        end
      RUBY
    end
  end

  context 'when case nodes are empty' do
    it 'accepts empty when nodes' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
          case x
          when y then 1
          when z # do nothing
          else
            3
          end
        end
      RUBY
    end
  end
end
