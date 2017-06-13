# frozen_string_literal: true

describe RuboCop::Cop::Rails::DynamicFindBy, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'Whitelist' => %w[find_by_sql] }
  end

  shared_examples 'register an offense and auto correct' do |message, corrected|
    it 'registers an offense' do
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq([message])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected)
    end
  end

  context 'with dynamic find_by_*' do
    let(:source) { 'User.find_by_name(name)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_name`.',
      'User.find_by(name: name)'
    )
  end

  context 'with dynamic find_by_*_and_*' do
    let(:source) { 'User.find_by_name_and_email(name, email)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_name_and_email`.',
      'User.find_by(name: name, email: email)'
    )
  end

  context 'with dynamic find_by_*!' do
    let(:source) { 'User.find_by_name!(name)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by!` instead of dynamic `find_by_name!`.',
      'User.find_by!(name: name)'
    )
  end

  context 'with dynamic find_by_*_and_*_and_*' do
    let(:source) { 'User.find_by_name_and_email_and_token(name, email, token)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_name_and_email_and_token`.',
      'User.find_by(name: name, email: email, token: token)'
    )
  end

  context 'with dynamic find_by_*_and_*_and_*!' do
    let(:source) do
      'User.find_by_name_and_email_and_token!(name, email, token)'
    end

    include_examples(
      'register an offense and auto correct',
      'Use `find_by!` instead of dynamic `find_by_name_and_email_and_token!`.',
      'User.find_by!(name: name, email: email, token: token)'
    )
  end

  context 'with dynamic find_by_*_and_*_and_* with newline' do
    let(:source) do
      <<-RUBY.strip_indent
        User.find_by_name_and_email_and_token(
          name,
          email,
          token
        )
      RUBY
    end

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_name_and_email_and_token`.',
      <<-RUBY.strip_indent
        User.find_by(
          name: name,
          email: email,
          token: token
        )
      RUBY
    )
  end

  context 'with column includes undersoce' do
    let(:source) { 'User.find_by_first_name(name)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_first_name`.',
      'User.find_by(first_name: name)'
    )
  end

  context 'with too much arguments' do
    let(:source) { 'User.find_by_name_and_email(name, email, token)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_name_and_email`.',
      # Do not correct
      'User.find_by_name_and_email(name, email, token)'
    )
  end

  context 'with too few arguments' do
    let(:source) { 'User.find_by_name_and_email(name)' }

    include_examples(
      'register an offense and auto correct',
      'Use `find_by` instead of dynamic `find_by_name_and_email`.',
      # Do not correct
      'User.find_by_name_and_email(name)'
    )
  end

  it 'accepts' do
    expect_no_offenses('User.find_by(name: name)')
  end

  it 'accepts method in whitelist' do
    expect_no_offenses(<<-RUBY.strip_indent)
      User.find_by_sql(["select * from users where name = ?", name])
    RUBY
  end
end
