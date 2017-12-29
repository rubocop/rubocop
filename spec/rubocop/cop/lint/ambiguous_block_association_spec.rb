# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousBlockAssociation do
  subject(:cop) { described_class.new }

  let(:error_message) do
    'Parenthesize the param `%s` to make sure that the block will be ' \
      'associated with the `%s` method call.'
  end

  before { inspect_source(source) }

  shared_examples 'accepts' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses.empty?).to be(true)
    end
  end

  it_behaves_like 'accepts', 'foo == bar { baz a }'
  it_behaves_like 'accepts', 'foo ->(a) { bar a }'
  it_behaves_like 'accepts', 'some_method(a) { |el| puts el }'
  it_behaves_like 'accepts', 'some_method(a) do;puts a;end'
  it_behaves_like 'accepts', 'some_method a do;puts "dev";end'
  it_behaves_like 'accepts', 'some_method a do |e|;puts e;end'
  it_behaves_like 'accepts', 'Foo.bar(a) { |el| puts el }'
  it_behaves_like 'accepts', 'env ENV.fetch("ENV") { "dev" }'
  it_behaves_like 'accepts', 'env(ENV.fetch("ENV") { "dev" })'
  it_behaves_like 'accepts', '{ f: "b"}.fetch(:a) do |e|;puts e;end'
  it_behaves_like 'accepts', 'Hash[some_method(a) { |el| el }]'
  it_behaves_like 'accepts', 'foo = lambda do |diagnostic|;end'
  it_behaves_like 'accepts', 'Proc.new { puts "proc" }'
  it_behaves_like 'accepts', 'expect { order.save }.to(change { orders.size })'
  it_behaves_like 'accepts', 'scope :active, -> { where(status: "active") }'
  it_behaves_like(
    'accepts',
    'assert_equal posts.find { |p| p.title == "Foo" }, results.first'
  )
  it_behaves_like(
    'accepts',
    'assert_equal(posts.find { |p| p.title == "Foo" }, results.first)'
  )
  it_behaves_like(
    'accepts',
    'assert_equal(results.first, posts.find { |p| p.title == "Foo" })'
  )
  it_behaves_like(
    'accepts',
    'allow(cop).to receive(:on_int) { raise RuntimeError }'
  )
  it_behaves_like(
    'accepts',
    'allow(cop).to(receive(:on_int) { raise RuntimeError })'
  )

  context 'without parentheses' do
    context 'without receiver' do
      let(:source) { 'some_method a { |el| puts el }' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a { |el| puts el }', 'a'))
        )
      end
    end

    context 'with receiver' do
      let(:source) { 'Foo.some_method a { |el| puts el }' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a { |el| puts el }', 'a'))
        )
      end
    end

    context 'rspec expect {}.to change {}' do
      let(:source) do
        'expect { order.expire }.to change { order.events }'
      end

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'change { order.events }', 'change'))
        )
      end
    end

    context 'as a hash key' do
      let(:source) { 'Hash[some_method a { |el| el }]' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a { |el| el }', 'a'))
        )
      end
    end

    context 'with assignment' do
      let(:source) { 'foo = some_method a { |el| puts el }' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a { |el| puts el }', 'a'))
        )
      end
    end
  end
end
