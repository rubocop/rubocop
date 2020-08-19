# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantResolution, :config do
  it 'registers no offense when qualifying a const' do
    expect_no_offenses(<<~RUBY)
      ::MyConst
    RUBY
  end

  it 'registers no offense qualifying a namespace const' do
    expect_no_offenses(<<~RUBY)
      ::MyConst::MY_CONST
    RUBY
  end

  it 'registers an offense not qualifying a const' do
    expect_offense(<<~RUBY)
      MyConst
      ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
    RUBY
  end

  it 'registers an offense not qualifying a namespace const' do
    expect_offense(<<~RUBY)
      MyConst::MY_CONST
      ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
    RUBY
  end

  context 'module & class definitions' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        module Foo; end
        class Bar; end
      RUBY
    end
  end

  context 'with Only set' do
    let(:cop_config) { { 'Only' => ['MY_CONST'] } }

    it 'registers no offense when qualifying a const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst
      RUBY
    end

    it 'registers no offense qualifying a namespace const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst::MY_CONST
      RUBY
    end

    it 'registers no offense not qualifying another const' do
      expect_no_offenses(<<~RUBY)
        MyConst
      RUBY
    end

    it 'registers no with a namespace const' do
      expect_no_offenses(<<~RUBY)
        MyConst::MY_CONST
      RUBY
    end

    it 'registers an offense with an unqualified const' do
      expect_offense(<<~RUBY)
        MY_CONST
        ^^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end

    it 'registers an offense when an unqualified namespace const' do
      expect_offense(<<~RUBY)
        MY_CONST::B
        ^^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end
  end

  context 'with Ignore set' do
    let(:cop_config) { { 'Ignore' => ['MY_CONST'] } }

    it 'registers no offense when qualifying a const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst
      RUBY
    end

    it 'registers no offense qualifying a namespace const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst::MY_CONST
      RUBY
    end

    it 'registers an offense not qualifying another const' do
      expect_offense(<<~RUBY)
        MyConst
        ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end

    it 'registers an with a namespace const' do
      expect_offense(<<~RUBY)
        MyConst::MY_CONST
        ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end

    it 'registers no offense with an unqualified const' do
      expect_no_offenses(<<~RUBY)
        MY_CONST
      RUBY
    end

    it 'registers no offense when an unqualified namespace const' do
      expect_no_offenses(<<~RUBY)
        MY_CONST::B
      RUBY
    end
  end
end
