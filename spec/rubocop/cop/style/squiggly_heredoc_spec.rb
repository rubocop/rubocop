# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SquigglyHeredoc, :config do
  it 'registers an offense for `<<-` heredoc without indentation' do
    expect_offense(<<~RUBY)
      <<-RUBY2
      ^^^^^^^^ Use squiggly heredoc <<~ instead.
      foo
      RUBY2
    RUBY

    expect_correction(<<~RUBY)
      <<~RUBY2
      foo
      RUBY2
    RUBY
  end

  it 'registers an offense for `<<` heredoc without indentation' do
    expect_offense(<<~RUBY)
      <<RUBY2
      ^^^^^^^ Use squiggly heredoc <<~ instead.
      foo
      RUBY2
    RUBY

    expect_correction(<<~RUBY)
      <<~RUBY2
      foo
      RUBY2
    RUBY
  end

  it 'does not register an offense for `<<-` heredoc with indentation' do
    expect_no_offenses(<<~RUBY)
      <<-RUBY2
        foo
      RUBY2
    RUBY
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: true`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => true })
    end

    it 'registers an offense for `<<-.squish` heredoc with too much indentation' do
      expect_offense(<<~RUBY)
        <<-RUBY2.squish
        ^^^^^^^^ Use squiggly heredoc <<~ instead.
            foo
        RUBY2
      RUBY

      expect_correction(<<~RUBY)
        <<~RUBY2.squish
            foo
        RUBY2
      RUBY
    end

    it 'registers an offense for `<<-.squish!` heredoc with too much indentation' do
      expect_offense(<<~RUBY)
        <<-RUBY2.squish!
        ^^^^^^^^ Use squiggly heredoc <<~ instead.
            foo
        RUBY2
      RUBY

      expect_correction(<<~RUBY)
        <<~RUBY2.squish!
            foo
        RUBY2
      RUBY
    end
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: false`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => false })
    end

    it 'does not register an offense for `squish` applied to heredoc' do
      expect_no_offenses(<<~RUBY)
        def foo
          <<-RUBY2.squish
          foo
          RUBY2
        end
      RUBY
    end
  end

  context 'when Ruby <= 2.2', :ruby22, unsupported_on: :prism do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        <<-RUBY2
        foo
        RUBY2
      RUBY
    end
  end
end
