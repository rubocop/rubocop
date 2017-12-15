# frozen_string_literal: true

describe RuboCop::Cop::Rails::RedundantReceiverInWithOptions, :config do
  subject(:cop) { described_class.new(config) }

  context 'rails >= 4.2' do
    let(:rails_version) { 4.2 }

    it 'registers an offense when using explicit receiver in `with_options`' do
      expect_offense(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :restrict_with_error do |assoc|
            assoc.has_many :customers
            ^^^^^ Redundant receiver in `with_options`.
            assoc.has_many :products
            ^^^^^ Redundant receiver in `with_options`.
            assoc.has_one :owner
            ^^^^^ Redundant receiver in `with_options`.
            assoc.belongs_to :company
            ^^^^^ Redundant receiver in `with_options`.
            assoc.has_and_belongs_to_many :clients
            ^^^^^ Redundant receiver in `with_options`.
          end
        end
      RUBY
    end

    it 'does not register an offense when using implicit receiver ' \
       'in `with_options`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :restrict_with_error do
            has_many :customers
            has_many :products
            has_one :owner
            belongs_to :company
            has_and_belongs_to_many :clients
          end
        end
      RUBY
    end

    it 'accepts with_options block that uses non-rails methods' do
      expect_no_offenses(<<-RUBY.strip_indent)
        with_options foo do |qux|
          qux.plants_seed
          qux.waters_soil
          qux.waits
          qux.watches_grow
        end
      RUBY
    end

    it 'autocorrects to implicit receiver in `with_options`' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :restrict_with_error do |assoc|
            assoc.has_many :customers
            assoc.has_many :products
            assoc.has_one :owner
            assoc.belongs_to :company
            has_and_belongs_to_many :clients
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :restrict_with_error do
            has_many :customers
            has_many :products
            has_one :owner
            belongs_to :company
            has_and_belongs_to_many :clients
          end
        end
      RUBY
    end
  end

  context 'rails <= 4.1' do
    let(:rails_version) { 4.1 }

    it 'accepts using explicit receiver in `with_options`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Account < ApplicationRecord
          with_options dependent: :restrict_with_error do |assoc|
            assoc.has_many :customers
            assoc.has_many :products
            assoc.has_one :owner
            assoc.belongs_to :company
            has_and_belongs_to_many :clients
          end
        end
      RUBY
    end
  end
end
