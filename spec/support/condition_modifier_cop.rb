# frozen_string_literal: true

RSpec.shared_examples 'condition modifier cop' do |keyword, extra_message = nil|
  let(:other_cops) { { 'Layout/LineLength' => { 'Max' => 80 } } }

  context "for a multiline '#{keyword}'" do
    it 'accepts it if single line would not fit on one line' do
      # This statement is one character too long to fit.
      condition = 'a' * (40 - keyword.length)
      body = 'b' * 39
      expect("#{body} #{keyword} #{condition}".length).to eq(81)

      expect_no_offenses(<<~RUBY)
        #{keyword} #{condition}
          #{body}
        end
      RUBY
    end

    context 'when Layout/LineLength is disabled' do
      let(:other_cops) { { 'Layout/LineLength' => { 'Enabled' => false } } }

      it 'registers an offense even for a long modifier statement' do
        expect_offense(<<~RUBY, keyword: keyword)
          %{keyword} foo
          ^{keyword} Favor modifier `#{keyword}` usage when having a single-line body.#{extra_message}
            "This string would make the line longer than eighty characters if combined with the statement."
          end
        RUBY
      end
    end

    it 'accepts it if body spans more than one line' do
      expect_no_offenses(<<~RUBY)
        #{keyword} some_condition
          do_something
          do_something_else
        end
      RUBY
    end

    it 'corrects it if result fits in one line' do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} condition
        ^{keyword} Favor modifier `#{keyword}` usage when having a single-line body.#{extra_message}
          do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        do_something #{keyword} condition
      RUBY
    end

    it 'accepts an empty body' do
      expect_no_offenses(<<~RUBY)
        #{keyword} cond
        end
      RUBY
    end

    it 'accepts it when condition has local variable assignment' do
      expect_no_offenses(<<~RUBY)
        #{keyword} (var = something)
          puts var
        end
      RUBY
    end

    it 'corrects it when assignment is in body' do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} true
        ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          x = 0
        end
      RUBY

      expect_correction(<<~RUBY)
        x = 0 #{keyword} true
      RUBY
    end
  end
end
