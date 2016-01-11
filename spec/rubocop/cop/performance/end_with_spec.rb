# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::EndWith do
  subject(:cop) { described_class.new }

  shared_examples 'different match methods' do |method|
    it "autocorrects #{method} /abc\\z/" do
      new_source = autocorrect_source(cop, "str#{method} /abc\\z/")
      expect(new_source).to eq "str.end_with?('abc')"
    end

    it "autocorrects #{method} /\\n\\z/" do
      new_source = autocorrect_source(cop, "str#{method} /\\n\\z/")
      expect(new_source).to eq 'str.end_with?("\n")'
    end

    it "autocorrects #{method} /\\t\\z/" do
      new_source = autocorrect_source(cop, "str#{method} /\\t\\z/")
      expect(new_source).to eq 'str.end_with?("\t")'
    end

    %w(. $ ^ |).each do |str|
      it "autocorrects #{method} /\\#{str}\\z/" do
        new_source = autocorrect_source(cop, "str#{method} /\\#{str}\\z/")
        expect(new_source).to eq "str.end_with?('#{str}')"
      end

      it "doesn't register an error for #{method} /#{str}\\z/" do
        inspect_source(cop, "str#{method} /#{str}\\z/")
        expect(cop.messages).to be_empty
      end
    end

    # escapes like "\n"
    # note that "\b" is a literal backspace char in a double-quoted string...
    # but in a regex, it's an anchor on a word boundary
    %w(a e f r t v).each do |str|
      it "autocorrects #{method} /\\#{str}\\z/" do
        new_source = autocorrect_source(cop, "str#{method} /\\#{str}\\z/")
        expect(new_source).to eq %{str.end_with?("\\#{str}")}
      end
    end

    # character classes, anchors
    %w(w W s S d D A Z z G b B).each do |str|
      it "doesn't register an error for #{method} /\\#{str}\\z/" do
        inspect_source(cop, "str#{method} /\\#{str}\\z/")
        expect(cop.messages).to be_empty
      end
    end

    # characters with no special meaning whatsoever
    %w(h i j l m o q y).each do |str|
      it "autocorrects #{method} /\\#{str}\\z/" do
        new_source = autocorrect_source(cop, "str#{method} /\\#{str}\\z/")
        expect(new_source).to eq "str.end_with?('#{str}')"
      end
    end

    it "formats the error message correctly for #{method} /abc\\z/" do
      inspect_source(cop, "str#{method} /abc\\z/")
      expect(cop.messages).to eq(['Use `String#end_with?` instead of a ' \
                                  'regex match anchored to the end of ' \
                                  'the string.'])
    end

    it "autocorrects #{method} /\\\\\\z/" do
      new_source = autocorrect_source(cop, "str#{method} /\\\\\\z/")
      expect(new_source).to eq("str.end_with?('\\\\')")
    end
  end

  include_examples('different match methods', ' =~')
  include_examples('different match methods', '.match')
end
