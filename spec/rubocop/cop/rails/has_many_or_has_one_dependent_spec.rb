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

    context 'with :through option' do
      it 'does not register an offense for non-nil value' do
        expect_no_offenses('has_one :foo, through: :bar')
      end

      it 'registers an offense for nil value' do
        expect_offense(<<-RUBY.strip_indent)
        class Person
          has_one :foo, through: nil
          ^^^^^^^ Specify a `:dependent` option.
        end
        RUBY
      end
    end

    context 'with_options dependent: :destroy' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person
            with_options dependent: :destroy do
              has_one :foo
            end
          end
        RUBY
      end

      it 'does not register an offense for using `class_name` option' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person
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

    context 'with :through option' do
      it 'does not register an offense for non-nil value' do
        expect_no_offenses('has_many :foo, through: :bars')
      end

      it 'registers an offense for nil value' do
        expect_offense(<<-RUBY.strip_indent)
        class Person
          has_many :foo, through: nil
          ^^^^^^^^ Specify a `:dependent` option.
        end
        RUBY
      end
    end

    context 'Surrounded `with_options` block' do
      it 'registers an offense when `dependent: :destroy` is not present' do
        expect_offense(<<-RUBY.strip_indent)
          class Person
            with_options through: nil do
              has_many :foo
              ^^^^^^^^ Specify a `:dependent` option.
            end
          end
        RUBY
      end

      it "doesn't register an offense for `with_options dependent: :destroy`" do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Person
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
            class Person
              with_options dependent: :destroy do
                has_many :foo
                has_many :bar
              end
            end
          RUBY
        end
      end
    end
  end
end
