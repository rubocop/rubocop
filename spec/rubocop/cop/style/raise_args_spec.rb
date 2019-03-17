# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RaiseArgs, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    context 'with a raise with 2 args' do
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          raise RuntimeError, msg
          ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source('raise RuntimeError, msg')
        expect(new_source).to eq('raise RuntimeError.new(msg)')
      end
    end

    context 'when used in a ternary expression' do
      it 'registers an offense and auto-corrects' do
        expect_offense(<<-RUBY.strip_indent)
          foo ? raise(Ex, 'error') : bar
                ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          foo ? raise(Ex.new('error')) : bar
        RUBY
      end
    end

    context 'when used in a logical and expression' do
      it 'registers an offense and auto-corrects' do
        expect_offense(<<-RUBY.strip_indent)
          bar && raise(Ex, 'error')
                 ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          bar && raise(Ex.new('error'))
        RUBY
      end
    end

    context 'when used in a logical or expression' do
      it 'registers an offense and auto-corrects' do
        expect_offense(<<-RUBY.strip_indent)
          bar || raise(Ex, 'error')
                 ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          bar || raise(Ex.new('error'))
        RUBY
      end
    end

    context 'with correct + opposite' do
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
            ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
          else
            raise Ex.new(msg)
          end
        RUBY
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          if a
            raise RuntimeError.new(msg)
          else
            raise Ex.new(msg)
          end
        RUBY
      end
    end

    context 'with a raise with 3 args' do
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          raise RuntimeError, msg, caller
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY
      end

      it 'does not auto-correct to compact style' do
        initial_source = 'raise RuntimeError, msg, caller'

        new_source = autocorrect_source(initial_source)
        expect(new_source).to eq(initial_source)
      end
    end

    it 'accepts a raise with msg argument' do
      expect_no_offenses('raise msg')
    end

    it 'accepts a raise with an exception argument' do
      expect_no_offenses('raise Ex.new(msg)')
    end
  end

  context 'when enforced style is exploded' do
    let(:cop_config) { { 'EnforcedStyle' => 'exploded' } }

    context 'with a raise with exception object' do
      context 'with one argument' do
        it 'reports an offense' do
          expect_offense(<<-RUBY.strip_indent)
            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'compact')
        end

        it 'auto-corrects to exploded style' do
          new_source = autocorrect_source('raise Ex.new(msg)')
          expect(new_source).to eq('raise Ex, msg')
        end
      end

      context 'with no arguments' do
        it 'reports an offense' do
          expect_offense(<<-RUBY.strip_indent)
            raise Ex.new
            ^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'compact')
        end

        it 'auto-corrects to exploded style' do
          new_source = autocorrect_source('raise Ex.new')
          expect(new_source).to eq('raise Ex')
        end
      end

      context 'when used in a ternary expression' do
        it 'registers an offense and auto-corrects' do
          expect_offense(<<-RUBY.strip_indent)
            foo ? raise(Ex.new('error')) : bar
                  ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            foo ? raise(Ex, 'error') : bar
          RUBY
        end
      end

      context 'when used in a logical and expression' do
        it 'registers an offense and auto-corrects' do
          expect_offense(<<-RUBY.strip_indent)
            bar && raise(Ex.new('error'))
                   ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            bar && raise(Ex, 'error')
          RUBY
        end
      end

      context 'when used in a logical or expression' do
        it 'registers an offense and auto-corrects' do
          expect_offense(<<-RUBY.strip_indent)
            bar || raise(Ex.new('error'))
                   ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            bar || raise(Ex, 'error')
          RUBY
        end
      end
    end

    context 'with opposite + correct' do
      it 'reports an offense for opposite + correct' do
        expect_offense(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          end
        RUBY
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'auto-corrects to exploded style' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex, msg
          end
        RUBY
      end
    end

    context 'when an exception object is assigned to a local variable' do
      it 'auto-corrects to exploded style' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          def do_something
            klass = RuntimeError
            raise klass.new('hi')
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          def do_something
            klass = RuntimeError
            raise klass, 'hi'
          end
        RUBY
      end
    end

    it 'accepts exception constructor with more than 1 argument' do
      expect_no_offenses('raise MyCustomError.new(a1, a2, a3)')
    end

    it 'accepts exception constructor with keyword arguments' do
      expect_no_offenses('raise MyKwArgError.new(a: 1, b: 2)')
    end

    it 'accepts a raise with splatted arguments' do
      expect_no_offenses('raise MyCustomError.new(*args)')
    end

    it 'accepts a raise with 3 args' do
      expect_no_offenses('raise RuntimeError, msg, caller')
    end

    it 'accepts a raise with 2 args' do
      expect_no_offenses('raise RuntimeError, msg')
    end

    it 'accepts a raise with msg argument' do
      expect_no_offenses('raise msg')
    end
  end
end
