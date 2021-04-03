# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeFirstArg, :config do
  let(:cop_config) { { 'AllowForAlignment' => true } }
  let(:message) { 'Put one space between the method name and the first argument.' }

  context 'for method calls without parentheses' do
    it 'registers an offense and corrects method call with two spaces before the first arg' do
      expect_offense(<<~RUBY)
        something  x
                 ^^ #{message}
        a.something  y, z
                   ^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        something x
        a.something y, z
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense and corrects method call with two spaces before the first arg' do
        expect_offense(<<~RUBY)
          a&.something  y, z
                      ^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          a&.something y, z
        RUBY
      end
    end

    it 'registers an offense for method call with no spaces before the first arg' do
      expect_offense(<<~RUBY)
        something'hello'
                 ^{} #{message}
        a.something'hello world'
                   ^{} #{message}
      RUBY

      expect_correction(<<~RUBY)
        something 'hello'
        a.something 'hello world'
      RUBY
    end

    context 'when a vertical argument positions are aligned' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj = a_method(arg, arg2)
          obj.no_parenthesized'asdf'
                              ^{} #{message}
        RUBY

        expect_correction(<<~RUBY)
          obj = a_method(arg, arg2)
          obj.no_parenthesized 'asdf'
        RUBY
      end
    end

    it 'accepts a method call with one space before the first arg' do
      expect_no_offenses(<<~RUBY)
        something x
        a.something y, z
      RUBY
    end

    it 'accepts + operator' do
      expect_no_offenses(<<~RUBY)
        something +
          x
      RUBY
    end

    it 'accepts setter call' do
      expect_no_offenses(<<~RUBY)
        something.x =
          y
      RUBY
    end

    it 'accepts multiple space containing line break' do
      expect_no_offenses(<<~RUBY)
        something \\
          x
      RUBY
    end

    context 'when AllowForAlignment is true' do
      it 'accepts method calls with aligned first arguments' do
        expect_no_offenses(<<~RUBY)
          form.inline_input   :full_name,     as: :string
          form.disabled_input :password,      as: :passwd
          form.masked_input   :zip_code,      as: :string
          form.masked_input   :email_address, as: :email
          form.masked_input   :phone_number,  as: :tel
        RUBY
      end
    end

    context 'when AllowForAlignment is false' do
      let(:cop_config) { { 'AllowForAlignment' => false } }

      it 'registers an offense and corrects method calls with aligned first arguments' do
        expect_offense(<<~RUBY)
          form.inline_input   :full_name,     as: :string
                           ^^^ Put one space between the method name and the first argument.
          form.disabled_input :password,      as: :passwd
          form.masked_input   :zip_code,      as: :string
                           ^^^ Put one space between the method name and the first argument.
          form.masked_input   :email_address, as: :email
                           ^^^ Put one space between the method name and the first argument.
          form.masked_input   :phone_number,  as: :tel
                           ^^^ Put one space between the method name and the first argument.
        RUBY

        expect_correction(<<~RUBY)
          form.inline_input :full_name,     as: :string
          form.disabled_input :password,      as: :passwd
          form.masked_input :zip_code,      as: :string
          form.masked_input :email_address, as: :email
          form.masked_input :phone_number,  as: :tel
        RUBY
      end
    end
  end

  context 'for method calls with parentheses' do
    it 'accepts a method call without space' do
      expect_no_offenses(<<~RUBY)
        something(x)
        a.something(y, z)
      RUBY
    end

    it 'accepts a method call with space after the left parenthesis' do
      expect_no_offenses('something(  x  )')
    end
  end
end
