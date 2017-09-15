# frozen_string_literal: true

describe RuboCop::Cop::Performance::StartWith do
  subject(:cop) { described_class.new }

  shared_examples 'different match methods' do |method|
    it "autocorrects #{method} /\\Aabc/" do
      new_source = autocorrect_source("str#{method} /\\Aabc/")
      expect(new_source).to eq "str.start_with?('abc')"
    end

    # escapes like "\n"
    # note that "\b" is a literal backspace char in a double-quoted string...
    # but in a regex, it's an anchor on a word boundary
    %w[a e f r t v].each do |str|
      it "autocorrects #{method} /\\A\\#{str}/" do
        new_source = autocorrect_source("str#{method} /\\A\\#{str}/")
        expect(new_source).to eq %{str.start_with?("\\#{str}")}
      end
    end

    # regexp metacharacters
    %w[. * ? $ ^ |].each do |str|
      it "autocorrects #{method} /\\A\\#{str}/" do
        new_source = autocorrect_source("str#{method} /\\A\\#{str}/")
        expect(new_source).to eq "str.start_with?('#{str}')"
      end

      it "doesn't register an error for #{method} /\\A#{str}/" do
        inspect_source("str#{method} /\\A#{str}/")
        expect(cop.messages.empty?).to be(true)
      end
    end

    # character classes, anchors
    %w[w W s S d D A Z z G b B h H R X S].each do |str|
      it "doesn't register an error for #{method} /\\A\\#{str}/" do
        inspect_source("str#{method} /\\A\\#{str}/")
        expect(cop.messages.empty?).to be(true)
      end
    end

    # characters with no special meaning whatsoever
    %w[i j l m o q y].each do |str|
      it "autocorrects #{method} /\\A\\#{str}/" do
        new_source = autocorrect_source("str#{method} /\\A\\#{str}/")
        expect(new_source).to eq "str.start_with?('#{str}')"
      end
    end

    it "formats the error message correctly for #{method} /\\Aabc/" do
      inspect_source("str#{method} /\\Aabc/")
      expect(cop.messages).to eq(['Use `String#start_with?` instead of a ' \
                                  'regex match anchored to the beginning of ' \
                                  'the string.'])
    end

    it "autocorrects #{method} /\\A\\\\/" do
      new_source = autocorrect_source("str#{method} /\\A\\\\/")
      expect(new_source).to eq("str.start_with?('\\\\')")
    end
  end

  include_examples('different match methods', ' =~')
  include_examples('different match methods', '.match')

  it 'allows match without a receiver' do
    expect_no_offenses('expect(subject.spin).to match(/\A\n/)')
  end
end
