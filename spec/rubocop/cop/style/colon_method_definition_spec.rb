# frozen_string_literal: true

describe RuboCop::Cop::Style::ColonMethodDefinition do
  subject(:cop) { described_class.new }

  it 'accepts a class method defined using .' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo
        def self.bar
          something
        end
      end
    RUBY
  end

  context 'using self' do
    it 'registers an offense for a class method defined using ::' do
      expect_offense(<<-RUBY.strip_indent)
        class Foo
          def self::bar
                  ^^ Do not use `::` for defining class methods.
            something
          end
        end
      RUBY
    end

    it 'corrects :: to .' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class Foo
          def self::bar
            something
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class Foo
          def self.bar
            something
          end
        end
      RUBY
    end
  end

  context 'using the class name' do
    it 'registers an offense for a class method defined using ::' do
      expect_offense(<<-RUBY.strip_indent)
        class Foo
          def Foo::bar
                 ^^ Do not use `::` for defining class methods.
            something
          end
        end
      RUBY
    end

    it 'corrects :: to .' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class Foo
          def Foo::bar
            something
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class Foo
          def Foo.bar
            something
          end
        end
      RUBY
    end
  end
end
