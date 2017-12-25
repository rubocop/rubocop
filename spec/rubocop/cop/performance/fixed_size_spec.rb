# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::FixedSize do
  subject(:cop) { described_class.new }

  let(:message) do
    'Do not compute the size of statically sized objects.'
  end

  shared_examples :common_functionality do |method|
    context 'strings' do
      it "registers an offense when calling #{method} on a single quoted " \
         'string' do
        inspect_source("'a'.#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on a double quoted " \
         'string' do
        inspect_source("\"a\".#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on a %q string" do
        inspect_source("%q(a).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on a %Q string" do
        inspect_source("%Q(a).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on a % string" do
        inspect_source("%(a).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on a double quoted string that " \
         'contains interpolation' do
        inspect_source("\"\#{foo}\".#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a %Q string that contains " \
         'interpolation' do
        inspect_source("\%Q(\#{foo}).#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a % string that contains " \
         'interpolation' do
        inspect_source("\%(\#{foo}).#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a single quoted string that " \
         'is assigned to a constant' do
        inspect_source("CONST = 'a'.#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a double quoted string that " \
         'is assigned to a constant' do
        inspect_source("CONST = \"a\".#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a %q string that is assigned to " \
         'a constant' do
        inspect_source("CONST = %q(a).#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a variable " do
        inspect_source(<<-RUBY.strip_indent)
          foo = "abc"
          foo.#{method}
        RUBY

        expect(cop.messages.empty?).to be(true)
      end
    end

    context 'symbols' do
      it "registers an offense when calling #{method} on a symbol" do
        inspect_source(":foo.#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on a quoted symbol" do
        inspect_source(":'foo-bar'.#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on an interpolated quoted symbol" do
        inspect_source(":\"foo-\#{bar}\".#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "registers an offense when calling #{method} on %s" do
        inspect_source("%s(foo-bar).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on a symbol that is assigned " \
         'to a constant' do
        inspect_source("CONST = :foo.#{method}")

        expect(cop.messages.empty?).to be(true)
      end
    end

    context 'arrays' do
      it "registers an offense when calling #{method} on an array using []" do
        inspect_source("[1, 2, foo].#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on an array using %w" do
        inspect_source("%w(1, 2, foo).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "registers an offense when calling #{method} on an array using %W" do
        inspect_source("%W(1, 2, foo).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on an array using [] that contains " \
         'a splat' do
        inspect_source("[1, 2, *foo].#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on array that is set to a variable" do
        inspect_source(<<-RUBY.strip_indent)
          foo = [1, 2, 3]
          foo.#{method}
        RUBY

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on an array that is assigned " \
         'to a constant' do
        inspect_source("CONST = [1, 2, 3].#{method}")

        expect(cop.messages.empty?).to be(true)
      end
    end

    context 'hashes' do
      it "registers an offense when calling #{method} on a hash using {}" do
        inspect_source("{a: 1, b: 2}.#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on a hash set to a variable" do
        inspect_source(<<-RUBY.strip_indent)
          foo = {a: 1, b: 2}
          foo.#{method}
        RUBY

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on a hash that contains a double splat" do
        inspect_source("{a: 1, **foo}.#{method}")

        expect(cop.messages.empty?).to be(true)
      end

      it "accepts calling #{method} on an hash that is assigned " \
         'to a constant' do
        inspect_source("CONST = {a: 1, b: 2}.#{method}")

        expect(cop.messages.empty?).to be(true)
      end
    end
  end

  it_behaves_like :common_functionality, 'size'
  it_behaves_like :common_functionality, 'length'
  it_behaves_like :common_functionality, 'count'

  shared_examples :count_with_arguments do |variable|
    it 'accepts calling count with a variable' do
      inspect_source("#{variable}.count(bar)")

      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts calling count with an instance variable' do
      inspect_source("#{variable}.count(@bar)")

      expect(cop.messages.empty?).to be(true)
    end

    it 'registers an offense when calling count with a string' do
      inspect_source("#{variable}.count('o')")

      expect(cop.messages).to eq([message])
    end

    it 'accepts calling count with a block' do
      inspect_source("#{variable}.count { |v| v == 'a' }")

      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts calling count with a symbol proc' do
      inspect_source("#{variable}.count(&:any?) ")

      expect(cop.messages.empty?).to be(true)
    end
  end

  it_behaves_like :count_with_arguments, '"foo"'
  it_behaves_like :count_with_arguments, '[1, 2, 3]'
  it_behaves_like :count_with_arguments, '{a: 1, b: 2}'
end
