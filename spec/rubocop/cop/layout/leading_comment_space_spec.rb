# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LeadingCommentSpace, :config do
  it 'registers an offense and corrects comment without leading space' do
    expect_offense(<<~RUBY)
      #missing space
      ^^^^^^^^^^^^^^ Missing space after `#`.
    RUBY

    expect_correction(<<~RUBY)
      # missing space
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

  it 'registers an offense and corrects #! after the first line' do
    expect_offense(<<~RUBY)
      test
      #!/usr/bin/ruby
      ^^^^^^^^^^^^^^^ Missing space after `#`.
    RUBY

    expect_correction(<<~RUBY)
      test
      # !/usr/bin/ruby
    RUBY
  end

  context 'file named config.ru' do
    it 'does not register an offense for #\ on first line' do
      expect_no_offenses(<<~'RUBY', 'config.ru')
        #\ -w -p 8765
        test
      RUBY
    end

    it 'registers an offense and corrects for #\ after the first line' do
      expect_offense(<<~'RUBY')
        test
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
      RUBY

      expect_correction(<<~'RUBY')
        test
        # \ -w -p 8765
      RUBY
    end
  end

  context 'file not named config.ru' do
    it 'registers an offense and corrects #\ on first line' do
      expect_offense(<<~'RUBY')
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
        test
      RUBY

      expect_correction(<<~'RUBY')
        # \ -w -p 8765
        test
      RUBY
    end

    it 'registers an offense and corrects #\ after the first line' do
      expect_offense(<<~'RUBY')
        test
        #\ -w -p 8765
        ^^^^^^^^^^^^^ Missing space after `#`.
      RUBY

      expect_correction(<<~'RUBY')
        test
        # \ -w -p 8765
      RUBY
    end
  end

  describe 'Doxygen style' do
    context 'when config option is disabled' do
      let(:cop_config) { { 'AllowDoxygenCommentStyle' => false } }

      it 'registers an offense and corrects using Doxygen style' do
        expect_offense(<<~RUBY)
          #**
          ^^^ Missing space after `#`.
          # Some comment
          # Another comment on a second line
          #*
          ^^ Missing space after `#`.
        RUBY

        expect_correction(<<~RUBY)
          # **
          # Some comment
          # Another comment on a second line
          # *
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

  describe 'RDoc syntax' do
    it 'does not register an offense when using `#++` or `#--`' do
      expect_no_offenses(<<~RUBY)
        #++
        #--
      RUBY
    end

    it 'registers an offense when starting `:`' do
      expect_offense(<<~RUBY)
        #:nodoc:
        ^^^^^^^^ Missing space after `#`.
      RUBY
    end
  end

  it 'accepts sprockets directives' do
    expect_no_offenses('#= require_tree .')
  end

  it 'accepts =begin/=end comments' do
    expect_no_offenses(<<~RUBY)
      =begin
      #blahblah
      =end
    RUBY
  end

  describe 'Gemfile Ruby comment' do
    context 'when config option is disabled' do
      let(:cop_config) { { 'AllowGemfileRubyComment' => false } }

      it 'registers an offense when using ruby config as comment' do
        expect_offense(<<~RUBY)
          # Specific version (comment) will be used by RVM
          #ruby=2.7.0
          ^^^^^^^^^^^ Missing space after `#`.
          #ruby-gemset=myproject
          ^^^^^^^^^^^^^^^^^^^^^^ Missing space after `#`.
          ruby '~> 2.7.0'
        RUBY
      end
    end

    context 'when config option is enabled' do
      let(:cop_config) { { 'AllowGemfileRubyComment' => true } }

      context 'file not named Gemfile' do
        it 'registers an offense when using ruby config as comment' do
          expect_offense(<<~RUBY, 'test/test_case.rb')
            # Specific version (comment) will be used by RVM
            #ruby=2.7.0
            ^^^^^^^^^^^ Missing space after `#`.
            #ruby-gemset=myproject
            ^^^^^^^^^^^^^^^^^^^^^^ Missing space after `#`.
            ruby '~> 2.7.0'
          RUBY
        end
      end

      context 'file named Gemfile' do
        it 'does not register an offense when using ruby config as comment' do
          expect_no_offenses(<<~RUBY, 'Gemfile')
            # Specific version (comment) will be used by RVM
            #ruby=2.7.0
            #ruby-gemset=myproject
            ruby '~> 2.7.0'
          RUBY
        end
      end
    end
  end
end
