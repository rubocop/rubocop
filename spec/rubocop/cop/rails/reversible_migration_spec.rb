# frozen_string_literal: true

describe RuboCop::Cop::Rails::ReversibleMigration, :config do
  subject(:cop) { described_class.new(config) }

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
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples :offense do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(source)

      expect(cop.messages).to eq(["#{name} is not reversible."])
    end
  end

  it_behaves_like :accepts, 'create_table', <<-RUBY
    create_table :users do |t|
      t.string :name
    end
  RUBY

  it_behaves_like :offense, 'execute', <<-RUBY
    execute "ALTER TABLE `pages_linked_pages` ADD UNIQUE `page_id_linked_page_id` (`page_id`,`linked_page_id`)"
  RUBY

  context 'within block' do
    it_behaves_like :accepts, 'create_table', <<-RUBY
      [:users, :articles].each do |table|
        create_table table do |t|
          t.string :name
        end
      end
    RUBY

    it_behaves_like :offense, 'execute', <<-RUBY
      [:pages_linked_pages, :pages_unlinked_pages].each do |table|
        execute "ALTER TABLE `table` ADD UNIQUE `page_id_linked_page_id` (`page_id`,`linked_page_id`)"
      end
    RUBY
  end

  context 'within #reversible' do
    it_behaves_like :accepts, 'execute', <<-RUBY
      reversible do |dir|
        dir.up do
          execute "ALTER TABLE `pages_linked_pages` ADD UNIQUE `page_id_linked_page_id` (`page_id`,`linked_page_id`)"
        end

        dir.down do
          execute "ALTER TABLE `pages_linked_pages` DROP INDEX `page_id_linked_page_id`"
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

  context 'change_table' do
    context 'Rails < 4.0', :rails3 do
      it_behaves_like :offense, 'change_table', <<-RUBY
        change_table :users do |t|
          t.column :name, :string
          t.text :description
          t.boolean :authorized
        end
      RUBY

      it_behaves_like :offense, 'change_table', <<-RUBY
        change_table :users do |t|
          t.change :description, :text
        end
      RUBY

      it_behaves_like :offense, 'change_table', <<-RUBY
        change_table :users do |t|
          t.change_default :authorized, 1
        end
      RUBY

      it_behaves_like :offense, 'change_table', <<-RUBY
        change_table :users do |t|
          t.remove :qualification
        end
      RUBY
    end

    context 'Rails >= 4.0', :rails4 do
      it_behaves_like :accepts, 'change_table(with reversible calls)', <<-RUBY
        change_table :users do |t|
          t.column :name, :string
          t.text :description
          t.boolean :authorized
        end
      RUBY

      it_behaves_like :offense, 'change_table(with change)', <<-RUBY
        change_table :users do |t|
          t.change :description, :text
        end
      RUBY

      it_behaves_like :offense, 'change_table(with change_default)', <<-RUBY
        change_table :users do |t|
          t.change_default :authorized, 1
        end
      RUBY

      it_behaves_like :offense, 'change_table(with remove)', <<-RUBY
        change_table :users do |t|
          t.remove :qualification
        end
      RUBY
    end
  end
end
