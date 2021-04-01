# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineIfThen, :config do
  # if

  it 'does not get confused by empty elsif branch' do
    expect_no_offenses(<<~RUBY)
      if cond
      elsif cond
      end
    RUBY
  end

  it 'registers an offense for then in multiline if' do
    expect_offense(<<~RUBY)
      if cond then
              ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond then\t
              ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond then
              ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond
      then
      ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond then # bad
              ^^^^ Do not use `then` for multi-line `if`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond
      end
      if cond\t
      end
      if cond
      end
      if cond
      end
      if cond # bad
      end
    RUBY
  end

  it 'registers an offense for then in multiline elsif' do
    expect_offense(<<~RUBY)
      if cond1
        a
      elsif cond2 then
                  ^^^^ Do not use `then` for multi-line `elsif`.
        b
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond1
        a
      elsif cond2
        b
      end
    RUBY
  end

  it 'accepts table style if/then/elsif/ends' do
    expect_no_offenses(<<~RUBY)
      if    @io == $stdout then str << "$stdout"
      elsif @io == $stdin  then str << "$stdin"
      elsif @io == $stderr then str << "$stderr"
      else                      str << @io.class.to_s
      end
    RUBY
  end

  it 'does not get confused by a then in a when' do
    expect_no_offenses(<<~RUBY)
      if a
        case b
        when c then
        end
      end
    RUBY
  end

  it 'does not get confused by a commented-out then' do
    expect_no_offenses(<<~RUBY)
      if a # then
        b
      end
      if c # then
      end
    RUBY
  end

  it 'does not raise an error for an implicit match if' do
    expect do
      expect_no_offenses(<<~RUBY)
        if //
        end
      RUBY
    end.not_to raise_error
  end

  # unless

  it 'registers an offense for then in multiline unless' do
    expect_offense(<<~RUBY)
      unless cond then
                  ^^^^ Do not use `then` for multi-line `unless`.
      end
    RUBY

    expect_correction(<<~RUBY)
      unless cond
      end
    RUBY
  end

  it 'does not get confused by a postfix unless' do
    expect_no_offenses('two unless one')
  end

  it 'does not get confused by a nested postfix unless' do
    expect_no_offenses(<<~RUBY)
      if two
        puts 1
      end unless two
    RUBY
  end

  it 'does not raise an error for an implicit match unless' do
    expect do
      expect_no_offenses(<<~RUBY)
        unless //
        end
      RUBY
    end.not_to raise_error
  end
end
