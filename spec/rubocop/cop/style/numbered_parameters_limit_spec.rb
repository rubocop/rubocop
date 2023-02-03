# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NumberedParametersLimit, :config do
  let(:cop_config) { { 'Max' => max } }
  let(:max) { 2 }

  context 'with Ruby >= 2.7', :ruby27 do
    it 'does not register an offense for a normal block with too many parameters' do
      expect_no_offenses(<<~RUBY)
        foo { |a, b, c, d, e, f, g| do_something(a,b,c,d,e,f,g) }
      RUBY
    end

    it 'does not register an offense for a numblock with fewer than `Max` parameters' do
      expect_no_offenses(<<~RUBY)
        foo { do_something(_1) }
      RUBY
    end

    it 'does not register an offense for a numblock with exactly `Max` parameters' do
      expect_no_offenses(<<~RUBY)
        foo { do_something(_1, _2) }
      RUBY
    end

    context 'when there are more than `Max` numbered parameters' do
      it 'registers an offense for a single line `numblock`' do
        expect_offense(<<~RUBY)
          foo { do_something(_1, _2, _3, _4, _5) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using more than 2 numbered parameters; 5 detected.
        RUBY
      end

      it 'registers an offense for a multiline `numblock`' do
        expect_offense(<<~RUBY)
          foo do
          ^^^^^^ Avoid using more than 2 numbered parameters; 5 detected.
            do_something(_1, _2, _3, _4, _5)
          end
        RUBY
      end
    end

    context 'when configuring Max' do
      let(:max) { 5 }

      it 'does not register an offense when there are not too many numbered params' do
        expect_no_offenses(<<~RUBY)
          foo { do_something(_1, _2, _3, _4, _5) }
        RUBY
      end
    end

    context 'when Max is 1' do
      let(:max) { 1 }

      it 'does not register an offense when only numbered parameter `_1` is used once' do
        expect_no_offenses(<<~RUBY)
          foo { do_something(_1) }
        RUBY
      end

      it 'does not register an offense when only numbered parameter `_1` is used twice' do
        expect_no_offenses(<<~RUBY)
          foo { do_something(_1, _1) }
        RUBY
      end

      it 'does not register an offense when only numbered parameter `_9` is used once' do
        expect_no_offenses(<<~RUBY)
          foo { do_something(_9) }
        RUBY
      end

      it 'does not register an offense when using numbered parameter with underscored local variable' do
        expect_no_offenses(<<~RUBY)
          _lvar = 42
          foo { do_something(_2, _lvar) }
        RUBY
      end

      it 'uses the right offense message' do
        expect_offense(<<~RUBY)
          foo { do_something(_1, _2, _3, _4, _5) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using more than 1 numbered parameter; 5 detected.
        RUBY
      end
    end

    it 'sets Max properly for auto-gen-config' do
      expect_offense(<<~RUBY)
        foo { do_something(_1, _2, _3, _4, _5) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using more than 2 numbered parameters; 5 detected.
      RUBY

      expect(cop.config_to_allow_offenses).to eq(exclude_limit: { 'Max' => 5 })
    end
  end
end
