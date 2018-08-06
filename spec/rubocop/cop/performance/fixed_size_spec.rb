# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::FixedSize do
  subject(:cop) { described_class.new }

  let(:message) do
    'Do not compute the size of statically sized objects.'
  end

  shared_examples 'common functionality' do |method|
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
        expect_no_offenses("\"\#{foo}\".#{method}")
      end

      it "accepts calling #{method} on a %Q string that contains " \
         'interpolation' do
        expect_no_offenses("\%Q(\#{foo}).#{method}")
      end

      it "accepts calling #{method} on a % string that contains " \
         'interpolation' do
        expect_no_offenses("\%(\#{foo}).#{method}")
      end

      it "accepts calling #{method} on a single quoted string that " \
         'is assigned to a constant' do
        expect_no_offenses("CONST = 'a'.#{method}")
      end

      it "accepts calling #{method} on a double quoted string that " \
         'is assigned to a constant' do
        expect_no_offenses("CONST = \"a\".#{method}")
      end

      it "accepts calling #{method} on a %q string that is assigned to " \
         'a constant' do
        expect_no_offenses("CONST = %q(a).#{method}")
      end

      it "accepts calling #{method} on a variable " do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = "abc"
          foo.#{method}
        RUBY
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
        expect_no_offenses(":\"foo-\#{bar}\".#{method}")
      end

      it "registers an offense when calling #{method} on %s" do
        inspect_source("%s(foo-bar).#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on a symbol that is assigned " \
         'to a constant' do
        expect_no_offenses("CONST = :foo.#{method}")
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
        expect_no_offenses("[1, 2, *foo].#{method}")
      end

      it "accepts calling #{method} on array that is set to a variable" do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = [1, 2, 3]
          foo.#{method}
        RUBY
      end

      it "accepts calling #{method} on an array that is assigned " \
         'to a constant' do
        expect_no_offenses("CONST = [1, 2, 3].#{method}")
      end
    end

    context 'hashes' do
      it "registers an offense when calling #{method} on a hash using {}" do
        inspect_source("{a: 1, b: 2}.#{method}")

        expect(cop.messages).to eq([message])
      end

      it "accepts calling #{method} on a hash set to a variable" do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = {a: 1, b: 2}
          foo.#{method}
        RUBY
      end

      it "accepts calling #{method} on a hash that contains a double splat" do
        expect_no_offenses("{a: 1, **foo}.#{method}")
      end

      it "accepts calling #{method} on an hash that is assigned " \
         'to a constant' do
        expect_no_offenses("CONST = {a: 1, b: 2}.#{method}")
      end
    end
  end

  it_behaves_like 'common functionality', 'size'
  it_behaves_like 'common functionality', 'length'
  it_behaves_like 'common functionality', 'count'

  shared_examples 'count with arguments' do |variable|
    it 'accepts calling count with a variable' do
      expect_no_offenses("#{variable}.count(bar)")
    end

    it 'accepts calling count with an instance variable' do
      expect_no_offenses("#{variable}.count(@bar)")
    end

    it 'registers an offense when calling count with a string' do
      inspect_source("#{variable}.count('o')")

      expect(cop.messages).to eq([message])
    end

    it 'accepts calling count with a block' do
      expect_no_offenses("#{variable}.count { |v| v == 'a' }")
    end

    it 'accepts calling count with a symbol proc' do
      expect_no_offenses("#{variable}.count(&:any?) ")
    end
  end

  it_behaves_like 'count with arguments', '"foo"'
  it_behaves_like 'count with arguments', '[1, 2, 3]'
  it_behaves_like 'count with arguments', '{a: 1, b: 2}'
end
