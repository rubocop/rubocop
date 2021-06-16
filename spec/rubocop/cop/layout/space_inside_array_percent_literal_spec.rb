# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideArrayPercentLiteral, :config do
  %w[i I w W].each do |type|
    [%w[{ }], %w[( )], %w([ ]), %w[! !]].each do |(ldelim, rdelim)|
      context "for #{type} type and #{[ldelim, rdelim]} delimiters" do
        define_method(:code_example) { |content| ['%', type, ldelim, content, rdelim].join }

        it 'registers an offense for unnecessary spaces' do
          expect_offense(<<~RUBY)
            #{code_example('1   2')}
                ^^^ Use only a single space inside array percent literal.
          RUBY

          expect_correction("#{code_example('1 2')}\n")
        end

        it 'registers an offense for multiple spaces between items' do
          expect_offense(<<~RUBY)
            #{code_example('1   2   3')}
                    ^^^ Use only a single space inside array percent literal.
                ^^^ Use only a single space inside array percent literal.
          RUBY

          expect_correction("#{code_example('1 2 3')}\n")
        end

        it 'accepts literals with escaped and additional spaces' do
          expect_offense(<<~RUBY)
            #{code_example('a\   b \ c')}
                  ^^ Use only a single space inside array percent literal.
          RUBY

          expect_correction("#{code_example('a\  b \ c')}\n")
        end

        it 'accepts literals without additional spaces' do
          expect_no_offenses(code_example('a b c'))
        end

        it 'accepts literals with escaped spaces' do
          expect_no_offenses(code_example('a\  b\ \  c'))
        end

        it 'accepts multi-line literals' do
          expect_no_offenses(<<~RUBY)
            %#{type}(
              a
              b
              c
            )
          RUBY
        end

        it 'accepts multi-line literals within a method' do
          expect_no_offenses(<<~RUBY)
            def foo
              %#{type}(
                a
                b
                c
              )
            end
          RUBY
        end

        it 'accepts newlines and additional following alignment spaces' do
          expect_no_offenses(<<~RUBY)
            %#{type}(a b
               c)
          RUBY
        end
      end
    end
  end

  it 'accepts non array percent literals' do
    expect_no_offenses('%q( a  b c )')
  end
end
