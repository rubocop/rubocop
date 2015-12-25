# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::StringReplacement do
  subject(:cop) { described_class.new }

  it 'accepts methods other than gsub' do
    inspect_source(cop, "'abc'.insert(2, 'a')")

    expect(cop.messages).to be_empty
  end

  shared_examples 'accepts' do |method|
    context 'non deterministic parameters' do
      it 'accepts gsub when the length of the pattern is greater than 1' do
        inspect_source(cop, "'abc'.#{method}('ab', 'de')")

        expect(cop.messages).to be_empty
      end

      it 'accepts the first param being a variable' do
        inspect_source(cop, ['regex = /a/',
                             "'abc'.#{method}(regex, '1')"])

        expect(cop.messages).to be_empty
      end

      it 'accepts the second param being a variable' do
        inspect_source(cop, ["replacement = 'e'",
                             "'abc'.#{method}('abc', replacement)"])

        expect(cop.messages).to be_empty
      end

      it 'accepts the both params being a variables' do
        inspect_source(cop, ['regex = /a/',
                             "replacement = 'e'",
                             "'abc'.#{method}(regex, replacement)"])

        expect(cop.messages).to be_empty
      end

      it 'accepts gsub with only one param' do
        inspect_source(cop, "'abc'.#{method}('a')")

        expect(cop.messages).to be_empty
      end

      it 'accepts gsub with a block' do
        inspect_source(cop, "'abc'.#{method}('a') { |s| s.upcase } ")

        expect(cop.messages).to be_empty
      end

      it 'accepts a pattern with string interpolation' do
        inspect_source(cop, ["foo = 'a'",
                             "'abc'.#{method}(\"\#{foo}\", '1')"])

        expect(cop.messages).to be_empty
      end

      it 'accepts a replacement with string interpolation' do
        inspect_source(cop, ["foo = '1'",
                             "'abc'.#{method}('a', \"\#{foo}\")"])

        expect(cop.messages).to be_empty
      end

      it 'allows empty regex literal pattern' do
        inspect_source(cop, "'abc'.#{method}(//, '1')")

        expect(cop.messages).to be_empty
      end

      it 'allows empty regex pattern from string' do
        inspect_source(cop, "'abc'.#{method}(Regexp.new(''), '1')")

        expect(cop.messages).to be_empty
      end

      it 'allows empty regex pattern from regex' do
        inspect_source(cop, "'abc'.#{method}(Regexp.new(//), '1')")

        expect(cop.messages).to be_empty
      end

      it 'allows regex literals with options' do
        inspect_source(cop, "'abc'.#{method}(/a/i, '1')")

        expect(cop.messages).to be_empty
      end

      it 'allows regex with options' do
        inspect_source(cop, "'abc'.#{method}(Regexp.new(/a/i), '1')")

        expect(cop.messages).to be_empty
      end

      it 'allows empty string pattern' do
        inspect_source(cop, "'abc'.#{method}('', '1')")

        expect(cop.messages).to be_empty
      end
    end

    it 'accepts calls to gsub when the length of the pattern is shorter than ' \
       'the length of the replacement' do
      inspect_source(cop, "'abc'.#{method}('a', 'ab')")

      expect(cop.messages).to be_empty
    end

    it 'accepts calls to gsub when the length of the pattern is longer than ' \
       'the length of the replacement' do
      inspect_source(cop, "'abc'.#{method}('ab', 'd')")

      expect(cop.messages).to be_empty
    end
  end

  it_behaves_like('accepts', 'gsub')
  it_behaves_like('accepts', 'gsub!')

  describe 'deterministic regex' do
    describe 'regex literal' do
      it 'registers an offense when using space' do
        inspect_source(cop, %('abc'.gsub(/ /, '')))

        expect(cop.messages).to eq(['Use `delete` instead of `gsub`.'])
      end

      %w(a b c ' " % ! = < > # & ; : ` ~ 1 2 3 - _ , \r \\\\ \y \u1234
         \x65).each do |str|
        it "registers an offense when replacing #{str} with a literal" do
          inspect_source(cop, "'abc'.gsub(/#{str}/, 'a')")
          expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
        end

        it "registers an offense when deleting #{str}" do
          inspect_source(cop, "'abc'.gsub(/#{str}/, '')")
          expect(cop.messages).to eq(['Use `delete` instead of `gsub`.'])
        end
      end

      it 'allows deterministic regex when the length of the pattern ' \
         'and the length of the replacement do not match' do
        inspect_source(cop, %('abc'.gsub(/a/, 'def')))

        expect(cop.messages).to be_empty
      end

      it 'registers an offense when escape characters in regex' do
        inspect_source(cop, %('abc'.gsub(/\n/, ',')))

        expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
      end

      it 'registers an offense when using %r notation' do
        inspect_source(cop, %('/abc'.gsub(%r{a}, 'd')))

        expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
      end
    end

    describe 'regex constructor' do
      it 'registers an offense when only using word characters' do
        inspect_source(cop, "'abc'.gsub(Regexp.new('b'), '2')")

        expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
      end

      it 'registers an offense when regex is built from regex' do
        inspect_source(cop, "'abc'.gsub(Regexp.new(/b/), '2')")

        expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
      end

      it 'registers an offense when using compile' do
        inspect_source(cop, "'123'.gsub(Regexp.compile('1'), 'a')")

        expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
      end
    end
  end

  describe 'non deterministic regex' do
    it 'allows regex containing a +' do
      inspect_source(cop, %('abc'.gsub(/a+/, 'def')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a *' do
      inspect_source(cop, %('abc'.gsub(/a*/, 'def')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a ^' do
      inspect_source(cop, %('abc'.gsub(/^/, '')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a $' do
      inspect_source(cop, %('abc'.gsub(/$/, '')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a ?' do
      inspect_source(cop, %('abc'.gsub(/a?/, 'def')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a .' do
      inspect_source(cop, %('abc'.gsub(/./, 'a')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a |' do
      inspect_source(cop, %('abc'.gsub(/a|b/, 'd')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing ()' do
      inspect_source(cop, %('abc'.gsub(/(ab)/, 'd')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing escaped ()' do
      inspect_source(cop, %('(abc)'.gsub(/\(ab\)/, 'd')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing {}' do
      inspect_source(cop, %('abc'.gsub(/a{3,}/, 'd')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing []' do
      inspect_source(cop, %('abc'.gsub(/[a-z]/, 'd')))

      expect(cop.messages).to be_empty
    end

    it 'allows regex containing a backslash' do
      inspect_source(cop, '"abc".gsub(/\s/, "d")')

      expect(cop.messages).to be_empty
    end

    it 'allows regex literal containing interpolations' do
      inspect_source(cop, ["foo = 'a'",
                           '"abc".gsub(/#{foo}/, "d")'])

      expect(cop.messages).to be_empty
    end

    it 'allows regex constructor containing a string with interpolations' do
      inspect_source(cop, ["foo = 'a'",
                           '"abc".gsub(Regexp.new("#{foo}"), "d")'])

      expect(cop.messages).to be_empty
    end

    it 'allows regex constructor containing regex with interpolations' do
      inspect_source(cop, ["foo = 'a'",
                           '"abc".gsub(Regexp.new(/#{foo}/), "d")'])

      expect(cop.messages).to be_empty
    end
  end

  it 'registers an offense when the pattern has non deterministic regex ' \
     'as a string' do
    inspect_source(cop, %('a + c'.gsub('+', '-')))

    expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
  end

  it 'registers an offense when using gsub to find and replace ' \
     'a single character' do
    inspect_source(cop, "'abc'.gsub('a', '1')")

    expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
    expect(cop.highlights).to eq(["gsub('a', '1')"])
  end

  it 'registers an offense when using gsub! to find and replace ' \
     'a single character ' do
    inspect_source(cop, "'abc'.gsub!('a', '1')")

    expect(cop.messages).to eq(['Use `tr!` instead of `gsub!`.'])
    expect(cop.highlights).to eq(["gsub!('a', '1')"])
  end

  it 'registers an offense for gsub! when deleting one characters' do
    inspect_source(cop, "'abc'.gsub!('a', '')")

    expect(cop.messages).to eq(['Use `delete!` instead of `gsub!`.'])
    expect(cop.highlights).to eq(["gsub!('a', '')"])
  end

  it 'registers an offense when using escape characters in the replacement' do
    inspect_source(cop, "'abc'.gsub('a', '\n')")

    expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
  end

  it 'regeisters an offense when using escape characters in the pattern' do
    inspect_source(cop, "'abc'.gsub('\n', ',')")

    expect(cop.messages).to eq(['Use `tr` instead of `gsub`.'])
  end

  context 'auto-correct' do
    describe 'corrects to tr' do
      it 'corrects when the length of the pattern and replacement are one' do
        new_source = autocorrect_source(cop, "'abc'.gsub('a', 'd')")

        expect(new_source).to eq("'abc'.tr('a', 'd')")
      end

      it 'corrects when the pattern is a regex literal' do
        new_source = autocorrect_source(cop, "'abc'.gsub(/a/, '1')")

        expect(new_source).to eq("'abc'.tr('a', '1')")
      end

      it 'corrects when the pattern is a regex literal using %r' do
        new_source = autocorrect_source(cop, "'abc'.gsub(%r{a}, '1')")

        expect(new_source).to eq("'abc'.tr('a', '1')")
      end

      it 'corrects when the pattern uses Regexp.new' do
        new_source = autocorrect_source(cop,
                                        "'abc'.gsub(Regexp.new('a'), '1')")

        expect(new_source).to eq("'abc'.tr('a', '1')")
      end

      it 'corrects when the pattern uses Regexp.compile' do
        new_source = autocorrect_source(cop,
                                        "'abc'.gsub(Regexp.compile('a'), '1')")

        expect(new_source).to eq("'abc'.tr('a', '1')")
      end

      it 'corrects when the replacement contains a new line character' do
        new_source = autocorrect_source(cop, "'abc'.gsub('a', '\n')")

        expect(new_source).to eq("'abc'.tr('a', '\n')")
      end

      it 'corrects when the replacement contains escape backslash' do
        new_source = autocorrect_source(cop, "\"\".gsub('/', '\\\\')")

        expect(new_source).to eq("\"\".tr('/', '\\\\')")
      end

      it 'corrects when the pattern contains a new line character' do
        new_source = autocorrect_source(cop, "'abc'.gsub('\n', ',')")

        expect(new_source).to eq("'abc'.tr('\n', ',')")
      end

      it 'corrects when the pattern contains double backslash' do
        new_source = autocorrect_source(cop, "''.gsub('\\\\', '')")

        expect(new_source).to eq("''.delete('\\\\')")
      end

      it 'corrects when replacing to a single quote' do
        new_source = autocorrect_source(cop, '"a`b".gsub("`", "\'")')

        expect(new_source).to eq('"a`b".tr("`", "\'")')
      end

      it 'corrects when replacing to a double quote' do
        new_source = autocorrect_source(cop, '"a`b".gsub("`", "\"")')

        expect(new_source).to eq('"a`b".tr("`", "\"")')
      end
    end

    describe 'corrects to delete' do
      it 'corrects when deleting a single character' do
        new_source = autocorrect_source(cop, "'abc'.gsub!('a', '')")

        expect(new_source).to eq("'abc'.delete!('a')")
      end

      it 'corrects when the pattern is a regex literal' do
        new_source = autocorrect_source(cop, "'abc'.gsub(/a/, '')")

        expect(new_source).to eq("'abc'.delete('a')")
      end

      it 'corrects when deleting an escape character' do
        new_source = autocorrect_source(cop, "'abc'.gsub('\n', '')")

        expect(new_source).to eq("'abc'.delete('\n')")
      end

      it 'corrects when the pattern uses Regexp.new' do
        new_source = autocorrect_source(cop, "'abc'.gsub(Regexp.new('a'), '')")

        expect(new_source).to eq("'abc'.delete('a')")
      end

      it 'corrects when the pattern uses Regexp.compile' do
        new_source = autocorrect_source(cop,
                                        "'ab'.gsub(Regexp.compile('a'), '')")

        expect(new_source).to eq("'ab'.delete('a')")
      end

      it 'corrects when there are no brackets' do
        new_source = autocorrect_source(cop, "'abc'.gsub! 'a', ''")

        expect(new_source).to eq("'abc'.delete! 'a'")
      end
    end
  end
end
