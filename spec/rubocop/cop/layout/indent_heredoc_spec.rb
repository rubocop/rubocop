# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentHeredoc, :config do
  subject(:cop) { described_class.new(config) }

  let(:allow_heredoc) { true }
  let(:other_cops) do
    {
      'Metrics/LineLength' => { 'Max' => 5, 'AllowHeredoc' => allow_heredoc }
    }
  end

  shared_examples 'offense' do |name, code, correction = nil, strip_fix = true|
    it "registers an offense for #{name}" do
      inspect_source(code.strip_indent)
      expect(cop.offenses.size).to eq(1)
    end

    it "autocorrects for #{name}" do
      corrected = autocorrect_source_with_loop(code.strip_indent)
      if strip_fix
        expect(corrected).to eq(correction.strip_indent)
      else
        expect(corrected).to eq(correction)
      end
    end
  end

  shared_examples 'accept' do |name, code|
    it "accepts for #{name}" do
      expect_no_offenses(code.strip_indent)
    end
  end

  shared_examples 'check message' do |name, message, code = nil|
    it "displays a message with #{name}" do
      if code
        inspect_source(code.strip_indent)
      else
        inspect_source(<<~RUBY)
          <<-RUBY2
          foo
          RUBY2
        RUBY
      end
      expect(cop.messages).to eq(message)
    end
  end

  shared_examples 'warning' do |message|
    it 'warns' do
      correct = lambda do
        autocorrect_source(<<~RUBY)
          <<-RUBY2
          foo
          RUBY2
        RUBY
      end
      expect(&correct).to raise_error(RuboCop::Warning, message)
    end
  end

  shared_examples 'all heredoc type' do |quote|
    context "quoted by #{quote}" do
      let(:cop_config) do
        { 'EnforcedStyle' => :powerpack }
      end

      include_examples 'offense', 'not indented', <<-RUBY, <<-CORRECTION
        <<#{quote}RUBY2#{quote}
        \#{foo}
        bar
        RUBY2
      RUBY
        <<#{quote}RUBY2#{quote}.strip_indent
          \#{foo}
          bar
        RUBY2
      CORRECTION
      include_examples 'offense', 'minus level indented', <<-RUBY, <<-CORRECTION
        def foo
          <<#{quote}RUBY2#{quote}
        \#{foo}
        bar
        RUBY2
        end
      RUBY
        def foo
          <<#{quote}RUBY2#{quote}.strip_indent
            \#{foo}
            bar
        RUBY2
        end
      CORRECTION
      include_examples 'offense', 'not indented, with `-`',
                       <<-RUBY, <<-CORRECTION
        <<-#{quote}RUBY2#{quote}
        \#{foo}
        bar
        RUBY2
      RUBY
        <<-#{quote}RUBY2#{quote}.strip_indent
          \#{foo}
          bar
        RUBY2
      CORRECTION
      include_examples 'offense', 'minus level indented, with `-`',
                       <<-RUBY, <<-CORRECTION
        def foo
          <<-#{quote}RUBY2#{quote}
        \#{foo}
        bar
          RUBY2
        end
      RUBY
        def foo
          <<-#{quote}RUBY2#{quote}.strip_indent
            \#{foo}
            bar
          RUBY2
        end
      CORRECTION

      it 'does not register an offense when not indented but with ' \
         'whitespace, with `-`' do
        expect_no_offenses(<<-RUBY)
          def foo
            <<-#{quote}RUBY2#{quote}
            something
            RUBY2
          end
        RUBY
      end

      include_examples 'accept', 'indented, but with `-`', <<-RUBY
        def foo
          <<-#{quote}RUBY2#{quote}
            something
          RUBY2
        end
      RUBY
      include_examples 'accept', 'not indented but with whitespace', <<-RUBY
        def foo
          <<#{quote}RUBY2#{quote}
          something
        RUBY2
        end
      RUBY
      include_examples 'accept', 'indented, but without `~`', <<-RUBY
        def foo
          <<#{quote}RUBY2#{quote}
            something
        RUBY2
        end
      RUBY
      include_examples 'accept', 'an empty line', <<-RUBY
        <<-#{quote}RUBY2#{quote}

        RUBY2
      RUBY

      context 'when Metrics/LineLength is configured' do
        let(:allow_heredoc) { false }

        include_examples 'offense', 'short heredoc', <<-RUBY, <<-CORRECTION
          <<#{quote}RUBY2#{quote}
          12
          RUBY2
        RUBY
          <<#{quote}RUBY2#{quote}.strip_indent
            12
          RUBY2
        CORRECTION

        include_examples 'accept', 'long heredoc', <<-RUBY
          <<#{quote}RUBY2#{quote}
          12345678
          RUBY2
        RUBY
      end

      include_examples 'check message', 'suggestion powerpack',
                       [
                         'Use 2 spaces for indentation in a heredoc by using ' \
                         '`String#strip_indent`.'
                       ]

      context 'EnforcedStyle is `squiggly`' do
        let(:cop_config) do
          { 'EnforcedStyle' => :squiggly }
        end

        include_examples 'offense', 'not indented', <<-RUBY, <<-CORRECTION
          <<~#{quote}RUBY2#{quote}
          something
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        CORRECTION
        include_examples 'offense', 'minus level indented',
                         <<-RUBY, <<-CORRECTION
          def foo
            <<~#{quote}RUBY2#{quote}
          something
            RUBY2
          end
        RUBY
          def foo
            <<~#{quote}RUBY2#{quote}
              something
            RUBY2
          end
        CORRECTION
        include_examples 'offense', 'too deep indented', <<-RUBY, <<-CORRECTION
          <<~#{quote}RUBY2#{quote}
              something
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        CORRECTION
        include_examples 'offense', 'not indented, without `~`',
                         <<-RUBY, <<-CORRECTION
          <<#{quote}RUBY2#{quote}
          foo
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            foo
          RUBY2
        CORRECTION

        include_examples 'offense', 'not indented, with `~`',
                         <<-RUBY, <<-CORRECTION
          <<~#{quote}RUBY2#{quote}
          foo
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            foo
          RUBY2
        CORRECTION

        include_examples 'offense', 'first line minus-level indented, with `-`',
                         <<-RUBY, <<-CORRECTION, false
                  puts <<-#{quote}RUBY2#{quote}
          def foo
            bar
          end
          RUBY2
        RUBY
        puts <<~#{quote}RUBY2#{quote}
          def foo
            bar
          end
        RUBY2
        CORRECTION

        include_examples 'accept', 'indented, with `~`', <<-RUBY
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        RUBY
        include_examples 'accept', 'include empty lines', <<-RUBY
          <<~#{quote}MSG#{quote}

            foo

              bar

          MSG
        RUBY

        include_examples 'offense', 'not indented enough with empty lines',
                         <<-RUBY, <<-CORRECTION
          def baz
            <<~#{quote}MSG#{quote}
            foo

              bar
            MSG
          end
        RUBY
          def baz
            <<~#{quote}MSG#{quote}
              foo

                bar
            MSG
          end
        CORRECTION

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
  end

  [nil, "'", '"', '`'].each do |quote|
    include_examples 'all heredoc type', quote
  end
end
