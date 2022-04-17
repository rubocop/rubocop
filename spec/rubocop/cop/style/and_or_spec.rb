# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AndOr, :config do
  context 'when style is conditionals' do
    cop_config = { 'EnforcedStyle' => 'conditionals' }

    let(:cop_config) { cop_config }

    { 'and' => '&&', 'or' => '||' }.each do |operator, prefer|
      it "accepts \"#{operator}\" outside of conditional" do
        expect_no_offenses(<<~RUBY)
          x = a + b #{operator} return x
        RUBY
      end

      it "registers an offense for \"#{operator}\" in if condition" do
        expect_offense(<<~RUBY, operator: operator)
          if a %{operator} b
               ^{operator} Use `#{prefer}` instead of `#{operator}`.
            do_something
          end
        RUBY

        expect_correction(<<~RUBY)
          if a #{prefer} b
            do_something
          end
        RUBY
      end

      it "accepts \"#{operator}\" in if body" do
        expect_no_offenses(<<~RUBY)
          if some_condition
            do_something #{operator} return
          end
        RUBY
      end

      it "registers an offense for \"#{operator}\" in while condition" do
        expect_offense(<<~RUBY, operator: operator)
          while a %{operator} b
                  ^{operator} Use `#{prefer}` instead of `#{operator}`.
            do_something
          end
        RUBY

        expect_correction(<<~RUBY)
          while a #{prefer} b
            do_something
          end
        RUBY
      end

      it "accepts \"#{operator}\" in while body" do
        expect_no_offenses(<<~RUBY)
          while some_condition
            do_something #{operator} return
          end
        RUBY
      end

      it "registers an offense for \"#{operator}\" in until condition" do
        expect_offense(<<~RUBY, operator: operator)
          until a %{operator} b
                  ^{operator} Use `#{prefer}` instead of `#{operator}`.
            do_something
          end
        RUBY

        expect_correction(<<~RUBY)
          until a #{prefer} b
            do_something
          end
        RUBY
      end

      it "accepts \"#{operator}\" in until body" do
        expect_no_offenses(<<~RUBY)
          until some_condition
            do_something #{operator} return
          end
        RUBY
      end

      it "registers an offense for \"#{operator}\" in post-while condition" do
        expect_offense(<<~RUBY, operator: operator)
          begin
            do_something
          end while a %{operator} b
                      ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          begin
            do_something
          end while a #{prefer} b
        RUBY
      end

      it "accepts \"#{operator}\" in post-while body" do
        expect_no_offenses(<<~RUBY)
          begin
            do_something #{operator} return
          end while some_condition
        RUBY
      end

      it "registers an offense for \"#{operator}\" in post-until condition" do
        expect_offense(<<~RUBY, operator: operator)
          begin
            do_something
          end until a %{operator} b
                      ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          begin
            do_something
          end until a #{prefer} b
        RUBY
      end

      it "accepts \"#{operator}\" in post-until body" do
        expect_no_offenses(<<~RUBY)
          begin
            do_something #{operator} return
          end until some_condition
        RUBY
      end
    end

    %w[&& ||].each do |operator|
      it "accepts #{operator} inside of conditional" do
        expect_no_offenses(<<~RUBY)
          test if a #{operator} b
        RUBY
      end

      it "accepts #{operator} outside of conditional" do
        expect_no_offenses(<<~RUBY)
          x = a #{operator} b
        RUBY
      end
    end
  end

  context 'when style is always' do
    cop_config = { 'EnforcedStyle' => 'always' }

    let(:cop_config) { cop_config }

    { 'and' => '&&', 'or' => '||' }.each do |operator, prefer|
      it "registers an offense for \"#{operator}\"" do
        expect_offense(<<~RUBY, operator: operator)
          test if a %{operator} b
                    ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          test if a #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" inside def" do
        expect_offense(<<~RUBY, operator: operator)
          def z(a, b)
            return true if a %{operator} b
                             ^{operator} Use `#{prefer}` instead of `#{operator}`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def z(a, b)
            return true if a #{prefer} b
          end
        RUBY
      end
    end

    it 'autocorrects "or" with an assignment on the left' do
      expect_offense(<<~RUBY)
        x = y or teststring.include? 'b'
              ^^ Use `||` instead of `or`.
      RUBY

      expect_correction(<<~RUBY)
        (x = y) || teststring.include?('b')
      RUBY
    end

    it 'autocorrects "or" with an assignment on the right' do
      expect_offense(<<~RUBY)
        teststring.include? 'b' or x = y
                                ^^ Use `||` instead of `or`.
      RUBY

      expect_correction(<<~RUBY)
        teststring.include?('b') || (x = y)
      RUBY
    end

    it 'autocorrects "and" with an Enumerable accessor on either side' do
      expect_offense(<<~RUBY)
        foo[:bar] and foo[:baz]
                  ^^^ Use `&&` instead of `and`.
      RUBY

      expect_correction(<<~RUBY)
        foo[:bar] && foo[:baz]
      RUBY
    end

    { 'and' => '&&', 'or' => '||' }.each do |operator, prefer|
      it "warns on short-circuit (#{operator})" do
        expect_offense(<<~RUBY, operator: operator)
          x = a + b %{operator} return x
                    ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          (x = a + b) #{prefer} (return x)
        RUBY
      end

      it "also warns on non short-circuit (#{operator})" do
        expect_offense(<<~RUBY, operator: operator)
          x = a + b if a %{operator} b
                         ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          x = a + b if a #{prefer} b
        RUBY
      end

      it "also warns on non short-circuit (#{operator}) (unless)" do
        expect_offense(<<~RUBY, operator: operator)
          x = a + b unless a %{operator} b
                             ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          x = a + b unless a #{prefer} b
        RUBY
      end

      it "also warns on while (#{operator})" do
        expect_offense(<<~RUBY, operator: operator)
          x = a + b while a %{operator} b
                            ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          x = a + b while a #{prefer} b
        RUBY
      end

      it "also warns on until (#{operator})" do
        expect_offense(<<~RUBY, operator: operator)
          x = a + b until a %{operator} b
                            ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          x = a + b until a #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" with #{prefer} in method calls" do
        expect_offense(<<~RUBY, operator: operator)
          method a %{operator} b
                   ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          method(a) #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" with #{prefer} in method calls (2)" do
        expect_offense(<<~RUBY, operator: operator)
          method a,b %{operator} b
                     ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          method(a,b) #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" with #{prefer} in method calls (3)" do
        expect_offense(<<~RUBY, operator: operator)
          obj.method a %{operator} b
                       ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          obj.method(a) #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" with #{prefer} in method calls (4)" do
        expect_offense(<<~RUBY, operator: operator)
          obj.method a,b %{operator} b
                         ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          obj.method(a,b) #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" with #{prefer} and doesn't add extra parentheses" do
        expect_offense(<<~RUBY, operator: operator)
          method(a, b) %{operator} b
                       ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          method(a, b) #{prefer} b
        RUBY
      end

      it "autocorrects \"#{operator}\" with #{prefer} and adds parentheses to expr" do
        expect_offense(<<~RUBY, operator: operator)
          b %{operator} method a,b
            ^{operator} Use `#{prefer}` instead of `#{operator}`.
        RUBY

        expect_correction(<<~RUBY)
          b #{prefer} method(a,b)
        RUBY
      end
    end

    context 'with !obj.method arg on right' do
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          x and !obj.method arg
            ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          x && !obj.method(arg)
        RUBY
      end
    end

    context 'with !obj.method arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          !obj.method arg and x
                          ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          !obj.method(arg) && x
        RUBY
      end
    end

    context 'with obj.method = arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          obj.method = arg and x
                           ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          (obj.method = arg) && x
        RUBY
      end
    end

    context 'with obj.method= arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          obj.method= arg and x
                          ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          (obj.method= arg) && x
        RUBY
      end
    end

    context 'with predicate method with arg without space on right' do
      it 'autocorrects "or" with || and adds parens' do
        expect_offense(<<~RUBY)
          false or 3.is_a?Integer
                ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          false || 3.is_a?(Integer)
        RUBY
      end

      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          false and 3.is_a?Integer
                ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          false && 3.is_a?(Integer)
        RUBY
      end
    end

    context 'with two predicate methods with args without spaces on right' do
      it 'autocorrects "or" with || and adds parens' do
        expect_offense(<<~RUBY)
          '1'.is_a?Integer or 1.is_a?Integer
                           ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          '1'.is_a?(Integer) || 1.is_a?(Integer)
        RUBY
      end

      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          '1'.is_a?Integer and 1.is_a?Integer
                           ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          '1'.is_a?(Integer) && 1.is_a?(Integer)
        RUBY
      end
    end

    context 'with one predicate method without space on right and another method' do
      it 'autocorrects "or" with || and adds parens' do
        expect_offense(<<~RUBY)
          '1'.is_a?Integer or 1.is_a? Integer
                           ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          '1'.is_a?(Integer) || 1.is_a?(Integer)
        RUBY
      end

      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          '1'.is_a?Integer and 1.is_a? Integer
                           ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          '1'.is_a?(Integer) && 1.is_a?(Integer)
        RUBY
      end
    end

    context 'with `not` expression on right' do
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          x and not arg
            ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          x && (not arg)
        RUBY
      end
    end

    context 'with `not` expression on left' do
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          not arg and x
                  ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          (not arg) && x
        RUBY
      end
    end

    context 'with !variable on left' do
      it "doesn't crash and burn" do
        # regression test; see GH issue 2482
        expect_offense(<<~RUBY)
          !var or var.empty?
               ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          !var || var.empty?
        RUBY
      end
    end

    context 'within a nested begin node' do
      # regression test; see GH issue 2531
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          def x
          end

          def y
            a = b and a.c
                  ^^^ Use `&&` instead of `and`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def x
          end

          def y
            (a = b) && a.c
          end
        RUBY
      end
    end

    context 'when left hand side is a comparison method' do
      # Regression: https://github.com/rubocop/rubocop/issues/4451
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          foo == bar and baz
                     ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          (foo == bar) && baz
        RUBY
      end
    end

    context 'when `or` precedes `and`' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo or bar and baz
              ^^ Use `||` instead of `or`.
                     ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          (foo || bar) && baz
        RUBY
      end
    end

    context 'when `or` precedes `&&`' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo or bar && baz
              ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          foo || bar && baz
        RUBY
      end
    end

    context 'when `and` precedes `or`' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo and bar or baz
              ^^^ Use `&&` instead of `and`.
                      ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          foo && bar || baz
        RUBY
      end
    end

    context 'when `and` precedes `||`' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo and bar || baz
              ^^^ Use `&&` instead of `and`.
        RUBY

        expect_correction(<<~RUBY)
          foo && (bar || baz)
        RUBY
      end
    end

    context 'within a nested begin node with one child only' do
      # regression test; see GH issue 2531
      it 'autocorrects "and" with && and adds parens' do
        expect_offense(<<~RUBY)
          (def y
            a = b and a.c
                  ^^^ Use `&&` instead of `and`.
          end)
        RUBY

        expect_correction(<<~RUBY)
          (def y
            (a = b) && a.c
          end)
        RUBY
      end
    end

    context 'with a file which contains __FILE__' do
      # regression test; see GH issue 2609
      it 'autocorrects "or" with ||' do
        expect_offense(<<~RUBY)
          APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
          system('bundle check') or system!('bundle install')
                                 ^^ Use `||` instead of `or`.
        RUBY

        expect_correction(<<~RUBY)
          APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
          system('bundle check') || system!('bundle install')
        RUBY
      end
    end
  end
end
