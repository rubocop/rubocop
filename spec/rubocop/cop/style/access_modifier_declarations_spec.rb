# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AccessModifierDeclarations, :config do
  subject(:cop) { described_class.new(config) }

  context 'when `group` is configured' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'group'
      }
    end

    %w[private protected public].each do |access_modifier|
      it "offends when #{access_modifier} is inlined with a method" do
        expect_offense(<<-RUBY.strip_indent)
          class Test
            #{access_modifier} def foo; end
            #{'^' * access_modifier.length} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY
      end

      it "offends when #{access_modifier} is inlined with a symbol" do
        expect_offense(<<-RUBY.strip_indent)
          class Test
            #{access_modifier} :foo
            #{'^' * access_modifier.length} `#{access_modifier}` should not be inlined in method definitions.

            def foo; end
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is not inlined" do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test
            #{access_modifier}
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is not inlined and " \
         'has a comment' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test
            #{access_modifier} # hey
          end
        RUBY
      end
    end
  end

  context 'when `inline` is configured' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'inline'
      }
    end

    %w[private protected public].each do |access_modifier|
      it "offends when #{access_modifier} is not inlined" do
        expect_offense(<<-RUBY.strip_indent)
          class Test
            #{access_modifier}
            #{'^' * access_modifier.length} `#{access_modifier}` should be inlined in method definitions.
          end
        RUBY
      end

      it "offends when #{access_modifier} is not inlined and has a comment" do
        expect_offense(<<-RUBY.strip_indent)
          class Test
            #{access_modifier} # hey
            #{'^' * access_modifier.length} `#{access_modifier}` should be inlined in method definitions.
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is inlined with a method" do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test
            #{access_modifier} def foo; end
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is inlined with a symbol" do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test
            #{access_modifier} :foo

            def foo; end
          end
        RUBY
      end
    end
  end
end
