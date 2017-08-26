# frozen_string_literal: true

describe RuboCop::Cop::Style::RedundantConditional do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  before { inspect_source(source) }

  shared_examples 'code with offense' do |code, expected, message_expression|
    context "when checking #{code.inspect}" do
      let(:source) { code }

      it 'registers an offense' do
        expected_message =
          'This conditional expression '\
          "can just be replaced by `#{message_expression || expected}`."
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([expected_message])
      end

      it 'auto-corrects' do
        expect(autocorrect_source(code)).to eq(expected)
      end

      it 'claims to auto-correct' do
        autocorrect_source(code)
        expect(cop.offenses.last.status).to eq(:corrected)
      end
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    context "when checking #{code.inspect}" do
      it 'does not register an offense' do
        expect(cop.offenses).to be_empty
      end
    end
  end

  it_behaves_like 'code with offense',
                  'x == y ? true : false',
                  'x == y'

  it_behaves_like 'code with offense',
                  'x == y ? false : true',
                  '!(x == y)'

  it_behaves_like 'code without offense',
                  'x == y ? 1 : 10'

  it_behaves_like 'code with offense',
                  <<-RUBY.strip_indent,
                    if x == y
                      true
                    else
                      false
                    end
                  RUBY
                  "x == y\n",
                  'x == y'

  it_behaves_like 'code with offense',
                  <<-RUBY.strip_indent,
                    if x == y
                      false
                    else
                      true
                    end
                  RUBY
                  "!(x == y)\n",
                  '!(x == y)'

  it_behaves_like 'code with offense',
                  <<-RUBY.strip_indent,
                    if cond
                      false
                    elsif x == y
                      true
                    else
                      false
                    end
                  RUBY
                  <<-RUBY.strip_indent,
                    if cond
                      false
                    else
                      x == y
                    end
                  RUBY
                  "\nelse\n  x == y"

  it_behaves_like 'code with offense',
                  <<-RUBY.strip_indent,
                    if cond
                      false
                    elsif x == y
                      false
                    else
                      true
                    end
                  RUBY
                  <<-RUBY.strip_indent,
                    if cond
                      false
                    else
                      !(x == y)
                    end
                  RUBY
                  "\nelse\n  !(x == y)"

  it_behaves_like 'code without offense',
                  <<-RUBY.strip_indent
                    if x == y
                      1
                    else
                      2
                    end
                  RUBY

  it_behaves_like 'code without offense',
                  <<-RUBY.strip_indent
                    if cond
                      1
                    elseif x == y
                      2
                    else
                      3
                    end
                  RUBY
end
