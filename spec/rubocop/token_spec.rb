# frozen_string_literal: true

RSpec.describe RuboCop::Token do
  let(:processed_source) { RuboCop::ProcessedSource.new(source, ruby_version) }
  let(:ruby_version) { RuboCop::Config::KNOWN_RUBIES.last }

  let(:source) { <<-RUBY.strip_indent }
    # comment
    def some_method
      [ 1, 2 ];
      foo[0] = 3
    end
  RUBY

  let(:first_token) { processed_source.tokens.first }
  let(:comment_token) do
    processed_source.find_token do |t|
      t.text.start_with?('#') && t.line == 1
    end
  end

  let(:left_array_bracket_token) do
    processed_source.find_token { |t| t.text == '[' && t.line == 3 }
  end
  let(:comma_token) { processed_source.find_token { |t| t.text == ',' } }
  let(:right_array_bracket_token) do
    processed_source.find_token { |t| t.text == ']' && t.line == 3 }
  end
  let(:semicolon_token) { processed_source.find_token { |t| t.text == ';' } }

  let(:left_ref_bracket_token) do
    processed_source.find_token { |t| t.text == '[' && t.line == 4 }
  end
  let(:zero_token) { processed_source.find_token { |t| t.text == '0' } }
  let(:right_ref_bracket_token) do
    processed_source.find_token { |t| t.text == ']' && t.line == 4 }
  end
  let(:equals_token) { processed_source.find_token { |t| t.text == '=' } }

  let(:end_token) { processed_source.find_token { |t| t.text == 'end' } }

  describe '.from_parser_token' do
    subject(:token) { described_class.from_parser_token(parser_token) }

    let(:parser_token) { [type, [text, range]] }
    let(:type) { :kDEF }
    let(:text) { 'def' }
    let(:range) { double('range', line: 42, column: 30) }

    it "sets parser token's type to rubocop token's type" do
      expect(token.type).to eq(type)
    end

    it "sets parser token's text to rubocop token's text" do
      expect(token.text).to eq(text)
    end

    it "sets parser token's range to rubocop token's pos" do
      expect(token.pos).to eq(range)
    end

    it 'returns a #to_s useful for debugging' do
      expect(token.to_s).to eq('[[42, 30], kDEF, "def"]')
    end
  end

  describe '#line' do
    it 'returns line of token' do
      expect(first_token.line).to eq 1
      expect(zero_token.line).to eq 4
      expect(end_token.line).to eq 5
    end
  end

  describe '#column' do
    it 'returns index of first char in token range on that line' do
      expect(first_token.column).to eq 0
      expect(zero_token.column).to eq 6
      expect(end_token.column).to eq 0
    end
  end

  describe '#begin_pos' do
    it 'returns index of first char in token range of entire source' do
      expect(first_token.begin_pos).to eq 0
      expect(zero_token.begin_pos).to eq 44
      expect(end_token.begin_pos).to eq 51
    end
  end

  describe '#end_pos' do
    it 'returns index of last char in token range of entire source' do
      expect(first_token.end_pos).to eq 9
      expect(zero_token.end_pos).to eq 45
      expect(end_token.end_pos).to eq 54
    end
  end

  describe '#space_after' do
    it 'returns truthy MatchData when there is a space after token' do
      expect(left_array_bracket_token.space_after?.is_a?(MatchData)).to be true
      expect(right_ref_bracket_token.space_after?.is_a?(MatchData)).to be true

      expect(left_array_bracket_token.space_after?).to be_truthy
      expect(right_ref_bracket_token.space_after?).to be_truthy
    end

    it 'returns nil when there is not a space after token' do
      expect(left_ref_bracket_token.space_after?).to be nil
      expect(zero_token.space_after?).to be nil
    end
  end

  describe '#to_s' do
    it 'returns string of token data' do
      expect(end_token.to_s).to include end_token.line.to_s
      expect(end_token.to_s).to include end_token.column.to_s
      expect(end_token.to_s).to include end_token.type.to_s
      expect(end_token.to_s).to include end_token.text.to_s
    end
  end

  describe '#space_before' do
    it 'returns truthy MatchData when there is a space before token' do
      expect(left_array_bracket_token.space_before?.is_a?(MatchData)).to be true
      expect(equals_token.space_before?.is_a?(MatchData)).to be true

      expect(left_array_bracket_token.space_before?).to be_truthy
      expect(equals_token.space_before?).to be_truthy
    end

    it 'returns nil when there is not a space before token' do
      expect(semicolon_token.space_before?).to be nil
      expect(zero_token.space_before?).to be nil
    end
  end

  context 'type predicates' do
    describe '#comment?' do
      it 'returns true for comment tokens' do
        expect(comment_token.comment?).to be true
      end

      it 'returns false for non comment tokens' do
        expect(zero_token.comment?).to be false
        expect(semicolon_token.comment?).to be false
      end
    end

    describe '#semicolon?' do
      it 'returns true for semicolon tokens' do
        expect(semicolon_token.semicolon?).to be true
      end

      it 'returns false for non semicolon tokens' do
        expect(comment_token.semicolon?).to be false
        expect(comma_token.semicolon?).to be false
      end
    end

    describe '#left_array_bracket?' do
      it 'returns true for left_array_bracket tokens' do
        expect(left_array_bracket_token.left_array_bracket?).to be true
      end

      it 'returns false for non left_array_bracket tokens' do
        expect(left_ref_bracket_token.left_array_bracket?).to be false
        expect(right_array_bracket_token.left_array_bracket?).to be false
      end
    end

    describe '#left_ref_bracket?' do
      it 'returns true for left_ref_bracket tokens' do
        expect(left_ref_bracket_token.left_ref_bracket?).to be true
      end

      it 'returns false for non left_ref_bracket tokens' do
        expect(left_array_bracket_token.left_ref_bracket?).to be false
        expect(right_ref_bracket_token.left_ref_bracket?).to be false
      end
    end

    describe '#left_bracket?' do
      it 'returns true for all left_bracket tokens' do
        expect(left_ref_bracket_token.left_bracket?).to be true
        expect(left_array_bracket_token.left_bracket?).to be true
      end

      it 'returns false for non left_bracket tokens' do
        expect(right_ref_bracket_token.left_bracket?).to be false
        expect(right_array_bracket_token.left_bracket?).to be false
      end
    end

    describe '#right_bracket?' do
      it 'returns true for all right_bracket tokens' do
        expect(right_ref_bracket_token.right_bracket?).to be true
        expect(right_array_bracket_token.right_bracket?).to be true
      end

      it 'returns false for non right_bracket tokens' do
        expect(left_ref_bracket_token.right_bracket?).to be false
        expect(left_array_bracket_token.right_bracket?).to be false
      end
    end

    describe '#left_brace?' do
      it 'returns true for right_bracket tokens' do
        expect(right_ref_bracket_token.right_bracket?).to be true
        expect(right_array_bracket_token.right_bracket?).to be true
      end

      it 'returns false for non right_bracket tokens' do
        expect(left_ref_bracket_token.right_bracket?).to be false
        expect(left_array_bracket_token.right_bracket?).to be false
      end
    end

    describe '#comma?' do
      it 'returns true for comma tokens' do
        expect(comma_token.comma?).to be true
      end

      it 'returns false for non comma tokens' do
        expect(semicolon_token.comma?).to be false
        expect(right_ref_bracket_token.comma?).to be false
      end
    end

    describe '#rescue_modifier?' do
      let(:source) { <<-RUBY.strip_indent }
        def foo
          bar rescue qux
        end
      RUBY

      let(:rescue_modifier_token) do
        processed_source.find_token { |t| t.text == 'rescue' }
      end

      it 'returns true for rescue modifier tokens' do
        expect(rescue_modifier_token.rescue_modifier?).to be true
      end

      it 'returns false for non rescue modifier tokens' do
        expect(first_token.rescue_modifier?).to be false
        expect(end_token.rescue_modifier?).to be false
      end
    end

    describe '#end?' do
      it 'returns true for end tokens' do
        expect(end_token.end?).to be true
      end

      it 'returns false for non end tokens' do
        expect(semicolon_token.end?).to be false
        expect(comment_token.end?).to be false
      end
    end

    describe '#equals_sign?' do
      it 'returns true for equals sign tokens' do
        expect(equals_token.equal_sign?).to be true
      end

      it 'returns false for non equals sign tokens' do
        expect(semicolon_token.equal_sign?).to be false
        expect(comma_token.equal_sign?).to be false
      end
    end

    context 'with braces & parens' do
      let(:source) { <<-RUBY.strip_indent }
        { a: 1 }
        foo { |f| bar(f) }
      RUBY

      let(:left_hash_brace_token) do
        processed_source.find_token { |t| t.text == '{' && t.line == 1 }
      end
      let(:right_hash_brace_token) do
        processed_source.find_token { |t| t.text == '}' && t.line == 1 }
      end

      let(:left_block_brace_token) do
        processed_source.find_token { |t| t.text == '{' && t.line == 2 }
      end
      let(:left_parens_token) do
        processed_source.find_token { |t| t.text == '(' }
      end
      let(:right_parens_token) do
        processed_source.find_token { |t| t.text == ')' }
      end
      let(:right_block_brace_token) do
        processed_source.find_token { |t| t.text == '}' && t.line == 2 }
      end

      describe '#left_brace?' do
        it 'returns true for left hash brace tokens' do
          expect(left_hash_brace_token.left_brace?).to be true
        end

        it 'returns false for non left hash brace tokens' do
          expect(left_block_brace_token.left_brace?).to be false
          expect(right_hash_brace_token.left_brace?).to be false
        end
      end

      describe '#left_curly_brace?' do
        it 'returns true for left block brace tokens' do
          expect(left_block_brace_token.left_curly_brace?).to be true
        end

        it 'returns false for non left block brace tokens' do
          expect(left_hash_brace_token.left_curly_brace?).to be false
          expect(right_block_brace_token.left_curly_brace?).to be false
        end
      end

      describe '#right_curly_brace?' do
        it 'returns true for all right brace tokens' do
          expect(right_hash_brace_token.right_curly_brace?).to be true
          expect(right_block_brace_token.right_curly_brace?).to be true
        end

        it 'returns false for non right brace tokens' do
          expect(left_hash_brace_token.right_curly_brace?).to be false
          expect(left_parens_token.right_curly_brace?).to be false
        end
      end

      describe '#left_parens?' do
        it 'returns true for left parens tokens' do
          expect(left_parens_token.left_parens?).to be true
        end

        it 'returns false for non left parens tokens' do
          expect(left_hash_brace_token.left_parens?).to be false
          expect(right_parens_token.left_parens?).to be false
        end
      end

      describe '#right_parens?' do
        it 'returns true for right parens tokens' do
          expect(right_parens_token.right_parens?).to be true
        end

        it 'returns false for non right parens tokens' do
          expect(right_hash_brace_token.right_parens?).to be false
          expect(left_parens_token.right_parens?).to be false
        end
      end
    end
  end
end
