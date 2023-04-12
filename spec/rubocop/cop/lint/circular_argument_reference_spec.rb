# frozen_string_literal: true

# Run test with Ruby 2.6 because this cop cannot handle invalid syntax in Ruby 2.7+.
RSpec.describe RuboCop::Cop::Lint::CircularArgumentReference, :config, :ruby26 do
  describe 'circular argument references in ordinal arguments' do
    context 'when the method contains a circular argument reference' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          def omg_wow(msg = msg)
                            ^^^ Circular argument reference - `msg`.
            puts msg
          end
        RUBY
      end
    end

    context 'when the method does not contain a circular argument reference' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def omg_wow(msg)
            puts msg
          end
        RUBY
      end
    end

    context 'when the seemingly-circular default value is a method call' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def omg_wow(msg = self.msg)
            puts msg
          end
        RUBY
      end
    end
  end

  describe 'circular argument references in keyword arguments' do
    context 'when the keyword argument is not circular' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def some_method(some_arg: nil)
            puts some_arg
          end
        RUBY
      end
    end

    context 'when the keyword argument is not circular, and calls a method' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def some_method(some_arg: some_method)
            puts some_arg
          end
        RUBY
      end
    end

    context 'when there is one circular argument reference' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          def some_method(some_arg: some_arg)
                                    ^^^^^^^^ Circular argument reference - `some_arg`.
            puts some_arg
          end
        RUBY
      end
    end

    context 'when the keyword argument is not circular, but calls a method ' \
            'of its own class with a self specification' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def puts_value(value: self.class.value, smile: self.smile)
            puts value
          end
        RUBY
      end
    end

    context 'when the keyword argument is not circular, but calls a method ' \
            'of some other object with the same name' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def puts_length(length: mystring.length)
            puts length
          end
        RUBY
      end
    end

    context 'when there are multiple offensive keyword arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          def some_method(some_arg: some_arg, other_arg: other_arg)
                                    ^^^^^^^^ Circular argument reference - `some_arg`.
                                                         ^^^^^^^^^ Circular argument reference - `other_arg`.
            puts [some_arg, other_arg]
          end
        RUBY
      end
    end
  end
end
