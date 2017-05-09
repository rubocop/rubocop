# frozen_string_literal: true

describe RuboCop::Cop::Rails::NotNullColumn, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Include' => nil } }

  context 'with add_column call' do
    context 'with null: false' do
      let(:source) { 'add_column :users, :name, :string, null: false' }
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          add_column :users, :name, :string, null: false
                                             ^^^^^^^^^^^ Do not add a NOT NULL column without a default value.
        RUBY
      end
    end

    context 'with null: false and default' do
      let(:source) do
        'add_column :users, :name, :string, null: false, default: ""'
      end
      include_examples 'accepts'
    end

    context 'with null: false and default: nil' do
      let(:source) do
        'add_column :users, :name, :string, null: false, default: nil'
      end
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          add_column :users, :name, :string, null: false, default: nil
                                             ^^^^^^^^^^^ Do not add a NOT NULL column without a default value.
        RUBY
      end
    end

    context 'with null: true' do
      let(:source) { 'add_column :users, :name, :string, null: true' }
      include_examples 'accepts'
    end

    context 'without any options' do
      let(:source) { 'add_column :users, :name, :string' }
      include_examples 'accepts'
    end
  end

  context 'with change_column call' do
    let(:source) do
      <<-END.strip_indent
        add_column :users, :name, :string
        User.update_all(name: "dummy")
        change_column :users, :name, :string, null: false
      END
    end
    include_examples 'accepts'
  end

  context 'with create_table call' do
    let(:source) do
      <<-END.strip_indent
        class CreateUsersTable < ActiveRecord::Migration
          def change
            create_table :users do |t|
              t.string :name, null: false
              t.timestamps null: false
            end
          end
        end
      END
    end
    include_examples 'accepts'
  end

  context 'with add_reference call' do
    context 'with null: false' do
      let(:source) { 'add_reference :products, :category, null: false' }
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          add_reference :products, :category, null: false
                                              ^^^^^^^^^^^ Do not add a NOT NULL column without a default value.
        RUBY
      end
    end

    context 'with default option' do
      let(:source) do
        'add_reference :products, :category, null: false, default: 1'
      end
      include_examples 'accepts'
    end

    context 'without any options' do
      let(:source) { 'add_reference :products, :category' }
      include_examples 'accepts'
    end
  end
end
