# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ReturnInMemoizedContext, :config do
  context 'returning a value from a memoized block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class A
          def foo
            @foo ||= begin
              return :bar if baz?
              ^^^^^^^^^^^^^^^^^^^ Do not return from within a memoized context.
              qux
            end
          end
        end
      RUBY
    end
  end

  context 'returning nil from a memoized block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class A
          def foo
            @foo ||= begin
              bar
              return if baz?
              ^^^^^^^^^^^^^^ Do not return from within a memoized context.
              qux
            end
          end
        end
      RUBY
    end
  end
end
