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

    it 'accepts it if single line would not fit on one line and body last argument is a hash type with value omission', :ruby31 do
      # This statement is one character too long to fit.
      condition = 'a' * (40 - keyword.length)
      body = "#{'b' * 35}(a:)"
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

    it "doesn't break when used as RHS of local var assignment" do
      expect_offense(<<~RUBY, keyword: keyword)
        a = %{keyword} b
            ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        a = (1 #{keyword} b)
      RUBY
    end

    it "doesn't break when used as RHS of instance var assignment" do
      expect_offense(<<~RUBY, keyword: keyword)
        @a = %{keyword} b
             ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        @a = (1 #{keyword} b)
      RUBY
    end

    it "doesn't break when used as RHS of class var assignment" do
      expect_offense(<<~RUBY, keyword: keyword)
        @@a = %{keyword} b
              ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        @@a = (1 #{keyword} b)
      RUBY
    end

    it "doesn't break when used as RHS of constant assignment" do
      expect_offense(<<~RUBY, keyword: keyword)
        A = %{keyword} b
            ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        A = (1 #{keyword} b)
      RUBY
    end

    it "doesn't break when used as RHS of binary arithmetic" do
      expect_offense(<<~RUBY, keyword: keyword)
        a + %{keyword} b
            ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        a + (1 #{keyword} b)
      RUBY
    end

    it 'handles inline comments during autocorrection' do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} bar # important comment not to be nuked
        ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
          baz
        end
      RUBY

      expect_correction(<<~RUBY)
        baz #{keyword} bar # important comment not to be nuked
      RUBY
    end

    it 'handles one-line usage' do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} foo; bar; end
        ^{keyword} Favor modifier `%{keyword}` usage when having a single-line body.#{extra_message}
      RUBY

      expect_correction(<<~RUBY)
        bar #{keyword} foo
      RUBY
    end

    # See: https://github.com/rubocop/rubocop/issues/8273
    context 'accepts multiline condition in modifier form' do
      it 'registers an offense' do
        expect_no_offenses(<<~RUBY)
          foo #{keyword} bar ||
                         baz
        RUBY
      end
    end

    context 'when there is a comment on the first line and some code after the end keyword' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          [
            1, #{keyword} foo # bar
                 baz
               end, 3
          ]
        RUBY
      end
    end
  end
end
