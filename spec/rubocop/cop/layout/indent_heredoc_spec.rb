# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentHeredoc, :config do
  subject(:cop) { described_class.new(config) }

  let(:allow_heredoc) { true }
  let(:other_cops) do
    {
      'Metrics/LineLength' => { 'Max' => 5, 'AllowHeredoc' => allow_heredoc }
    }
  end

  shared_examples :offense do |name, code, correction = nil|
    it "registers an offense for #{name}" do
      inspect_source(code.strip_indent)
      expect(cop.offenses.size).to eq(1)
    end

    it "autocorrects for #{name}" do
      corrected = autocorrect_source_with_loop(code.strip_indent)
      expect(corrected).to eq(correction.strip_indent)
    end
  end

  shared_examples :accept do |name, code|
    it "accepts for #{name}" do
      inspect_source(code.strip_indent)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples :check_message do |name, message|
    it "displays a message with #{name}" do
      inspect_source(<<-RUBY.strip_indent)
        <<-RUBY2
        foo
        RUBY2
      RUBY
      expect(cop.messages).to eq(message)
    end
  end

  shared_examples :warning do |message|
    it 'warns' do
      correct = lambda do
        autocorrect_source(<<-RUBY.strip_indent)
          <<-RUBY2
          foo
          RUBY2
        RUBY
      end
      expect(&correct).to raise_error(RuboCop::Warning, message)
    end
  end

  shared_examples :all_heredoc_type do |quote|
    context "quoted by #{quote}" do
      let(:cop_config) do
        { 'EnforcedStyle' => :powerpack }
      end

      include_examples :offense, 'not indented', <<-RUBY, <<-CORRECTION
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
      include_examples :offense, 'minus level indented', <<-RUBY, <<-CORRECTION
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
      include_examples :offense, 'not indented, with `-`',
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
      include_examples :offense, 'minus level indented, with `-`',
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

      include_examples :accept, 'not indented but with whitespace, with `-`',
                       <<-RUBY
        def foo
          <<-#{quote}RUBY2#{quote}
          something
          RUBY2
        end
      RUBY
      include_examples :accept, 'indented, but with `-`', <<-RUBY
        def foo
          <<-#{quote}RUBY2#{quote}
            something
          RUBY2
        end
      RUBY
      include_examples :accept, 'not indented but with whitespace', <<-RUBY
        def foo
          <<#{quote}RUBY2#{quote}
          something
        RUBY2
        end
      RUBY
      include_examples :accept, 'indented, but without `~`', <<-RUBY
        def foo
          <<#{quote}RUBY2#{quote}
            something
        RUBY2
        end
      RUBY
      include_examples :accept, 'an empty line', <<-RUBY
        <<-#{quote}RUBY2#{quote}

        RUBY2
      RUBY

      context 'when Metrics/LineLength is configured' do
        let(:allow_heredoc) { false }

        include_examples :offense, 'short heredoc', <<-RUBY, <<-CORRECTION
          <<#{quote}RUBY2#{quote}
          12
          RUBY2
        RUBY
          <<#{quote}RUBY2#{quote}.strip_indent
            12
          RUBY2
        CORRECTION

        include_examples :accept, 'long heredoc', <<-RUBY
          <<#{quote}RUBY2#{quote}
          12345678
          RUBY2
        RUBY
      end

      include_examples :check_message, 'suggestion powerpack',
                       [
                         'Use 2 spaces for indentation in a heredoc by using ' \
                         '`String#strip_indent`.'
                       ]

      context 'EnforcedStyle is `auto_detection`' do
        let(:cop_config) do
          { 'EnforcedStyle' => :auto_detection }
        end

        message = 'Use 2 spaces for indentation in a heredoc by using ' \
                  "some library(e.g. ActiveSupport's `String#strip_heredoc`)."
        include_examples :check_message, 'some library', [message]
        warning = 'Auto-correction does not work for Layout/IndentHeredoc. ' \
                  'Please configure EnforcedStyle.'
        include_examples :warning, warning

        context 'Ruby 2.3', :ruby23 do
          message = 'Use 2 spaces for indentation in a heredoc by using ' \
                    '`<<~` instead of `<<-`.'
          include_examples :check_message, 'squiggly heredoc', [message]
          include_examples :offense, 'not indented', <<-RUBY, <<-CORRECTION
            <<#{quote}RUBY2#{quote}
            \#{foo}
            bar
            RUBY2
          RUBY
            <<~#{quote}RUBY2#{quote}
              \#{foo}
              bar
            RUBY2
          CORRECTION
        end

        context 'Rails', :enabled_rails do
          message = 'Use 2 spaces for indentation in a heredoc by using ' \
                    '`String#strip_heredoc`.'
          include_examples :check_message, 'suggestion ActiveSupport', [message]
          include_examples :offense, 'not indented', <<-RUBY, <<-CORRECTION
            <<#{quote}RUBY2#{quote}
            \#{foo}
            bar
            RUBY2
          RUBY
            <<#{quote}RUBY2#{quote}.strip_heredoc
              \#{foo}
              bar
            RUBY2
          CORRECTION
        end
      end

      context 'EnforcedStyle is `squiggly`', :ruby23 do
        let(:cop_config) do
          { 'EnforcedStyle' => :squiggly }
        end

        include_examples :offense, 'not indented', <<-RUBY, <<-CORRECTION
          <<~#{quote}RUBY2#{quote}
          something
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        CORRECTION
        include_examples :offense, 'minus level indented',
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
        include_examples :offense, 'too deep indented', <<-RUBY, <<-CORRECTION
          <<~#{quote}RUBY2#{quote}
              something
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        CORRECTION
        include_examples :offense, 'not indented, without `~`',
                         <<-RUBY, <<-CORRECTION
          <<#{quote}RUBY2#{quote}
          foo
          RUBY2
        RUBY
          <<~#{quote}RUBY2#{quote}
            foo
          RUBY2
        CORRECTION
        include_examples :offense, 'first line minus-level indented, with `-`',
                         <<-RUBY, <<-CORRECTION
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

        include_examples :accept, 'indented, with `~`', <<-RUBY
          <<~#{quote}RUBY2#{quote}
            something
          RUBY2
        RUBY
        include_examples :accept, 'include empty lines', <<-RUBY
          <<~#{quote}MSG#{quote}

            foo

              bar

          MSG
        RUBY

        it 'displays message to use `<<~` instead of `<<`' do
          inspect_source(<<-RUBY.strip_indent)
          <<RUBY2
          foo
          RUBY2
          RUBY
          expect(cop.messages).to eq(
            [
              'Use 2 spaces for indentation in a heredoc by using `<<~` ' \
              'instead of `<<`.'
            ]
          )
        end
        it 'displays message to use `<<~` instead of `<<-`' do
          inspect_source(<<-RUBY.strip_indent)
          <<-RUBY2
          foo
          RUBY2
          RUBY
          expect(cop.messages).to eq(
            [
              'Use 2 spaces for indentation in a heredoc by using `<<~` ' \
              'instead of `<<-`.'
            ]
          )
        end

        context 'Ruby 2.2', :ruby22 do
          warning = '`squiggly` style is selectable only on Ruby 2.3 or ' \
                    'higher for Layout/IndentHeredoc.'
          include_examples :warning, warning
        end
      end
    end
  end

  [nil, "'", '"', '`'].each do |quote|
    include_examples :all_heredoc_type, quote
  end
end
