# frozen_string_literal: true

describe RuboCop::Cop::Performance::Size do
  subject(:cop) { described_class.new }

  it 'does not register an offense when calling count ' \
     'as a stand alone method' do
    inspect_source(cop, 'count(items)')

    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when calling count on an object ' \
     'other than an array or a hash' do
    inspect_source(cop, 'object.count(items)')

    expect(cop.messages).to be_empty
  end

  describe 'on array' do
    it 'registers an offense when calling count' do
      expect_offense(<<-RUBY.strip_indent)
        [1, 2, 3].count
                  ^^^^^ Use `size` instead of `count`.
      RUBY
    end

    it 'registers an offense when calling count on to_a' do
      expect_offense(<<-RUBY.strip_indent)
        (1..3).to_a.count
                    ^^^^^ Use `size` instead of `count`.
      RUBY
    end

    it 'registers an offense when calling count on Array[]' do
      expect_offense(<<-RUBY.strip_indent)
        Array[*1..5].count
                     ^^^^^ Use `size` instead of `count`.
      RUBY
    end

    it 'does not register an offense when calling size' do
      expect_no_offenses('[1, 2, 3].size')
    end

    it 'does not register an offense when calling another method' do
      expect_no_offenses('[1, 2, 3].each')
    end

    it 'does not register an offense when calling count with a block' do
      expect_no_offenses('[1, 2, 3].count { |e| e > 3 }')
    end

    it 'does not register an offense when calling count with a to_proc block' do
      expect_no_offenses('[1, 2, 3].count(&:nil?)')
    end

    it 'does not register an offense when calling count with an argument' do
      expect_no_offenses('[1, 2, 3].count(1)')
    end

    it 'corrects count to size' do
      new_source = autocorrect_source(cop, '[1, 2, 3].count')

      expect(new_source).to eq('[1, 2, 3].size')
    end

    it 'corrects count to size on to_a' do
      new_source = autocorrect_source(cop, '(1..3).to_a.count')

      expect(new_source).to eq('(1..3).to_a.size')
    end

    it 'corrects count to size on Array[]' do
      new_source = autocorrect_source(cop, 'Array[*1..5].count')

      expect(new_source).to eq('Array[*1..5].size')
    end
  end

  describe 'on hash' do
    it 'registers an offense when calling count' do
      expect_offense(<<-RUBY.strip_indent)
        {a: 1, b: 2, c: 3}.count
                           ^^^^^ Use `size` instead of `count`.
      RUBY
    end

    it 'registers an offense when calling count on to_h' do
      expect_offense(<<-RUBY.strip_indent)
        [[:foo, :bar], [1, 2]].to_h.count
                                    ^^^^^ Use `size` instead of `count`.
      RUBY
    end

    it 'registers an offense when calling count on Hash[]' do
      expect_offense(<<-RUBY.strip_indent)
        Hash[*('a'..'z')].count
                          ^^^^^ Use `size` instead of `count`.
      RUBY
    end

    it 'does not register an offense when calling size' do
      expect_no_offenses('{a: 1, b: 2, c: 3}.size')
    end

    it 'does not register an offense when calling another method' do
      expect_no_offenses('{a: 1, b: 2, c: 3}.each')
    end

    it 'does not register an offense when calling count with a block' do
      expect_no_offenses('{a: 1, b: 2, c: 3}.count { |e| e > 3 }')
    end

    it 'does not register an offense when calling count with a to_proc block' do
      expect_no_offenses('{a: 1, b: 2, c: 3}.count(&:nil?)')
    end

    it 'does not register an offense when calling count with an argument' do
      expect_no_offenses('{a: 1, b: 2, c: 3}.count(1)')
    end

    it 'corrects count to size' do
      new_source = autocorrect_source(cop, '{a: 1, b: 2, c: 3}.count')

      expect(new_source).to eq('{a: 1, b: 2, c: 3}.size')
    end

    it 'corrects count to size on to_h' do
      new_source = autocorrect_source(cop, '[[:foo, :bar], [1, 2]].to_h.count')

      expect(new_source).to eq('[[:foo, :bar], [1, 2]].to_h.size')
    end

    it 'corrects count to size on Hash[]' do
      new_source = autocorrect_source(cop, "Hash[*('a'..'z')].count")

      expect(new_source).to eq("Hash[*('a'..'z')].size")
    end
  end
end
