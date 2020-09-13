# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsidePercentLiteralDelimiters do
  subject(:cop) { described_class.new }

  let(:message) do
    'Do not use spaces inside percent literal delimiters.'
  end

  %w[i I w W x].each do |type|
    [%w[{ }], %w[( )], %w([ ]), %w[! !]].each do |(ldelim, rdelim)|
      context "for #{type} type and #{[ldelim, rdelim]} delimiters" do
        define_method(:code_example) do |content|
          ['%', type, ldelim, content, rdelim].join
        end

        it 'registers an offense for unnecessary spaces' do
          expect_offense(<<~RUBY)
            #{code_example(' 1 2  ')}
                   ^^ #{message}
               ^ #{message}
          RUBY

          expect_correction("#{code_example('1 2')}\n")
        end

        it 'registers an offense for spaces after first delimiter' do
          expect_offense(<<~RUBY)
            #{code_example(' 1 2')}
               ^ #{message}
          RUBY

          expect_correction("#{code_example('1 2')}\n")
        end

        it 'registers an offense for spaces before final delimiter' do
          expect_offense(<<~RUBY)
            #{code_example('1 2 ')}
                  ^ #{message}
          RUBY

          expect_correction("#{code_example('1 2')}\n")
        end

        it 'registers an offense for literals with escaped and other spaces' do
          expect_offense(<<~RUBY)
            #{code_example(' \ a b c\  ')}
                         ^ #{message}
               ^ #{message}
          RUBY
          expect_correction("#{code_example('\ a b c\ ')}\n")
        end

        it 'accepts literals without additional spaces' do
          expect_no_offenses(code_example('a b c'))
        end

        it 'accepts literals with escaped spaces' do
          expect_no_offenses(code_example('\ a b c\ '))
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

        it 'accepts spaces between entries' do
          expect_no_offenses(code_example('a  b  c'))
        end
      end
    end
  end

  it 'accepts other percent literals' do
    expect_no_offenses(<<-RUBY)
      %q( a  b c )
      %r( a  b c )
      %s( a  b c )
    RUBY
  end

  it 'accepts execute-string literals' do
    expect_no_offenses('` curl `')
  end
end
