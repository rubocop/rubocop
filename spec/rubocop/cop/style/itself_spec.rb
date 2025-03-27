# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Itself, :config do
  context 'with EnforcedStyle: itself' do
    let(:cop_config) { { 'EnforcedStyle' => 'itself' } }

    context 'for blocks' do
      it 'registers an offense and corrects for `{ |x| x }`' do
        expect_offense(<<~RUBY)
          foo { |x| x }
              ^^^^^^^^^ Prefer `&:itself`.
        RUBY

        expect_correction(<<~RUBY)
          foo(&:itself)
        RUBY
      end

      it 'does not register an offense with zero args' do
        expect_no_offenses(<<~RUBY)
          foo {}
        RUBY
      end

      it 'does not register an offense with more than one arg' do
        expect_no_offenses(<<~RUBY)
          foo { |x, y| }
        RUBY
      end

      it 'does not register an offense with one arg that does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { |x| x * 2}
        RUBY
      end

      it 'properly corrects chained receivers' do
        expect_offense(<<~RUBY)
          foo.bar { |x| x }
                  ^^^^^^^^^ Prefer `&:itself`.
        RUBY

        expect_correction(<<~RUBY)
          foo.bar(&:itself)
        RUBY
      end

      it 'properly corrects multiline blocks' do
        expect_offense(<<~RUBY)
          foo.bar do |x|
                  ^^^^^^ Prefer `&:itself`.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          foo.bar(&:itself)
        RUBY
      end

      it 'properly corrects multiline blocks with multiline receiver' do
        expect_offense(<<~RUBY)
          foo
            .bar do |x|
                 ^^^^^^ Prefer `&:itself`.
              x
            end
        RUBY

        expect_correction(<<~RUBY)
          foo
            .bar(&:itself)
        RUBY
      end

      context 'when the send node already has arguments' do
        it 'properly corrects' do
          expect_offense(<<~RUBY)
            foo(y) { |x| x }
                   ^^^^^^^^^ Prefer `&:itself`.
          RUBY

          expect_correction(<<~RUBY)
            foo(y, &:itself)
          RUBY
        end

        it 'properly corrects with a multiline block' do
          expect_offense(<<~RUBY)
            foo(y) do |x|
                   ^^^^^^ Prefer `&:itself`.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            foo(y, &:itself)
          RUBY
        end

        it 'properly corrects with a multiline receiver and block' do
          expect_offense(<<~RUBY)
            foo
              .bar(y) do |x|
                      ^^^^^^ Prefer `&:itself`.
                x
              end
          RUBY

          expect_correction(<<~RUBY)
            foo
              .bar(y, &:itself)
          RUBY
        end

        it 'properly corrects with a multiline arguments' do
          expect_offense(<<~RUBY)
            foo(a, b
                ) { |x| x }
                  ^^^^^^^^^ Prefer `&:itself`.
          RUBY

          expect_correction(<<~RUBY)
            foo(a, b, &:itself
                )
          RUBY
        end
      end
    end

    context 'for numblocks' do
      it 'registers an offense and corrects for `{ _1 }`' do
        expect_offense(<<~RUBY)
          foo { _1 }
              ^^^^^^ Prefer `&:itself`.
        RUBY

        expect_correction(<<~RUBY)
          foo(&:itself)
        RUBY
      end

      it 'does not register an offense with multiple args' do
        expect_no_offenses(<<~RUBY)
          foo { _1 + _2 }
        RUBY
      end

      it 'does not register an offense with one arg that does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { _1 * 2 }
        RUBY
      end
    end

    context 'for itblocks', :ruby34, unsupported_on: :parser do
      it 'registers an offense and corrects for `{ it }`' do
        expect_offense(<<~RUBY)
          foo { it }
              ^^^^^^ Prefer `&:itself`.
        RUBY

        expect_correction(<<~RUBY)
          foo(&:itself)
        RUBY
      end

      it 'does not register an offense when it does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { it * 2 }
        RUBY
      end
    end

    context 'for &:itself' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo(&:itself)
        RUBY
      end
    end
  end

  context 'with EnforcedStyle: it' do
    let(:cop_config) { { 'EnforcedStyle' => 'it' } }

    context 'for blocks' do
      it 'registers an offense and corrects for `{ |x| x }`' do
        expect_offense(<<~RUBY)
          foo { |x| x }
              ^^^^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo { it }
        RUBY
      end

      it 'does not register an offense with zero args' do
        expect_no_offenses(<<~RUBY)
          foo {}
        RUBY
      end

      it 'does not register an offense with more than one arg' do
        expect_no_offenses(<<~RUBY)
          foo { |x, y| }
        RUBY
      end

      it 'does not register an offense with one arg that does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { |x| x * 2}
        RUBY
      end

      it 'properly corrects chained receivers' do
        expect_offense(<<~RUBY)
          foo.bar { |x| x }
                  ^^^^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo.bar { it }
        RUBY
      end

      it 'properly corrects multiline blocks' do
        expect_offense(<<~RUBY)
          foo.bar do |x|
                  ^^^^^^ Prefer `{ it }`.
            x
          end
        RUBY

        expect_correction(<<~RUBY)
          foo.bar { it }
        RUBY
      end

      it 'properly corrects multiline blocks with multiline receiver' do
        expect_offense(<<~RUBY)
          foo
            .bar do |x|
                 ^^^^^^ Prefer `{ it }`.
              x
            end
        RUBY

        expect_correction(<<~RUBY)
          foo
            .bar { it }
        RUBY
      end
    end

    context 'for numblocks' do
      it 'registers an offense and corrects for `{ _1 }`' do
        expect_offense(<<~RUBY)
          foo { _1 }
              ^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo { it }
        RUBY
      end

      it 'does not register an offense with multiple args' do
        expect_no_offenses(<<~RUBY)
          foo { _1 + _2 }
        RUBY
      end

      it 'does not register an offense with one arg that does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { _1 * 2 }
        RUBY
      end
    end

    context 'for itblocks', :ruby34, unsupported_on: :parser do
      it 'does not register an offense for `{ it }`' do
        expect_no_offenses(<<~RUBY)
          foo { it }
        RUBY
      end

      it 'does not register an offense when it does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { it * 2 }
        RUBY
      end
    end

    context 'for `&:itself`' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo(&:itself)
              ^^^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo { it }
        RUBY
      end

      it 'registers an offense and corrects without parens' do
        expect_offense(<<~RUBY)
          foo &:itself
              ^^^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo { it }
        RUBY
      end

      it 'registers an offense and corrects with a chained receiver' do
        expect_offense(<<~RUBY)
          foo.bar &:itself
                  ^^^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo.bar { it }
        RUBY
      end

      it 'registers an offense and corrects with multiple lines' do
        expect_offense(<<~RUBY)
          foo
             .bar &:itself
                  ^^^^^^^^ Prefer `{ it }`.
        RUBY

        expect_correction(<<~RUBY)
          foo
             .bar { it }
        RUBY
      end

      it 'does not register an offense when the send node has other arguments' do
        expect_no_offenses(<<~RUBY)
          foo(x, &:itself)
        RUBY
      end
    end
  end

  context 'with EnforcedStyle: named_parameter' do
    let(:cop_config) { { 'EnforcedStyle' => 'named_parameter' } }

    context 'for blocks' do
      it 'does not register an offense for `{ |x| x }`' do
        expect_no_offenses(<<~RUBY)
          foo { |x| x }
        RUBY
      end

      it 'does not register an offense with zero args' do
        expect_no_offenses(<<~RUBY)
          foo {}
        RUBY
      end

      it 'does not register an offense with more than one arg' do
        expect_no_offenses(<<~RUBY)
          foo { |x, y| }
        RUBY
      end

      it 'does not register an offense with one arg that does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { |x| x * 2 }
        RUBY
      end

      it 'does not register an offense for chained receivers' do
        expect_no_offenses(<<~RUBY)
          foo.bar { |x| x }
        RUBY
      end

      it 'does not register an offense for multiline blocks' do
        expect_no_offenses(<<~RUBY)
          foo.bar do |x|
            x
          end
        RUBY
      end
    end

    context 'for numblocks' do
      it 'registers an offense but does not correct for `{ _1 }`' do
        expect_offense(<<~RUBY)
          foo { _1 }
              ^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'does not register an offense with multiple args' do
        expect_no_offenses(<<~RUBY)
          foo { _1 + _2 }
        RUBY
      end

      it 'does not register an offense with one arg that does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { _1 * 2 }
        RUBY
      end

      it 'properly corrects chained receivers' do
        expect_offense(<<~RUBY)
          foo.bar { _1 }
                  ^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'properly corrects multiline blocks' do
        expect_offense(<<~RUBY)
          foo.bar do
                  ^^ Prefer a block in the form `{ |x| x }`.
            _1
          end
        RUBY

        expect_no_corrections
      end

      it 'properly corrects multiline blocks with multiline receiver' do
        expect_offense(<<~RUBY)
          foo
            .bar do
                 ^^ Prefer a block in the form `{ |x| x }`.
              _1
            end
        RUBY

        expect_no_corrections
      end
    end

    context 'for itblocks', :ruby34, unsupported_on: :parser do
      it 'registers an offense but does not correct for `{ it }`' do
        expect_offense(<<~RUBY)
          foo { it }
              ^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'does not register an offense when it does not just return itself' do
        expect_no_offenses(<<~RUBY)
          foo { it * 2 }
        RUBY
      end
    end

    context 'for `&:itself`' do
      it 'registers an offense but does not correct' do
        expect_offense(<<~RUBY)
          foo(&:itself)
              ^^^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense but does not correct without parens' do
        expect_offense(<<~RUBY)
          foo &:itself
              ^^^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense but does not correct with a chained receiver' do
        expect_offense(<<~RUBY)
          foo.bar &:itself
                  ^^^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense but does not correct with multiple lines' do
        expect_offense(<<~RUBY)
          foo
             .bar &:itself
                  ^^^^^^^^ Prefer a block in the form `{ |x| x }`.
        RUBY

        expect_no_corrections
      end

      it 'does not register an offense when the send node has other arguments' do
        expect_no_offenses(<<~RUBY)
          foo(x, &:itself)
        RUBY
      end
    end
  end
end
