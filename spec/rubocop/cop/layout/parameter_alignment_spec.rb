# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ParameterAlignment, :config do
  let(:config) do
    RuboCop::Config.new('Layout/ParameterAlignment' => cop_config,
                        'Layout/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'aligned with first parameter' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_first_parameter' } }

    it 'registers an offense and corrects parameters with single indent' do
      expect_offense(<<~RUBY)
        def method(a,
          b)
          ^ Align the parameters of a method definition if they span more than one line.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(a,
                   b)
        end
      RUBY
    end

    it 'registers an offense and corrects parameters with double indent' do
      expect_offense(<<~RUBY)
        def method(a,
            b)
            ^ Align the parameters of a method definition if they span more than one line.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(a,
                   b)
        end
      RUBY
    end

    it 'accepts parameter lists on a single line' do
      expect_no_offenses(<<~RUBY)
        def method(a, b)
        end
      RUBY
    end

    it 'accepts proper indentation' do
      expect_no_offenses(<<~RUBY)
        def method(a,
                   b)
        end
      RUBY
    end

    it 'accepts the first parameter being on a new row' do
      expect_no_offenses(<<~RUBY)
        def method(
          a,
          b)
        end
      RUBY
    end

    it 'accepts a method definition without parameters' do
      expect_no_offenses(<<~RUBY)
        def method
        end
      RUBY
    end

    it "doesn't get confused by splat" do
      expect_offense(<<~RUBY)
        def func2(a,
                 *b,
                 ^^ Align the parameters of a method definition if they span more than one line.
                  c)
        end
      RUBY

      expect_correction(<<~RUBY)
        def func2(a,
                  *b,
                  c)
        end
      RUBY
    end

    context 'defining self.method' do
      it 'registers an offense and corrects parameters with single indent' do
        expect_offense(<<~RUBY)
          def self.method(a,
            b)
            ^ Align the parameters of a method definition if they span more than one line.
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.method(a,
                          b)
          end
        RUBY
      end

      it 'accepts proper indentation' do
        expect_no_offenses(<<~RUBY)
          def self.method(a,
                          b)
          end
        RUBY
      end
    end

    it 'registers an offense and corrects alignment in simple case' do
      expect_offense(<<~RUBY)
        def func(a,
               b,
               ^ Align the parameters of a method definition if they span more than one line.
        c)
        ^ Align the parameters of a method definition if they span more than one line.
          123
        end
      RUBY

      expect_correction(<<~RUBY)
        def func(a,
                 b,
                 c)
          123
        end
      RUBY
    end
  end

  context 'aligned with fixed indentation' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_fixed_indentation' } }

    it 'registers an offense and corrects parameters aligned to first param' do
      expect_offense(<<~RUBY)
        def method(a,
                   b)
                   ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(a,
          b)
        end
      RUBY
    end

    it 'registers an offense and corrects parameters with double indent' do
      expect_offense(<<~RUBY)
        def method(a,
            b)
            ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(a,
          b)
        end
      RUBY
    end

    it 'accepts parameter lists on a single line' do
      expect_no_offenses(<<~RUBY)
        def method(a, b)
        end
      RUBY
    end

    it 'accepts proper indentation' do
      expect_no_offenses(<<~RUBY)
        def method(a,
          b)
        end
      RUBY
    end

    it 'accepts the first parameter being on a new row' do
      expect_no_offenses(<<~RUBY)
        def method(
          a,
          b)
        end
      RUBY
    end

    it 'accepts a method definition without parameters' do
      expect_no_offenses(<<~RUBY)
        def method
        end
      RUBY
    end

    it "doesn't get confused by splat" do
      expect_offense(<<~RUBY)
        def func2(a,
                 *b,
                 ^^ Use one level of indentation for parameters following the first line of a multi-line method definition.
                  c)
                  ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
        end
      RUBY

      expect_correction(<<~RUBY)
        def func2(a,
          *b,
          c)
        end
      RUBY
    end

    context 'defining self.method' do
      it 'registers an offense and corrects parameters aligned to first param' do
        expect_offense(<<~RUBY)
          def self.method(a,
                          b)
                          ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.method(a,
            b)
          end
        RUBY
      end

      it 'accepts proper indentation' do
        expect_no_offenses(<<~RUBY)
          def self.method(a,
            b)
          end
        RUBY
      end
    end
  end
end
