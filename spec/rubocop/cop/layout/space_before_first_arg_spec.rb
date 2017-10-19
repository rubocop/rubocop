# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceBeforeFirstArg, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'AllowForAlignment' => true } }

  context 'for method calls without parentheses' do
    it 'registers an offense for method call with two spaces before the ' \
       'first arg' do
      inspect_source(<<-RUBY.strip_indent)
        something  x
        a.something  y, z
      RUBY
      expect(cop.messages)
        .to eq(['Put one space between the method name and the first ' \
                'argument.'] * 2)
      expect(cop.highlights).to eq(['  ', '  '])
    end

    it 'auto-corrects extra space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something  x
        a.something   y, z
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something x
        a.something y, z
      RUBY
    end

    it 'registers an offense for method call with no spaces before the '\
       'first arg' do
      inspect_source(<<-RUBY.strip_indent)
        something'hello'
        a.something'hello world'
      RUBY
      expect(cop.messages)
        .to eq(['Put one space between the method name and the first ' \
                'argument.'] * 2)
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something'hello'
        a.something'hello world'
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something 'hello'
        a.something 'hello world'
      RUBY
    end

    it 'accepts a method call with one space before the first arg' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something x
        a.something y, z
      RUBY
    end

    it 'accepts + operator' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something +
          x
      RUBY
    end

    it 'accepts setter call' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something.x =
          y
      RUBY
    end

    it 'accepts multiple space containing line break' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something \\
          x
      RUBY
    end

    context 'when AllowForAlignment is true' do
      it 'accepts method calls with aligned first arguments' do
        expect_no_offenses(<<-RUBY.strip_indent)
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

      it 'does not accept method calls with aligned first arguments' do
        expect_offense(<<-RUBY.strip_indent)
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
      end
    end
  end

  context 'for method calls with parentheses' do
    it 'accepts a method call without space' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something(x)
        a.something(y, z)
      RUBY
    end

    it 'accepts a method call with space after the left parenthesis' do
      expect_no_offenses('something(  x  )')
    end
  end
end
