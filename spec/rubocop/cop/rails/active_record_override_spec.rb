# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordOverride do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when overriding create' do
    expect_offense(<<-RUBY.strip_indent)
      class X < ApplicationRecord
        def create
        ^^^^^^^^^^ Use `before_create`, `around_create`, or `after_create` callbacks instead of overriding the Active Record method `create`.
          super
        end
      end
    RUBY
  end

  it 'registers an offense when overriding destroy' do
    expect_offense(<<-RUBY.strip_indent)
      class X < ApplicationRecord
        def destroy
        ^^^^^^^^^^^ Use `before_destroy`, `around_destroy`, or `after_destroy` callbacks instead of overriding the Active Record method `destroy`.
          super
        end
      end
    RUBY
  end

  it 'registers an offense when overriding save' do
    expect_offense(<<-RUBY.strip_indent)
      class X < ApplicationRecord
        def save
        ^^^^^^^^ Use `before_save`, `around_save`, or `after_save` callbacks instead of overriding the Active Record method `save`.
          super
        end
      end
    RUBY
  end

  it 'registers an offense when overriding update' do
    expect_offense(<<-RUBY.strip_indent)
      class X < ActiveModel::Base
        module_function

        def update
        ^^^^^^^^^^ Use `before_update`, `around_update`, or `after_update` callbacks instead of overriding the Active Record method `update`.
          super
        end
      end
    RUBY
  end

  context 'when overriding without a super call' do
    it 'registers no offense when overriding save' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class X < ApplicationRecord
          def save
            @a = 5
          end
        end
      RUBY
    end
  end

  context 'when class is not an ActiveRecord model' do
    it 'registers no offense when overriding save' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class X
          def save
            super
          end
        end
      RUBY
    end
  end

  context 'when class is not an ActiveRecord model' do
    it 'registers no offense when overriding save' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class X < Y
          def save
            super
          end
        end
      RUBY
    end
  end

  context 'when class has no parent specified' do
    it 'registers no offense when overriding save' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class X
          def initialize; end

          def save; end
        end
      RUBY
    end
  end
end
