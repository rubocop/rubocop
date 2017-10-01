# frozen_string_literal: true

describe RuboCop::Cop::Rails::IndexTrue, :config do
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
      inspect_source(cop, source)

      expect(cop.offenses).to be_empty
    end
  end

  shared_examples :offense do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(cop, source)

      expect(cop.messages.any?).to eq(true)
    end
  end

  context 'when add_column statement contains `index: true`' do
    let(:code) do
      'add_column :books, :author_id, :integer, index: true'
    end

    it 'adds an offense when an add_column statement contains `index: true`' do
      expect_offense(<<-RUBY.strip_indent)
        add_column :books, :author_id, :integer, index: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `index: true` does not work in an `add_column` or `change_column` method. Please use `add_index :table, :column`.
      RUBY
    end
  end

  context 'when add_column statement does not contain `index: true`' do
    let(:source) do
      'add_column :books, :author_id, :integer'
    end

    it 'doest not add any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        add_column :books, :author_id, :integer
      RUBY
    end
  end

  context 'when change_column statement contains `index: true`' do
    let(:code) do
      'change_column :books, :author_id, :integer, index: true'
    end

    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        change_column :books, :author_id, :integer, index: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `index: true` does not work in an `add_column` or `change_column` method. Please use `add_index :table, :column`.
      RUBY
    end
  end

  context 'when add_column statement does not contain `index: true`' do
    let(:source) do
      'change_column :books, :author_id, :integer'
    end

    it 'does not add any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        change_column :books, :author_id, :integer
      RUBY
    end
  end
end
