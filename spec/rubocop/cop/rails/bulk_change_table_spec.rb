# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BulkChangeTable, :config do
  subject(:cop) { described_class.new(config) }

  let(:rails_version) { 5.2 }

  shared_examples 'offense' do
    it 'registers an offense when including combinable transformations' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'registers an offense when including combinable alter methods' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          add_column :users, :name, :string, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_column :users, :nickname
        end
      RUBY
    end
  end

  shared_examples 'no offense' do
    it 'does not register an offense' \
       'when including combinable transformations' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including combinable alter methods' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          add_column :users, :name, :string, null: false
          remove_column :users, :nickname
        end
      RUBY
    end
  end

  shared_examples 'offense for mysql' do
    it 'registers an offense when including combinable transformations' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.index :name
            t.index :address
          end
        end
      RUBY
    end

    it 'registers an offense when including combinable alter methods' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          remove_index :users, :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_index :users, :address
        end
      RUBY
    end
  end

  shared_examples 'no offense for mysql' do
    it 'does not register an offense' \
       'when including combinable transformations' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
            t.index :name
            t.index :address
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including combinable alter methods' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          remove_index :users, :name
          remove_index :users, :address
        end
      RUBY
    end
  end

  shared_examples 'offense for postgresql' do
    it 'registers an offense when including combinable transformations' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.change_default :name, 'unknown'
            t.change_default :address, nil
          end
        end
      RUBY
    end

    it 'registers an offense when including combinable alter methods' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          change_column_null :users, :name, false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          change_column_null :users, :address, false
        end
      RUBY
    end
  end

  shared_examples 'no offense for postgresql' do
    it 'does not register an offense' \
       'when including combinable transformations' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
            t.change_default :name, 'unknown'
            t.change_default :address, nil
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including combinable alter methods' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_column_null :users, :name, false
          change_column_null :users, :address, false
        end
      RUBY
    end
  end

  it_behaves_like 'no offense'
  it_behaves_like 'no offense for mysql'
  it_behaves_like 'no offense for postgresql'

  context 'when database is MySQL' do
    let(:cop_config) do
      {
        'Database' => 'mysql',
        'Include' => ['*']
      }
    end

    it_behaves_like 'offense'
    it_behaves_like 'offense for mysql'
    it_behaves_like 'no offense for postgresql'

    it 'registers offenses when including combinable alter methods' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          add_reference :users, :team
          add_column :users, :name, :string, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_column :users, :nickname
          remove_column :users, :flag
          add_column :teams, :owner_name, :string, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :teams, bulk: true` to combine alter queries.
          add_column :teams, :member_count, :integer, null: false
          User.reset_column_information
          User.all.each do |user|
            user.refresh!
          end
          remove_column :users, :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_column :users, :metadata
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including combinable transformations with `bulk: true`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users, bulk: true do |t|
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including combinable transformations with `bulk: false`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users, bulk: false do |t|
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including a combinable transformation' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
            t.belongs_to :team
            t.string :name, null: false
          end
        end
      RUBY
    end

    it 'does not register an offense when including a transformation' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
            t.string :name, null: false
          end
        end
      RUBY
    end

    it 'does not register an offense when transformations are inside of `if`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          change_table :users do |t|
            if Rails.env.test?
              t.string :name, null: true
              t.string :address, null: true
            else
              t.string :name, null: false
              t.string :address, null: false
            end
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including transformations with block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          reversible do |dir|
            change_table :users do |t|
              dir.up do
                t.string :name, null: false
                t.string :address, null: false
              end

              dir.down do
                t.remove :name
                t.remove :address
              end
            end
          end
        end
      RUBY
    end

    it 'does not register an offense' \
       'when the target of the alter method is another table' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          add_reference :users, :team
          add_column :users, :name, :string, null: false
          remove_column :teams, :owner_name
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including non-combinable alter method between' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          add_column :users, :name, :string, null: false
          add_reference :users, :team
          remove_column :users, :nickname
        end
      RUBY
    end

    it 'does not register an offense' \
       'when including a combinable alter method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          add_reference :users, :team
          add_column :users, :name, :string, null: false
        end
      RUBY
    end

    it 'does not register an offense when including an alter method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          add_column :users, :name, :string, null: false
        end
      RUBY
    end

    it 'does not register an offense when alter methods are inside of `if`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          if Rails.env.test?
            add_reference :users, :team
            add_column :users, :name, :string, null: true
            remove_column :users, :nickname
          else
            add_reference :users, :team
            add_column :users, :name, :string, null: false
            remove_column :users, :nickname
          end
        end
      RUBY
    end

    it 'does not register an offense when using empty migration' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class EmptyMigration < ActiveRecord::Migration[5.1]
          def change; end
        end
      RUBY
    end

    it 'register an offense when using string as table name' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          remove_index "users", :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_index "users", :address
        end
      RUBY
    end

    it 'register an offense when using mixed style table name' do
      expect_offense(<<-RUBY.strip_indent)
        def change
          remove_index "users", :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_index :users, :address
        end
      RUBY
    end

    it 'does not register an offense when using variables as table name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def change
          %w[owners members].each do |table|
            add_column table, :name, :string, null: false
          end
        end
      RUBY
    end
  end

  context 'when database is PostgreSQL' do
    let(:cop_config) do
      {
        'Database' => 'postgresql',
        'Include' => ['*']
      }
    end

    it_behaves_like 'offense'
    it_behaves_like 'no offense for mysql'
    it_behaves_like 'offense for postgresql'

    context 'with Rails 5.1' do
      let(:rails_version) { 5.1 }

      it_behaves_like 'no offense'
      it_behaves_like 'no offense for mysql'
      it_behaves_like 'no offense for postgresql'
    end
  end

  context 'when `database.yml` is exists' do
    let(:yaml) {}

    before do
      allow(File).to receive(:exist?)
        .with('config/database.yml')
        .and_return(true)
      allow(YAML).to receive(:load_file)
        .with('config/database.yml')
        .and_return(yaml)
    end

    context 'mysql2' do
      let(:yaml) do
        {
          'development' => {
            'adapter' => 'mysql2'
          }
        }
      end

      it_behaves_like 'offense for mysql'
    end

    context 'postgresql' do
      let(:yaml) do
        {
          'development' => {
            'adapter' => 'postgresql'
          }
        }
      end

      it_behaves_like 'offense for postgresql'
    end

    context 'invalid (e.g. ERB)' do
      before do
        allow(YAML).to receive(:load_file).with('config/database.yml') do
          YAML.parse('pool: <%= Rails.env.production? ? 10 : 5 %>')
        end
      end

      it_behaves_like 'no offense'
    end
  end
end
