# frozen_string_literal: true

describe RuboCop::Cop::Lint::UnreachableCode do
  subject(:cop) { described_class.new }

  def wrap(str)
    head = <<-RUBY.strip_indent
      def something
        array.each do |item|
    RUBY
    tail = <<-RUBY.strip_indent
        end
      end
    RUBY
    body = str.strip_indent.each_line.map { |line| "    #{line}" }.join
    head + body + tail
  end

  %w[return next break retry redo throw raise fail].each do |t|
    it "registers an offense for `#{t}` before other statements" do
      expect_offense(wrap(<<-RUBY))
        #{t}
        bar
        ^^^ Unreachable code detected.
      RUBY
    end

    it "registers an offense for `#{t}` in `begin`" do
      expect_offense(wrap(<<-RUBY))
        begin
          #{t}
          bar
          ^^^ Unreachable code detected.
        end
      RUBY
    end

    it "registers an offense for `#{t}` in all `if` branches" do
      expect_offense(wrap(<<-RUBY))
        if cond
          #{t}
        else
          #{t}
        end
        bar
        ^^^ Unreachable code detected.
      RUBY
    end

    it "registers an offense for `#{t}` in all `if` branches" \
       'with other expressions' do
      expect_offense(wrap(<<-RUBY))
        if cond
          something
          #{t}
        else
          something2
          #{t}
        end
        bar
        ^^^ Unreachable code detected.
      RUBY
    end

    it "registers an offense for `#{t}` in all `if` and `elsif` branches" do
      expect_offense(wrap(<<-RUBY))
        if cond
          something
          #{t}
        elsif cond2
          something2
          #{t}
        else
          something3
          #{t}
        end
        bar
        ^^^ Unreachable code detected.
      RUBY
    end

    it "registers an offense for `#{t}` in all `case` branches" do
      expect_offense(wrap(<<-RUBY))
        case cond
        when 1
          something
          #{t}
        when 2
          something2
          #{t}
        else
          something3
          #{t}
        end
        bar
        ^^^ Unreachable code detected.
      RUBY
    end

    it "accepts code with conditional `#{t}`" do
      expect_no_offenses(wrap(<<-RUBY))
        #{t} if cond
        bar
      RUBY
    end

    it "accepts `#{t}` as the final expression" do
      expect_no_offenses(wrap(<<-RUBY))
        #{t} if cond
      RUBY
    end

    it "accepts `#{t}` is in all `if` branchsi" do
      expect_no_offenses(wrap(<<-RUBY))
        if cond
          #{t}
        else
          #{t}
        end
      RUBY
    end

    it "accepts `#{t}` is in `if` branch only" do
      expect_no_offenses(wrap(<<-RUBY))
        if cond
          something
          #{t}
        else
          something2
        end
        bar
      RUBY
    end

    it "accepts `#{t}` is in `if`, and without `else`" do
      expect_no_offenses(wrap(<<-RUBY))
        if cond
          something
          #{t}
        end
        bar
      RUBY
    end

    it "accepts `#{t}` is in `else` branch only" do
      expect_no_offenses(wrap(<<-RUBY))
        if cond
          something
        else
          something2
          #{t}
        end
        bar
      RUBY
    end

    it "accepts `#{t}` is not in `elsif` branch" do
      expect_no_offenses(wrap(<<-RUBY))
        if cond
          something
          #{t}
        elsif cond2
          something2
        else
          something3
          #{t}
        end
        bar
      RUBY
    end

    it "accepts `#{t}` is in `case` branch without else" do
      expect_no_offenses(wrap(<<-RUBY))
        case cond
        when 1
          something
          #{t}
        when 2
          something2
          #{t}
        end
        bar
      RUBY
    end
  end
end
