# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantFormat, :config do
  %i[format sprintf].each do |method|
    context "with #{method}" do
      it 'does not register an offense when called with no arguments' do
        expect_no_offenses(<<~RUBY)
          #{method}
          #{method}()
        RUBY
      end

      it 'does not register an offense when called with additional arguments' do
        expect_no_offenses(<<~RUBY)
          #{method}('%s', foo)
        RUBY
      end

      it 'does not register an offense when called with a splat' do
        expect_no_offenses(<<~RUBY)
          #{method}('%s', *args)
        RUBY
      end

      it 'does not register an offense when called with a double splat' do
        expect_no_offenses(<<~RUBY)
          #{method}('%s', **args)
        RUBY
      end

      it 'does not register an offense when called with a double splat with annotations' do
        expect_no_offenses(<<~RUBY)
          #{method}('%<username>s', **args)
        RUBY
      end

      it 'does not register an offense when called on an object' do
        expect_no_offenses(<<~RUBY)
          foo.#{method}('bar')
        RUBY
      end

      context 'when only given a single string argument' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            %{method}('foo')
            ^{method}^^^^^^^ Use `'foo'` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~RUBY)
            'foo'
          RUBY
        end

        it 'registers an offense when the argument is an interpolated string' do
          expect_offense(<<~'RUBY', method: method)
            %{method}("#{foo}")
            ^{method}^^^^^^^^^^ Use `"#{foo}"` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~'RUBY')
            "#{foo}"
          RUBY
        end

        it 'registers an offense when called with `Kernel`' do
          expect_offense(<<~RUBY, method: method)
            Kernel.%{method}('foo')
            ^^^^^^^^{method}^^^^^^^ Use `'foo'` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~RUBY)
            'foo'
          RUBY
        end

        it 'registers an offense when called with `::Kernel`' do
          expect_offense(<<~RUBY, method: method)
            ::Kernel.%{method}('foo')
            ^^^^^^^^^^{method}^^^^^^^ Use `'foo'` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~RUBY)
            'foo'
          RUBY
        end

        it 'registers an offense when the argument is a control character' do
          expect_offense(<<~'RUBY', method: method)
            %{method}("\n")
            ^{method}^^^^^^ Use `"\n"` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~'RUBY')
            "\n"
          RUBY
        end
      end

      context 'with literal arguments' do
        # rubocop:disable Metrics/ParameterLists
        shared_examples 'offending format specifier' do |specifier, value, result, start_delim = "'", end_delim = "'", **metadata|
          it 'registers an offense and corrects', **metadata do
            options = {
              method: method,
              specifier: specifier,
              value: value,
              start_delim: start_delim,
              end_delim: end_delim
            }

            expect_offense(<<~RUBY, **options)
              %{method}(%{start_delim}%{specifier}%{end_delim}, %{value})
              ^{method}^^{start_delim}^{specifier}^{end_delim}^^^{value}^ Use `#{result}` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              #{result}
            RUBY
          end
        end
        # rubocop:enable Metrics/ParameterLists

        shared_examples 'non-offending format specifier' do |specifier, value|
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              #{method}('#{specifier}', #{value})
            RUBY
          end
        end

        it_behaves_like 'offending format specifier', '%s', "'foo'", "'foo'"
        it_behaves_like 'offending format specifier', '%s', "'foo'", '%{foo}', '%{', '}'
        it_behaves_like 'offending format specifier', '%s', "'foo'", '%q{foo}', '%q{', '}'
        it_behaves_like 'offending format specifier', '%s', "'foo'", '%Q{foo}', '%Q{', '}'
        it_behaves_like 'offending format specifier', '%s', '%q{foo}', "'foo'"
        it_behaves_like 'offending format specifier', '%s', '%{foo}', "'foo'"
        it_behaves_like 'offending format specifier', '%s', '%Q{foo}', "'foo'"
        it_behaves_like 'offending format specifier', '%s', '"#{foo}"', '"#{foo}"'
        it_behaves_like 'offending format specifier', '%s', '"#{foo}"', '%{#{foo}}', '%{', '}'
        it_behaves_like 'offending format specifier', '%s', '"#{foo}"', '%Q{#{foo}}', '%q{', '}'
        it_behaves_like 'offending format specifier', '%s', '"#{foo}"', '%Q{#{foo}}', '%Q{', '}'
        it_behaves_like 'offending format specifier', '%s', ':foo', "'foo'"
        it_behaves_like 'offending format specifier', '%s', ':"#{foo}"', '"#{foo}"'
        it_behaves_like 'offending format specifier', '%s', '1', "'1'"
        it_behaves_like 'offending format specifier', '%s', '1.1', "'1.1'"
        it_behaves_like 'offending format specifier', '%s', '1r', "'1/1'"
        it_behaves_like 'offending format specifier', '%s', '1i', "'0+1i'"
        it_behaves_like 'offending format specifier', '%s', 'true', "'true'"
        it_behaves_like 'offending format specifier', '%s', 'false', "'false'"
        it_behaves_like 'offending format specifier', '%s', 'nil', "'nil'"

        it_behaves_like 'non-offending format specifier', '%s', 'foo'
        it_behaves_like 'non-offending format specifier', '%s', '[]'
        it_behaves_like 'non-offending format specifier', '%s', '{}'

        %i[%d %i %u].each do |specifier|
          it_behaves_like 'offending format specifier', specifier, '5', "'5'"
          it_behaves_like 'offending format specifier', specifier, '5.5', "'5'"
          it_behaves_like 'offending format specifier', specifier, '5r', "'5'"
          it_behaves_like 'offending format specifier', specifier, '3/8r', "'0'"
          it_behaves_like 'offending format specifier', specifier, '(3/8r)', "'0'"
          it_behaves_like 'offending format specifier', specifier, '5+0i', "'5'"
          it_behaves_like 'offending format specifier', specifier, '(5+0i)', "'5'"
          it_behaves_like 'offending format specifier', specifier, "'5'", "'5'"
          it_behaves_like 'offending format specifier', specifier, "'-5'", "'-5'"
          it_behaves_like 'offending format specifier', specifier, "'-5'", "'-5'"

          it_behaves_like 'non-offending format specifier', specifier, "'5.5'"
          it_behaves_like 'non-offending format specifier', specifier, '"abcd"'
          it_behaves_like 'non-offending format specifier', specifier, 'true'
          it_behaves_like 'non-offending format specifier', specifier, 'false'
          it_behaves_like 'non-offending format specifier', specifier, 'nil'
          it_behaves_like 'non-offending format specifier', specifier, '[]'
          it_behaves_like 'non-offending format specifier', specifier, '{}'
        end

        it_behaves_like 'offending format specifier', '%f', '5', "'5.000000'"
        it_behaves_like 'offending format specifier', '%f', '5.5', "'5.500000'"
        it_behaves_like 'offending format specifier', '%f', '5r', "'5.000000'"
        it_behaves_like 'offending format specifier', '%f', '3/8r', "'0.375000'"
        it_behaves_like 'offending format specifier', '%f', '(3/8r)', "'0.375000'"
        it_behaves_like 'offending format specifier', '%f', '5+0i', "'5.000000'"
        it_behaves_like 'offending format specifier', '%f', '(5+0i)', "'5.000000'"
        it_behaves_like 'offending format specifier', '%f', "'5'", "'5.000000'"
        it_behaves_like 'offending format specifier', '%f', "'-5'", "'-5.000000'"

        it_behaves_like 'non-offending format specifier', '%f', '"abcd"'
        it_behaves_like 'non-offending format specifier', '%f', 'true'
        it_behaves_like 'non-offending format specifier', '%f', 'false'
        it_behaves_like 'non-offending format specifier', '%f', 'nil'
        it_behaves_like 'non-offending format specifier', '%f', '[]'
        it_behaves_like 'non-offending format specifier', '%f', '{}'

        # Width, precision and flags
        it_behaves_like 'offending format specifier', '%10s', "'foo'", "'       foo'"
        it_behaves_like 'offending format specifier', '%-10s', "'foo'", "'foo       '"
        it_behaves_like 'offending format specifier', '%10d', '5', "'         5'"
        it_behaves_like 'offending format specifier', '%-10d', '5', "'5         '"
        it_behaves_like 'offending format specifier', '% d', '5', "' 5'"
        it_behaves_like 'offending format specifier', '%+d', '5', "'+5'"
        it_behaves_like 'offending format specifier', '%.3d', '10', "'010'"
        it_behaves_like 'offending format specifier', '%.d', '0', "''"
        it_behaves_like 'offending format specifier', '%05d', '5', "'00005'"
        it_behaves_like 'offending format specifier', '%.2f', '5', "'5.00'"
        it_behaves_like 'offending format specifier', '%10.2f', '5', "'      5.00'"
        it_behaves_like 'offending format specifier', '%-10.2f', '5', "'5.00      '"

        # Width or precision with interpolation
        it_behaves_like 'non-offending format specifier', '%10s', '"#{foo}"'
        it_behaves_like 'non-offending format specifier', '%.1s', '"#{foo}"'

        it 'is able to handle `%%` specifiers' do
          expect_no_offenses(<<~RUBY)
            #{method}('%% %s', foo)
          RUBY
        end

        it 'does not register an offense when a splat is given as arguments' do
          expect_no_offenses(<<~RUBY)
            #{method}('%d.%d.%d.%d', *@address.unpack('CCCC'))
          RUBY
        end

        context 'with numbered specifiers' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              %{method}('%2$s %1$s', 'world', 'hello')
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `'hello world'` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              'hello world'
            RUBY
          end

          it 'does not register an offense when the arguments do not match' do
            expect_no_offenses(<<~RUBY)
              #{method}('%2$s %1$i', 'abcd', '5')
            RUBY
          end
        end

        context 'with `*` in specifier' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              %{method}('%*d', 5, 14)
              ^{method}^^^^^^^^^^^^^^ Use `'   14'` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              '   14'
            RUBY
          end

          it 'registers an offense and corrects with multiple `*`s' do
            expect_offense(<<~RUBY, method: method)
              %{method}('$%0*.*f', 5, 2, 0.5)
              ^{method}^^^^^^^^^^^^^^^^^^^^^^ Use `'$00.50'` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              '$00.50'
            RUBY
          end

          it 'registers an offense and corrects with a negative `*`' do
            expect_offense(<<~RUBY, method: method)
              %{method}('%-*d', 5, 14)
              ^{method}^^^^^^^^^^^^^^^ Use `'14   '` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              '14   '
            RUBY
          end

          it 'registers an offense and corrects with a variable width and a specified argument' do
            expect_offense(<<~RUBY, method: method)
              %{method}('%1$*2$s', 14, 5)
              ^{method}^^^^^^^^^^^^^^^^^^ Use `'   14'` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              '   14'
            RUBY
          end

          it 'registers an offense and corrects with a negative variable width and a specified argument' do
            expect_offense(<<~RUBY, method: method)
              %{method}('%1$-*2$s', 14, 5)
              ^{method}^^^^^^^^^^^^^^^^^^^ Use `'14   '` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              '14   '
            RUBY
          end

          it 'does not register an offense when the variable width argument is not numeric' do
            expect_no_offenses(<<~RUBY)
              #{method}('%*d', 'a', 'foo')
            RUBY
          end

          it 'does not register an offense when the star argument is not literal' do
            expect_no_offenses(<<~RUBY)
              #{method}('%*s', foo, 'bar')
            RUBY
          end

          it 'does not register an offense when the star argument is negative and not literal' do
            expect_no_offenses(<<~RUBY)
              #{method}('%-*s', foo, 'bar')
            RUBY
          end

          it 'does not register an offense when the format argument is not literal' do
            expect_no_offenses(<<~RUBY)
              #{method}('%*d', 5, foo)
            RUBY
          end

          it 'does not register an offense with multiple `*`s when the argument is not literal' do
            expect_no_offenses(<<~RUBY)
              #{method}('%*.*d', 5, 2, foo)
            RUBY
          end
        end

        context 'with annotated specifiers' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              #{method}('%<foo>s %<bar>s', foo: 'foo', bar: 'bar')
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `'foo bar'` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              'foo bar'
            RUBY
          end

          it 'registers an offense and corrects with interpolated strings' do
            expect_offense(<<~'RUBY', method: method)
              %{method}('%<foo>s %<bar>s', foo: "#{foo}", bar: 'bar')
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `"#{foo} bar"` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~'RUBY')
              "#{foo} bar"
            RUBY
          end

          it 'does not register an offense when given a non-literal' do
            expect_no_offenses(<<~RUBY)
              #{method}('%<foo>s', foo: foo)
            RUBY
          end

          it 'does not register an offense when there are missing hash keys' do
            expect_no_offenses(<<~RUBY)
              format('(%<foo>?%<bar>s:%<baz>s)', 'foobar')
            RUBY
          end
        end

        context 'with template specifiers' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              #{method}('%{foo}s %{bar}s', foo: 'foo', bar: 'bar')
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `'foos bars'` directly instead of `#{method}`.
            RUBY

            expect_correction(<<~RUBY)
              'foos bars'
            RUBY
          end

          it 'registers an offense and corrects with interpolated strings' do
            expect_offense(<<~'RUBY', method: method)
              %{method}('%{foo}s %{bar}s', foo: "#{foo}", bar: 'bar')
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `"#{foo}s bars"` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~'RUBY')
              "#{foo}s bars"
            RUBY
          end

          it 'does not register an offense when given a non-literal' do
            expect_no_offenses(<<~RUBY)
              #{method}('%{foo}', foo: foo)
            RUBY
          end

          it 'does not register an offense when not given keyword arguments' do
            expect_no_offenses(<<~RUBY)
              #{method}('%{foo}', foo)
            RUBY
          end

          it 'does not register an offense when given numeric placeholders in the template argument' do
            expect_no_offenses(<<~RUBY)
              #{method}('%<placeholder>d, %<placeholder>f', placeholder)
            RUBY
          end
        end

        context 'with an interpolated format string' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              #{method}("%0\#{width}d", 3)
            RUBY
          end
        end

        context 'when there are multiple %s fields and multiple string arguments' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              %{method}('%s %s', 'foo', 'bar')
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^ Use `'foo bar'` directly instead of `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              'foo bar'
            RUBY
          end
        end

        context 'when there are multiple %s fields and not all arguments are string literals' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              #{method}('%s %s', 'foo', bar)
            RUBY
          end
        end

        context 'with invalid format arguments' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              format('%{y}-%{m}-%{d}', 2015, 1, 1)
            RUBY
          end
        end
      end

      context 'with constants' do
        it 'registers an offense when the only argument is a constant' do
          expect_offense(<<~RUBY, method: method)
            %{method}(FORMAT)
            ^{method}^^^^^^^^ Use `FORMAT` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~RUBY)
            FORMAT
          RUBY
        end

        it 'does not register an offense when the first argument is a constant' do
          expect_no_offenses(<<~RUBY)
            #{method}(FORMAT, 'foo', 'bar')
          RUBY
        end

        it 'does not register an offense when only argument is a splatted constant' do
          expect_no_offenses(<<~RUBY)
            #{method}(*FORMAT)
          RUBY
        end
      end

      context 'when the string contains control characters' do
        it 'registers an offense with the correct message' do
          expect_offense(<<~'RUBY', method: method)
            %{method}("%s\a\b\t\n\v\f\r\e", 'foo')
            ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `"foo\a\b\t\n\v\f\r\e"` directly instead of `%{method}`.
          RUBY

          expect_correction(<<~'RUBY')
            "foo\a\b\t\n\v\f\r\e"
          RUBY
        end
      end
    end
  end
end
