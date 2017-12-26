# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::InverseOf do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'with scope' do
    it 'registers an offense when not specifying `:inverse_of`' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_one :foo, -> () { where(bar: true) }
          ^^^^^^^ Specify an `:inverse_of` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:inverse_of`' do
      expect_no_offenses(
        'has_many :foo, -> () { where(bar: true) }, inverse_of: false'
      )
    end
  end

  context 'with option preventing automatic inverse' do
    it 'registers an offense when not specifying `:inverse_of`' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          belongs_to :foo, foreign_key: 'foo_id'
          ^^^^^^^^^^ Specify an `:inverse_of` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:inverse_of`' do
      expect_no_offenses(
        "has_one :foo, foreign_key: 'foo_id', inverse_of: :bar"
      )
    end

    it 'does not register an offense with `:inverse_of` as first option' do
      expect_no_offenses(
        "has_one :foo, inverse_of: :bar, foreign_key: 'foo_id'"
      )
    end

    it 'registers an offense with other option and `:inverse_of` unset' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_many :foo, dependent: :destroy, foreign_key: 'foo_id'
          ^^^^^^^^ Specify an `:inverse_of` option.
        end
      RUBY
    end

    it 'registers an offense when including `class_name` option' do
      expect_offense(<<-RUBY.strip_indent)
        class Book < ApplicationRecord
          belongs_to :author, class_name: "Patron"
          ^^^^^^^^^^ Specify an `:inverse_of` option.
        end
      RUBY
    end

    it 'registers an offense when including `conditions` option' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_many :foo, conditions: -> { where(bar: true) }
          ^^^^^^^^ Specify an `:inverse_of` option.
        end
      RUBY
    end
  end

  context 'with scope and options' do
    it 'registers an offense when not specifying `:inverse_of`' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_many :foo, -> { group 'x' }, dependent: :destroy
          ^^^^^^^^ Specify an `:inverse_of` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:inverse_of`' do
      expect_no_offenses(
        "has_many :foo, -> { group 'x' }, dependent: :destroy, inverse_of: :baz"
      )
    end
  end

  context '`:as` option' do
    context 'Rails < 5.2', :rails5 do
      it 'registers an offense when not specifying `:inverse_of`' do
        expect_offense(<<-RUBY.strip_indent)
          class Person
            has_many :pictures, as: :imageable
            ^^^^^^^^ Specify an `:inverse_of` option.
          end
        RUBY
      end
    end

    context 'Rails >= 5.2', :config do
      let(:rails_version) { 5.2 }

      it 'does not register an offense when not specifying `:inverse_of`' do
        expect_no_offenses(
          'has_many :pictures, as: :imageable'
        )
      end
    end
  end

  context 'with no options' do
    it 'does not register an offense' do
      expect_no_offenses('has_one :foo')
    end
  end

  context 'with other options' do
    it 'does not register an offense' do
      expect_no_offenses('has_one :foo, dependent: :nullify')
    end
  end

  context 'with option ignoring `:inverse_of`' do
    it 'does not register an offense when including `through` option' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Physician < ApplicationRecord
          has_many :appointments
          has_many :patients, -> () { where(bar: true) }, through: :appointments
        end
      RUBY
    end

    it 'does not register an offense when including `polymorphic` option' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Picture < ApplicationRecord
          belongs_to :imageable, -> () { where(bar: true) }, polymorphic: true
        end
      RUBY
    end
  end

  context 'with valid options in `with_options`' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Person
          with_options inverse_of: false do
            has_one :foo, -> () { where(bar: true) }
          end
        end
      RUBY
    end

    it 'does not register an offense when using the explicit receiver' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Person
          with_options inverse_of: :bar do |assoc|
            assoc.belongs_to :foo, foreign_key: 'foo_id'
          end
        end
      RUBY
    end

    it 'registers an offense when using the invalid explicit receiver' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          with_options inverse_of: :bar do |_assoc|
            belongs_to :foo, foreign_key: 'foo_id'
            ^^^^^^^^^^ Specify an `:inverse_of` option.
          end
        end
      RUBY
    end

    it 'does not register an offense when using multiple blocks' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Book < ApplicationRecord
          with_options inverse_of: :book do
            with_helper do |helper|
              helper.define_assoc
              with_options class_name: "Patron" do
                belongs_to :author
              end
            end
          end
        end
      RUBY
    end
  end

  context 'with invalid options in `with_options`' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          with_options class_name: "hoge" do
            has_one :foo
            ^^^^^^^ Specify an `:inverse_of` option.
          end
        end
      RUBY
    end

    it 'registers an offense when using the explicit receiver' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          with_options class_name: "baz" do |assoc|
            assoc.belongs_to :foo, foreign_key: 'foo_id'
                  ^^^^^^^^^^ Specify an `:inverse_of` option.
          end
        end
      RUBY
    end

    it 'registers an offense when using multiple blocks' do
      expect_offense(<<-RUBY.strip_indent)
        class Book < ApplicationRecord
          with_options class_name: "Patron" do
            with_helper do |helper|
              helper.define_assoc
              with_options foreign_key: "patron_id" do
                belongs_to :author
                ^^^^^^^^^^ Specify an `:inverse_of` option.
              end
            end
          end
        end
      RUBY
    end
  end
end
