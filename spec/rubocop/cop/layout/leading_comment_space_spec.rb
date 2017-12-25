# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LeadingCommentSpace do
  subject(:cop) { described_class.new }

  it 'registers an offense for comment without leading space' do
    expect_offense(<<-RUBY.strip_indent)
      #missing space
      ^^^^^^^^^^^^^^ Missing space after `#`.
    RUBY
  end

  it 'does not register an offense for # followed by no text' do
    expect_no_offenses('#')
  end

  it 'does not register an offense for more than one space' do
    expect_no_offenses('#   heavily indented')
  end

  it 'does not register an offense for more than one #' do
    expect_no_offenses('###### heavily indented')
  end

  it 'does not register an offense for only #s' do
    expect_no_offenses('######')
  end

  it 'does not register an offense for #! on first line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      #!/usr/bin/ruby
      test
    RUBY
  end

  it 'registers an offense for #! after the first line' do
    expect_offense(<<-RUBY.strip_indent)
      test
      #!/usr/bin/ruby
      ^^^^^^^^^^^^^^^ Missing space after `#`.
    RUBY
  end

  context 'file named config.ru' do
    it 'does not register an offense for #\ on first line' do
      expect_no_offenses(<<-'RUBY'.strip_indent, 'config.ru')
        #\ -w -p 8765
        test
      RUBY
    end

    it 'registers an offense for #\ after the first line' do
      expect_offense(<<-'RUBY'.strip_indent, 'config.ru')
        test
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
      RUBY
    end
  end

  context 'file not named config.ru' do
    it 'registers an offense for #\ on first line' do
      expect_offense(<<-'RUBY'.strip_indent, 'test/test_case.rb')
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
        test
       RUBY
    end

    it 'registers an offense for #\ after the first line' do
      expect_offense(<<-'RUBY'.strip_indent, 'test/test_case.rb')
        test
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
      RUBY
    end
  end

  it 'accepts rdoc syntax' do
    expect_no_offenses(<<-RUBY.strip_indent)
      #++
      #--
      #:nodoc:
    RUBY
  end

  it 'accepts sprockets directives' do
    expect_no_offenses('#= require_tree .')
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source('#comment')
    expect(new_source).to eq('# comment')
  end

  it 'accepts =begin/=end comments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      =begin
      #blahblah
      =end
    RUBY
  end
end
