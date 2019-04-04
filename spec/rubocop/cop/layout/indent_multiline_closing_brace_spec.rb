# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentMultilineClosingBrace do
  subject(:cop) { described_class.new }

  context 'method call' do
    context 'when closing paren in same column as method start' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz(
              "abc",
              "def",
            )
          RUBY
        )
      end
    end

    context 'when one line' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz("abc", "def")
          RUBY
        )
      end
    end

    context 'when no args' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz()
          RUBY
        )
      end
    end

    context 'when no parens' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz "abc",
             "def"
          RUBY
        )
      end
    end

    context 'when paren is on ending line' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz("abc",
             "def")
          RUBY
        )
      end
    end

    context 'when paren is on ending line and first arg is on different line' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz(
             "abc",
             "123",
             "345",
             "def",  )
          RUBY
        )
      end
    end

    context 'when no args' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            foo.to eq 1
          RUBY
        )
      end
    end

    context 'when multiple calls on separate lines' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            allow(obj).to(
              receive(:message).and_throw(:this_symbol)
            )
          RUBY
        )
      end
    end

    context 'when method and object are on different lines' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            foo(:bar)
              .bar(:baz)
          RUBY
        )
      end
    end

    context 'when method and object are on different lines with nested calls' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            allow(obj)
              .to(receive(:message))
          RUBY
        )
      end
    end

    context 'when hash args with braces' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            taz({
              a: "abc",
              b: "def",
            })
          RUBY
        )
      end
    end

    context 'when do block' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            context 'when do block' do
              it 'something' do
                foo.bar(2)
              end
            end
          RUBY
        )
      end
    end

    context 'when eq on other line' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            expect(new_source).to eq(
              something
            )
          RUBY
        )
      end
    end

    context 'when paren isnt indented enough' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
              taz(
                "abc",
                "foo",
            )
            ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
              taz(
                "abc",
                "foo",
            )
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            \s\staz(
            \s\s  "abc",
            \s\s  "foo",
            \s\s)
          RUBY
        )
      end
    end

    context 'when paren is indented too much' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            taz(
              "abc",
              "foo",
                  )
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            taz(
              "abc",
              "foo",
                  )
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            taz(
              "abc",
              "foo",
            )
          RUBY
        )
      end
    end

    context 'when hash args with braces' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            taz({
              a: "abc",
              b: "foo",
                  })
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            taz({
              a: "abc",
              b: "foo",
                  })
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            taz({
              a: "abc",
              b: "foo",
            })
          RUBY
        )
      end
    end
  end

  context 'array' do
    context 'when closing brace in same column as start' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            [
              "abc",
              "def",
            ]
          RUBY
        )
      end
    end

    context 'when one line' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            ["abc", "def"]
          RUBY
        )
      end
    end

    context 'when no items' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            []
          RUBY
        )
      end
    end

    context 'when on same line as last item' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            [
              1]
          RUBY
        )
      end
    end

    context 'when paren is indented too much' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            [
              "abc",
              "foo",
                  ]
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            [
              "abc",
              "foo",
                  ]
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            [
              "abc",
              "foo",
            ]
          RUBY
        )
      end
    end

    context 'when nested parens indented too much' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            [
              "abc",
              "foo",
              [
                123
                ]
                ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
                  ]
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            [
              "abc",
              "foo",
              [
                123
                ]
                  ]
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            [
              "abc",
              "foo",
              [
                123
              ]
            ]
          RUBY
        )
      end
    end

    context 'when nested parens not indent enough' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
              [
                "abc",
                "foo",
                [
                  123
            ]
            ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
                ]
                ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
              [
                "abc",
                "foo",
                [
                  123
            ]
                ]
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            \s\s[
            \s\s  "abc",
            \s\s  "foo",
            \s\s  [
            \s\s    123
            \s\s  ]
            \s\s]
          RUBY
        )
      end
    end
  end

  context 'hash' do
    context 'when closing brace in same column as start' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            {
              abc: "abc",
              :def => "def",
            }
          RUBY
        )
      end
    end

    context 'when one line' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            {abc: "abc", "def" => "def"}
          RUBY
        )
      end
    end

    context 'when no items' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            {}
          RUBY
        )
      end
    end

    context 'when on same line as last item' do
      it 'does not add any offenses' do
        expect_no_offenses(
          <<-RUBY
            {
              "abc": 2}
          RUBY
        )
      end
    end

    context 'when paren is indented too much' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            {
              abc: "abc",
              foo: "foo",
                  }
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            {
              abc: "abc",
              foo: "foo",
                  }
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            {
              abc: "abc",
              foo: "foo",
            }
          RUBY
        )
      end
    end

    context 'when nested parens indented too much' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            {
              abc: "abc",
              foo: "foo",
              bar: {
                bar: 123
                }
                ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
                  }
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            {
              abc: "abc",
              foo: "foo",
              bar: {
                bar: 123
                }
                  }
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            {
              abc: "abc",
              foo: "foo",
              bar: {
                bar: 123
              }
            }
          RUBY
        )
      end
    end

    context 'when nested parens not indent enough' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
              {
                abc: "abc",
                foo: "foo",
                bar: {
                  bar: 123
            }
            ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
                }
                ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
              {
                abc: "abc",
                foo: "foo",
                bar: {
                  bar: 123
            }
                }
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            \s\s{
            \s\s  abc: "abc",
            \s\s  foo: "foo",
            \s\s  bar: {
            \s\s    bar: 123
            \s\s  }
            \s\s}
          RUBY
        )
      end
    end
  end

  context 'multiple' do
    context 'when hash and array and call' do
      it 'adds an offense' do
        expect_offense(
          <<-RUBY
            foo([
                {
                  abc: "abc",
                  foo: "foo",
                  bar: {
                    bar: 123
              }
              ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
                  }
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
                  ])
                  ^ Right brace in multi-line expression must align with the beginning of the first line containing the expression.
          RUBY
        )
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(
          <<-RUBY
            foo([
                {
                  abc: "abc",
                  foo: "foo",
                  bar: {
                    bar: 123
              }
                  }
                  ])
          RUBY
        )

        expect(new_source).to eq(
          <<-RUBY
            foo([
                {
                  abc: "abc",
                  foo: "foo",
                  bar: {
                    bar: 123
                  }
                }
            ])
          RUBY
        )
      end
    end
  end
end
