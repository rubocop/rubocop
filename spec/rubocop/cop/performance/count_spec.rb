# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::Count do
  subject(:cop) { described_class.new }

  shared_examples 'selectors' do |selector|
    it "registers an offense for using array.#{selector}...size" do
      inspect_source(cop, "[1, 2, 3].#{selector} { |e| e.even? }.size")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...size`."])
    end

    it "registers an offense for using hash.#{selector}...size" do
      inspect_source(cop, "{a: 1, b: 2, c: 3}.#{selector} { |e| e == :a }.size")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...size`."])
    end

    it "registers an offense for using array.#{selector}...length" do
      inspect_source(cop, "[1, 2, 3].#{selector} { |e| e.even? }.length")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...length`."])
    end

    it "registers an offense for using hash.#{selector}...length" do
      inspect_source(cop, "{a: 1, b: 2}.#{selector} { |e| e == :a }.length")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...length`."])
    end

    it "registers an offense for using array.#{selector}...count" do
      inspect_source(cop, "[1, 2, 3].#{selector} { |e| e.even? }.count")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
    end

    it "registers an offense for using hash.#{selector}...count" do
      inspect_source(cop, "{a: 1, b: 2}.#{selector} { |e| e == :a }.count")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
    end

    it "allows usage of #{selector}...count with a block" do
      inspect_source(cop,
                     "[1, 2, 3].#{selector} { |e| e.odd? }.count { |e| e > 2 }")

      expect(cop.messages).to be_empty
    end

    it "allows usage of #{selector}...count with a block" do
      source = "{a: 1, b: 2}.#{selector} { |e| e == :a }.count { |e| e > 2 }"
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it "allows usage of #{selector}!...size" do
      inspect_source(cop,
                     "[1, 2, 3].#{selector}! { |e| e.odd? }.size")

      expect(cop.messages).to be_empty
    end

    it "allows usage of #{selector}!...count" do
      inspect_source(cop,
                     "[1, 2, 3].#{selector}! { |e| e.odd? }.count")

      expect(cop.messages).to be_empty
    end

    it "allows usage of #{selector}!...length" do
      inspect_source(cop,
                     "[1, 2, 3].#{selector}! { |e| e.odd? }.length")

      expect(cop.messages).to be_empty
    end

    it "allows usage of #{selector} without getting the size" do
      inspect_source(cop, "[1, 2, 3].#{selector} { |e| e.even? }")

      expect(cop.messages).to be_empty
    end
  end

  it_behaves_like('selectors', 'select')
  it_behaves_like('selectors', 'reject')

  it 'allows usage of another method with size' do
    inspect_source(cop, '[1, 2, 3].map { |e| e + 1 }.size')

    expect(cop.messages).to be_empty
  end

  it 'allows usage of size on an array' do
    inspect_source(cop, '[1, 2, 3].size')

    expect(cop.messages).to be_empty
  end

  it 'allows usage of count on an array' do
    inspect_source(cop, '[1, 2, 3].count')

    expect(cop.messages).to be_empty
  end

  context 'autocorrect' do
    it 'corrects select..size to count' do
      new_source = autocorrect_source(cop, '[1, 2].select { |e| e > 2 }.size')

      expect(new_source).to eq('[1, 2].count { |e| e > 2 }')
    end

    it 'corrects select..count without a block to count' do
      new_source = autocorrect_source(cop, '[1, 2].select { |e| e > 2 }.count')

      expect(new_source).to eq('[1, 2].count { |e| e > 2 }')
    end

    it 'corrects select..length to count' do
      new_source = autocorrect_source(cop, '[1, 2].select { |e| e > 2 }.length')

      expect(new_source).to eq('[1, 2].count { |e| e > 2 }')
    end

    it 'will not correct reject...size' do
      new_source = autocorrect_source(cop, '[1, 2].reject { |e| e > 2 }.size')

      expect(new_source).to eq('[1, 2].reject { |e| e > 2 }.size')
    end

    it 'will not correct reject...count' do
      new_source = autocorrect_source(cop, '[1, 2].reject { |e| e > 2 }.count')

      expect(new_source).to eq('[1, 2].reject { |e| e > 2 }.count')
    end

    it 'will not correct reject...length' do
      new_source = autocorrect_source(cop, '[1, 2].reject { |e| e > 2 }.length')

      expect(new_source).to eq('[1, 2].reject { |e| e > 2 }.length')
    end

    it 'will not correct select...count when count has a block' do
      source = '[1, 2].select { |e| e > 2 }.count { |e| e.even? }'
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(source)
    end
  end
end
