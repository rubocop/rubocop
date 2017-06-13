# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsidePercentLiteralDelimiters do
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

        def expect_corrected(source, expected)
          expect(autocorrect_source(cop, source)).to eq expected
        end

        it 'registers an offense for unnecessary spaces' do
          source = code_example(' 1 2  ')
          inspect_source(source)
          expect(cop.offenses.size).to eq(2)
          expect(cop.messages.uniq).to eq([message])
          expect(cop.highlights).to eq([' ', '  '])
          expect_corrected(source, code_example('1 2'))
        end

        it 'registers an offense for spaces after first delimiter' do
          source = code_example(' 1 2')
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect_corrected(source, code_example('1 2'))
        end

        it 'registers an offense for spaces before final delimiter' do
          source = code_example('1 2 ')
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect_corrected(source, code_example('1 2'))
        end

        it 'registers an offense for literals with escaped and other spaces' do
          source = code_example(' \ a b c\  ')
          inspect_source(source)
          expect(cop.offenses.size).to eq(2)
          expect_corrected(source, code_example('\ a b c\ '))
        end

        it 'accepts literals without additional spaces' do
          inspect_source(code_example('a b c'))
          expect(cop.messages).to be_empty
        end

        it 'accepts literals with escaped spaces' do
          inspect_source(code_example('\ a b c\ '))
          expect(cop.messages).to be_empty
        end

        it 'accepts multi-line literals' do
          inspect_source(<<-RUBY.strip_indent)
            %#{type}(
              a
              b
              c
            )
          RUBY
          expect(cop.messages).to be_empty
        end

        it 'accepts multi-line literals within a method' do
          inspect_source(<<-RUBY.strip_indent)
            def foo
              %#{type}(
                a
                b
                c
              )
            end
          RUBY
          expect(cop.messages).to be_empty
        end

        it 'accepts newlines and additional following alignment spaces' do
          inspect_source(<<-RUBY.strip_indent)
            %#{type}(a b
               c)
          RUBY
          expect(cop.messages).to be_empty
        end

        it 'accepts spaces between entries' do
          inspect_source(code_example('a  b  c'))
          expect(cop.messages).to be_empty
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
