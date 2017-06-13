# frozen_string_literal: true

describe RuboCop::Cop::Performance::CompareWithBlock do
  subject(:cop) { described_class.new }

  shared_examples 'compare with block' do |method|
    it "registers an offense for #{method}" do
      inspect_source("array.#{method} { |a, b| a.foo <=> b.foo }")
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for #{method} with [:foo]" do
      inspect_source("array.#{method} { |a, b| a[:foo] <=> b[:foo] }")
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for #{method} with ['foo']" do
      inspect_source("array.#{method} { |a, b| a['foo'] <=> b['foo'] }")
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for #{method} with [1]" do
      inspect_source("array.#{method} { |a, b| a[1] <=> b[1] }")
      expect(cop.offenses.size).to eq(1)
    end

    it 'highlights compare method' do
      inspect_source("array.#{method} { |a, b| a.foo <=> b.foo }")
      expect(cop.highlights).to eq(["#{method} { |a, b| a.foo <=> b.foo }"])
    end

    it "accepts valid #{method} usage" do
      inspect_source("array.#{method} { |a, b| b <=> a }")
      expect(cop.offenses).to be_empty
    end

    it "accepts #{method}_by" do
      inspect_source("array.#{method}_by { |a| a.baz }")
    end

    it "autocorrects array.#{method} { |a, b| a.foo <=> b.foo }" do
      new_source =
        autocorrect_source("array.#{method} { |a, b| a.foo <=> b.foo }")
      expect(new_source).to eq "array.#{method}_by(&:foo)"
    end

    it "autocorrects array.#{method} { |a, b| a.bar <=> b.bar }" do
      new_source =
        autocorrect_source("array.#{method} { |a, b| a.bar <=> b.bar }")
      expect(new_source).to eq "array.#{method}_by(&:bar)"
    end

    it "autocorrects array.#{method} { |x, y| x.foo <=> y.foo }" do
      new_source =
        autocorrect_source("array.#{method} { |x, y| x.foo <=> y.foo }")
      expect(new_source).to eq "array.#{method}_by(&:foo)"
    end

    it "autocorrects array.#{method} do |a, b| a.foo <=> b.foo end" do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        array.#{method} do |a, b|
          a.foo <=> b.foo
        end
      RUBY
      expect(new_source).to eq "array.#{method}_by(&:foo)\n"
    end

    it "autocorrects array.#{method} { |a, b| a[:foo] <=> b[:foo] }" do
      new_source = autocorrect_source(
        "array.#{method} { |a, b| a[:foo] <=> b[:foo] }"
      )
      expect(new_source).to eq "array.#{method}_by { |a| a[:foo] }"
    end

    it "autocorrects array.#{method} { |a, b| a['foo'] <=> b['foo'] }" do
      new_source = autocorrect_source(
        "array.#{method} { |a, b| a['foo'] <=> b['foo'] }"
      )
      expect(new_source).to eq "array.#{method}_by { |a| a['foo'] }"
    end

    it "autocorrects array.#{method} { |a, b| a[1] <=> b[1] }" do
      new_source = autocorrect_source(
        "array.#{method} { |a, b| a[1] <=> b[1] }"
      )
      expect(new_source).to eq "array.#{method}_by { |a| a[1] }"
    end

    it 'formats the error message correctly for ' \
      "array.#{method} { |a, b| a.foo <=> b.foo }" do
      inspect_source("array.#{method} { |a, b| a.foo <=> b.foo }")
      expect(cop.messages).to eq(["Use `#{method}_by(&:foo)` instead of " \
                                  "`#{method} { |a, b| a.foo <=> b.foo }`."])
    end

    it 'formats the error message correctly for ' \
      "array.#{method} { |a, b| a[:foo] <=> b[:foo] }" do
      inspect_source("array.#{method} { |a, b| a[:foo] <=> b[:foo] }")
      expected = ["Use `#{method}_by { |a| a[:foo] }` instead of " \
                  "`#{method} { |a, b| a[:foo] <=> b[:foo] }`."]
      expect(cop.messages).to eq(expected)
    end
  end

  include_examples 'compare with block', 'sort'
  include_examples 'compare with block', 'max'
  include_examples 'compare with block', 'min'
end
