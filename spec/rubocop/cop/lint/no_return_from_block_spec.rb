# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NoReturnFromBlock, :config do
  context 'when AllowReturnFromBlock is false' do
    let(:cop_config) { { 'AllowReturnFromBlock' => false } }

    it 'registers an offense for a block with a return statement' do
      expect_offense(<<~RUBY)
        items.each do |item|
          return if item.nil?
          ^^^^^^ Return from block detected.
          puts item.some_attribute
        end
      RUBY
    end

    it 'registers an offense for each return in a block' do
      expect_offense(<<~RUBY)
        items.each do |item|
          return if item.nil?
          ^^^^^^ Return from block detected.
          puts item.some_attribute
          return if item.some_attribute.nil?
          ^^^^^^ Return from block detected.
          item.some_attribute
        end
      RUBY
    end

    it 'does not register an offense for a block without a return statement' do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          puts item.some_attribute unless item.nil?
        end
      RUBY
    end
  end

  context 'when AllowReturnFromBlock is true' do
    let(:cop_config) { { 'AllowReturnFromBlock' => true } }

    it 'does not register an offense for a block with a return statement' do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          return if item.nil?
          puts item.some_attribute
        end
      RUBY
    end

    it 'does not register an offense for a block without a return statement' do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          puts item.some_attribute unless item.nil?
        end
      RUBY
    end
  end
end
