# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MethodKeywordName, :config do
  it 'does not register an offense with non-keyword method name' do
    expect_no_offenses(<<~RUBY)
      def foo
        1
      end
    RUBY
  end

  it 'registers an offense for method with keyword name' do
    expect_offense(<<~RUBY)
      def
      def foo
      ^^^ Do not use ruby keyword for method names.
        1
      end
    RUBY
  end

  it 'registers an offense for single line method with keyword name' do
    expect_offense(<<~RUBY)
      def def foo; 1; end
          ^^^ Do not use ruby keyword for method names.
    RUBY
  end
end
