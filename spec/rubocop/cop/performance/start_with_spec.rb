# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::StartWith do
  subject(:cop) { described_class.new }

  shared_examples 'different match methods' do |method|
    it "autocorrects #{method} /\\Aabc/" do
      new_source = autocorrect_source(cop, "str#{method} /\\Aabc/")
      expect(new_source).to eq "str.start_with?('abc')"
    end

    it "autocorrects #{method} /\\A\\n/" do
      new_source = autocorrect_source(cop, "str#{method} /\\A\\n/")
      expect(new_source).to eq 'str.start_with?("\n")'
    end

    it "autocorrects #{method} /\\A\\t/" do
      new_source = autocorrect_source(cop, "str#{method} /\\A\\t/")
      expect(new_source).to eq 'str.start_with?("\t")'
    end

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

    it "formats the error message correctly for #{method} /\\Aabc/" do
      inspect_source(cop, "str#{method} /\\Aabc/")
      expect(cop.messages).to eq(['Use `String#start_with?` instead of a ' \
                                  'regex match anchored to the beginning of ' \
                                  'the string.'])
    end
  end

  include_examples('different match methods', ' =~')
  include_examples('different match methods', '.match')
end
