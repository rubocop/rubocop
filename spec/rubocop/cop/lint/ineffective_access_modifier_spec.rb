# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::IneffectiveAccessModifier, :config do
  context 'when `private` is applied to a class method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class C
          private

          def self.method
          ^^^ `private` (on line 2) does not make singleton methods private. Use `private_class_method` or `private` inside a `class << self` block instead.
            puts "hi"
          end
        end
      RUBY
    end
  end

  context 'when `protected` is applied to a class method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class C
          protected

          def self.method
          ^^^ `protected` (on line 2) does not make singleton methods protected. Use `protected` inside a `class << self` block instead.
            puts "hi"
          end
        end
      RUBY
    end
  end

  context 'when `private_class_method` is used' do
    context 'when `private_class_method` contains all private method names' do
      it "doesn't register an offense" do
        expect_no_offenses(<<~RUBY)
          class C
            private

            def self.method
              puts "hi"
            end

            private_class_method :method
          end
        RUBY
      end
    end

    context 'when `private_class_method` does not contain the method' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class C
            private

            def self.method2
            ^^^ `private` (on line 2) does not make singleton methods private. Use `private_class_method` or `private` inside a `class << self` block instead.
              puts "hi"
            end

            private_class_method :method
          end
        RUBY
      end
    end
  end

  context 'when no access modifier is used' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        class C
          def self.method
            puts "hi"
          end

          def self.method2
            puts "hi"
          end
        end
      RUBY
    end
  end

  context 'when a `class << self` block is used' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        class C
          private

          class << self
            def self.method
              puts "hi"
            end
          end
        end
      RUBY
    end
  end

  context 'when there is an intervening instance method' do
    it 'still registers an offense' do
      expect_offense(<<~RUBY)
        class C

          private

          def instance_method
          end

          def self.method
          ^^^ `private` (on line 3) does not make singleton methods private. Use `private_class_method` or `private` inside a `class << self` block instead.
            puts "hi"
          end
        end
      RUBY
    end
  end

  context 'when there is `begin` before a method definition' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class C
          begin
          end

          def do_something
          end
        end
      RUBY
    end
  end
end
