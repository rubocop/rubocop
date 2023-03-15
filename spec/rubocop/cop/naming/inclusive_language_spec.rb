# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::InclusiveLanguage, :config do
  context 'flagged term matching' do
    let(:cop_config) do
      { 'FlaggedTerms' => { 'whitelist' => {} } }
    end

    it 'registers an offense when using a flagged term' do
      expect_offense(<<~RUBY)
        whitelist = %w(user1 user2)
        ^^^^^^^^^ Consider replacing 'whitelist' with another term.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when using a flagged term with mixed case' do
      expect_offense(<<~RUBY)
        class WhiteList
              ^^^^^^^^^ Consider replacing 'WhiteList' with another term.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for a partial word match' do
      expect_offense(<<~RUBY)
        class Nodewhitelist
                  ^^^^^^^^^ Consider replacing 'whitelist' with another term.
        end
      RUBY

      expect_no_corrections
    end

    context 'disable default flagged term' do
      let(:cop_config) do
        { 'FlaggedTerms' => { 'whitelist' => nil, 'blacklist' => {} } }
      end

      it 'ignores flagged terms that are set to nil' do
        expect_offense(<<~RUBY)
          # working on replacing whitelist and blacklist
                                               ^^^^^^^^^ Consider replacing 'blacklist' with another term.
        RUBY

        expect_no_corrections
      end
    end

    context 'multiple offenses on a line' do
      let(:cop_config) do
        { 'FlaggedTerms' => {
          'master' => { 'Suggestions' => %w[main primary leader] },
          'slave' => { 'Suggestions' => %w[replica secondary follower] }
        } }
      end

      it 'registers an offense for each word' do
        expect_offense(<<~RUBY)
          master, slave = nodes
                  ^^^^^ Consider replacing 'slave' with 'replica', 'secondary', or 'follower'.
          ^^^^^^ Consider replacing 'master' with 'main', 'primary', or 'leader'.
        RUBY

        expect_no_corrections
      end
    end

    context 'regex' do
      let(:cop_config) do
        { 'FlaggedTerms' => { 'whitelist' => { 'Regex' => /white[-_\s]?list/ } } }
      end

      it 'registers an offense for a flagged term matched with a regexp' do
        expect_offense(<<~RUBY)
          # white-list of IPs
            ^^^^^^^^^^ Consider replacing 'white-list' with another term.
        RUBY

        expect_no_corrections
      end
    end

    context 'WholeWord: true' do
      let(:cop_config) do
        { 'CheckStrings' => true, 'FlaggedTerms' => { 'slave' => { 'WholeWord' => true } } }
      end

      it 'only flags when the term is a whole word' do
        expect_offense(<<~RUBY)
          # infix allowed
          TeslaVehicle
          SLAVersion
          :teslavehicle

          # prefix allowed
          DatabaseSlave

          # suffix allowed
          Slave1

          # not allowed
          Slave
          ^^^^^ Consider replacing 'Slave' with another term.
          :database_slave
                    ^^^^^ Consider replacing 'slave' with another term.
          'database@slave'
                    ^^^^^ Consider replacing 'slave' with another term.
        RUBY

        expect_no_corrections
      end
    end
  end

  context 'allowed use' do
    let(:cop_config) do
      { 'FlaggedTerms' => {
        'master' => { 'AllowedRegex' => 'master\'s degree' }
      } }
    end

    it 'does not register an offense for an allowed use' do
      expect_no_offenses(<<~RUBY)
        # They had a Master's Degree
      RUBY
    end

    context 'offense after an allowed use' do
      let(:cop_config) do
        { 'FlaggedTerms' => {
          'foo' => {},
          'bar' => { 'AllowedRegex' => 'barx' }
        } }
      end

      it 'registers an offense at the correct location' do
        expect_offense(<<~RUBY)
          barx, foo = method_call
                ^^^ Consider replacing 'foo' with another term.
        RUBY

        expect_no_corrections
      end
    end
  end

  context 'suggestions' do
    context 'flagged term with one suggestion' do
      let(:cop_config) do
        { 'FlaggedTerms' => {
          'whitelist' => { 'Suggestions' => 'allowlist' }
        } }
      end

      it 'includes the suggestion in the offense message' do
        expect_offense(<<~RUBY)
          whitelist = %w(user1 user2)
          ^^^^^^^^^ Consider replacing 'whitelist' with 'allowlist'.
        RUBY

        expect_correction(<<~RUBY)
          allowlist = %w(user1 user2)
        RUBY
      end
    end

    context 'flagged term with two suggestions' do
      let(:cop_config) do
        { 'FlaggedTerms' => {
          'whitelist' => { 'Suggestions' => %w[allowlist permit] }
        } }
      end

      it 'includes both suggestions in the offense message' do
        expect_offense(<<~RUBY)
          whitelist = %w(user1 user2)
          ^^^^^^^^^ Consider replacing 'whitelist' with 'allowlist' or 'permit'.
        RUBY

        expect_no_corrections
      end
    end

    context 'flagged term with three or more suggestions' do
      let(:cop_config) do
        {
          'CheckStrings' => true,
          'FlaggedTerms' => {
            'master' => { 'Suggestions' => %w[main primary leader] }
          }
        }
      end

      it 'includes all suggestions in the message' do
        expect_offense(<<~RUBY)
          default_branch = 'master'
                            ^^^^^^ Consider replacing 'master' with 'main', 'primary', or 'leader'.
        RUBY

        expect_no_corrections
      end
    end
  end

  context 'identifiers' do
    let(:cop_config) do
      { 'CheckIdentifiers' => check_identifiers, 'FlaggedTerms' => { 'whitelist' => {} } }
    end

    context 'when CheckIdentifiers config is true' do
      let(:check_identifiers) { true }

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          whitelist = %w(user1 user2)
          ^^^^^^^^^ Consider replacing 'whitelist' with another term.
        RUBY

        expect_no_corrections
      end
    end

    context 'when CheckIdentifiers config is false' do
      let(:check_identifiers) { false }

      it 'does not register offenses for identifiers' do
        expect_no_offenses(<<~RUBY)
          whitelist = %w(user1 user2)
        RUBY
      end
    end
  end

  context 'variables' do
    let(:cop_config) do
      { 'CheckVariables' => check_variables, 'FlaggedTerms' => { 'whitelist' => {} } }
    end

    context 'when CheckVariables config is true' do
      let(:check_variables) { true }

      it 'registers offenses for instance variables' do
        expect_offense(<<~RUBY)
          @whitelist = %w(user1 user2)
           ^^^^^^^^^ Consider replacing 'whitelist' with another term.
        RUBY

        expect_no_corrections
      end

      it 'registers offenses for class variables' do
        expect_offense(<<~RUBY)
          @@whitelist = %w(user1 user2)
            ^^^^^^^^^ Consider replacing 'whitelist' with another term.
        RUBY

        expect_no_corrections
      end

      it 'registers offenses for global variables' do
        expect_offense(<<~RUBY)
          $whitelist = %w(user1 user2)
           ^^^^^^^^^ Consider replacing 'whitelist' with another term.
        RUBY

        expect_no_corrections
      end
    end

    context 'when CheckVariables config is false' do
      let(:check_variables) { false }

      it 'does not register offenses for variables' do
        expect_no_offenses(<<~RUBY)
          @whitelist = %w(user1 user2)
        RUBY
      end
    end
  end

  context 'constants' do
    let(:cop_config) do
      { 'CheckConstants' => check_constants, 'FlaggedTerms' => { 'whitelist' => {} } }
    end

    context 'when CheckConstants config is true' do
      let(:check_constants) { true }

      it 'registers offenses for constants' do
        expect_offense(<<~RUBY)
          WHITELIST = %w(user1 user2)
          ^^^^^^^^^ Consider replacing 'WHITELIST' with another term.
        RUBY

        expect_no_corrections
      end
    end

    context 'when CheckConstants config is false' do
      let(:check_constants) { false }

      it 'does not register offenses for constants' do
        expect_no_offenses(<<~RUBY)
          WHITELIST = %w(user1 user2)
        RUBY
      end
    end
  end

  context 'strings' do
    let(:check_strings) { true }
    let(:cop_config) do
      { 'CheckStrings' => check_strings, 'FlaggedTerms' => { 'master' => {}, 'slave' => {} } }
    end

    it 'registers an offense for an interpolated string' do
      expect_offense(<<~RUBY)
        puts "master node \#{node}"
              ^^^^^^ Consider replacing 'master' with another term.

      RUBY
    end

    it 'registers an offense for a multiline string' do
      expect_offense(<<~RUBY)
        node_types = "master
                      ^^^^^^ Consider replacing 'master' with another term.
          slave
          ^^^^^ Consider replacing 'slave' with another term.
          primary
          secondary"
      RUBY

      expect_no_corrections
    end

    it 'registers an offense in a heredoc' do
      expect_offense(<<~RUBY)
        node_text = <<~TEXT
          master
          ^^^^^^ Consider replacing 'master' with another term.
          primary
          slave
          ^^^^^ Consider replacing 'slave' with another term.
          secondary
        TEXT
      RUBY

      expect_no_corrections
    end

    it 'does not register offenses and not raise `ArgumentError` for invalid byte sequence in UTF-8' do
      expect_no_offenses(<<-RUBY)
        %W("a\\255\\255")
      RUBY
    end

    context 'when CheckStrings config is false' do
      let(:check_strings) { false }

      it 'does not register offenses for strings' do
        expect_no_offenses(<<~RUBY)
          puts "master node \#{node}"
        RUBY
      end
    end
  end

  context 'symbols' do
    let(:cop_config) do
      { 'CheckSymbols' => check_symbols, 'FlaggedTerms' => { 'master' => {} } }
    end

    context 'when CheckSymbols is true' do
      let(:check_symbols) { true }

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          config[:master] = {}
                  ^^^^^^ Consider replacing 'master' with another term.
        RUBY

        expect_no_corrections
      end
    end

    context 'when CheckSymbols is false' do
      let(:check_symbols) { false }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          config[:master] = {}
        RUBY
      end
    end
  end

  context 'comments' do
    let(:check_comments) { true }
    let(:cop_config) do
      { 'CheckComments' => check_comments, 'FlaggedTerms' => { 'foo' => {} } }
    end

    it 'registers an offense in a single line comment' do
      expect_offense(<<~RUBY)
        # is it a foo?
                  ^^^ Consider replacing 'foo' with another term.
        bar = baz # it's a foo!
                           ^^^ Consider replacing 'foo' with another term.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense in a block comment' do
      expect_offense(<<~RUBY)
        =begin
        foo
        ^^^ Consider replacing 'foo' with another term.
        bar
        =end
      RUBY

      expect_no_corrections
    end

    context 'when CheckComments is false' do
      let(:check_comments) { false }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # is it a foo?
        RUBY
      end
    end
  end

  context 'filepath' do
    let(:source) { 'print 1' }
    let(:processed_source) { parse_source(source) }
    let(:offenses) { _investigate(cop, processed_source) }
    let(:messages) { offenses.sort.map(&:message) }

    before { allow(processed_source.buffer).to receive(:name).and_return(filename) }

    context 'one offense in filename' do
      let(:cop_config) do
        { 'FlaggedTerms' => { 'master' => { 'Suggestions' => 'main' } } }
      end
      let(:filename) { '/some/dir/master.rb' }

      it 'registers an offense' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(["Consider replacing 'master' in file path with 'main'."])
      end
    end

    context 'multiple offenses in filename' do
      let(:cop_config) do
        { 'FlaggedTerms' => { 'master' => {}, 'slave' => {} } }
      end
      let(:filename) { '/some/config/master-slave.rb' }

      it 'registers an offense with all problematic words' do
        expect(offenses.size).to eq(1)
        expect(messages)
          .to eq(["Consider replacing 'master', 'slave' in file path with other terms."])
      end
    end

    context 'offense in directory name' do
      let(:cop_config) do
        { 'FlaggedTerms' => { 'master' => {} } }
      end
      let(:filename) { '/db/master/config.yml' }

      it 'registers an offense for a director' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(["Consider replacing 'master' in file path with another term."])
      end
    end

    context 'CheckFilepaths is false' do
      let(:cop_config) do
        { 'CheckFilepaths' => false, 'FlaggedTerms' => { 'master' => {} } }
      end
      let(:filename) { '/some/dir/master.rb' }

      it 'does not register an offense' do
        expect(offenses.size).to eq(0)
        expect(messages.empty?).to be(true)
      end
    end
  end
end
