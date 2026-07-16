# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MissingRespondToMissing, :config do
  it 'registers an offense when respond_to_missing? is not implemented' do
    expect_offense(<<~RUBY)
      class Test
        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'registers an offense when method_missing is implemented as a class methods' do
    expect_offense(<<~RUBY)
      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? implemented as instance methods' do
    expect_no_offenses(<<~RUBY)
      class Test
        def respond_to_missing?
        end

        def method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? implemented as class methods' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.respond_to_missing?
        end

        def self.method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? when defined with inline access modifier' do
    expect_no_offenses(<<~RUBY)
      class Test
        private def respond_to_missing?
        end

        private def method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? when defined with inline access modifier and ' \
     'method_missing is not qualified by inline access modifier' do
    expect_no_offenses(<<~RUBY)
      class Test
        private def respond_to_missing?
        end

        def method_missing
        end
      end
    RUBY
  end

  it 'registers an offense respond_to_missing? is implemented as ' \
     'an instance method and method_missing is implemented as a class method' do
    expect_offense(<<~RUBY)
      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end

        def respond_to_missing?
        end
      end
    RUBY
  end

  it 'registers an offense respond_to_missing? is implemented as ' \
     'a class method and method_missing is implemented as an instance method' do
    expect_offense(<<~RUBY)
      class Test
        def self.respond_to_missing?
        end

        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'registers an offense when respond_to_missing? is defined only in a sibling class' do
    expect_offense(<<~RUBY)
      class Outer
        class A
          def method_missing(name)
          ^^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
          end
        end

        class B
          def respond_to_missing?(name, include_private = false)
            super
          end
        end
      end
    RUBY
  end

  it 'allows top-level method_missing and respond_to_missing?' do
    expect_no_offenses(<<~RUBY)
      def respond_to_missing?(name, include_private = false)
        super
      end

      def method_missing(name)
      end
    RUBY
  end

  it 'registers an offense for a top-level method_missing without respond_to_missing?' do
    expect_offense(<<~RUBY)
      def method_missing(name)
      ^^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
      end
    RUBY
  end

  context 'with a project index', :project_index do
    def index_with_current(source, sources = {})
      build_index(sources.merge('file:///current.rb' => source))
    end

    it 'does not register an offense when `respond_to_missing?` is defined in a reopening in another file' do
      source = <<~RUBY
        class Tool
          def method_missing(name, *args)
            super
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///other.rb' => <<~OTHER
          class Tool
            def respond_to_missing?(name, include_private = false)
              true
            end
          end
        OTHER
      )

      expect_no_offenses(source, 'current.rb')
    end

    it 'registers an offense when `respond_to_missing?` is not defined in any definition site' do
      source = <<~RUBY
        class Tool
          def method_missing(name, *args)
            super
          end
        end
      RUBY
      cop.project_index = index_with_current(source, 'file:///other.rb' => "class Tool\nend\n")

      expect_offense(<<~RUBY, 'current.rb')
        class Tool
          def method_missing(name, *args)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
            super
          end
        end
      RUBY
    end

    it 'registers an offense when only a different class defines `respond_to_missing?`' do
      source = <<~RUBY
        class Tool
          def method_missing(name, *args)
            super
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///other.rb' => <<~OTHER
          class Other
            def respond_to_missing?(name, include_private = false)
              true
            end
          end
        OTHER
      )

      expect_offense(<<~RUBY, 'current.rb')
        class Tool
          def method_missing(name, *args)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
            super
          end
        end
      RUBY
    end

    it 'registers an offense when only an ancestor defines `respond_to_missing?`' do
      source = <<~RUBY
        class Tool < Base
          def method_missing(name, *args)
            super
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///base.rb' => <<~OTHER
          class Base
            def respond_to_missing?(name, include_private = false)
              true
            end
          end
        OTHER
      )

      expect_offense(<<~RUBY, 'current.rb')
        class Tool < Base
          def method_missing(name, *args)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
            super
          end
        end
      RUBY
    end

    it 'does not register an offense for a singleton `method_missing` with a singleton ' \
       '`respond_to_missing?` in a reopening' do
      source = <<~RUBY
        class Tool
          def self.method_missing(name, *args)
            super
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///other.rb' => <<~OTHER
          class Tool
            def self.respond_to_missing?(name, include_private = false)
              true
            end
          end
        OTHER
      )

      expect_no_offenses(source, 'current.rb')
    end

    it 'registers an offense for a singleton `method_missing` when only an instance ' \
       '`respond_to_missing?` exists in a reopening' do
      source = <<~RUBY
        class Tool
          def self.method_missing(name, *args)
            super
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///other.rb' => <<~OTHER
          class Tool
            def respond_to_missing?(name, include_private = false)
              true
            end
          end
        OTHER
      )

      expect_offense(<<~RUBY, 'current.rb')
        class Tool
          def self.method_missing(name, *args)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
            super
          end
        end
      RUBY
    end
  end
end
