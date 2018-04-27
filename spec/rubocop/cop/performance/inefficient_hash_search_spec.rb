# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::InefficientHashSearch do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a hash literal receives `keys.include?`' do
    expect_offense(<<-RUBY.strip_indent)
      { a: 1 }.keys.include? 1
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `#key?` instead of `#keys.include?`.
    RUBY
  end

  it 'registers an offense when an existing hash receives `keys.include?`' do
    expect_offense(<<-RUBY.strip_indent)
      h = { a: 1 }; h.keys.include? 1
                    ^^^^^^^^^^^^^^^^^ Use `#key?` instead of `#keys.include?`.
    RUBY
  end

  it 'registers an offense when a hash literal receives `values.include?`' do
    expect_offense(<<-RUBY.strip_indent)
      { a: 1 }.values.include? 1
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#value?` instead of `#values.include?`.
    RUBY
  end

  it 'registers an offense when an existing hash receives `values.include?`' do
    expect_offense(<<-RUBY.strip_indent)
      h = { a: 1 }; h.values.include? 1
                    ^^^^^^^^^^^^^^^^^^^ Use `#value?` instead of `#values.include?`.
    RUBY
  end

  it 'finds no offense when calling `include?` on an existing `keys` array' do
    expect_no_offenses(<<-RUBY.strip_indent)
      h = { a: 1 }; keys = h.keys ; keys.include? 1
    RUBY
  end

  it 'finds no offense when calling `include?` on an existing `values` array' do
    expect_no_offenses(<<-RUBY.strip_indent)
      h = { a: 1 }; values = h.values ; values.include? 1
    RUBY
  end

  context 'autocorrect' do
    context 'when using `keys.include?`' do
      it 'corrects to `key?`' do
        new_source = autocorrect_source('{ a: 1 }.keys.include?(1)')
        expect(new_source).to eq('{ a: 1 }.key?(1)')
      end

      it 'corrects when hash is not a literal' do
        new_source = autocorrect_source('h = { a: 1 }; h.keys.include?(1)')
        expect(new_source).to eq('h = { a: 1 }; h.key?(1)')
      end

      it 'gracefully handles whitespace' do
        new_source = autocorrect_source("{ a: 1 }.  keys.\ninclude?  1")
        expect(new_source).to eq('{ a: 1 }.key?(1)')
      end
    end

    context 'when using `values.include?`' do
      it 'corrects to `value?`' do
        new_source = autocorrect_source('{ a: 1 }.values.include?(1)')
        expect(new_source).to eq('{ a: 1 }.value?(1)')
      end

      it 'corrects when hash is not a literal' do
        new_source = autocorrect_source('h = { a: 1 }; h.values.include?(1)')
        expect(new_source).to eq('h = { a: 1 }; h.value?(1)')
      end

      it 'gracefully handles whitespace' do
        new_source = autocorrect_source("{ a: 1 }.  values.\ninclude?  1")
        expect(new_source).to eq('{ a: 1 }.value?(1)')
      end
    end
  end
end
