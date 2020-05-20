# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AccessModifierDeclarations, :config do
  shared_examples 'always accepted' do |access_modifier|
    it 'accepts when #{access_modifier} is a hash literal value' do
      expect_no_offenses(<<~RUBY)
        class Foo
          foo
          bar(key: #{access_modifier})
        end
      RUBY
    end

    context 'allow access modifiers on symbols' do
      let(:cop_config) { { 'AllowModifiersOnSymbols' => true } }

      it 'accepts when argument to #{access_modifier} is a symbol' do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} :bar
          end
        RUBY
      end
    end

    context 'do not allow access modifiers on symbols' do
      let(:cop_config) { { 'AllowModifiersOnSymbols' => false } }

      it 'accepts when argument to #{access_modifier} is a symbol' do
        expect_offense(<<~RUBY)
          class Foo
            foo
            #{access_modifier} :bar
            #{'^' * access_modifier.length} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY
      end
    end
  end

  context 'when `group` is configured' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'group'
      }
    end

    %w[private protected public].each do |access_modifier|
      it "offends when #{access_modifier} is inlined with a method" do
        expect_offense(<<~RUBY)
          class Test
            #{access_modifier} def foo; end
            #{'^' * access_modifier.length} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is not inlined" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier}
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is not inlined and " \
         'has a comment' do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier} # hey
          end
        RUBY
      end

      include_examples 'always accepted', access_modifier
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
        expect_offense(<<~RUBY)
          class Test
            #{access_modifier}
            #{'^' * access_modifier.length} `#{access_modifier}` should be inlined in method definitions.
          end
        RUBY
      end

      it "offends when #{access_modifier} is not inlined and has a comment" do
        expect_offense(<<~RUBY)
          class Test
            #{access_modifier} # hey
            #{'^' * access_modifier.length} `#{access_modifier}` should be inlined in method definitions.
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is inlined with a method" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier} def foo; end
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is inlined with a symbol" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier} :foo

            def foo; end
          end
        RUBY
      end

      include_examples 'always accepted', access_modifier
    end
  end
end
