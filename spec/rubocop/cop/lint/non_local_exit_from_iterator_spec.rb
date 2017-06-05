# frozen_string_literal: true

describe RuboCop::Cop::Lint::NonLocalExitFromIterator do
  subject(:cop) { described_class.new }

  context 'inspection' do
    before do
      inspect_source(cop, source)
    end

    let(:message) do
      'Non-local exit from iterator, without return value. ' \
        '`next`, `break`, `Array#find`, `Array#any?`, etc. is preferred.'
    end

    shared_examples_for 'offense detector' do
      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(message)
        expect(cop.offenses.first.severity.name).to eq(:warning)
        expect(cop.highlights).to eq(['return'])
      end
    end

    context 'when block is followed by method chain' do
      context 'and has single argument' do
        let(:source) { <<-RUBY }
          items.each do |item|
            return if item.stock == 0
            item.update!(foobar: true)
          end
        RUBY

        it_behaves_like('offense detector')
        it { expect(cop.offenses.first.line).to eq(2) }
      end

      context 'and has multiple arguments' do
        let(:source) { <<-RUBY }
          items.each_with_index do |item, i|
            return if item.stock == 0
            item.update!(foobar: true)
          end
        RUBY

        it_behaves_like('offense detector')
        it { expect(cop.offenses.first.line).to eq(2) }
      end

      context 'and has no argument' do
        let(:source) { <<-RUBY }
          item.with_lock do
            return if item.stock == 0
            item.update!(foobar: true)
          end
        RUBY

        it { expect(cop.offenses).to be_empty }
      end
    end

    context 'when block is not followed by method chain' do
      let(:source) { <<-RUBY }
        transaction do
          return unless update_necessary?
          find_each do |item|
            return if item.stock == 0 # false-negative...
            item.update!(foobar: true)
          end
        end
      RUBY

      it { expect(cop.offenses).to be_empty }
    end

    context 'when block is lambda' do
      let(:source) { <<-RUBY }
        items.each(lambda do |item|
          return if item.stock == 0
          item.update!(foobar: true)
        end)
        items.each -> (item) {
          return if item.stock == 0
          item.update!(foobar: true)
        }
      RUBY

      it { expect(cop.offenses).to be_empty }
    end

    context 'when lambda is inside of block followed by method chain' do
      let(:source) { <<-RUBY }
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

      it { expect(cop.offenses).to be_empty }
    end

    context 'when block in middle of nest is followed by method chain' do
      let(:source) { <<-RUBY }
        transaction do
          return unless update_necessary?
          items.each do |item|
            return if item.nil?
            item.with_lock do
              return if item.stock == 0
              item.very_complicated_update_operation!
            end
          end
        end
      RUBY

      it 'registers offenses' do
        expect(cop.offenses.size).to eq(2)
        expect(cop.offenses[0].message).to eq(message)
        expect(cop.offenses[0].severity.name).to eq(:warning)
        expect(cop.offenses[0].line).to eq(4)
        expect(cop.offenses[1].message).to eq(message)
        expect(cop.offenses[1].severity.name).to eq(:warning)
        expect(cop.offenses[1].line).to eq(6)
        expect(cop.highlights).to eq(%w[return return])
      end
    end

    context 'when return with value' do
      let(:source) { <<-RUBY }
        def find_first_sold_out_item(items)
          items.each do |item|
            return item if item.stock == 0
            item.foobar!
          end
        end
      RUBY

      it { expect(cop.offenses).to be_empty }
    end

    context 'when the message is define_method' do
      let(:source) { <<-RUBY }
        [:method_one, :method_two].each do |method_name|
          define_method(method_name) do
            return if predicate?
          end
        end
      RUBY

      it { expect(cop.offenses).to be_empty }
    end

    context 'when the message is define_singleton_method' do
      let(:source) { <<-RUBY }
        str = 'foo'
        str.define_singleton_method :bar do |baz|
          return unless baz
          replace baz
        end
      RUBY

      it { expect(cop.offenses).to be_empty }
    end

    context 'when the return is within a nested method definition' do
      context 'with an instance method definition' do
        let(:source) { <<-RUBY }
          Foo.configure do |c|
            def bar
              return if baz?
            end
          end
        RUBY

        it { expect(cop.offenses).to be_empty }
      end

      context 'with a class method definition' do
        let(:source) { <<-RUBY }
          Foo.configure do |c|
            def self.bar
              return if baz?
            end
          end
        RUBY

        it { expect(cop.offenses).to be_empty }
      end
    end
  end
end
