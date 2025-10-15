# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EndlessMethod, :config do
  context 'Ruby >= 3.0', :ruby30 do
    let(:other_cops) do
      {
        'Layout/LineLength' => {
          'Enabled' => line_length_enabled,
          'Max' => 80
        }
      }
    end
    let(:line_length_enabled) { true }

    context 'EnforcedStyle: disallow' do
      let(:cop_config) { { 'EnforcedStyle' => 'disallow' } }

      it 'registers an offense for an endless method' do
        expect_offense(<<~RUBY)
          def my_method() = x
          ^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions.
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            x
          end
        RUBY
      end

      it 'registers an offense for an endless method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b) = x
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions.
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b)
            x
          end
        RUBY
      end

      it 'does not register an offense for a single line method' do
        expect_no_offenses(<<~RUBY)
          def my_method
            x
          end
        RUBY
      end
    end

    context 'EnforcedStyle: allow_single_line' do
      let(:cop_config) { { 'EnforcedStyle' => 'allow_single_line' } }

      it 'does not register an offense for an endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x
        RUBY
      end

      it 'does not register an offense for an endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'does not register an offense for a single line method' do
        expect_no_offenses(<<~RUBY)
          def my_method
            x
          end
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method' do
        expect_offense(<<~RUBY)
          def my_method() = x.foo
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
                             .bar
                             .baz
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            x.foo
                             .bar
                             .baz
          end
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method with begin' do
        expect_offense(<<~RUBY)
          def my_method() = begin
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
            foo && bar
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            begin
            foo && bar
          end
          end
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b) = x.foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
                                 .bar
                                 .baz
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b)
            x.foo
                                 .bar
                                 .baz
          end
        RUBY
      end
    end

    context 'EnforcedStyle: allow_always' do
      let(:cop_config) { { 'EnforcedStyle' => 'allow_always' } }

      it 'does not register an offense for an endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x
        RUBY
      end

      it 'does not register an offense for an endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'does not register an offense for a single line method' do
        expect_no_offenses(<<~RUBY)
          def my_method
            x
          end
        RUBY
      end

      it 'does not register an offense for a multiline endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x.foo
                             .bar
                             .baz
        RUBY
      end

      it 'does not register an offense for a multiline endless method with begin' do
        expect_no_offenses(<<~RUBY)
          def my_method() = begin
            foo && bar
          end
        RUBY
      end

      it 'does not register an offense for a multiline endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x.foo
                                 .bar
                                 .baz
        RUBY
      end
    end

    context 'EnforcedStyle: require_single_line' do
      let(:cop_config) { { 'EnforcedStyle' => 'require_single_line' } }

      it 'does not register an offense for a single line endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x
        RUBY
      end

      it 'does not register an offense for a single line endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method' do
        expect_offense(<<~RUBY)
          def my_method() = x.foo
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
                             .bar
                             .baz
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            x.foo
                             .bar
                             .baz
          end
        RUBY
      end

      it 'does not register an offense for no statements method' do
        expect_no_offenses(<<~RUBY)
          def my_method
          end
        RUBY
      end

      it 'does not register an offense for multiple statements method' do
        expect_no_offenses(<<~RUBY)
          def my_method
            x.foo
            x.bar
          end
        RUBY
      end

      it 'does not register an offense for multiple statements method with `begin`' do
        expect_no_offenses(<<~RUBY)
          def my_method
            begin
              foo && bar
            end
          end
        RUBY
      end

      it 'does not register an offense when heredoc is used only in regular method definition' do
        expect_no_offenses(<<~RUBY)
          def my_method
            <<~HEREDOC
              hello
            HEREDOC
          end
        RUBY
      end

      it 'does not register an offense for heredoc is used in regular method definition' do
        expect_no_offenses(<<~RUBY)
          def my_method
            puts <<~HEREDOC
              hello
            HEREDOC
          end
        RUBY
      end

      it 'registers an offense and corrects for a single line method' do
        expect_offense(<<~RUBY)
          def my_method
          ^^^^^^^^^^^^^ Use endless method definitions for single line methods.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method = x
        RUBY
      end

      it 'registers an offense and corrects for a single line method with access modifier' do
        expect_offense(<<~RUBY)
          private def my_method
                  ^^^^^^^^^^^^^ Use endless method definitions for single line methods.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          private def my_method = x
        RUBY
      end

      it 'does not register an offense for a single line setter method' do
        expect_no_offenses(<<~RUBY)
          def my_method=(arg)
            arg.foo
          end
        RUBY
      end

      it 'does not register an offense when the endless version excess Metrics/MaxLineLength[Max]' do
        expect_no_offenses(<<~RUBY)
          def my_method
            'this_string_ends_at_column_75_________________________________________'
          end
        RUBY
      end

      it 'does not register an offense when the endless with access modifier version excess Metrics/MaxLineLength[Max]' do
        expect_no_offenses(<<~RUBY)
          private def my_method
            'this_string_ends_at_column_75_________________________________'
          end
        RUBY
      end

      context 'when Metrics/MaxLineLength is disabled' do
        let(:line_length_enabled) { false }

        it 'registers an offense and corrects for a long single line method that is long' do
          expect_offense(<<~RUBY)
            def my_method
            ^^^^^^^^^^^^^ Use endless method definitions for single line methods.
              'this_string_ends_at_column_75_________________________________________'
            end
          RUBY

          expect_correction(<<~RUBY)
            def my_method = 'this_string_ends_at_column_75_________________________________________'
          RUBY
        end

        it 'registers an offense and corrects for a long single line method with access modifier that is long' do
          expect_offense(<<~RUBY)
            private def my_method
                    ^^^^^^^^^^^^^ Use endless method definitions for single line methods.
              'this_string_ends_at_column_75_________________________________'
            end
          RUBY

          expect_correction(<<~RUBY)
            private def my_method = 'this_string_ends_at_column_75_________________________________'
          RUBY
        end
      end

      it 'registers an offense and corrects for a single line method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b)
          ^^^^^^^^^^^^^^^^^^^ Use endless method definitions for single line methods.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b) = x.foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
                                 .bar
                                 .baz
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b)
            x.foo
                                 .bar
                                 .baz
          end
        RUBY
      end
    end

    context 'EnforcedStyle: require_always' do
      let(:cop_config) { { 'EnforcedStyle' => 'require_always' } }

      it 'does not register an offense for an endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x
        RUBY
      end

      it 'does not register an offense for an endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'does not register an offense for an multiline endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method = x.foo
                           .bar
                           .baz
        RUBY
      end

      it 'does not register an offense for no statements method' do
        expect_no_offenses(<<~RUBY)
          def my_method
          end
        RUBY
      end

      it 'does not register an offense for multiple statements method' do
        expect_no_offenses(<<~RUBY)
          def my_method
            x.foo
            x.bar
          end
        RUBY
      end

      it 'does not register an offense for multiple statements method with `begin`' do
        expect_no_offenses(<<~RUBY)
          def my_method
            begin
              foo && bar
            end
          end
        RUBY
      end

      it 'does not register an offense when heredoc is used only in regular method definition' do
        expect_no_offenses(<<~RUBY)
          def my_method
            <<~HEREDOC
              hello
            HEREDOC
          end
        RUBY
      end

      it 'does not register an offense for heredoc is used in regular method definition' do
        expect_no_offenses(<<~RUBY)
          def my_method
            puts <<~HEREDOC
              hello
            HEREDOC
          end
        RUBY
      end

      it 'registers an offense and corrects for a single line method' do
        expect_offense(<<~RUBY)
          def my_method
          ^^^^^^^^^^^^^ Use endless method definitions.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method = x
        RUBY
      end

      it 'registers an offense and corrects for a single line method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b)
          ^^^^^^^^^^^^^^^^^^^ Use endless method definitions.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'registers an offense and corrects for a multiline method' do
        expect_offense(<<~RUBY)
          def my_method
          ^^^^^^^^^^^^^ Use endless method definitions.
            x.foo
             .bar
             .baz
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method = x.foo
             .bar
             .baz
        RUBY
      end

      it 'does not register an offense for a multiline setter method' do
        expect_no_offenses(<<~RUBY)
          def my_method=(arg)
            x.foo
             .bar
             .baz
          end
        RUBY
      end

      it 'does not register an offense when the endless version excess Metrics/MaxLineLength[Max]' do
        expect_no_offenses(<<~RUBY)
          def my_method
            'this_string_ends_at_column_75_________________________________________'
          end
        RUBY
      end

      context 'when Metrics/MaxLineLength is disabled' do
        let(:line_length_enabled) { false }

        it 'registers an offense and corrects for a long single line method that is long' do
          expect_offense(<<~RUBY)
            def my_method
            ^^^^^^^^^^^^^ Use endless method definitions.
              'this_string_ends_at_column_75_________________________________________'
            end
          RUBY

          expect_correction(<<~RUBY)
            def my_method = 'this_string_ends_at_column_75_________________________________________'
          RUBY
        end
      end

      it 'registers an offense and corrects for a multiline method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b)
          ^^^^^^^^^^^^^^^^^^^ Use endless method definitions.
            x.foo
             .bar
             .baz
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b) = x.foo
             .bar
             .baz
        RUBY
      end
    end
  end
end
