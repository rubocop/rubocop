# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HasManyOrHasOneDependent do
  subject(:cop) { described_class.new }

  context 'has_one' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_one :foo
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:dependent` strategy' do
      expect_offense(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_one :foo, class_name: 'bar'
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_one :foo, dependent: :destroy
        end
      RUBY
    end

    context 'with :through option' do
      it 'does not register an offense for non-nil value' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person < ApplicationRecord
            has_one :foo, through: :bar
          end
        RUBY
      end

      it 'registers an offense for nil value' do
        expect_offense(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_one :foo, through: nil
          ^^^^^^^ Specify a `:dependent` option.
        end
        RUBY
      end
    end

    context 'with_options dependent: :destroy' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_one :foo
            end
          end
        RUBY
      end

      it 'does not register an offense for using `class_name` option' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_one :foo, class_name: 'Foo'
            end
          end
        RUBY
      end
    end
  end

  context 'has_many' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_many :foo
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:dependent` strategy' do
      expect_offense(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_many :foo, class_name: 'bar'
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy' do
      expect_no_offenses('has_many :foo, dependent: :bar')
    end

    context 'with :through option' do
      it 'does not register an offense for non-nil value' do
        expect_no_offenses('has_many :foo, through: :bars')
      end

      it 'registers an offense for nil value' do
        expect_offense(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
          has_many :foo, through: nil
          ^^^^^^^^ Specify a `:dependent` option.
        end
        RUBY
      end
    end

    context 'Surrounded `with_options` block' do
      it 'registers an offense when `dependent: :destroy` is not present' do
        expect_offense(<<-RUBY.strip_indent)
          class Person < ApplicationRecord
            with_options through: nil do
              has_many :foo
              ^^^^^^^^ Specify a `:dependent` option.
            end
          end
        RUBY
      end

      it "doesn't register an offense for `with_options dependent: :destroy`" do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_many :foo
            end
          end
        RUBY
      end

      context 'Multiple associations' do
        it "doesn't register an offense for " \
           '`with_options dependent: :destroy`' do
          expect_no_offenses(<<-RUBY.strip_indent)
            class Person < ApplicationRecord
              with_options dependent: :destroy do
                has_many :foo
                has_many :bar
              end
            end
          RUBY
        end
      end
    end

    context 'Nested `with_options` block' do
      it 'does not register an offense when `dependent: :destroy` is present' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Article < ApplicationRecord
            with_options dependent: :destroy do
              has_many :tags
              with_options class_name: 'Tag' do
                has_many :special_tags, foreign_key: :special_id, inverse_of: :special
              end
            end
          end
        RUBY
      end
    end
  end

  context 'base-class check' do
    it 'registers an offense for `ActiveRecord::Base` class' do
      expect_offense(<<-RUBY.strip_indent)
        class Person < ActiveRecord::Base
          has_one :foo
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when using mix-in module that has ' \
       'an association of Active Record' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          extend ActiveSupport::Concern

          included do
            has_many :bazs
            ^^^^^^^^ Specify a `:dependent` option.
          end
        end
      RUBY
    end

    it 'does not register an offense when using associations of ' \
       'Active Resource' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class User < ActiveResource::Base
          has_many :projects, class_name: 'API::Project'
        end
      RUBY
    end
  end

  context 'when an Active Record model does not have any associations' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Person < ApplicationRecord
        end
      RUBY
    end
  end
end
