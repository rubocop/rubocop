# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LiteralInInterpolation, :config do
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

  describe 'type int' do
    it_behaves_like('literal interpolation', 1)
    it_behaves_like('literal interpolation', -1)
    it_behaves_like('literal interpolation', '1_123', '1123')
    it_behaves_like('literal interpolation', '123_456_789_123_456_789', '123456789123456789')
    it_behaves_like('literal interpolation', '0xaabb', '43707')
    it_behaves_like('literal interpolation', '0o377', '255')
  end

  describe 'type float' do
    it_behaves_like('literal interpolation', '1.2e-3', '0.0012')
    it_behaves_like('literal interpolation', 2.0)
  end

  describe 'type str' do
    it_behaves_like('literal interpolation', '"double_quot_string"', 'double_quot_string')
    it_behaves_like('literal interpolation', "'single_quot_string'", 'single_quot_string')
    it_behaves_like('literal interpolation', '"double_quot_string: \'"', "double_quot_string: '")
    it_behaves_like('literal interpolation', "'single_quot_string: \"'", 'single_quot_string: \"')
  end

  describe 'type sym' do
    it_behaves_like('literal interpolation', ':symbol', 'symbol')
    it_behaves_like('literal interpolation', ':"symbol"', 'symbol')
    it_behaves_like('literal interpolation',
                    ':"single quot in symbol: \'"', "single quot in symbol: '")
    it_behaves_like('literal interpolation',
                    ":'double quot in symbol: \"'", 'double quot in symbol: \"')
  end

  describe 'type array' do
    it_behaves_like('literal interpolation', '[]', '[]')
    it_behaves_like('literal interpolation', '["a", "b"]', '[\"a\", \"b\"]')
    it_behaves_like('literal interpolation', '%w[]', '[]')
    it_behaves_like('literal interpolation', '%w[v1]', '[\"v1\"]')
    it_behaves_like('literal interpolation', '%w[v1 v2]', '[\"v1\", \"v2\"]')
    it_behaves_like('literal interpolation', '%i[s1 s2]', '[\"s1\", \"s2\"]')
    it_behaves_like('literal interpolation', '%I[s1 s2]', '[\"s1\", \"s2\"]')
    it_behaves_like('literal interpolation', '%i[s1     s2]', '[\"s1\", \"s2\"]')
    it_behaves_like('literal interpolation', '%i[ s1   s2 ]', '[\"s1\", \"s2\"]')
  end

  describe 'type hash' do
    it_behaves_like('literal interpolation', '{"a" => "b"}', '{\"a\"=>\"b\"}')
    it_behaves_like('literal interpolation', "{ foo: 'bar', :fiz => \"buzz\" }",
                    '{:foo=>\"bar\", :fiz=>\"buzz\"}')
    it_behaves_like('literal interpolation', "{ foo: { fiz: 'buzz' } }", '{:foo=>{:fiz=>\"buzz\"}}')
    it_behaves_like(
      'literal interpolation',
      '{ num: { separate: 1_123, long_separate: 123_456_789_123_456_789, exponent: 1.2e-3 } }',
      '{:num=>{:separate=>1123, :long_separate=>123456789123456789, :exponent=>0.0012}}'
    )
    it_behaves_like('literal interpolation', '{ n_adic_num: { hex: 0xaabb, oct: 0o377 } }',
                    '{:n_adic_num=>{:hex=>43707, :oct=>255}}')
    it_behaves_like(
      'literal interpolation',
      '{ double_quot: { simple: "double_quot", single_in_double: "double_quot: \'" } }',
      '{:double_quot=>{:simple=>\"double_quot\", :single_in_double=>\"double_quot: \'\"}}'
    )
    it_behaves_like(
      'literal interpolation',
      "{ single_quot: { simple: 'single_quot', double_in_single: 'single_quot: \"' } }",
      '{:single_quot=>{:simple=>\"single_quot\", :double_in_single=>\"single_quot: \\\\\\"\"}}'
    )
    it_behaves_like('literal interpolation', '{ bool: { key: true } }', '{:bool=>{:key=>true}}')
    it_behaves_like('literal interpolation', '{ bool: { key: false } }', '{:bool=>{:key=>false}}')
    it_behaves_like('literal interpolation', '{ nil: { key: nil } }', '{:nil=>{:key=>nil}}')
    it_behaves_like('literal interpolation', '{ symbol: { key: :symbol } }',
                    '{:symbol=>{:key=>:symbol}}')
    it_behaves_like('literal interpolation', '{ symbol: { key: :"symbol" } }',
                    '{:symbol=>{:key=>:symbol}}')
    it_behaves_like('literal interpolation',
                    '{ single_quot_symbol: { key: :"single_quot_in_symbol: \'" } }',
                    '{:single_quot_symbol=>{:key=>:\"single_quot_in_symbol: \'\"}}')
    it_behaves_like('literal interpolation',
                    "{ double_quot_symbol: { key: :'double_quot_in_symbol: \"' } }",
                    '{:double_quot_symbol=>{:key=>:\"double_quot_in_symbol: \\\\\"\"}}')
    it_behaves_like('literal interpolation',
                    '{ single_quot_symbol_not_in_space: { key: :"single_quot_in_symbol:\'" } }',
                    '{:single_quot_symbol_not_in_space=>{:key=>:\"single_quot_in_symbol:\'\"}}')
    it_behaves_like('literal interpolation',
                    '{ single_quot_symbol_in_space: { key: :"single_quot_in_symbol: " } }',
                    '{:single_quot_symbol_in_space=>{:key=>:\"single_quot_in_symbol: \"}}')
    it_behaves_like('literal interpolation', '{ range: { key: 1..2 } }', '{:range=>{:key=>1..2}}')
    it_behaves_like('literal interpolation', '{ range: { key: 1...2 } }', '{:range=>{:key=>1...2}}')
    it_behaves_like('literal interpolation', '{ array: { key: %w[] } }', '{:array=>{:key=>[]}}')
    it_behaves_like('literal interpolation', '{ array: { key: %w[v1] } }',
                    '{:array=>{:key=>[\"v1\"]}}')
    it_behaves_like('literal interpolation', '{ array: { key: %w[v1 v2] } }',
                    '{:array=>{:key=>[\"v1\", \"v2\"]}}')
    it_behaves_like('literal interpolation', '{ array: { key: %i[s1 s2] } }',
                    '{:array=>{:key=>[\"s1\", \"s2\"]}}')
    it_behaves_like('literal interpolation', '{ array: { key: %I[s1 s2] } }',
                    '{:array=>{:key=>[\"s1\", \"s2\"]}}')
    it_behaves_like('literal interpolation', '{ array: { key: %i[s1     s2] } }',
                    '{:array=>{:key=>[\"s1\", \"s2\"]}}')
    it_behaves_like('literal interpolation', '{ array: { key: %i[ s1   s2 ] } }',
                    '{:array=>{:key=>[\"s1\", \"s2\"]}}')
  end

  describe 'type else' do
    it_behaves_like('literal interpolation', 'nil', '')
    it_behaves_like('literal interpolation', 1..2)
    it_behaves_like('literal interpolation', 1...2)
    it_behaves_like('literal interpolation', true)
    it_behaves_like('literal interpolation', false)
  end

  shared_examples 'literal interpolation in words literal' do |prefix|
    let(:word) { 'interpolation' }

    it "accepts interpolation of a string literal with space in #{prefix}[]" do
      expect_no_offenses(<<~RUBY)
        #{prefix}[\#{"this interpolation"} is significant]
      RUBY
    end

    it "accepts interpolation of a symbol literal with space in #{prefix}[]" do
      expect_no_offenses(<<~RUBY)
        #{prefix}[\#{:"this interpolation"} is significant]
      RUBY
    end

    it "accepts interpolation of an array literal containing a string with space in #{prefix}[]" do
      expect_no_offenses(<<~RUBY)
        #{prefix}[\#{["this interpolation"]} is significant]
      RUBY
    end

    it "accepts interpolation of an array literal containing a symbol with space in #{prefix}[]" do
      expect_no_offenses(<<~RUBY)
        #{prefix}[\#{[:"this interpolation"]} is significant]
      RUBY
    end

    it "removes interpolation of a string literal without space in #{prefix}[]" do
      expect_offense(<<~'RUBY', prefix: prefix, literal: word.inspect)
        %{prefix}[this #{%{literal}} is not significant]
        _{prefix}        ^{literal} Literal interpolation detected.
      RUBY

      expect_correction(<<~RUBY)
        #{prefix}[this #{word} is not significant]
      RUBY
    end

    it "removes interpolation of a symbol literal without space in #{prefix}[]" do
      expect_offense(<<~'RUBY', prefix: prefix, literal: word.to_sym.inspect)
        %{prefix}[this #{%{literal}} is not significant]
        _{prefix}        ^{literal} Literal interpolation detected.
      RUBY

      expect_correction(<<~RUBY)
        #{prefix}[this #{word} is not significant]
      RUBY
    end

    it "removes interpolation of an array containing a string literal without space in #{prefix}[]" do
      expect_offense(<<~'RUBY', prefix: prefix, literal: [word].inspect)
        %{prefix}[this #{%{literal}} is not significant]
        _{prefix}        ^{literal} Literal interpolation detected.
      RUBY

      expect_correction(<<~RUBY)
        #{prefix}[this #{[word].inspect.gsub(/"/, '\"')} is not significant]
      RUBY
    end

    it "removes interpolation of an array containing a symbol literal without space in #{prefix}[]" do
      expect_offense(<<~'RUBY', prefix: prefix, literal: [word.to_sym].inspect)
        %{prefix}[this #{%{literal}} is not significant]
        _{prefix}        ^{literal} Literal interpolation detected.
      RUBY

      expect_correction(<<~RUBY)
        #{prefix}[this #{[word.to_sym].inspect} is not significant]
      RUBY
    end
  end

  it_behaves_like('literal interpolation in words literal', '%W')
  it_behaves_like('literal interpolation in words literal', '%I')

  it 'handles nested interpolations when autocorrecting' do
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

  it 'handles double quotes in single quotes when autocorrecting' do
    expect_offense(<<~'RUBY')
      "this is #{'"'} silly"
                 ^^^ Literal interpolation detected.
    RUBY

    expect_correction(<<~'RUBY')
      "this is \" silly"
    RUBY
  end

  it 'handles backslash in single quotes when autocorrecting' do
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

  it 'handles backslash in double quotes when autocorrecting' do
    expect_offense(<<~'RUBY')
      "this is #{"\n"} silly"
                 ^^^^ Literal interpolation detected.
      "this is #{%(\n)} silly"
                 ^^^^^ Literal interpolation detected.
      "this is #{%Q(\n)} silly"
                 ^^^^^^ Literal interpolation detected.
    RUBY

    expect_correction(<<~RUBY)
      "this is#{trailing_whitespace}
       silly"
      "this is#{trailing_whitespace}
       silly"
      "this is#{trailing_whitespace}
       silly"
    RUBY
  end

  it 'does not register an offense when space literal at the end of heredoc line' do
    expect_no_offenses(<<~RUBY)
      <<~HERE
        Line with explicit space literal at the end. \#{'  '}
      HERE
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
        `this is the #{expected}`
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
