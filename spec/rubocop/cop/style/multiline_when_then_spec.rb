# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineWhenThen do
  subject(:cop) { described_class.new }

  it 'registers an offense for empty when statement with then' do
    expect_offense(<<~RUBY)
      case foo
      when bar then
               ^^^^ Do not use `then` for multiline `when` statement.
      end
    RUBY
  end

  it 'registers an offense for multiline when statement with then' do
    expect_offense(<<~RUBY)
      case foo
      when bar then
               ^^^^ Do not use `then` for multiline `when` statement.
      do_something
      end
    RUBY
  end

  it "doesn't register an offense for singleline when statement with then" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar then do_something
      end
    RUBY
  end

  it "doesn't register an offense for multiline when statement
  with then followed by other lines" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar then do_something
                    do_another_thing
      end
    RUBY
  end

  it "doesn't register an offense for empty when statement without then" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar
      end
    RUBY
  end

  it "doesn't register an offense for multiline when statement without then" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar
      do_something
      end
    RUBY
  end

  it 'autocorrects then in empty when' do
    new_source = autocorrect_source(<<~RUBY)
      case foo
      when bar then
      end
    RUBY
    expect(new_source).to eq(<<~RUBY)
      case foo
      when bar
      end
    RUBY
  end

  it 'autocorrects then in multiline when' do
    new_source = autocorrect_source(<<~RUBY)
      case foo
      when bar then
      do_something
      end
    RUBY
    expect(new_source).to eq(<<~RUBY)
      case foo
      when bar
      do_something
      end
    RUBY
  end
end
