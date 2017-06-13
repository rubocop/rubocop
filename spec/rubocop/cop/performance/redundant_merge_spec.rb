# frozen_string_literal: true

describe RuboCop::Cop::Performance::RedundantMerge, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'MaxKeyValuePairs' => 2 }
  end

  it 'autocorrects hash.merge!(a: 1)' do
    new_source = autocorrect_source('hash.merge!(a: 1)')
    expect(new_source).to eq 'hash[:a] = 1'
  end

  it 'autocorrects hash.merge!("abc" => "value")' do
    new_source = autocorrect_source('hash.merge!("abc" => "value")')
    expect(new_source).to eq 'hash["abc"] = "value"'
  end

  context 'when receiver is a local variable' do
    it 'autocorrects hash.merge!(a: 1, b: 2)' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        hash = {}
        hash.merge!(a: 1, b: 2)
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        hash = {}
        hash[:a] = 1
        hash[:b] = 2
      RUBY
    end
  end

  context 'when receiver is a method call' do
    it "doesn't autocorrect hash.merge!(a: 1, b: 2)" do
      new_source = autocorrect_source('hash.merge!(a: 1, b: 2)')
      expect(new_source).to eq('hash.merge!(a: 1, b: 2)')
    end
  end

  context 'when receiver is implicit' do
    it "doesn't autocorrect" do
      new_source = autocorrect_source('merge!(foo: 1, bar: 2)')
      expect(new_source).to eq('merge!(foo: 1, bar: 2)')
    end
  end

  context 'when any argument is a double splat' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo.merge!(baz: qux, **bar)
      RUBY
    end
  end

  context 'when internal to each_with_object' do
    it 'autocorrects when the receiver is the object being built' do
      source = <<-RUBY.strip_indent
        foo.each_with_object({}) do |f, hash|
          hash.merge!(a: 1, b: 2)
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo.each_with_object({}) do |f, hash|
          hash[:a] = 1
          hash[:b] = 2
        end
      RUBY
    end

    it 'autocorrects when the receiver is the object being built when ' \
       'merge! is the last statement' do
      source = <<-RUBY.strip_indent
        foo.each_with_object({}) do |f, hash|
          some_method
          hash.merge!(a: 1, b: 2)
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo.each_with_object({}) do |f, hash|
          some_method
          hash[:a] = 1
          hash[:b] = 2
        end
      RUBY
    end

    it 'autocorrects when the receiver is the object being built when ' \
       'merge! is not the last statement' do
      source = <<-RUBY.strip_indent
        foo.each_with_object({}) do |f, hash|
          hash.merge!(a: 1, b: 2)
          why_are_you_doing_this?
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo.each_with_object({}) do |f, hash|
          hash[:a] = 1
          hash[:b] = 2
          why_are_you_doing_this?
        end
      RUBY
    end

    it 'does not register an offense when merge! is being assigned inside ' \
       'each_with_object' do
      source = <<-RUBY.strip_indent
        foo.each_with_object({}) do |f, hash|
          changes = hash.merge!(a: 1, b: 2)
          why_are_you_doing_this?
        end
      RUBY
      inspect_source(source)

      expect(cop.offenses).to be_empty
    end

    it 'autocorrects when receiver uses element reference to the object ' \
       'built by each_with_object' do
      source = <<-RUBY.strip_indent
        foo.each_with_object(bar) do |f, hash|
          hash[:a].merge!(b: "")
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo.each_with_object(bar) do |f, hash|
          hash[:a][:b] = ""
        end
      RUBY
    end

    it 'autocorrects when receiver uses multiple element references to the ' \
       'object built by each_with_object' do
      source = <<-RUBY.strip_indent
        foo.each_with_object(bar) do |f, hash|
          hash[:a][:b].merge!(c: "")
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo.each_with_object(bar) do |f, hash|
          hash[:a][:b][:c] = ""
        end
      RUBY
    end

    it 'autocorrects merge! called on any method on the object built ' \
       'by each_with_object' do
      source = <<-RUBY.strip_indent
        foo.each_with_object(bar) do |f, hash|
          hash.bar.merge!(c: "")
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo.each_with_object(bar) do |f, hash|
          hash.bar[:c] = ""
        end
      RUBY
    end
  end

  %w[if unless while until].each do |kw|
    context "when there is a modifier #{kw}, and more than 1 pair" do
      it "autocorrects it to an #{kw} block" do
        new_source = autocorrect_source(
          <<-RUBY.strip_indent
            hash = {}
            hash.merge!(a: 1, b: 2) #{kw} condition1 && condition2
          RUBY
        )
        expect(new_source).to eq(<<-RUBY.strip_indent)
          hash = {}
          #{kw} condition1 && condition2
            hash[:a] = 1
            hash[:b] = 2
          end
        RUBY
      end

      context 'when original code was indented' do
        it 'maintains proper indentation' do
          new_source = autocorrect_source(
            <<-RUBY.strip_indent
              hash = {}
              begin
                hash.merge!(a: 1, b: 2) #{kw} condition1
              end
            RUBY
          )
          expect(new_source).to eq(<<-RUBY.strip_indent)
            hash = {}
            begin
              #{kw} condition1
                hash[:a] = 1
                hash[:b] = 2
              end
            end
          RUBY
        end
      end
    end
  end

  context 'when code is indented, and there is more than 1 pair' do
    it 'indents the autocorrected code properly' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        hash = {}
        begin
          hash.merge!(a: 1, b: 2)
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        hash = {}
        begin
          hash[:a] = 1
          hash[:b] = 2
        end
      RUBY
    end
  end

  it "doesn't register an error when return value is used" do
    expect_no_offenses(<<-RUBY.strip_indent)
      variable = hash.merge!(a: 1)
      puts variable
    RUBY
  end

  it 'formats the error message correctly for hash.merge!(a: 1)' do
    expect_offense(<<-RUBY.strip_indent)
      hash.merge!(a: 1)
      ^^^^^^^^^^^^^^^^^ Use `hash[:a] = 1` instead of `hash.merge!(a: 1)`.
    RUBY
  end

  context 'with MaxKeyValuePairs of 1' do
    let(:cop_config) do
      { 'MaxKeyValuePairs' => 1 }
    end

    it "doesn't register errors for multi-value hash merges" do
      expect_no_offenses(<<-RUBY.strip_indent)
        hash = {}
        hash.merge!(a: 1, b: 2)
      RUBY
    end
  end
end
