# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ParameterAlignment do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/ParameterAlignment' => cop_config,
                        'Layout/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'aligned with first parameter' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_first_parameter'
      }
    end

    it 'registers an offense for parameters with single indent' do
      expect_offense(<<~RUBY)
        def method(a,
          b)
          ^ Align the parameters of a method definition if they span more than one line.
        end
      RUBY
    end

    it 'registers an offense for parameters with double indent' do
      expect_offense(<<~RUBY)
        def method(a,
            b)
            ^ Align the parameters of a method definition if they span more than one line.
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
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(<<~RUBY)
        def method(a,
            b)
        end
      RUBY
      expect(new_source).to eq(<<~RUBY)
        def method(a,
                   b)
        end
      RUBY
    end

    context 'defining self.method' do
      it 'registers an offense for parameters with single indent' do
        expect_offense(<<~RUBY)
          def self.method(a,
            b)
            ^ Align the parameters of a method definition if they span more than one line.
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

      it 'auto-corrects alignment' do
        new_source = autocorrect_source(<<~RUBY)
          def self.method(a,
              b)
          end
        RUBY
        expect(new_source).to eq(<<~RUBY)
          def self.method(a,
                          b)
          end
        RUBY
      end
    end

    it 'auto-corrects alignment in simple case' do
      new_source = autocorrect_source(<<~RUBY)
        def func(a,
               b,
        c)
          123
        end
      RUBY
      expect(new_source).to eq(<<~RUBY)
        def func(a,
                 b,
                 c)
          123
        end
      RUBY
    end
  end

  context 'aligned with fixed indentation' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_fixed_indentation'
      }
    end

    it 'registers an offense for parameters aligned to first param' do
      expect_offense(<<~RUBY)
        def method(a,
                   b)
                   ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
        end
      RUBY
    end

    it 'registers an offense for parameters with double indent' do
      expect_offense(<<~RUBY)
        def method(a,
            b)
            ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
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
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(<<~RUBY)
        def method(a,
            b)
        end
      RUBY
      expect(new_source).to eq(<<~RUBY)
        def method(a,
          b)
        end
      RUBY
    end

    context 'defining self.method' do
      it 'registers an offense for parameters aligned to first param' do
        expect_offense(<<~RUBY)
          def self.method(a,
                          b)
                          ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
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

      it 'auto-corrects alignment' do
        new_source = autocorrect_source(<<~RUBY)
          def self.method(a,
              b)
          end
        RUBY
        expect(new_source).to eq(<<~RUBY)
          def self.method(a,
            b)
          end
        RUBY
      end
    end
  end
end
