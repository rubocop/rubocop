# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfInsideElse do
  subject(:cop) { described_class.new }

  it 'catches an if node nested inside an else' do
    expect_offense(<<-RUBY.strip_indent)
      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        end
      end
    RUBY
  end

  it 'catches an if..else nested inside an else' do
    expect_offense(<<-RUBY.strip_indent)
      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        else
          bar
        end
      end
    RUBY
  end

  it 'catches a modifier if nested inside an else' do
    expect_offense(<<-RUBY.strip_indent)
      if a
        blah
      else
        foo if b
            ^^ Convert `if` nested inside `else` to `elsif`.
      end
    RUBY
  end

  it "isn't offended if there is a statement following the if node" do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
        blah
      else
        if b
          foo
        end
        bar
      end
    RUBY
  end

  it "isn't offended if there is a statement preceding the if node" do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
        blah
      else
        bar
        if b
          foo
        end
      end
    RUBY
  end

  it "isn't offended by if..elsif..else" do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
        blah
      elsif b
        blah
      else
        blah
      end
    RUBY
  end

  it 'ignores unless inside else' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
        blah
      else
        unless b
          foo
        end
      end
    RUBY
  end

  it 'ignores if inside unless' do
    expect_no_offenses(<<-RUBY.strip_indent)
      unless a
        if b
          foo
        end
      end
    RUBY
  end

  it 'ignores nested ternary expressions' do
    expect_no_offenses('a ? b : c ? d : e')
  end

  it 'ignores ternary inside if..else' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
        blah
      else
        a ? b : c
      end
    RUBY
  end
end
