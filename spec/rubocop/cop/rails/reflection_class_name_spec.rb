# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReflectionClassName do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "registers an offense when using `foreign_key: 'account_id'`" do
    it 'has_many' do
      expect_offense(<<~RUBY)
        has_many :accounts, class_name: Account, foreign_key: :account_id
                            ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY
    end

    it '.name' do
      expect_offense(<<~RUBY)
        has_many :accounts, class_name: Account.name
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY
    end

    it 'has_one' do
      expect_offense(<<~RUBY)
        has_one :account, class_name: Account
                          ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY
    end

    it 'belongs_to' do
      expect_offense(<<~RUBY)
        belongs_to :account, class_name: Account
                             ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY
    end
  end

  it 'does not register an offense when using string with interpolation' do
    expect_no_offenses(<<~'RUBY')
      has_many :accounts, class_name: "#{prefix}Account"
    RUBY
  end

  it 'does not register an offense when using `foreign_key :account_id`' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: 'Account', foreign_key: :account_id
      has_one :account, class_name: 'Account'
      belongs_to :account, class_name: 'Account'
    RUBY
  end

  it 'does not register an offense when using symbol for `class_name`' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: :Account, foreign_key: :account_id
      has_one :account, class_name: :Account
      belongs_to :account, class_name: :Account
    RUBY
  end
end
