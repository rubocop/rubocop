# frozen_string_literal: true

describe RuboCop::Cop::Rails::CreateTableWithTimestamps do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when calling `#create_table` without block' do
    expect_offense <<-RUBY
      create_table :users
      ^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
    RUBY
  end

  it 'registers an offense when not including timestamps in empty block' do
    expect_offense <<-RUBY
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
      end
    RUBY
  end

  it 'registers an offense when not including timestamps in one line block' do
    expect_offense <<-RUBY
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
        t.string :name
      end
    RUBY
  end

  it 'registers an offense when not including timestamps in multiline block' do
    expect_offense <<-RUBY
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
        t.string :name
        t.string :email
      end
    RUBY
  end

  it 'does not register an offense when including timestamps in block' do
    expect_no_offenses <<-RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.timestamps
      end
    RUBY
  end

  it 'does not register an offense when including created_at in block' do
    expect_no_offenses <<-RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      end
    RUBY
  end

  it 'does not register an offense when including updated_at in block' do
    expect_no_offenses <<-RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
      end
    RUBY
  end
end
