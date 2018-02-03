# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyLineAfterGuardClause do
  subject(:cop) { described_class.new }

  it 'registers an offense for guard clause not followed by empty line' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        return if need_return?
        ^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        foobar
      end
    RUBY
  end

  it 'registers an offense for next guard clause not followed by empty line' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        next unless need_next?
        ^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        foobar
      end
    RUBY
  end

  it 'does not register offence for modifier if' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        foo += 1 if need_add?
        foobar
      end
    RUBY
  end

  it 'does not register offence for guard clause followed by end' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        if something?
          return
        end
      end
    RUBY
  end

  it 'does not register offence for guard clause inside oneliner block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        object.tap { |obj| return another_object if something? }
        foobar
      end
    RUBY
  end

  it 'does not register offence for multiple guard clauses' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        return another_object if something?
        return another_object if something_else?
        return another_object if something_different?

        foobar
      end
    RUBY
  end

  it 'does not register offence if next line is end' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        return another_object if something_different?
      end
    RUBY
  end

  it 'registers an offence for methods starting with end_' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        next unless need_next?
        ^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        end_this!
      end
    RUBY
  end

  it 'autocorrects offence' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def foo
        next if foo?
        next if bar?
        foobar
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def foo
        next if foo?
        next if bar?

        foobar
      end
    RUBY
  end

  it 'correctly autocorrects offence with comment on same line' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def foo
        next if foo? # This is foo
        foobar
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def foo
        next if foo? # This is foo

        foobar
      end
    RUBY
  end
end
