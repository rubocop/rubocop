# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SafeNavigation, :config do
  let(:cop_config) { { 'ConvertCodeThatCanStartToReturnNil' => false } }
  let(:target_ruby_version) { 2.3 }

  it 'allows calls to methods not safeguarded by respond_to' do
    expect_no_offenses('foo.bar')
  end

  it 'allows calls using safe navigation' do
    expect_no_offenses('foo&.bar')
  end

  it 'allows calls on nil' do
    expect_no_offenses('nil&.bar')
  end

  it 'allows an object check before hash access' do
    expect_no_offenses('foo && foo[:bar]')
  end

  it 'allows an object check before a negated predicate' do
    expect_no_offenses('foo && !foo.bar?')
  end

  it 'allows an object check before a nil check on a short chain' do
    expect_no_offenses('user && user.thing.nil?')
  end

  it 'allows an object check before a method chain longer than 2 methods' do
    expect_no_offenses('user && user.one.two.three')
  end

  it 'allows an object check before a long chain with a block' do
    expect_no_offenses('user && user.thing.plus.another { |a| a}.other_thing')
  end

  it 'allows an object check before a nil check on a long chain' do
    expect_no_offenses('user && user.thing.plus.some.other_thing.nil?')
  end

  it 'allows an object check before a blank check' do
    # The `nil` object doesn't respond to `blank?` in normal Ruby (it's added
    # by Rails), but it's included in the AllowedMethods parameter in default
    # configuration for this cop.
    expect_no_offenses('user && user.thing.blank?')
  end

  it 'allows an object check before a negated predicate method chain' do
    expect_no_offenses('foo && !foo.bar.baz?')
  end

  it 'allows method call that is used in a comparison safe guarded by an object check' do
    expect_no_offenses('foo.bar > 2 if foo')
  end

  it 'allows method call that is used in a regex comparison safe guarded by an object check' do
    expect_no_offenses('foo.bar =~ /baz/ if foo')
  end

  it 'allows method call that is used in a negated regex comparison ' \
     'safe guarded by an object check' do
    expect_no_offenses('foo.bar !~ /baz/ if foo')
  end

  it 'allows method call that is used in a spaceship comparison safe guarded by an object check' do
    expect_no_offenses('foo.bar <=> baz if foo')
  end

  it 'allows an object check before a method call that is used in a comparison' do
    expect_no_offenses('foo && foo.bar > 2')
  end

  it 'allows an object check before a method call that is used in a regex comparison' do
    expect_no_offenses('foo && foo.bar =~ /baz/')
  end

  it 'allows an object check before a method call that is used in a negated regex comparison' do
    expect_no_offenses('foo && foo.bar !~ /baz/')
  end

  it 'allows an object check before a method call that is used with `empty?`' do
    expect_no_offenses('foo && foo.empty?')
  end

  it 'allows an object check before a method call that is used in a spaceship comparison' do
    expect_no_offenses('foo && foo.bar <=> baz')
  end

  it 'allows an object check before a method chain that is used in a comparison' do
    expect_no_offenses('foo && foo.bar.baz > 2')
  end

  it 'allows a method chain that is used in a comparison safe guarded by an object check' do
    expect_no_offenses('foo.bar.baz > 2 if foo')
  end

  it 'allows a method call safeguarded with a negative check for the object when using `unless`' do
    expect_no_offenses('obj.do_something unless obj')
  end

  it 'allows a method call safeguarded with a negative check for the object when using `if`' do
    expect_no_offenses('obj.do_something if !obj')
  end

  it 'allows method calls that do not get called using . safe guarded by an object check' do
    expect_no_offenses('foo + bar if foo')
  end

  it 'allows chained method calls during arithmetic operations safe guarded by an object check' do
    expect_no_offenses('foo.baz + bar if foo')
  end

  it 'allows chained method calls during assignment safe guarded by an object check' do
    expect_no_offenses('foo.baz = bar if foo')
  end

  it 'allows an object check before a negated method call with a safe navigation' do
    expect_no_offenses('obj && !obj&.do_something')
  end

  it 'allows object checks in the condition of an elsif statement ' \
     'and a method call on that object in the body' do
    expect_no_offenses(<<~RUBY)
      if foo
        something
      elsif bar
        bar.baz
      end
    RUBY
  end

  it 'allows for empty if blocks with comments' do
    expect_no_offenses(<<~RUBY)
      if foo
        # a random comment
        # TODO: Implement this before
      end
    RUBY
  end

  it 'allows a method call as a parameter when the parameter is ' \
     'safe guarded with an object check' do
    expect_no_offenses('foo(bar.baz) if bar')
  end

  it 'allows a method call safeguarded when using `unless nil?`' do
    expect_no_offenses(<<~RUBY)
      foo unless nil?
    RUBY
  end

  # See https://github.com/rubocop/rubocop/issues/8781
  it 'does not move comments that are inside an inner block' do
    expect_offense(<<~RUBY)
      # Comment 1
      if x
      ^^^^ Use safe navigation (`&.`) instead of checking if an object exists before calling the method.
        # Comment 2
        x.each do
          # Comment 3
          # Comment 4
        end
        # Comment 5
      end
    RUBY

    expect_correction(<<~RUBY)
      # Comment 1
      # Comment 2
      # Comment 5
      x&.each do
          # Comment 3
          # Comment 4
        end
    RUBY
  end

  shared_examples 'all variable types' do |variable|
    context 'modifier if' do
      shared_examples 'safe guarding logical break keywords' do |keyword|
        it "allows a method call being passed to #{keyword} safe guarded by an object check" do
          expect_no_offenses(<<~RUBY)
            something.each do
              #{keyword} #{variable}.bar if #{variable}
            end
          RUBY
        end
      end

      it_behaves_like 'safe guarding logical break keywords', 'break'
      it_behaves_like 'safe guarding logical break keywords', 'fail'
      it_behaves_like 'safe guarding logical break keywords', 'next'
      it_behaves_like 'safe guarding logical break keywords', 'raise'
      it_behaves_like 'safe guarding logical break keywords', 'return'
      it_behaves_like 'safe guarding logical break keywords', 'throw'
      it_behaves_like 'safe guarding logical break keywords', 'yield'

      it 'registers an offense for a method call that nil responds to ' \
         'safe guarded by an object check' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.to_i if %{variable}
          ^{variable}^^^^^^^^^^{variable} Use safe navigation (`&.`) instead of checking if an object exists before calling the method.
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.to_i
        RUBY
      end

      it 'registers an offense when safe guard check and safe navigation method call are connected with `&&` condition' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable} && %{variable}&.do_something
          ^{variable}^^^^^{variable}^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead of checking if an object exists before calling the method.
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.do_something
        RUBY
      end

      it 'registers an offense for a method call on an accessor ' \
         'safeguarded by a check for the accessed variable' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}[1].bar if %{variable}[1]
          ^{variable}^^^^^^^^^^^^{variable}^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}[1]&.bar
        RUBY
      end

      it 'registers an offense for a method call safeguarded with a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar if %{variable}
          ^{variable}^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a method call with params safeguarded ' \
         'with a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) if %{variable}
          ^{variable}^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a method call with a block safeguarded ' \
         'with a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar { |e| e.qux } if %{variable}
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call with params and a block ' \
         'safeguarded with a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) { |e| e.qux } if %{variable}
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a chained method call safeguarded with a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.one.two(baz) { |e| e.qux } if %{variable}
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.one&.two(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call safeguarded with a ' \
         'negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar unless !%{variable}
          ^{variable}^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a method call with params safeguarded ' \
         'with a negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) unless !%{variable}
          ^{variable}^^^^^^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a method call with a block safeguarded ' \
         'with a negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar { |e| e.qux } unless !%{variable}
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call with params and a block ' \
         'safeguarded with a negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) { |e| e.qux } unless !%{variable}
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call safeguarded with a nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar unless %{variable}.nil?
          ^{variable}^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a method call with params safeguarded ' \
         'with a nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) unless %{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a method call with a block safeguarded ' \
         'with a nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar { |e| e.qux } unless %{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call with params and a block ' \
         'safeguarded with a nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) { |e| e.qux } unless %{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a chained method call safeguarded ' \
         'with an unless nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.one.two(baz) { |e| e.qux } unless %{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.one&.two(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call safeguarded with a ' \
         'negative nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar if !%{variable}.nil?
          ^{variable}^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a method call with params safeguarded ' \
         'with a negative nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) if !%{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a method call with a block safeguarded ' \
         'with a negative nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar { |e| e.qux } if !%{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a method call with params and a block ' \
         'safeguarded with a negative nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.bar(baz) { |e| e.qux } if !%{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a chained method call safeguarded ' \
         'with a negative nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable}.one.two(baz) { |e| e.qux } if !%{variable}.nil?
          ^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.one&.two(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for an object check followed by a method call ' \
         'with a comment at EOL' do
        expect_offense(<<~RUBY, variable: variable)
          foo if %{variable} && %{variable}.bar # comment
                 ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
        RUBY

        expect_correction(<<~RUBY)
          foo if #{variable}&.bar # comment
        RUBY
      end
    end

    context 'if expression' do
      it 'registers an offense for a single method call inside of a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if %{variable}
          ^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'inside of a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if %{variable}
          ^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz)
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a single method call with a block ' \
         'inside of a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if %{variable}
          ^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'and a block inside of a check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if %{variable}
          ^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz) { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call inside of a non-nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if !%{variable}.nil?
          ^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'inside of a non-nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if !%{variable}.nil?
          ^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz)
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a single method call with a block ' \
         'inside of a non-nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if !%{variable}.nil?
          ^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'and a block inside of a non-nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          if !%{variable}.nil?
          ^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz) { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call inside of an ' \
         'unless nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless %{variable}.nil?
          ^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'inside of an unless nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless %{variable}.nil?
          ^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz)
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a single method call with a block ' \
         'inside of an unless nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless %{variable}.nil?
          ^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'and a block inside of an unless nil check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless %{variable}.nil?
          ^^^^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz) { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call inside of an ' \
         'unless negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless !%{variable}
          ^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'inside of an unless negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless !%{variable}
          ^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz)
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz)
        RUBY
      end

      it 'registers an offense for a single method call with a block ' \
         'inside of an unless negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless !%{variable}
          ^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar { |e| e.qux }
        RUBY
      end

      it 'registers an offense for a single method call with params ' \
         'and a block inside of an unless negative check for the object' do
        expect_offense(<<~RUBY, variable: variable)
          unless !%{variable}
          ^^^^^^^^^{variable} Use safe navigation (`&.`) instead [...]
            %{variable}.bar(baz) { |e| e.qux }
          end
        RUBY

        expect_correction(<<~RUBY)
          #{variable}&.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'does not lose comments within if expression' do
        expect_offense(<<~RUBY, variable: variable)
          if %{variable} # hello
          ^^^^{variable}^^^^^^^^ Use safe navigation (`&.`) instead [...]
            # this is a comment
            # another comment
            %{variable}.bar
          end # bye!
        RUBY

        expect_correction(<<~RUBY)
          # hello
          # this is a comment
          # another comment
          #{variable}&.bar # bye!
        RUBY
      end

      it 'only moves comments that fall within the expression' do
        expect_offense(<<~RUBY, variable: variable)
          # comment one
          def foobar
            if %{variable}
            ^^^^{variable} Use safe navigation (`&.`) instead [...]
              # comment 2
              %{variable}.bar
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          # comment one
          def foobar
            # comment 2
          #{variable}&.bar
          end
        RUBY
      end

      it 'allows a single method call inside of a check for the object with an else' do
        expect_no_offenses(<<~RUBY)
          if #{variable}
            #{variable}.bar
          else
            something
          end
        RUBY
      end

      context 'ternary expression' do
        it 'allows non-convertible ternary expression' do
          expect_no_offenses(<<~RUBY)
            !#{variable}.nil? ? #{variable}.bar : something
          RUBY
        end

        it 'registers an offense for convertible ternary expressions' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} ? %{variable}.bar : nil
            ^{variable}^^^^{variable}^^^^^^^^^^ Use safe navigation (`&.`) instead [...]

            %{variable}.nil? ? nil : %{variable}.bar
            ^{variable}^^^^^^^^^^^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]

            !%{variable}.nil? ? %{variable}.bar : nil
            ^^{variable}^^^^^^^^^^{variable}^^^^^^^^^ Use safe navigation (`&.`) instead [...]

            !%{variable} ? nil : %{variable}.bar
            ^^{variable}^^^^^^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar

            #{variable}&.bar

            #{variable}&.bar

            #{variable}&.bar
          RUBY
        end
      end
    end

    context 'object check before method call' do
      context 'ConvertCodeThatCanStartToReturnNil true' do
        let(:cop_config) { { 'ConvertCodeThatCanStartToReturnNil' => true } }

        it 'registers an offense for a non-nil object check followed by a method call' do
          expect_offense(<<~RUBY, variable: variable)
            !%{variable}.nil? && %{variable}.bar
            ^^{variable}^^^^^^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar
          RUBY
        end

        it 'registers an offense for a non-nil object check followed by a ' \
           'method call with params' do
          expect_offense(<<~RUBY, variable: variable)
            !%{variable}.nil? && %{variable}.bar(baz)
            ^^{variable}^^^^^^^^^^{variable}^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar(baz)
          RUBY
        end

        it 'registers an offense for a non-nil object check followed by a ' \
           'method call with a block' do
          expect_offense(<<~RUBY, variable: variable)
            !%{variable}.nil? && %{variable}.bar { |e| e.qux }
            ^^{variable}^^^^^^^^^^{variable}^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar { |e| e.qux }
          RUBY
        end

        it 'registers an offense for a non-nil object check followed by a ' \
           'method call with params and a block' do
          expect_offense(<<~RUBY, variable: variable)
            !%{variable}.nil? && %{variable}.bar(baz) { |e| e.qux }
            ^^{variable}^^^^^^^^^^{variable}^^^^^^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar(baz) { |e| e.qux }
          RUBY
        end

        it 'registers an offense for an object check followed by a method call' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar
            ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar
          RUBY
        end

        it 'registers an offense for an object check followed by a method call with params' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar(baz)
            ^{variable}^^^^^{variable}^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar(baz)
          RUBY
        end

        it 'registers an offense for an object check followed by a method call with a block' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar { |e| e.qux }
            ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar { |e| e.qux }
          RUBY
        end

        it 'registers an offense for an object check followed by a ' \
           'method call with params and a block' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar(baz) { |e| e.qux }
            ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar(baz) { |e| e.qux }
          RUBY
        end

        it 'registers an offense for a check for the object followed by a ' \
           'method call in the condition for an if expression' do
          expect_offense(<<~RUBY, variable: variable)
            if %{variable} && %{variable}.bar
               ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
              something
            end
          RUBY

          expect_correction(<<~RUBY)
            if #{variable}&.bar
              something
            end
          RUBY
        end

        it 'corrects an object check followed by a method call and another check' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar && something
            ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar && something
          RUBY
        end

        context 'method chaining' do
          it 'registers an offense for an object check followed by ' \
             'chained method calls with blocks' do
            expect_offense(<<~RUBY, variable: variable)
              %{variable} && %{variable}.one { |a| b}.two(baz) { |e| e.qux }
              ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
            RUBY

            expect_correction(<<~RUBY)
              #{variable}&.one { |a| b}&.two(baz) { |e| e.qux }
            RUBY
          end

          context 'MaxChainLength: 1' do
            let(:cop_config) { { 'MaxChainLength' => 1 } }

            it 'registers an offense for an object check followed by 1 chained method calls' do
              expect_offense(<<~RUBY, variable: variable)
                %{variable} && %{variable}.one
                ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
              RUBY

              expect_correction(<<~RUBY)
                #{variable}&.one
              RUBY
            end

            it 'allows an object check followed by 2 chained method calls' do
              expect_no_offenses(<<~RUBY)
                #{variable} && #{variable}.one.two
              RUBY
            end
          end

          context 'MaxChainLength: 3' do
            let(:cop_config) { { 'MaxChainLength' => 3 } }

            it 'registers an offense for an object check followed by 3 chained method calls' do
              expect_offense(<<~RUBY, variable: variable)
                %{variable} && %{variable}.one.two.three
                ^{variable}^^^^^{variable}^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
              RUBY

              expect_correction(<<~RUBY)
                #{variable}&.one&.two&.three
              RUBY
            end

            it 'allows an object check followed by 4 chained method calls' do
              expect_no_offenses(<<~RUBY)
                #{variable} && #{variable}.one.two.three.fore
              RUBY
            end
          end

          context 'with Lint/SafeNavigationChain disabled' do
            let(:config) do
              RuboCop::Config.new(
                'AllCops' => { 'TargetRubyVersion' => target_ruby_version },
                'Lint/SafeNavigationChain' => { 'Enabled' => false },
                'Style/SafeNavigation' => cop_config
              )
            end

            it 'allows an object check followed by chained method calls' do
              expect_no_offenses(<<~RUBY)
                #{variable} && #{variable}.one.two.three(baz) { |e| e.qux }
              RUBY
            end

            it 'allows an object check followed by chained method calls with blocks' do
              expect_no_offenses(<<~RUBY)
                #{variable} && #{variable}.one { |a| b }.two(baz) { |e| e.qux }
              RUBY
            end
          end
        end
      end

      context 'ConvertCodeThatCanStartToReturnNil false' do
        let(:cop_config) { { 'ConvertCodeThatCanStartToReturnNil' => false } }

        it 'allows a non-nil object check followed by a method call' do
          expect_no_offenses("!#{variable}.nil? && #{variable}.bar")
        end

        it 'allows a non-nil object check followed by a method call with params' do
          expect_no_offenses("!#{variable}.nil? && #{variable}.bar(baz)")
        end

        it 'allows a non-nil object check followed by a method call with a block' do
          expect_no_offenses(<<~RUBY)
            !#{variable}.nil? && #{variable}.bar { |e| e.qux }
          RUBY
        end

        it 'allows a non-nil object check followed by a method call with params and a block' do
          expect_no_offenses(<<~RUBY)
            !#{variable}.nil? && #{variable}.bar(baz) { |e| e.qux }
          RUBY
        end

        it 'registers an offense for an object check followed by a method calls that nil responds to' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.to_i
            ^{variable}^^^^^{variable}^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.to_i
          RUBY
        end

        it 'registers an offense for an object check followed by a method call' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar
            ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar
          RUBY
        end

        it 'registers an offense for an object check followed by a method call with params' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar(baz)
            ^{variable}^^^^^{variable}^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar(baz)
          RUBY
        end

        it 'registers an offense for an object check followed by a method call with a block' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar { |e| e.qux }
            ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar { |e| e.qux }
          RUBY
        end

        it 'registers an offense for an object check followed by ' \
           'a method call with params and a block' do
          expect_offense(<<~RUBY, variable: variable)
            %{variable} && %{variable}.bar(baz) { |e| e.qux }
            ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
          RUBY

          expect_correction(<<~RUBY)
            #{variable}&.bar(baz) { |e| e.qux }
          RUBY
        end

        it 'registers an offense for a check for the object followed by ' \
           'a method call in the condition for an if expression' do
          expect_offense(<<~RUBY, variable: variable)
            if %{variable} && %{variable}.bar
               ^{variable}^^^^^{variable}^^^^ Use safe navigation (`&.`) instead [...]
              something
            end
          RUBY

          expect_correction(<<~RUBY)
            if #{variable}&.bar
              something
            end
          RUBY
        end

        context 'method chaining' do
          it 'corrects an object check followed by a chained method call' do
            expect_offense(<<~RUBY, variable: variable)
              %{variable} && %{variable}.one.two
              ^{variable}^^^^^{variable}^^^^^^^^ Use safe navigation (`&.`) instead [...]
            RUBY

            expect_correction(<<~RUBY)
              #{variable}&.one&.two
            RUBY
          end

          it 'corrects an object check followed by a chained method call with params' do
            expect_offense(<<~RUBY, variable: variable)
              %{variable} && %{variable}.one.two(baz)
              ^{variable}^^^^^{variable}^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
            RUBY

            expect_correction(<<~RUBY)
              #{variable}&.one&.two(baz)
            RUBY
          end

          it 'corrects an object check followed by a chained method call with a symbol proc' do
            expect_offense(<<~RUBY, variable: variable)
              %{variable} && %{variable}.one.two(&:baz)
              ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
            RUBY

            expect_correction(<<~RUBY)
              #{variable}&.one&.two(&:baz)
            RUBY
          end

          it 'corrects an object check followed by a chained method call with a block' do
            expect_offense(<<~RUBY, variable: variable)
              %{variable} && %{variable}.one.two(baz) { |e| e.qux }
              ^{variable}^^^^^{variable}^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use safe navigation (`&.`) instead [...]
            RUBY

            expect_correction(<<~RUBY)
              #{variable}&.one&.two(baz) { |e| e.qux }
            RUBY
          end
        end
      end

      it 'allows a nil object check followed by a method call' do
        expect_no_offenses("#{variable}.nil? || #{variable}.bar")
      end

      it 'allows a nil object check followed by a method call with params' do
        expect_no_offenses("#{variable}.nil? || #{variable}.bar(baz)")
      end

      it 'allows a nil object check followed by a method call with a block' do
        expect_no_offenses(<<~RUBY)
          #{variable}.nil? || #{variable}.bar { |e| e.qux }
        RUBY
      end

      it 'allows a nil object check followed by a method call with params and a block' do
        expect_no_offenses(<<~RUBY)
          #{variable}.nil? || #{variable}.bar(baz) { |e| e.qux }
        RUBY
      end

      it 'allows a non object check followed by a method call' do
        expect_no_offenses("!#{variable} || #{variable}.bar")
      end

      it 'allows a non object check followed by a method call with params' do
        expect_no_offenses("!#{variable} || #{variable}.bar(baz)")
      end

      it 'allows a non object check followed by a method call with a block' do
        expect_no_offenses("!#{variable} || #{variable}.bar { |e| e.qux }")
      end

      it 'allows a non object check followed by a method call with params and a block' do
        expect_no_offenses(<<~RUBY)
          !#{variable} || #{variable}.bar(baz) { |e| e.qux }
        RUBY
      end
    end
  end

  it_behaves_like('all variable types', 'foo')
  it_behaves_like('all variable types', 'FOO')
  it_behaves_like('all variable types', 'FOO::BAR')
  it_behaves_like('all variable types', '@foo')
  it_behaves_like('all variable types', '@@foo')
  it_behaves_like('all variable types', '$FOO')

  context 'respond_to?' do
    it 'allows method calls safeguarded by a respond_to check' do
      expect_no_offenses('foo.bar if foo.respond_to?(:bar)')
    end

    it 'allows method calls safeguarded by a respond_to check to a different method' do
      expect_no_offenses('foo.bar if foo.respond_to?(:foobar)')
    end

    it 'allows method calls safeguarded by a respond_to check on a' \
       'different variable but the same method' do
      expect_no_offenses('foo.bar if baz.respond_to?(:bar)')
    end

    it 'allows method calls safeguarded by a respond_to check on a different variable and method' do
      expect_no_offenses('foo.bar if baz.respond_to?(:foo)')
    end

    it 'allows enumerable accessor method calls safeguarded by a respond_to check' do
      expect_no_offenses('foo[0] if foo.respond_to?(:[])')
    end
  end

  context 'when Ruby <= 2.2', :ruby22 do
    it 'does not register an offense when a method call that nil responds to safe guarded by an object check' do
      expect_no_offenses('foo.bar if foo')
    end
  end
end
