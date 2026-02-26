# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NonLocalExitFromIterator, :config do
  context 'when block is followed by method chain' do
    context 'and has single argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          items.each do |item|
            return if item.stock == 0
            ^^^^^^ Non-local exit from iterator, [...]
            item.update!(foobar: true)
          end
        RUBY
      end
    end

    context 'and has multiple arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          items.each_with_index do |item, i|
            return if item.stock == 0
            ^^^^^^ Non-local exit from iterator, [...]
            item.update!(foobar: true)
          end
        RUBY
      end
    end

    context 'and has no argument' do
      it 'allows' do
        expect_no_offenses(<<~RUBY)
          item.with_lock do
            return if item.stock == 0
            item.update!(foobar: true)
          end
        RUBY
      end
    end
  end

  context 'when block is not followed by method chain' do
    it 'allows' do
      expect_no_offenses(<<~RUBY)
        transaction do
          return unless update_necessary?
          find_each do |item|
            return if item.stock == 0 # false-negative...
            item.update!(foobar: true)
          end
        end
      RUBY
    end
  end

  context 'when block is lambda' do
    it 'allows' do
      expect_no_offenses(<<~RUBY)
        items.each(lambda do |item|
          return if item.stock == 0
          item.update!(foobar: true)
        end)
        items.each -> (item) {
          return if item.stock == 0
          item.update!(foobar: true)
        }
      RUBY
    end
  end

  context 'when lambda is inside of block followed by method chain' do
    it 'allows' do
      expect_no_offenses(<<~RUBY)
        RSpec.configure do |config|
          # some configuration

          if Gem.loaded_specs["paper_trail"].version < Gem::Version.new("4.0.0")
            current_behavior = ActiveSupport::Deprecation.behavior
            ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
              return if message =~ /foobar/
              Array.wrap(current_behavior).each do |behavior|
                behavior.call(message, callstack)
              end
            end

            # more configuration
          end
        end
      RUBY
    end
  end

  context 'when block in middle of nest is followed by method chain' do
    it 'registers offenses' do
      expect_offense(<<~RUBY)
        transaction do
          return unless update_necessary?
          items.each do |item|
            return if item.nil?
            ^^^^^^ Non-local exit from iterator, [...]
            item.with_lock do
              return if item.stock == 0
              ^^^^^^ Non-local exit from iterator, [...]
              item.very_complicated_update_operation!
            end
          end
        end
      RUBY
    end
  end

  it 'allows return with value' do
    expect_no_offenses(<<~RUBY)
      def find_first_sold_out_item(items)
        items.each do |item|
          return item if item.stock == 0
          item.foobar!
        end
      end
    RUBY
  end

  it 'allows return in define_method' do
    expect_no_offenses(<<~RUBY)
      [:method_one, :method_two].each do |method_name|
        define_method(method_name) do
          return if predicate?
        end
      end
    RUBY
  end

  it 'allows return in define_singleton_method' do
    expect_no_offenses(<<~RUBY)
      str = 'foo'
      str.define_singleton_method :bar do |baz|
        return unless baz
        replace baz
      end
    RUBY
  end

  context 'when the return is within a nested method definition' do
    it 'allows return in an instance method definition' do
      expect_no_offenses(<<~RUBY)
        Foo.configure do |c|
          def bar
            return if baz?
          end
        end
      RUBY
    end

    it 'allows return in a class method definition' do
      expect_no_offenses(<<~RUBY)
        Foo.configure do |c|
          def self.bar
            return if baz?
          end
        end
      RUBY
    end
  end
end
