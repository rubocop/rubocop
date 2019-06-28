# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LeadingCommentSpace, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for comment without leading space' do
    expect_offense(<<~RUBY)
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
    expect_no_offenses(<<~RUBY)
      #!/usr/bin/ruby
      test
    RUBY
  end

  it 'registers an offense for #! after the first line' do
    expect_offense(<<~RUBY)
      test
      #!/usr/bin/ruby
      ^^^^^^^^^^^^^^^ Missing space after `#`.
    RUBY
  end

  context 'file named config.ru' do
    it 'does not register an offense for #\ on first line' do
      expect_no_offenses(<<~'RUBY', 'config.ru')
        #\ -w -p 8765
        test
      RUBY
    end

    it 'registers an offense for #\ after the first line' do
      expect_offense(<<~'RUBY', 'config.ru')
        test
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
      RUBY
    end
  end

  context 'file not named config.ru' do
    it 'registers an offense for #\ on first line' do
      expect_offense(<<~'RUBY', 'test/test_case.rb')
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
        test
      RUBY
    end

    it 'registers an offense for #\ after the first line' do
      expect_offense(<<~'RUBY', 'test/test_case.rb')
        test
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
      RUBY
    end
  end

  describe 'Doxygen style' do
    context 'when config option is disabled' do
      let(:cop_config) { { 'AllowDoxygenCommentStyle' => false } }

      it 'registers an offense when using Doxygen style' do
        expect_offense(<<~RUBY)
          #**
          ^^^ Missing space after `#`.
          # Some comment
          # Another comment on a second line
          #*
          ^^ Missing space after `#`.
        RUBY
      end
    end

    context 'when config option is enabled' do
      let(:cop_config) { { 'AllowDoxygenCommentStyle' => true } }

      it 'does not register offense when using Doxygen style' do
        expect_no_offenses(<<~RUBY)
          #**
          # Some comment
          # Another comment on a second line
          #*
        RUBY
      end
    end
  end

  it 'accepts rdoc syntax' do
    expect_no_offenses(<<~RUBY)
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
    expect_no_offenses(<<~RUBY)
      =begin
      #blahblah
      =end
    RUBY
  end
end
