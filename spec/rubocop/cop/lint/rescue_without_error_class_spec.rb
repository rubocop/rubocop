# frozen_string_literal: true

describe RuboCop::Cop::Lint::RescueWithoutErrorClass, :config do
  subject(:cop) { described_class.new(config) }

  context 'when rescuing in a begin block' do
    it 'registers an offense without an error class' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          foo
        rescue
        ^^^^^^ Avoid rescuing without specifying an error class.
          bar
        end
      RUBY
    end

    it 'does not register an offense with an error class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        begin
          foo
        rescue BarError
          bar
        end
      RUBY
    end
  end

  context 'when rescuing in a method definition' do
    it 'registers an offense without an error class' do
      expect_offense(<<-RUBY.strip_indent)
        def baz
          foo
        rescue
        ^^^^^^ Avoid rescuing without specifying an error class.
          bar
        end
      RUBY
    end

    it 'does not register an offense with an error class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def baz
          foo
        rescue BarError
          bar
        end
      RUBY
    end
  end
end
