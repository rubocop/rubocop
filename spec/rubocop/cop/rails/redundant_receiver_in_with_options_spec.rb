# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantReceiverInWithOptions, :config do
  subject(:cop) { described_class.new(config) }

  context 'rails >= 4.2' do
    let(:rails_version) { 4.2 }

    it 'registers an offense when using explicit receiver in `with_options`' do
      expect_offense(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :destroy do |assoc|
            assoc.has_many :customers
            ^^^^^ Redundant receiver in `with_options`.
            assoc.has_many :products
            ^^^^^ Redundant receiver in `with_options`.
            assoc.has_many :invoices
            ^^^^^ Redundant receiver in `with_options`.
            assoc.has_many :expenses
            ^^^^^ Redundant receiver in `with_options`.
          end
        end
      RUBY
    end

    it 'does not register an offense when using inplicit receiver ' \
       'in `with_options`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :destroy do
            has_many :customers
            has_many :products
            has_many :invoices
            has_many :expenses
          end
        end
      RUBY
    end

    it 'registers an offense when including multiple redendant receivers ' \
       'in single line' do
      expect_offense(<<-RUBY.strip_indent)
        with_options options: false do |merger|
          merger.invoke(merger.something)
          ^^^^^^ Redundant receiver in `with_options`.
                        ^^^^^^ Redundant receiver in `with_options`.
        end
      RUBY
    end

    it 'does not register an offense when including method invocations ' \
       'to different receivers' do
      expect_no_offenses(<<-RUBY.strip_indent)
        client = ApplicationClient.new
        with_options options: false do |merger|
          client.invoke(merger.something, something)
        end
      RUBY
    end

    it 'autocorrects to implicit receiver in `with_options`' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :destroy do |assoc|
            assoc.has_many :customers
            assoc.has_many :products
            assoc.has_many :invoices
            assoc.has_many :expenses
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :destroy do
            has_many :customers
            has_many :products
            has_many :invoices
            has_many :expenses
          end
        end
      RUBY
    end

    it 'autocorrects to implicit receiver when including multiple receivers' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        with_options options: false do |merger|
          merger.invoke(merger.something)
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        with_options options: false do
          invoke(something)
        end
      RUBY
    end

    it 'does not register an offense when including block node' \
       'in `with_options`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        with_options options: false do |merger|
          merger.invoke
          with_another_method do |another_receiver|
            merger.invoke(another_receiver)
          end
        end
      RUBY
    end
  end

  context 'rails <= 4.1' do
    let(:rails_version) { 4.1 }

    it 'registers an offense when using explicit receiver in `with_options`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :destroy do |assoc|
            assoc.has_many :customers
            assoc.has_many :products
            assoc.has_many :invoices
            assoc.has_many :expenses
          end
        end
      RUBY
    end
  end
end
