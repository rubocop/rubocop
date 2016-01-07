# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::FixedSize do
  subject(:cop) { described_class.new }

  shared_examples :common_functionality do |method|
    context 'strings' do
      it "registers an offense when calling #{method} on a single quoted " \
         'string' do
        inspect_source(cop, "'a'.#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on a double quoted " \
         'string' do
        inspect_source(cop, "\"a\".#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on a %q string" do
        inspect_source(cop, "%q(a).#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on a %Q string" do
        inspect_source(cop, "%Q(a).#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on a % string" do
        inspect_source(cop, "%(a).#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "accepts calling #{method} on a double quoted string that " \
         'contains interpolation' do
        inspect_source(cop, "\"\#{foo}\".#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on a %Q string that contains " \
         'interpolation' do
        inspect_source(cop, "\%Q(\#{foo}).#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on a % string that contains " \
         'interpolation' do
        inspect_source(cop, "\%(\#{foo}).#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on a single quoted string that " \
         'is assigned to a constant' do
        inspect_source(cop, "CONST = 'a'.#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on a double quoted string that " \
         'is assigned to a constant' do
        inspect_source(cop, "CONST = \"a\".#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on a %q string that is assigned to " \
         'a constant' do
        inspect_source(cop, "CONST = %q(a).#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on a variable " do
        inspect_source(cop, ['foo = "abc"',
                             "foo.#{method}"])

        expect(cop.messages).to be_empty
      end
    end

    context 'symbols' do
      it "registers an offense when calling #{method} on a symbol" do
        inspect_source(cop, ":foo.#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on a quoted symbol" do
        inspect_source(cop, ":'foo-bar'.#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "accepts calling #{method} on an interpolated quoted symbol" do
        inspect_source(cop, ":\"foo-\#{bar}\".#{method}")

        expect(cop.messages).to be_empty
      end

      it "registers an offense when calling #{method} on %s" do
        inspect_source(cop, "%s(foo-bar).#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "accepts calling #{method} on a symbol that is assigned " \
         'to a constant' do
        inspect_source(cop, "CONST = :foo.#{method}")

        expect(cop.messages).to be_empty
      end
    end

    context 'arrays' do
      it "registers an offense when calling #{method} on an array using []" do
        inspect_source(cop, "[1, 2, foo].#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on an array using %w" do
        inspect_source(cop, "%w(1, 2, foo).#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "registers an offense when calling #{method} on an array using %W" do
        inspect_source(cop, "%W(1, 2, foo).#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "accepts calling #{method} on an array using [] that contains " \
         'a splat' do
        inspect_source(cop, "[1, 2, *foo].#{method}")

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on array that is set to a variable" do
        inspect_source(cop, ['foo = [1, 2, 3]',
                             "foo.#{method}"])

        expect(cop.messages).to be_empty
      end

      it "accepts calling #{method} on an array that is assigned " \
         'to a constant' do
        inspect_source(cop, "CONST = [1, 2, 3].#{method}")

        expect(cop.messages).to be_empty
      end
    end

    context 'hashes' do
      it "registers an offense when calling #{method} on a hash using {}" do
        inspect_source(cop, "{a: 1, b: 2}.#{method}")

        expect(cop.messages).to eq([described_class::MSG])
      end

      it "accepts calling #{method} on a hash set to a variable" do
        inspect_source(cop, ['foo = {a: 1, b: 2}',
                             "foo.#{method}"])

        expect(cop.messages).to be_empty
      end

      context 'ruby >= 2.0', :ruby20 do
        it "accepts calling #{method} on a hash that contains a double splat" do
          inspect_source(cop, "{a: 1, **foo}.#{method}")

          expect(cop.messages).to be_empty
        end
      end

      it "accepts calling #{method} on an hash that is assigned " \
         'to a constant' do
        inspect_source(cop, "CONST = {a: 1, b: 2}.#{method}")

        expect(cop.messages).to be_empty
      end
    end
  end

  it_behaves_like :common_functionality, 'size'
  it_behaves_like :common_functionality, 'length'
  it_behaves_like :common_functionality, 'count'

  shared_examples :count_with_arguments do |variable|
    it 'accepts calling count with a variable' do
      inspect_source(cop, "#{variable}.count(bar)")

      expect(cop.messages).to be_empty
    end

    it 'accepts calling count with an instance variable' do
      inspect_source(cop, "#{variable}.count(@bar)")

      expect(cop.messages).to be_empty
    end

    it 'registers an offense when calling count with a string' do
      inspect_source(cop, "#{variable}.count('o')")

      expect(cop.messages).to eq([described_class::MSG])
    end

    it 'accepts calling count with a block' do
      inspect_source(cop, "#{variable}.count { |v| v == 'a' }")

      expect(cop.messages).to be_empty
    end

    it 'accepts calling count with a symbol proc' do
      inspect_source(cop, "#{variable}.count(&:any?) ")

      expect(cop.messages).to be_empty
    end
  end

  it_behaves_like :count_with_arguments, '"foo"'
  it_behaves_like :count_with_arguments, '[1, 2, 3]'
  it_behaves_like :count_with_arguments, '{a: 1, b: 2}'
end
