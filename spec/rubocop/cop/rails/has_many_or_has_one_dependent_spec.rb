# frozen_string_literal: true

describe RuboCop::Cop::Rails::HasManyOrHasOneDependent do
  subject(:cop) { described_class.new }

  context 'has_one' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_one :foo
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:dependent` strategy' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_one :foo, class_name: 'bar'
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy' do
      expect_no_offenses('has_one :foo, dependent: :bar')
    end
  end

  context 'has_many' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_many :foo
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:dependent` strategy' do
      expect_offense(<<-RUBY.strip_indent)
        class Person
          has_many :foo, class_name: 'bar'
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy' do
      expect_no_offenses('has_many :foo, dependent: :bar')
    end
  end
end
