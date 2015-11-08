# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::EndWith do
  subject(:cop) { described_class.new }

  shared_examples 'different match methods' do |method|
    it "autocorrects #{method} /abc\\Z/" do
      new_source = autocorrect_source(cop, "str#{method} /abc\\Z/")
      expect(new_source).to eq "str.end_with?('abc')"
    end

    it "autocorrects #{method} /\\n\\Z/" do
      new_source = autocorrect_source(cop, "str#{method} /\\n\\Z/")
      expect(new_source).to eq 'str.end_with?("\n")'
    end

    it "autocorrects #{method} /\\t\\Z/" do
      new_source = autocorrect_source(cop, "str#{method} /\\t\\Z/")
      expect(new_source).to eq 'str.end_with?("\t")'
    end

    %w(. $ ^ |).each do |str|
      it "autocorrects #{method} /\\#{str}\\Z/" do
        new_source = autocorrect_source(cop, "str#{method} /\\#{str}\\Z/")
        expect(new_source).to eq "str.end_with?('#{str}')"
      end

      it "doesn't register an error for #{method} /#{str}\\Z/" do
        inspect_source(cop, "str#{method} /#{str}\\Z/")
        expect(cop.messages).to be_empty
      end
    end

    it "formats the error message correctly for #{method} /abc\\Z/" do
      inspect_source(cop, "str#{method} /abc\\Z/")
      expect(cop.messages).to eq(['Use `String#end_with?` instead of a ' \
                                  'regex match anchored to the end of ' \
                                  'the string.'])
    end
  end

  include_examples('different match methods', ' =~')
  include_examples('different match methods', '.match')
end
