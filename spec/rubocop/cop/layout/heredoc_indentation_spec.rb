# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::HeredocIndentation, :config do
  let(:allow_heredoc) { true }
  let(:other_cops) { { 'Layout/LineLength' => { 'Max' => 5, 'AllowHeredoc' => allow_heredoc } } }

  shared_examples 'all heredoc type' do |quote|
    context "quoted by #{quote}" do
      it 'does not register an offense when not indented but with whitespace, with `-`' do
        expect_no_offenses(<<-RUBY)
          def foo
            <<-#{quote}RUBY2#{quote}
            something
            RUBY2
          end
        RUBY
      end

      it 'accepts for indented, but with `-`' do
        expect_no_offenses(<<~RUBY)
          def foo
            <<-#{quote}RUBY2#{quote}
              something
            RUBY2
          end
        RUBY
      end

      it 'accepts for not indented but with whitespace' do
        expect_no_offenses(<<~RUBY)
          def foo
            <<#{quote}RUBY2#{quote}
            something
          RUBY2
          end
        RUBY
      end

      it 'accepts for indented, but without `~`' do
        expect_no_offenses(<<~RUBY)
          def foo
            <<#{quote}RUBY2#{quote}
              something
          RUBY2
          end
        RUBY
      end

      it 'accepts for an empty line' do
        expect_no_offenses(<<~RUBY)
          <<-#{quote}RUBY2#{quote}

          RUBY2
        RUBY
      end

      context 'when Layout/LineLength is configured' do
        let(:allow_heredoc) { false }

        it 'accepts for long heredoc' do
          expect_no_offenses(<<~RUBY)
            <<#{quote}RUBY2#{quote}
            12345678
            RUBY2
          RUBY
        end
      end

      it 'registers an offense for not indented' do
        expect_offense(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
          something
          ^^^^^^^^^ Use 2 spaces for indentation in a heredoc.
          RUBY2
        RUBY

        expect_correction(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        RUBY
      end

      it 'registers an offense for minus level indented' do
        expect_offense(<<~RUBY)
          def foo
            <<~#{quote}RUBY2#{quote}
          something
          ^^^^^^^^^ Use 2 spaces for indentation in a heredoc.
            RUBY2
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo
            <<~#{quote}RUBY2#{quote}
              something
            RUBY2
          end
        RUBY
      end

      it 'registers an offense for too deep indented' do
        expect_offense(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
              something
          ^^^^^^^^^^^^^ Use 2 spaces for indentation in a heredoc.
          RUBY2
        RUBY

        expect_correction(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        RUBY
      end

      it 'registers an offense for not indented, without `~`' do
        expect_offense(<<~RUBY)
          <<#{quote}RUBY2#{quote}
          foo
          ^^^ Use 2 spaces for indentation in a heredoc by using `<<~` instead of `<<`.
          RUBY2
        RUBY

        expect_correction(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
            foo
          RUBY2
        RUBY
      end

      it 'registers an offense for not indented, with `~`' do
        expect_offense(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
          foo
          ^^^ Use 2 spaces for indentation in a heredoc.
          RUBY2
        RUBY

        expect_correction(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
            foo
          RUBY2
        RUBY
      end

      it 'registers an offense for first line minus-level indented, with `-`' do
        expect_offense(<<~RUBY)
                  puts <<-#{quote}RUBY2#{quote}
          def foo
          ^^^^^^^ Use 2 spaces for indentation in a heredoc by using `<<~` instead of `<<-`.
            bar
          end
          RUBY2
        RUBY

        expect_correction(<<-RUBY)
        puts <<~#{quote}RUBY2#{quote}
          def foo
            bar
          end
        RUBY2
        RUBY
      end

      it 'accepts for indented, with `~`' do
        expect_no_offenses(<<~RUBY)
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        RUBY
      end

      it 'accepts for include empty lines' do
        expect_no_offenses(<<~RUBY)
          <<~#{quote}MSG#{quote}

            foo

              bar

          MSG
        RUBY
      end

      { empty: '', whitespace: '    ' }.each do |description, line|
        it "registers an offense for not indented enough with #{description} line" do
          # Using <<- in this section makes the code more readable.
          # rubocop:disable Layout/HeredocIndentation
          expect_offense(<<-RUBY)
            def baz
              <<~#{quote}MSG#{quote}
              foo
^^^^^^^^^^^^^^^^^ Use 2 spaces for indentation in a heredoc.
#{line}
                bar
              MSG
            end
          RUBY

          expect_correction(<<-RUBY)
            def baz
              <<~#{quote}MSG#{quote}
                foo
#{line}
                  bar
              MSG
            end
          RUBY
        end

        it "registers an offense for too deep indented with #{description} line" do
          expect_offense(<<-RUBY)
            <<~#{quote}RUBY2#{quote}
                  foo
^^^^^^^^^^^^^^^^^^^^^ Use 2 spaces for indentation in a heredoc.
#{line}
                bar
            RUBY2
          RUBY

          expect_correction(<<-RUBY)
            <<~#{quote}RUBY2#{quote}
                foo
#{line}
              bar
            RUBY2
          RUBY
        end
        # rubocop:enable Layout/HeredocIndentation
      end

      it 'displays message to use `<<~` instead of `<<`' do
        expect_offense(<<~RUBY)
          <<RUBY2
          foo
          ^^^ Use 2 spaces for indentation in a heredoc by using `<<~` instead of `<<`.
          RUBY2
        RUBY
      end

      it 'displays message to use `<<~` instead of `<<-`' do
        expect_offense(<<~RUBY)
          <<-RUBY2
          foo
          ^^^ Use 2 spaces for indentation in a heredoc by using `<<~` instead of `<<-`.
          RUBY2
        RUBY
      end
    end
  end

  [nil, "'", '"', '`'].each { |quote| include_examples 'all heredoc type', quote }
end
