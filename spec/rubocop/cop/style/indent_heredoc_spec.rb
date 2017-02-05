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

      context 'Ruby 2.3', :ruby23 do
        let(:cop_config) do
          { 'EnforcedStyle' => :ruby23 }
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
      end
    end
  end

  [nil, "'", '"', '`'].each do |quote|
    include_examples :all_heredoc_type, quote
  end
end
