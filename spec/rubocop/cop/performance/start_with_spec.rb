# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::StartWith do
  subject(:cop) { described_class.new }

  shared_examples 'different match methods' do |method|
    it "autocorrects #{method} /\\Aabc/" do
      new_source = autocorrect_source(cop, "str#{method} /\\Aabc/")
      expect(new_source).to eq "str.start_with?('abc')"
    end

    # escapes like "\n"
    # note that "\b" is a literal backspace char in a double-quoted string...
    # but in a regex, it's an anchor on a word boundary
    %w(a e f r t v).each do |str|
      it "autocorrects #{method} /\\A\\#{str}/" do
        new_source = autocorrect_source(cop, "str#{method} /\\A\\#{str}/")
        expect(new_source).to eq %{str.start_with?("\\#{str}")}
      end
    end

    # regexp metacharacters
    %w(. * ? $ ^ |).each do |str|
      it "autocorrects #{method} /\\A\\#{str}/" do
        new_source = autocorrect_source(cop, "str#{method} /\\A\\#{str}/")
        expect(new_source).to eq "str.start_with?('#{str}')"
      end

      it "doesn't register an error for #{method} /\\A#{str}/" do
        inspect_source(cop, "str#{method} /\\A#{str}/")
        expect(cop.messages).to be_empty
      end
    end

    # character classes, anchors
    %w(w W s S d D A Z z G b B).each do |str|
      it "doesn't register an error for #{method} /\\A\\#{str}/" do
        inspect_source(cop, "str#{method} /\\A\\#{str}/")
        expect(cop.messages).to be_empty
      end
    end

    # characters with no special meaning whatsoever
    %w(h i j l m o q y).each do |str|
      it "autocorrects #{method} /\\A\\#{str}/" do
        new_source = autocorrect_source(cop, "str#{method} /\\A\\#{str}/")
        expect(new_source).to eq "str.start_with?('#{str}')"
      end
    end

    it "formats the error message correctly for #{method} /\\Aabc/" do
      inspect_source(cop, "str#{method} /\\Aabc/")
      expect(cop.messages).to eq(['Use `String#start_with?` instead of a ' \
                                  'regex match anchored to the beginning of ' \
                                  'the string.'])
    end

    it "autocorrects #{method} /\\A\\\\/" do
      new_source = autocorrect_source(cop, "str#{method} /\\A\\\\/")
      expect(new_source).to eq("str.start_with?('\\\\')")
    end
  end

  include_examples('different match methods', ' =~')
  include_examples('different match methods', '.match')
end
