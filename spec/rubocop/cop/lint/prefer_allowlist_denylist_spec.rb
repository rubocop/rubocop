# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::PreferAllowlistDenylist do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when neither whitelist nor blacklist is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        puts 'hi'
      RUBY
    end
  end

  context 'when blacklist is used as a string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        puts 'something blacklist something'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when blacklist is used as a method name' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        blacklist_method
        ^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when blacklist is used in a migration' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        t.text :something_blacklist_something
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when blacklist is in all caps' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        SOMETHING_BLACKLIST = [1,2]
        SOMETHING_BLACKLIST.include?(3)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when whitelist is used as a string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        puts 'something whitelist something'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when whitelist is used as a method name' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        whitelist_method
        ^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when whitelist is used in a migration' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        t.text :something_whitelist_something
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end

  context 'when whitelist is in all caps' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        SOMETHING_WHITELIST = [1,2]
        SOMETHING_WHITELIST.include?(3)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'.
      RUBY
    end
  end
end
