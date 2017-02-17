# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IndentHeredoc, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |name, code, correction = nil|
    it "registers an offense for #{name}" do
      inspect_source(cop, code.strip_indent)
      expect(cop.offenses.size).to eq(1)
    end

    it "autocorrects for #{name}" do
      corrected = autocorrect_source_with_loop(cop, code.strip_indent)
      expect(corrected).to eq(correction.strip_indent)
    end
  end

  shared_examples :accept do |name, code|
    it "accepts for #{name}" do
      inspect_source(cop, code.strip_indent)
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples :check_message do |name, message|
    it "displays a message with #{name}" do
      inspect_source(cop, <<-END.strip_indent)
        <<-END2
        foo
        END2
      END
      expect(cop.messages).to eq(message)
    end
  end

  shared_examples :warning do |message|
    it 'warns' do
      correct = lambda do
        autocorrect_source(cop, <<-END.strip_indent)
          <<-END2
          foo
          END2
        END
      end
      expect(&correct).to raise_error(RuboCop::Warning, message)
    end
  end

  shared_examples :all_heredoc_type do |quote|
    context "quoted by #{quote}" do
      let(:cop_config) do
        { 'EnforcedStyle' => :powerpack }
      end

      include_examples :offense, 'not indented', <<-END, <<-CORRECTION
        <<#{quote}END2#{quote}
        \#{foo}
        bar
        END2
      END
        <<#{quote}END2#{quote}.strip_indent
          \#{foo}
          bar
        END2
      CORRECTION
      include_examples :offense, 'minus level indented', <<-END, <<-CORRECTION
        def foo
          <<#{quote}END2#{quote}
        \#{foo}
        bar
        END2
        end
      END
        def foo
          <<#{quote}END2#{quote}.strip_indent
            \#{foo}
            bar
        END2
        end
      CORRECTION
      include_examples :offense, 'not indented, with `-`', <<-END, <<-CORRECTION
        <<-#{quote}END2#{quote}
        \#{foo}
        bar
        END2
      END
        <<-#{quote}END2#{quote}.strip_indent
          \#{foo}
          bar
        END2
      CORRECTION
      include_examples :offense, 'minus level indented, with `-`',
                       <<-END, <<-CORRECTION
        def foo
          <<-#{quote}END2#{quote}
        \#{foo}
        bar
          END2
        end
      END
        def foo
          <<-#{quote}END2#{quote}.strip_indent
            \#{foo}
            bar
          END2
        end
      CORRECTION

      include_examples :accept, 'not indented but with whitespace, with `-`',
                       <<-END
        def foo
          <<-#{quote}END2#{quote}
          something
          END2
        end
      END
      include_examples :accept, 'indented, but with `-`', <<-END
        def foo
          <<-#{quote}END2#{quote}
            something
          END2
        end
      END
      include_examples :accept, 'not indented but with whitespace', <<-END
        def foo
          <<#{quote}END2#{quote}
          something
        END2
        end
      END
      include_examples :accept, 'indented, but without `~`', <<-END
        def foo
          <<#{quote}END2#{quote}
            something
        END2
        end
      END

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
        warning = 'Auto Correction does not work for Style/IndentHeredoc. ' \
                  'Please configure EnforcedStyle.'
        include_examples :warning, warning

        context 'Ruby 2.3', :ruby23 do
          message = 'Use 2 spaces for indentation in a heredoc by using ' \
                    '`<<~` instead of `<<-`.'
          include_examples :check_message, 'squiggly heredoc', [message]
          include_examples :offense, 'not indented', <<-END, <<-CORRECTION
            <<#{quote}END2#{quote}
            \#{foo}
            bar
            END2
          END
            <<~#{quote}END2#{quote}
              \#{foo}
              bar
            END2
          CORRECTION
        end

        context 'Rails', :enabled_rails do
          message = 'Use 2 spaces for indentation in a heredoc by using ' \
                    '`String#strip_heredoc`.'
          include_examples :check_message, 'suggestion ActiveSupport', [message]
          include_examples :offense, 'not indented', <<-END, <<-CORRECTION
            <<#{quote}END2#{quote}
            \#{foo}
            bar
            END2
          END
            <<#{quote}END2#{quote}.strip_heredoc
              \#{foo}
              bar
            END2
          CORRECTION
        end
      end

      context 'EnforcedStyle is `squiggly`', :ruby23 do
        let(:cop_config) do
          { 'EnforcedStyle' => :squiggly }
        end

        include_examples :offense, 'not indented', <<-END, <<-CORRECTION
          <<~#{quote}END2#{quote}
          something
          END2
        END
          <<~#{quote}END2#{quote}
            something
          END2
        CORRECTION
        include_examples :offense, 'minus level indented', <<-END, <<-CORRECTION
          def foo
            <<~#{quote}END2#{quote}
          something
            END2
          end
        END
          def foo
            <<~#{quote}END2#{quote}
              something
            END2
          end
        CORRECTION
        include_examples :offense, 'too deep indented', <<-END, <<-CORRECTION
          <<~#{quote}END2#{quote}
              something
          END2
        END
          <<~#{quote}END2#{quote}
            something
          END2
        CORRECTION
        include_examples :offense, 'not indented, without `~`',
                         <<-END, <<-CORRECTION
          <<#{quote}END2#{quote}
          foo
          END2
        END
          <<~#{quote}END2#{quote}
            foo
          END2
        CORRECTION

        include_examples :accept, 'indentaed, with `~`', <<-END
          <<~#{quote}END2#{quote}
            something
          END2
        END

        it 'displays message to use `<<~` instead of `<<`' do
          inspect_source(cop, <<-END.strip_indent)
          <<END2
          foo
          END2
          END
          expect(cop.messages).to eq(
            [
              'Use 2 spaces for indentation in a heredoc by using `<<~` ' \
              'instead of `<<`.'
            ]
          )
        end
        it 'displays message to use `<<~` instead of `<<-`' do
          inspect_source(cop, <<-END.strip_indent)
          <<-END2
          foo
          END2
          END
          expect(cop.messages).to eq(
            [
              'Use 2 spaces for indentation in a heredoc by using `<<~` ' \
              'instead of `<<-`.'
            ]
          )
        end

        context 'Ruby 2.2', :ruby22 do
          warning = '`squiggly` style is selectable only Ruby 2.3 or higher ' \
                    'for Style/IndentHeredoc.'
          include_examples :warning, warning
        end
      end
    end
  end

  [nil, "'", '"', '`'].each do |quote|
    include_examples :all_heredoc_type, quote
  end
end
