# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CaseEquality, :config do
  shared_examples 'offenses' do
    it 'does not fail when the receiver is implicit' do
      expect_no_offenses(<<~RUBY)
        puts "No offense"
      RUBY
    end

    it 'registers an offense and corrects for === when the receiver is a regexp' do
      expect_offense(<<~RUBY)
        /OMG/ === var
              ^^^ Avoid the use of the case equality operator `===`.
      RUBY

      expect_correction(<<~RUBY)
        var =~ /OMG/
      RUBY
    end

    it 'registers an offense and corrects for === when the receiver is a range' do
      expect_offense(<<~RUBY)
        (1..10) === var
                ^^^ Avoid the use of the case equality operator `===`.
      RUBY

      expect_correction(<<~RUBY)
        (1..10).include?(var)
      RUBY
    end

    it 'registers an offense and does not correct for === when receiver is of some other type' do
      expect_offense(<<~RUBY)
        foo === var
            ^^^ Avoid the use of the case equality operator `===`.
      RUBY

      expect_no_corrections
    end
  end

  context 'when AllowOnConstant is false' do
    let(:cop_config) do
      { 'AllowOnConstant' => false }
    end

    it 'registers an offense and corrects for === when the receiver is a constant' do
      expect_offense(<<~RUBY)
        Array === var
              ^^^ Avoid the use of the case equality operator `===`.
      RUBY

      expect_correction(<<~RUBY)
        var.is_a?(Array)
      RUBY
    end

    include_examples 'offenses'
  end

  context 'when AllowOnConstant is true' do
    let(:cop_config) do
      { 'AllowOnConstant' => true }
    end

    it 'does not register an offense for === when the receiver is a constant' do
      expect_no_offenses(<<~RUBY)
        Array === var
      RUBY
    end

    include_examples 'offenses'
  end
end
