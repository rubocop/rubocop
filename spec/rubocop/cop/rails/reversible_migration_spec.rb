# frozen_string_literal: true

describe RuboCop::Cop::Rails::ReversibleMigration do
  subject(:cop) { described_class.new }

  let(:source) do
    <<-RUBY
      class ExampleMigration < ActiveRecord::Migration
        def change
          #{code}
        end
      end
    RUBY
  end

  shared_examples :accepts do |name, code|
    let(:code) { code }

    it "accepts usages of #{name}" do
      inspect_source(cop, source)

      expect(cop.offenses).to be_empty
    end
  end

  shared_examples :offense do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(cop, source)

      expect(cop.messages).to eq(["#{name} is not reversible."])
    end
  end

  it_behaves_like :accepts, 'create_table', <<-RUBY
    create_table :users do |t|
      t.string :name
    end
  RUBY

  it_behaves_like :offense, 'change_table', <<-RUBY
    change_table :users do |t|
      t.column :name, :string
    end
  RUBY

  context 'within block' do
    it_behaves_like :accepts, 'create_table', <<-RUBY
      [:users, :articles].each do |table|
        create_table table do |t|
          t.string :name
        end
      end
    RUBY

    it_behaves_like :offense, 'change_table', <<-RUBY
      [:users, :articles].each do |table|
        change_table table do |t|
          t.column :name, :string
        end
      end
    RUBY
  end

  context 'within #reversible' do
    it_behaves_like :accepts, 'change_table', <<-RUBY
      reversible do |dir|
        change_table :users do |t|
          dir.up do
            t.column :name, :string
          end

          dir.down do
            t.remove :name
          end
        end
      end
    RUBY
  end

  context 'drop_table' do
    it_behaves_like :accepts, 'drop_table(with block)', <<-RUBY
      drop_table :users do |t|
        t.string :name
      end
    RUBY

    it_behaves_like :offense, 'drop_table(without block)', <<-RUBY
      drop_table :users
    RUBY
  end

  context 'change_column_default' do
    it_behaves_like :accepts,
                    'change_column_default(with :from and :to)', <<-RUBY
      change_column_default(:posts, :state, from: nil, to: "draft")
    RUBY

    it_behaves_like :offense,
                    'change_column_default(without :from and :to)', <<-RUBY
      change_column_default(:suppliers, :qualification, 'new')
    RUBY
  end

  context 'remove_column' do
    it_behaves_like :accepts, 'remove_column(with type)', <<-RUBY
      remove_column(:suppliers, :qualification, :string)
    RUBY

    it_behaves_like :accepts, 'remove_column(with type and options)', <<-RUBY
      remove_column(:suppliers, :qualification, :string, null: false)
    RUBY

    it_behaves_like :offense, 'remove_column(without type)', <<-RUBY
      remove_column(:suppliers, :qualification)
    RUBY
  end

  context 'remove_foreign_key' do
    it_behaves_like :accepts, 'remove_foreign_key(with table)', <<-RUBY
      remove_foreign_key :accounts, :branches
    RUBY

    it_behaves_like :offense, 'remove_foreign_key(without table)', <<-RUBY
      remove_foreign_key :accounts, column: :owner_id
    RUBY
  end
end
