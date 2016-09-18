# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::NotNullColumn, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Include' => nil } }

  before do
    inspect_source(cop, source)
  end

  context 'with add_column call' do
    context 'with null: false' do
      let(:source) { 'add_column :users, :name, :string, null: false' }
      it 'reports an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(
          ['Do not add a NOT NULL column without a default value']
        )
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
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(
          ['Do not add a NOT NULL column without a default value']
        )
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
      [
        'add_column :users, :name, :string',
        'User.update_all(name: "dummy")',
        'change_column :users, :name, :string, null: false'
      ]
    end
    include_examples 'accepts'
  end

  context 'with create_table call' do
    let(:source) do
      ['class CreateUsersTable < ActiveRecord::Migration',
       '  def change',
       '    create_table :users do |t|',
       '      t.string :name, null: false',
       '      t.timestamps null: false',
       '    end',
       '  end',
       'end']
    end
    include_examples 'accepts'
  end
end
