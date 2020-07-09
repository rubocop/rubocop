# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LiteralInInterpolation do
  subject(:cop) { described_class.new }

  it 'accepts empty interpolation' do
    expect_no_offenses('"this is #{a} silly"')
  end

  it 'accepts interpolation of xstr' do
    expect_no_offenses('"this is #{`a`} silly"')
  end

  it 'accepts interpolation of irange where endpoints are not literals' do
    expect_no_offenses('"this is an irange: #{var1..var2}"')
  end

  it 'accepts interpolation of erange where endpoints are not literals' do
    expect_no_offenses('"this is an erange: #{var1...var2}"')
  end

  shared_examples 'literal interpolation' do |literal, expected = literal|
    it "registers an offense for #{literal} in interpolation " \
       'and removes interpolation around it' do
      expect_offense(<<~'RUBY', literal: literal)
        "this is the #{%{literal}}"
                       ^{literal} Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        "this is the #{expected}"
      RUBY
    end

    it "removes interpolation around #{literal} when there is more text" do
      expect_offense(<<~'RUBY', literal: literal)
        "this is the #{%{literal}} literally"
                       ^{literal} Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        "this is the #{expected} literally"
      RUBY
    end

    it "removes interpolation around multiple #{literal}" do
      expect_offense(<<~'RUBY', literal: literal)
        "some #{%{literal}} with #{%{literal}} too"
                ^{literal} Literal interpolation detected.
                _{literal}         ^{literal} Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        "some #{expected} with #{expected} too"
      RUBY
    end

    context 'when there is non-literal and literal interpolation' do
      context 'when literal interpolation is before non-literal' do
        it 'only removes interpolation around literal' do
          expect_offense(<<~'RUBY', literal: literal)
            "this is #{%{literal}} with #{a} now"
                       ^{literal} Literal interpolation detected.
          RUBY
          expect_correction(<<~RUBY)
            "this is #{expected} with \#{a} now"
          RUBY
        end
      end

      context 'when literal interpolation is after non-literal' do
        it 'only removes interpolation around literal' do
          expect_offense(<<~'RUBY', literal: literal)
            "this is #{a} with #{%{literal}} now"
                                 ^{literal} Literal interpolation detected.
          RUBY
          expect_correction(<<~RUBY)
            "this is \#{a} with #{expected} now"
          RUBY
        end
      end
    end

    it "registers an offense only for final #{literal} in interpolation" do
      expect_offense(<<~'RUBY', literal: literal)
        "this is the #{%{literal};%{literal}}"
                       _{literal} ^{literal} Literal interpolation detected.
      RUBY
    end
  end

  it_behaves_like('literal interpolation', 1)
  it_behaves_like('literal interpolation', -1)
  it_behaves_like('literal interpolation', '1_123', '1123')
  it_behaves_like('literal interpolation',
                  '123_456_789_123_456_789', '123456789123456789')
  it_behaves_like('literal interpolation', '1.2e-3', '0.0012')
  it_behaves_like('literal interpolation', '0xaabb', '43707')
  it_behaves_like('literal interpolation', '0o377', '255')
  it_behaves_like('literal interpolation', 2.0)
  it_behaves_like('literal interpolation', '[]', '[]')
  it_behaves_like('literal interpolation', '["a", "b"]', '[\"a\", \"b\"]')
  it_behaves_like('literal interpolation', '{"a" => "b"}', '{\"a\" => \"b\"}')
  it_behaves_like('literal interpolation', true)
  it_behaves_like('literal interpolation', false)
  it_behaves_like('literal interpolation', 'nil')
  it_behaves_like('literal interpolation', ':symbol', 'symbol')
  it_behaves_like('literal interpolation', ':"symbol"', 'symbol')
  it_behaves_like('literal interpolation', 1..2)
  it_behaves_like('literal interpolation', 1...2)
  it_behaves_like('literal interpolation', '%w[]', '[]')
  it_behaves_like('literal interpolation', '%w[v1]', '[\"v1\"]')
  it_behaves_like('literal interpolation', '%w[v1 v2]', '[\"v1\", \"v2\"]')
  it_behaves_like('literal interpolation', '%i[s1 s2]', '[\"s1\", \"s2\"]')
  it_behaves_like('literal interpolation', '%I[s1 s2]', '[\"s1\", \"s2\"]')
  it_behaves_like('literal interpolation', '%i[s1     s2]', '[\"s1\", \"s2\"]')
  it_behaves_like('literal interpolation', '%i[ s1   s2 ]', '[\"s1\", \"s2\"]')

  it 'handles nested interpolations when auto-correction' do
    expect_offense(<<~'RUBY')
      "this is #{"#{1}"} silly"
                    ^ Literal interpolation detected.
    RUBY
    # next iteration fixes this
    expect_correction(<<~'RUBY', loop: false)
      "this is #{"1"} silly"
    RUBY
  end

  shared_examples 'special keywords' do |keyword|
    it "accepts strings like #{keyword}" do
      expect_no_offenses(<<~RUBY)
        %("this is \#{#{keyword}} silly")
      RUBY
    end

    it "registers an offense and autocorrects interpolation after #{keyword}" do
      expect_offense(<<~'RUBY', keyword: keyword)
        "this is the #{%{keyword}} #{1}"
                       _{keyword}    ^ Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        "this is the \#{#{keyword}} 1"
      RUBY
    end
  end

  it_behaves_like('special keywords', '__FILE__')
  it_behaves_like('special keywords', '__LINE__')
  it_behaves_like('special keywords', '__END__')
  it_behaves_like('special keywords', '__ENCODING__')

  shared_examples 'non-special string literal interpolation' do |string|
    it "registers an offense for #{string} and removes the interpolation " \
       "and quotes around #{string}" do
      expect_offense(<<~'RUBY', string: string)
        "this is the #{%{string}}"
                       ^{string} Literal interpolation detected.
      RUBY

      expect_correction(<<~RUBY)
        "this is the #{string.gsub(/'|"/, '')}"
      RUBY
    end
  end

  it_behaves_like('non-special string literal interpolation', %('foo'))
  it_behaves_like('non-special string literal interpolation', %("foo"))

  it 'handles double quotes in single quotes when auto-correction' do
    expect_offense(<<~'RUBY')
      "this is #{'"'} silly"
                 ^^^ Literal interpolation detected.
    RUBY

    expect_correction(<<~'RUBY')
      "this is \" silly"
    RUBY
  end

  it 'handles backslach in single quotes when auto-correction' do
    expect_offense(<<~'RUBY')
      x = "ABC".gsub(/(A)(B)(C)/, "D#{'\2'}F")
                                      ^^^^ Literal interpolation detected.
      "this is #{'\n'} silly"
                 ^^^^ Literal interpolation detected.
      "this is #{%q(\n)} silly"
                 ^^^^^^ Literal interpolation detected.
    RUBY

    expect_correction(<<~'RUBY')
      x = "ABC".gsub(/(A)(B)(C)/, "D\\2F")
      "this is \\n silly"
      "this is \\n silly"
    RUBY
  end

  it 'handles backslach in double quotes when auto-correction' do
    expect_offense(<<~'RUBY')
      "this is #{"\n"} silly"
                 ^^^^ Literal interpolation detected.
      "this is #{%(\n)} silly"
                 ^^^^^ Literal interpolation detected.
      "this is #{%Q(\n)} silly"
                 ^^^^^^ Literal interpolation detected.
    RUBY

    expect_correction(<<~'RUBY')
      "this is 
       silly"
      "this is 
       silly"
      "this is 
       silly"
    RUBY
  end

  context 'in string-like contexts' do
    let(:literal) { '42' }
    let(:expected) { '42' }

    it 'removes interpolation in symbols' do
      expect_offense(<<~'RUBY', literal: literal)
        :"this is the #{%{literal}}"
                        ^{literal} Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        :"this is the #{expected}"
      RUBY
    end

    it 'removes interpolation in backticks' do
      expect_offense(<<~'RUBY', literal: literal)
        `this is the #{%{literal}}`
                       ^{literal} Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        \`this is the #{expected}\`
      RUBY
    end

    it 'removes interpolation in regular expressions' do
      expect_offense(<<~'RUBY', literal: literal)
        /this is the #{%{literal}}/
                       ^{literal} Literal interpolation detected.
      RUBY
      expect_correction(<<~RUBY)
        /this is the #{expected}/
      RUBY
    end
  end
end
