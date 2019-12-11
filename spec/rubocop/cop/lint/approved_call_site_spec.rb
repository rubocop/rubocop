# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ApprovedCallSite do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Lint/ApprovedCallSite' => { 'Identifiers' => ['Fakeclass'] }
    )
  end

  it 'registers an offense when using `Fakeclass` as a receiver' do
    expect_offense(<<~RUBY)
      Fakeclass.with
      ^^^^^^^^^^^^^^ Fakeclass call site.
    RUBY
  end

  it 'does not register an offense when not using `Fakeclass`' do
    expect_no_offenses(<<~RUBY)
      NotFakeclass.with
      Fakeclass
    RUBY
  end

  context 'with multiple Identifiers' do
    let(:config) do
      RuboCop::Config.new(
        'Lint/ApprovedCallSite' => { 'Identifiers' => %w[Fakeclass Another] }
      )
    end

    it 'registers an offense when using `Fakeclass` as a receiver' do
      expect_offense(<<~RUBY)
        Fakeclass.with
        ^^^^^^^^^^^^^^ Fakeclass call site.
        Another.example
        ^^^^^^^^^^^^^^^ Another call site.
      RUBY
    end

    it 'does not register an offense when not using `Fakeclass`' do
      expect_no_offenses(<<~RUBY)
        NotFakeclass.with
        Fakeclass
        NotAnotherClass
        AnotherClass
      RUBY
    end
  end

  context 'when Identifiers config is nil' do
    let(:config) do
      RuboCop::Config.new('Lint/ApprovedCallSite' => { 'Identifiers' => nil })
    end

    it 'does not register an offense when not using `Fakeclass`' do
      expect_no_offenses(<<~RUBY)
        NotFakeclass.with
        Fakeclass
      RUBY
    end
  end

  context 'when config contains nil or empty string' do
    let(:config) do
      RuboCop::Config.new(
        'Lint/ApprovedCallSite' => { 'Identifiers' => [nil, '', 'Fakeclass'] }
      )
    end

    it 'registers an offense when using `Fakeclass` as a receiver' do
      expect_offense(<<~RUBY)
        Fakeclass.with
        ^^^^^^^^^^^^^^ Fakeclass call site.
      RUBY
    end

    it 'does not register an offense when not using `Fakeclass`' do
      expect_no_offenses(<<~RUBY)
        NotFakeclass.with
        Fakeclass
      RUBY
    end
  end
end
