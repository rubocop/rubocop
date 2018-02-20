# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EndAlignment, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'EnforcedStyleAlignWith' => 'keyword', 'AutoCorrect' => true }
  end

  include_examples 'aligned', "\xef\xbb\xbfclass", 'Test', 'end'

  include_examples 'aligned', 'class',  'Test',      'end'
  include_examples 'aligned', 'module', 'Test',      'end'
  include_examples 'aligned', 'if',     'test',      'end'
  include_examples 'aligned', 'unless', 'test',      'end'
  include_examples 'aligned', 'while',  'test',      'end'
  include_examples 'aligned', 'until',  'test',      'end'
  include_examples 'aligned', 'case',   'a when b',  'end'

  include_examples 'misaligned', <<-RUBY, false
    puts 1; class Test
      end
      ^^^ `end` at 2, 2 is not aligned with `class` at 1, 8.

    module Test
      end
      ^^^ `end` at 2, 2 is not aligned with `module` at 1, 0.

    puts 1; class Test
      end
      ^^^ `end` at 2, 2 is not aligned with `class` at 1, 8.

    module Test
      end
      ^^^ `end` at 2, 2 is not aligned with `module` at 1, 0.

    puts 1; if test
      end
      ^^^ `end` at 2, 2 is not aligned with `if` at 1, 8.

    if test
      end
      ^^^ `end` at 2, 2 is not aligned with `if` at 1, 0.

    puts 1; unless test
      end
      ^^^ `end` at 2, 2 is not aligned with `unless` at 1, 8.

    unless test
      end
      ^^^ `end` at 2, 2 is not aligned with `unless` at 1, 0.

    puts 1; while test
      end
      ^^^ `end` at 2, 2 is not aligned with `while` at 1, 8.

    while test
      end
      ^^^ `end` at 2, 2 is not aligned with `while` at 1, 0.

    puts 1; until test
      end
      ^^^ `end` at 2, 2 is not aligned with `until` at 1, 8.

    until test
      end
      ^^^ `end` at 2, 2 is not aligned with `until` at 1, 0.

    puts 1; case a when b
      end
      ^^^ `end` at 2, 2 is not aligned with `case` at 1, 8.

    case a when b
      end
      ^^^ `end` at 2, 2 is not aligned with `case` at 1, 0.
  RUBY

  include_examples 'aligned', 'puts 1; class',  'Test',     '        end'
  include_examples 'aligned', 'puts 1; module', 'Test',     '        end'
  include_examples 'aligned', 'puts 1; if',     'Test',     '        end'
  include_examples 'aligned', 'puts 1; unless', 'Test',     '        end'
  include_examples 'aligned', 'puts 1; while',  'Test',     '        end'
  include_examples 'aligned', 'puts 1; until',  'Test',     '        end'
  include_examples 'aligned', 'puts 1; case',   'a when b', '        end'

  it 'can handle ternary if' do
    expect_no_offenses('a = cond ? x : y')
  end

  it 'can handle modifier if' do
    expect_no_offenses('a = x if cond')
  end

  context 'when EnforcedStyleAlignWith is start_of_line' do
    let(:cop_config) do
      { 'EnforcedStyleAlignWith' => 'start_of_line', 'AutoCorrect' => true }
    end

    include_examples 'aligned', 'puts 1; class',  'Test',     'end'
    include_examples 'aligned', 'puts 1; module', 'Test',     'end'
    include_examples 'aligned', 'puts 1; if',     'test',     'end'
    include_examples 'aligned', 'puts 1; unless', 'test',     'end'
    include_examples 'aligned', 'puts 1; while',  'test',     'end'
    include_examples 'aligned', 'puts 1; until',  'test',     'end'
    include_examples 'aligned', 'puts 1; case',   'a when b', 'end'

    include_examples 'misaligned', <<-RUBY, false
      puts 1; class Test
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; class Test` at 1, 0.

      class Test
        end
        ^^^ `end` at 2, 2 is not aligned with `class Test` at 1, 0.

      puts 1; module Test
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; module Test` at 1, 0.

      module Test
        end
        ^^^ `end` at 2, 2 is not aligned with `module Test` at 1, 0.

      puts 1; if test
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; if test` at 1, 0.

      if test
        end
        ^^^ `end` at 2, 2 is not aligned with `if test` at 1, 0.

      puts 1; unless test
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; unless test` at 1, 0.

      unless test
        end
        ^^^ `end` at 2, 2 is not aligned with `unless test` at 1, 0.

      puts 1; while test
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; while test` at 1, 0.

      while test
        end
        ^^^ `end` at 2, 2 is not aligned with `while test` at 1, 0.

      puts 1; until test
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; until test` at 1, 0.

      until test
        end
        ^^^ `end` at 2, 2 is not aligned with `until test` at 1, 0.

      puts 1; case a when b
        end
        ^^^ `end` at 2, 2 is not aligned with `puts 1; case a when b` at 1, 0.

      case a when b
        end
        ^^^ `end` at 2, 2 is not aligned with `case a when b` at 1, 0.
    RUBY

    include_examples 'misaligned', <<-RUBY, :keyword
      puts(if test
           end)
           ^^^ `end` at 2, 5 is not aligned with `puts(if test` at 1, 0.
    RUBY
  end

  context 'when EnforcedStyleAlignWith is variable' do
    # same as 'EnforcedStyleAlignWith' => 'keyword',
    # as long as assignments or `case` are not involved
    let(:cop_config) do
      { 'EnforcedStyleAlignWith' => 'variable', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', <<-RUBY, false
      class Test
        end
        ^^^ `end` at 2, 2 is not aligned with `class` at 1, 0.

      module Test
             end
             ^^^ `end` at 2, 7 is not aligned with `module` at 1, 0.

      if test
        end
        ^^^ `end` at 2, 2 is not aligned with `if` at 1, 0.

      unless test
        end
        ^^^ `end` at 2, 2 is not aligned with `unless` at 1, 0.

      while test
        end
        ^^^ `end` at 2, 2 is not aligned with `while` at 1, 0.

      until test
        end
        ^^^ `end` at 2, 2 is not aligned with `until` at 1, 0.

      case a when b
        end
        ^^^ `end` at 2, 2 is not aligned with `case` at 1, 0.
    RUBY

    include_examples 'aligned', 'class',  'Test',      'end'
    include_examples 'aligned', 'module', 'Test',      'end'
    include_examples 'aligned', 'if',     'test',      'end'
    include_examples 'aligned', 'unless', 'test',      'end'
    include_examples 'aligned', 'while',  'test',      'end'
    include_examples 'aligned', 'until',  'test',      'end'
    include_examples 'aligned', 'case',   'a when b',  'end'

    include_examples 'misaligned', <<-RUBY, :start_of_line
      puts 1; class Test
      end
      ^^^ `end` at 2, 0 is not aligned with `class` at 1, 8.

      puts 1; module Test
      end
      ^^^ `end` at 2, 0 is not aligned with `module` at 1, 8.

      puts 1; if test
      end
      ^^^ `end` at 2, 0 is not aligned with `if` at 1, 8.

      puts 1; unless test
      end
      ^^^ `end` at 2, 0 is not aligned with `unless` at 1, 8.

      puts 1; while test
      end
      ^^^ `end` at 2, 0 is not aligned with `while` at 1, 8.

      puts 1; until test
      end
      ^^^ `end` at 2, 0 is not aligned with `until` at 1, 8.

      puts 1; case a when b
      end
      ^^^ `end` at 2, 0 is not aligned with `case` at 1, 8.
    RUBY

    include_examples 'aligned', 'puts 1; class',  'Test',     '        end'
    include_examples 'aligned', 'puts 1; module', 'Test',     '        end'
    include_examples 'aligned', 'puts 1; if',     'Test',     '        end'
    include_examples 'aligned', 'puts 1; unless', 'Test',     '        end'
    include_examples 'aligned', 'puts 1; while',  'Test',     '        end'
    include_examples 'aligned', 'puts 1; until',  'Test',     '        end'
    include_examples 'aligned', 'puts 1; case',   'a when b', '        end'
  end

  context 'correct + opposite' do
    let(:source) do
      <<-RUBY.strip_indent
        x = if a
              a1
            end
        y = if b
          b1
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first)
        .to eq('`end` at 6, 0 is not aligned with `if` at 4, 4.')
      expect(cop.highlights.first).to eq('end')
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        x = if a
              a1
            end
        y = if b
          b1
            end
      RUBY
    end
  end

  context 'when end is preceded by something else than whitespace' do
    let(:source) do
      <<-RUBY.strip_indent
        module A
        puts a end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first)
        .to eq('`end` at 2, 7 is not aligned with `module` at 1, 0.')
      expect(cop.highlights.first).to eq('end')
    end

    it "doesn't auto-correct" do
      expect(autocorrect_source(source))
        .to eq(source)
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end
  end

  context 'case as argument' do
    context 'when EnforcedStyleAlignWith is keyword' do
      let(:cop_config) do
        { 'EnforcedStyleAlignWith' => 'keyword', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'test case', 'a when b', '     end'

      include_examples 'misaligned', <<-RUBY, :start_of_line
        test case a when b
        end
        ^^^ `end` at 2, 0 is not aligned with `case` at 1, 5.
      RUBY
    end

    context 'when EnforcedStyleAlignWith is variable' do
      let(:cop_config) do
        { 'EnforcedStyleAlignWith' => 'variable', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'test case', 'a when b', 'end'

      include_examples 'misaligned', <<-RUBY, :keyword
        test case a when b
             end
             ^^^ `end` at 2, 5 is not aligned with `test case` at 1, 0.
      RUBY
    end

    context 'when EnforcedStyleAlignWith is start_of_line' do
      let(:cop_config) do
        { 'EnforcedStyleAlignWith' => 'start_of_line', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'test case a when b', '', 'end'

      include_examples 'misaligned', <<-RUBY, :keyword
        test case a when b
             end
             ^^^ `end` at 2, 5 is not aligned with `test case a when b` at 1, 0.
      RUBY
    end
  end

  context 'regarding assignment' do
    context 'when EnforcedStyleAlignWith is keyword' do
      include_examples 'misaligned', <<-RUBY, :start_of_line
        var = if test
        end
        ^^^ `end` at 2, 0 is not aligned with `if` at 1, 6.

        var = unless test
        end
        ^^^ `end` at 2, 0 is not aligned with `unless` at 1, 6.

        var = while test
        end
        ^^^ `end` at 2, 0 is not aligned with `while` at 1, 6.

        var = until test
        end
        ^^^ `end` at 2, 0 is not aligned with `until` at 1, 6.
      RUBY

      include_examples 'aligned', 'var = if',     'test',     '      end'
      include_examples 'aligned', 'var = unless', 'test',     '      end'
      include_examples 'aligned', 'var = while',  'test',     '      end'
      include_examples 'aligned', 'var = until',  'test',     '      end'
      include_examples 'aligned', 'var = case',   'a when b', '      end'
    end

    context 'when EnforcedStyleAlignWith is variable' do
      let(:cop_config) do
        { 'EnforcedStyleAlignWith' => 'variable', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'var = if',     'test',     'end'
      include_examples 'aligned', 'var = unless', 'test',     'end'
      include_examples 'aligned', 'var = while',  'test',     'end'
      include_examples 'aligned', 'var = until',  'test',     'end'
      include_examples 'aligned', 'var = until',  'test',     'end.ab.join("")'
      include_examples 'aligned', 'var = until',  'test',     'end.ab.tap {}'
      include_examples 'aligned', 'var = case',   'a when b', 'end'
      include_examples 'aligned', "var =\n  if",  'test', '  end'

      include_examples 'misaligned', <<-RUBY, :keyword
        var = if test
              end
              ^^^ `end` at 2, 6 is not aligned with `var = if` at 1, 0.

        var = unless test
              end
              ^^^ `end` at 2, 6 is not aligned with `var = unless` at 1, 0.

        var = while test
              end
              ^^^ `end` at 2, 6 is not aligned with `var = while` at 1, 0.

        var = until test
              end
              ^^^ `end` at 2, 6 is not aligned with `var = until` at 1, 0.
      RUBY

      include_examples 'misaligned', <<-RUBY, :keyword
        var = until test
              end.j
              ^^^ `end` at 2, 6 is not aligned with `var = until` at 1, 0.
      RUBY

      include_examples 'aligned', '@var = if',  'test', 'end'
      include_examples 'aligned', '@@var = if', 'test', 'end'
      include_examples 'aligned', '$var = if',  'test', 'end'
      include_examples 'aligned', 'CNST = if',  'test', 'end'
      include_examples 'aligned', 'a, b = if',  'test', 'end'
      include_examples 'aligned', 'var ||= if', 'test', 'end'
      include_examples 'aligned', 'var &&= if', 'test', 'end'
      include_examples 'aligned', 'var += if',  'test', 'end'
      include_examples 'aligned', 'h[k] = if',  'test', 'end'
      include_examples 'aligned', 'h.k = if',   'test', 'end'

      include_examples 'misaligned', <<-RUBY, :keyword
        var = case a when b
              end
              ^^^ `end` at 2, 6 is not aligned with `var = case` at 1, 0.

        @var = if test
               end
               ^^^ `end` at 2, 7 is not aligned with `@var = if` at 1, 0.

        @@var = if test
                end
                ^^^ `end` at 2, 8 is not aligned with `@@var = if` at 1, 0.

        $var = if test
               end
               ^^^ `end` at 2, 7 is not aligned with `$var = if` at 1, 0.

        CNST = if test
               end
               ^^^ `end` at 2, 7 is not aligned with `CNST = if` at 1, 0.

        a, b = if test
               end
               ^^^ `end` at 2, 7 is not aligned with `a, b = if` at 1, 0.

        var ||= if test
                end
                ^^^ `end` at 2, 8 is not aligned with `var ||= if` at 1, 0.

        var &&= if test
                end
                ^^^ `end` at 2, 8 is not aligned with `var &&= if` at 1, 0.

        var += if test
               end
               ^^^ `end` at 2, 7 is not aligned with `var += if` at 1, 0.

        h[k] = if test
               end
               ^^^ `end` at 2, 7 is not aligned with `h[k] = if` at 1, 0.
      RUBY

      include_examples 'misaligned', <<-RUBY, false
        h.k = if test
                 end
                 ^^^ `end` at 2, 9 is not aligned with `h.k = if` at 1, 0.
      RUBY
    end
  end

  context 'when EnforcedStyleAlignWith is start_of_line' do
    let(:cop_config) do
      { 'EnforcedStyleAlignWith' => 'start_of_line', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', <<-RUBY, :keyword
      var = if test
            end
            ^^^ `end` at 2, 6 is not aligned with `var = if test` at 1, 0.

      var = unless test
            end
            ^^^ `end` at 2, 6 is not aligned with `var = unless test` at 1, 0.

      var = while test
            end
            ^^^ `end` at 2, 6 is not aligned with `var = while test` at 1, 0.

      var = until test
            end
            ^^^ `end` at 2, 6 is not aligned with `var = until test` at 1, 0.

      var = case a when b
            end
            ^^^ `end` at 2, 6 is not aligned with `var = case a when b` at 1, 0.
    RUBY

    include_examples 'aligned', 'var = if',     'test',     'end'
    include_examples 'aligned', 'var = unless', 'test',     'end'
    include_examples 'aligned', 'var = while',  'test',     'end'
    include_examples 'aligned', 'var = until',  'test',     'end'
    include_examples 'aligned', 'var = case',   'a when b', 'end'
  end
end
