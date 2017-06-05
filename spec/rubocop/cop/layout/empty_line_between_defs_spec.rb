# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLineBetweenDefs, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowAdjacentOneLineDefs' => false } }

  it 'finds offenses in inner classes' do
    source = <<-RUBY.strip_indent
      class K
        def m
        end
        class J
          def n
          end
          def o
          end
        end
        # checks something
        def p
        end
      end
    RUBY
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([7])
  end

  context 'when there are only comments between defs' do
    let(:source) do
      <<-RUBY.strip_indent
        class J
          def n
          end # n-related
          # checks something o-related
          # and more
          def o
          end
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        class J
          def n
          end # n-related
          # checks something o-related
          # and more
          def o
          ^^^ Use empty lines between method definitions.
          end
        end
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class J
          def n
          end # n-related

          # checks something o-related
          # and more
          def o
          end
        end
      RUBY
    end
  end

  context 'conditional method definitions' do
    it 'accepts defs inside a conditional without blank lines in between' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if condition
          def foo
            true
          end
        else
          def foo
            false
          end
        end
      RUBY
    end

    it 'registers an offense for consecutive defs inside a conditional' do
      source = <<-RUBY.strip_indent
        if condition
          def foo
            true
          end
          def bar
            true
          end
        else
          def foo
            false
          end
        end
      RUBY
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'class methods' do
    context 'adjacent class methods' do
      let(:offending_source) do
        <<-RUBY.strip_indent
          class Test
            def self.foo
              true
            end
            def self.bar
              true
            end
          end
        RUBY
      end

      it 'registers an offense for missing blank line between methods' do
        expect_offense(<<-RUBY.strip_indent)
          class Test
            def self.foo
              true
            end
            def self.bar
            ^^^ Use empty lines between method definitions.
              true
            end
          end
        RUBY
      end

      it 'autocorrects it' do
        corrected = autocorrect_source(cop, offending_source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          class Test
            def self.foo
              true
            end

            def self.bar
              true
            end
          end
        RUBY
      end
    end

    context 'mixed instance and class methods' do
      let(:offending_source) do
        <<-RUBY.strip_indent
          class Test
            def foo
              true
            end
            def self.bar
              true
            end
          end
        RUBY
      end

      it 'registers an offense for missing blank line between methods' do
        expect_offense(<<-RUBY.strip_indent)
          class Test
            def foo
              true
            end
            def self.bar
            ^^^ Use empty lines between method definitions.
              true
            end
          end
        RUBY
      end

      it 'autocorrects it' do
        corrected = autocorrect_source(cop, offending_source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          class Test
            def foo
              true
            end

            def self.bar
              true
            end
          end
        RUBY
      end
    end
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows a line with code' do
    expect_no_offenses(<<-RUBY.strip_indent)
      x = 0
      def m
      end
    RUBY
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows code and a comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      x = 0
      # 123
      def m
      end
    RUBY
  end

  it 'accepts the first def without leading empty line in a class' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class K
        def m
        end
      end
    RUBY
  end

  it 'accepts a def that follows an empty line and then a comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class A
        # calculates value
        def m
        end

        private
        # calculates size
        def n
        end
      end
    RUBY
  end

  it 'accepts a def that is the first of a module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Util
        public
        #
        def html_escape(s)
        end
      end
    RUBY
  end

  it 'accepts a nested def' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def mock_model(*attributes)
        Class.new do
          def initialize(attrs)
          end
        end
      end
    RUBY
  end

  it 'registers an offense for adjacent one-liners by default' do
    source = <<-RUBY.strip_indent
      def a; end
      def b; end
    RUBY
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects adjacent one-liners by default' do
    corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
      def a; end
      def b; end
    RUBY
    expect(corrected).to eq(<<-RUBY.strip_indent)
      def a; end

      def b; end
    RUBY
  end

  it 'auto-corrects when there are too many new lines' do
    corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
      def a; end



      def b; end
    RUBY
    expect(corrected).to eq(<<-RUBY.strip_indent)
      def a; end

      def b; end
    RUBY
  end

  it 'treats lines with whitespaces as blank' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class J
        def n
        end

        def o
        end
      end
    RUBY
  end

  it "doesn't allow more than the required number of newlines" do
    source = <<-RUBY.strip_indent
      class A
        def n
        end


        def o
        end
      end
    RUBY
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
  end

  context 'when AllowAdjacentOneLineDefs is enabled' do
    let(:cop_config) { { 'AllowAdjacentOneLineDefs' => true } }

    it 'accepts adjacent one-liners' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def a; end
        def b; end
      RUBY
    end

    it 'registers an offense for adjacent defs if some are multi-line' do
      source = <<-RUBY.strip_indent
        def a; end
        def b; end
        def c # Not a one-liner, so this is an offense.
        end
        def d; end # Also an offense since previous was multi-line:
      RUBY
      inspect_source(cop, source)
      expect(cop.offenses.map(&:line)).to eq([3, 5])
    end
  end

  context 'when a maximum of empty lines is specified' do
    let(:cop_config) { { 'NumberOfEmptyLines' => [0, 1] } }

    it 'finds no offense for no empty line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def n
        end
        def o
        end
      RUBY
    end

    it 'finds no offense for one empty line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def n
        end

        def o
         end
      RUBY
    end

    it 'finds an  offense for two empty lines' do
      source = <<-RUBY.strip_indent
        def n
        end


        def o
        end
      RUBY
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects' do
      source = <<-RUBY.strip_indent
        def n
        end


        def o
        end
      RUBY
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        def n
        end

        def o
        end
      RUBY
    end
  end

  context 'when multiple lines between defs are allowed' do
    let(:cop_config) { { 'NumberOfEmptyLines' => 2 } }

    it 'treats lines with whitespaces as blank' do
      source = <<-RUBY.strip_indent
        def n
        end

        def o
        end
      RUBY
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects when there are no new lines' do
      source = <<-RUBY.strip_indent
        def n
        end
        def o
        end
      RUBY
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        def n
        end


        def o
        end
      RUBY
    end

    it 'auto-corrects when there are too few new lines' do
      source = <<-RUBY.strip_indent
        def n
        end

        def o
        end
      RUBY
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        def n
        end


        def o
        end
      RUBY
    end

    it 'auto-corrects when there are too many new lines' do
      source = <<-RUBY.strip_indent
        def n
        end




        def o
        end
      RUBY
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        def n
        end


        def o
        end
      RUBY
    end
  end
end
