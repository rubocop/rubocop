# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WhileUntilModifier, :config do
  it_behaves_like 'condition modifier cop', :while
  it_behaves_like 'condition modifier cop', :until

  context 'when the body is a modifier if' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          bar if baz
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          bar if baz
        end
      RUBY
    end
  end

  context 'when the body is a modifier unless' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          bar unless baz
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          bar unless baz
        end
      RUBY
    end
  end

  context 'when the body is a ternary' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          x.odd? ? do_a : do_b
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          x.odd? ? do_a : do_b
        end
      RUBY
    end
  end

  context 'when the body is a nested `while`' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          bar while baz
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          bar while baz
        end
      RUBY
    end
  end

  context 'when the body is a nested `until`' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          bar until baz
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          bar until baz
        end
      RUBY
    end
  end

  context 'when the body is a single-line `case`' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          case x; when 42 then a; end
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          case x; when 42 then a; end
        end
      RUBY
    end
  end

  context 'when the body is a single-line `case` match' do
    it 'does not register an offense for while' do
      expect_no_offenses(<<~RUBY)
        while foo
          case x; in 42 then a; end
        end
      RUBY
    end

    it 'does not register an offense for until' do
      expect_no_offenses(<<~RUBY)
        until foo
          case x; in 42 then a; end
        end
      RUBY
    end
  end

  context 'when the modifier form is long but allowed by `Layout/LineLength`' do
    let(:other_cops) do
      { 'Layout/LineLength' => { 'Enabled' => true, 'Max' => 40, 'AllowURI' => allow_uri } }
    end
    let(:allow_uri) { true }
    let(:long_url) { 'https://example.com/a/rather/long/path?with=query' }

    context 'when the excess is an allowed URI' do
      it 'registers an offense and corrects to modifier form' do
        expect_offense(<<~RUBY)
          while url == '#{long_url}'
          ^^^^^ Favor modifier `while` usage when having a single-line body.
            step
          end
        RUBY

        expect_correction(<<~RUBY)
          step while url == '#{long_url}'
        RUBY
      end
    end

    context 'when AllowURI is false' do
      let(:allow_uri) { false }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          while url == '#{long_url}'
            step
          end
        RUBY
      end
    end
  end
end
