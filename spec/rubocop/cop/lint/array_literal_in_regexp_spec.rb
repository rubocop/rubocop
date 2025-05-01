# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ArrayLiteralInRegexp, :config do
  shared_examples 'character class' do |source, correction|
    it "registers an offense and corrects for `#{source}`" do
      expect_offense(<<~'RUBY', source: source)
        /#{%{source}}/
         ^^^{source}^ Use a character class instead of interpolating an array in a regexp.
      RUBY

      expect_correction("#{correction}\n")
    end
  end

  shared_examples 'alternation' do |source, correction|
    it "registers an offense and corrects for `#{source}`" do
      expect_offense(<<~'RUBY', source: source)
        /#{%{source}}/
         ^^^{source}^ Use alternation instead of interpolating an array in a regexp.
      RUBY

      expect_correction("#{correction}\n")
    end
  end

  shared_examples 'offense' do |source|
    it "registers an offense but does not correct for `#{source}`" do
      expect_offense(<<~'RUBY', source: source)
        /#{%{source}}/
         ^^^{source}^ Use alternation or a character class instead of interpolating an array in a regexp.
      RUBY

      expect_no_corrections
    end
  end

  it_behaves_like 'character class', '%w[a]', '/[a]/'
  it_behaves_like 'character class', '%w[a b c]', '/[abc]/'
  it_behaves_like 'character class', '["a", "b", "c"]', '/[abc]/'
  it_behaves_like 'character class', '%i[a b c]', '/[abc]/'
  it_behaves_like 'character class', '[:a, :b, :c]', '/[abc]/'
  it_behaves_like 'character class', '[1, 2, 3]', '/[123]/'
  it_behaves_like 'character class', '%w[^ - $ |]', '/[\^\-\$\|]/'
  it_behaves_like 'character class', '%w[あ い 🐧]', '/[あい🐧]/'

  it_behaves_like 'alternation', '%w[foo]', '/(?:foo)/'
  it_behaves_like 'alternation', '%w[foo bar baz]', '/(?:foo|bar|baz)/'
  it_behaves_like 'alternation', '%w[a b cat]', '/(?:a|b|cat)/'
  it_behaves_like 'alternation', '[1.0, 2.5, 4.7]', '/(?:1\.0|2\.5|4\.7)/'
  it_behaves_like 'alternation', '["a", 5, 18.9]', '/(?:a|5|18\.9)/'
  it_behaves_like 'alternation', '%w[^^ -- $$ || ++ **]', '/(?:\^\^|\-\-|\$\$|\|\||\+\+|\*\*)/'
  it_behaves_like 'alternation', '%w[true false nil]', '/(?:true|false|nil)/'
  it_behaves_like 'alternation', '[true, false, nil]', '/(?:true|false|nil)/'
  it_behaves_like 'alternation', '%w[❤️ 💚 💙]', '/(?:❤️|💚|💙)/'

  it_behaves_like 'offense', '[foo]'
  it_behaves_like 'offense', '["#{foo}"]'
  it_behaves_like 'offense', '[:"#{foo}"]'
  it_behaves_like 'offense', '[`foo`]'
  it_behaves_like 'offense', '[1r]'
  it_behaves_like 'offense', '[1i]'
  it_behaves_like 'offense', '[1..2]'
  it_behaves_like 'offense', '[1...2]'
  it_behaves_like 'offense', '[/abc/]'
  it_behaves_like 'offense', '[[]]'
  it_behaves_like 'offense', '[{}]'

  it 'does not register an offense without interpolation' do
    expect_no_offenses(<<~RUBY)
      /[abc]/
    RUBY
  end

  it 'does not register an offense when the interpolated value is not an array' do
    expect_no_offenses(<<~'RUBY')
      /#{foo}/
    RUBY
  end

  it 'does not register an offense when an interpolated array is inside a string' do
    expect_no_offenses(<<~'RUBY')
      "#{%w[a b c]}"
    RUBY
  end

  it 'does not register an offense with empty interpolation' do
    expect_no_offenses(<<~'RUBY')
      /#{}/
    RUBY
  end
end
