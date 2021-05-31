# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::InclusiveLanguage, :config do
  context 'flagged term with suggestion' do
    let(:cop_config) do
      { 'FlaggedTerms' => {
        'whitelist' => { 'Suggestions' => 'allowlist' }
      } }
    end

    it 'registers an offense when using a flagged term' do
      expect_offense(<<~RUBY)
        whitelist = %w(user1 user2)
        ^^^^^^^^^ Consider replacing problematic term 'whitelist' with 'allowlist'.
      RUBY
    end

    it 'registers an offense when using a flagged term with mixed case' do
      expect_offense(<<~RUBY)
        class WhiteList
              ^^^^^^^^^ Consider replacing problematic term 'WhiteList' with 'allowlist'.
        end
      RUBY
    end
  end

  context 'flagged term with two suggestions' do
    let(:cop_config) do
      { 'FlaggedTerms' => {
        'whitelist' => { 'Suggestions' => %w[allowlist permit] }
      } }
    end

    it 'registers an offense when using a flagged term' do
      expect_offense(<<~RUBY)
        whitelist = %w(user1 user2)
        ^^^^^^^^^ Consider replacing problematic term 'whitelist' with 'allowlist' or 'permit'.
      RUBY
    end
  end

  context 'flagged term with three or more suggestions' do
    let(:cop_config) do
      { 'FlaggedTerms' => {
        'master' => { 'Suggestions' => %w[main primary leader] }
      } }
    end

    it 'includes all suggestions in the message' do
      expect_offense(<<~RUBY)
        config[:master] = {}
                ^^^^^^ Consider replacing problematic term 'master' with 'main', 'primary', or 'leader'.
      RUBY
    end
  end

  context 'flagged term with a regex' do
    let(:cop_config) do
      { 'FlaggedTerms' => {
        'whitelist' => { 'Regex' => /white[_\-\s]?list/, 'Suggestions' => 'allowlist' }
      } }
    end

    it 'registers an offense when using a regexp' do
      expect_offense(<<~RUBY)
        white_list = %w(user1 user2)
        ^^^^^^^^^^ Consider replacing problematic term 'white_list' with 'allowlist'.
      RUBY
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
                ^^^^^ Consider replacing problematic term 'slave' with 'replica', 'secondary', or 'follower'.
        ^^^^^^ Consider replacing problematic term 'master' with 'main', 'primary', or 'leader'.
      RUBY
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
              ^^^ Consider replacing problematic term 'foo'.
      RUBY
    end
  end

  context 'filename' do
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
        expect(messages)
          .to eq(["Consider replacing problematic term 'master' with 'main' in file path."])
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
          .to eq(["Consider replacing problematic terms 'master', 'slave' in file path."])
      end
    end

    context 'offense in directory name' do
      let(:cop_config) do
        { 'FlaggedTerms' => { 'master' => {} } }
      end
      let(:filename) { '/db/master/config.yml' }

      it 'registers an offense for a director' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(["Consider replacing problematic term 'master' in file path."])
      end
    end
  end
end
