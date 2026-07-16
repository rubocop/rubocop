# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantConstantBase, :config do
  let(:other_cops) { { 'Lint/ConstantResolution' => { 'Enabled' => false } } }

  context 'with prefixed constant in class' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          ::Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant in module' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        module Foo
          ::Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant in neither class nor module' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Bar
        ^^ Remove redundant `::`.
      RUBY

      expect_correction(<<~RUBY)
        Bar
      RUBY
    end
  end

  context 'with prefixed nested constant in neither class nor module' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Bar::Baz
        ^^ Remove redundant `::`.
      RUBY

      expect_correction(<<~RUBY)
        Bar::Baz
      RUBY
    end
  end

  context 'with prefixed constant in sclass' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class << self
          ::Bar
          ^^ Remove redundant `::`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class << self
          Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant as super class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class Foo < ::Bar
                    ^^ Remove redundant `::`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant and prefixed super class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class Foo < ::Bar
                    ^^ Remove redundant `::`.
          ::A
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Bar
          ::A
        end
      RUBY
    end
  end

  context 'when `Lint/ConstantResolution` is disabling' do
    let(:other_cops) { { 'Lint/ConstantResolution' => { 'Enabled' => true } } }

    context 'with prefixed constant in neither class nor module' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          ::Bar
        RUBY
      end
    end
  end

  context 'with a project index', :project_index do
    def build_index(sources)
      graph = Rubydex::Graph.new
      sources.each { |uri, source| graph.index_source(uri, source, 'ruby') }
      graph.resolve
      graph
    end

    def index_with_current(source, sources = {})
      build_index(sources.merge('file:///current.rb' => source))
    end

    it 'registers an offense inside a namespace when nothing shadows the constant' do
      source = <<~RUBY
        module App
          def self.load
            ::Config.load
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source, 'file:///config.rb' => "class Config\nend\n"
      )

      expect_offense(<<~RUBY, 'current.rb')
        module App
          def self.load
            ::Config.load
            ^^ Remove redundant `::`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module App
          def self.load
            Config.load
          end
        end
      RUBY
    end

    it 'does not register an offense when the namespace shadows the constant' do
      source = <<~RUBY
        module App
          def self.load
            ::Config.load
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///config.rb' => "class Config\nend\n",
        'file:///app_config.rb' => "module App\n  class Config\n  end\nend\n"
      )

      expect_no_offenses(source, 'current.rb')
    end

    it 'does not register an offense when the constant is not in the index' do
      source = <<~RUBY
        module App
          def self.parse(json)
            ::JSON.parse(json)
          end
        end
      RUBY
      cop.project_index = index_with_current(source)

      expect_no_offenses(source, 'current.rb')
    end
  end
end
