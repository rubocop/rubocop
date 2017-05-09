# frozen_string_literal: true

describe RuboCop::Cop::Lint::IneffectiveAccessModifier do
  subject(:cop) { described_class.new }

  context 'when `private` is applied to a class method' do
    let(:source) do
      <<-END.strip_indent
        class C
          private

          def self.method
            puts "hi"
          end
        end
      END
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
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
    let(:source) do
      <<-END.strip_indent
        class C
          protected

          def self.method
            puts "hi"
          end
        end
      END
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
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
    let(:source) do
      <<-END.strip_indent
        class C
          private

          def self.method
            puts "hi"
          end

          private_class_method :method
        end
      END
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when a `class << self` block is used' do
    let(:source) do
      <<-END.strip_indent
        class C
          private

          class << self
            def self.method
              puts "hi"
            end
          end
        end
      END
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when there is an intervening instance method' do
    let(:source) do
      <<-END.strip_indent
        class C

          private

          def instance_method
          end

          def self.method
            puts "hi"
          end
        end
      END
    end

    it 'still registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
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
end
