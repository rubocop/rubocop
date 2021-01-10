# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineIfModifier, :config do
  context 'if guard clause' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        {
        ^ Favor a normal if-statement over a modifier clause in a multiline statement.
          result: run
        } if cond
      RUBY

      expect_correction(<<~RUBY)
        if cond
          {
            result: run
          }
        end
      RUBY
    end

    it 'allows a one liner' do
      expect_no_offenses(<<~RUBY)
        run if cond
      RUBY
    end

    it 'allows a multiline condition' do
      expect_no_offenses(<<~RUBY)
        run if cond &&
               cond2
      RUBY
    end

    it 'registers an offense when indented' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |  {
        |  ^ Favor a normal if-statement over a modifier clause in a multiline statement.
        |    result: run
        |  } if cond
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |  if cond
        |    {
        |      result: run
        |    }
        |  end
      RUBY
    end
  end

  context 'unless guard clause' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        {
        ^ Favor a normal unless-statement over a modifier clause in a multiline statement.
          result: run
        } unless cond
      RUBY

      expect_correction(<<~RUBY)
        unless cond
          {
            result: run
          }
        end
      RUBY
    end

    it 'allows a one liner' do
      expect_no_offenses(<<~RUBY)
        run unless cond
      RUBY
    end

    it 'allows a multiline condition' do
      expect_no_offenses(<<~RUBY)
        run unless cond &&
                   cond2
      RUBY
    end

    it 'registers an offense when indented' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |  {
        |  ^ Favor a normal unless-statement over a modifier clause in a multiline statement.
        |    result: run
        |  } unless cond
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |  unless cond
        |    {
        |      result: run
        |    }
        |  end
      RUBY
    end
  end
end
