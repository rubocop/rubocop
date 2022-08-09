# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NoopRescue, :config do
  context 'when do nothing `rescue`' do
    it 'registers an offense when postfix `rescue`' do
      expect_offense(<<~RUBY)
        foo rescue nil
            ^^^^^^^^^^ Don't suppress or ignore checked exception.
      RUBY
    end

    it 'registers an offense when inside the method definition' do
      expect_offense(<<~RUBY)
        def foo
          do_something
        rescue StandardError => e
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Don't suppress or ignore checked exception.
          # no op
        end
      RUBY
    end

    it 'registers an offense when begin-rescue' do
      expect_offense(<<~RUBY)
        begin
          do_something
        rescue StandardError
        ^^^^^^^^^^^^^^^^^^^^ Don't suppress or ignore checked exception.
          nil
        end
      RUBY
    end

    it 'registers an offense when catching multiple exceptions' do
      expect_offense(<<~RUBY)
        def foo
        rescue RuntimeError, AwesomeError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't suppress or ignore checked exception.
        end
      RUBY
    end
  end

  context 'when do something `rescue`' do
    it 'does not register an offense when using `#good_method`' do
      expect_no_offenses(<<~RUBY)
        foo rescue do_something
      RUBY
    end

    it 'does not register an offense when inside the method definition' do
      expect_no_offenses(<<~RUBY)
        def foo
        rescue
          do_something
        end
      RUBY
    end

    it 'does not registers an offense when begin-rescue' do
      expect_no_offenses(<<~RUBY)
        begin
          do_something
        rescue StandardError
          do_something
        end
      RUBY
    end

    it 'does not registers an offense when catching multiple exceptions' do
      expect_no_offenses(<<~RUBY)
        def foo
        rescue RuntimeError, AwesomeError
          do_something
        end
      RUBY
    end
  end
end
