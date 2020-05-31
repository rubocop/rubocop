# frozen_string_literal: true

RSpec.describe RuboCop::CommentConfig do
  subject(:comment_config) { described_class.new(parse_source(source)) }

  describe '#cop_enabled_at_line?' do
    let(:source) do
      [
        '# rubocop:disable Metrics/MethodLength with a comment why',
        'def some_method',
        "  puts 'foo'",                                      # 3
        'end',
        '# rubocop:enable Metrics/MethodLength',
        '',
        '# rubocop:disable all',
        'some_method',                                       # 8
        '# rubocop:enable all',
        '',
        "code = 'This is evil.'",
        'eval(code) # rubocop:disable Security/Eval',
        "puts 'This is not evil.'",                          # 12
        '',
        'def some_method',
        "  puts 'Disabling indented single line' # rubocop:disable " \
        'Layout/LineLength',
        'end',
        '',                                                  # 18
        'string = <<END',
        'This is a string not a real comment # rubocop:disable Style/Loop',
        'END',
        '',
        'foo # rubocop:disable Style/MethodCallWithoutArgsParentheses', # 23
        '',
        '# rubocop:enable Lint/Void',
        '',
        '# rubocop:disable Style/For, Style/Not,Layout/IndentationStyle',
        'foo',                                               # 28
        '',
        'class One',
        '  # rubocop:disable Style/ClassVars',
        '  @@class_var = 1',
        'end',                                               # 33
        '',
        'class Two',
        '  # rubocop:disable Style/ClassVars',
        '  @@class_var = 2',
        'end',                                               # 38
        '# rubocop:enable Style/Not,Layout/IndentationStyle',
        '# rubocop:disable Style/Send, Lint/RandOne some comment why',
        '# rubocop:disable Layout/BlockAlignment some comment why',
        '# rubocop:enable Style/Send, Layout/BlockAlignment but why?',
        '# rubocop:enable Lint/RandOne foo bar!',            # 43
        '# rubocop:disable EmptyInterpolation',
        '"result is #{}"',
        '# rubocop:enable Lint/EmptyInterpolation',
        '# rubocop:disable RSpec/Example',
        '# rubocop:disable Custom2/Number9',                 # 48
        '',
        '#=SomeDslDirective # rubocop:disable Layout/LeadingCommentSpace'
      ].join("\n")
    end

    def disabled_lines_of_cop(cop)
      (1..source.lines.count).each_with_object([]) do |line_number, disabled_lines|
        enabled = comment_config.cop_enabled_at_line?(cop, line_number)
        disabled_lines << line_number unless enabled
      end
    end

    it 'supports disabling multiple lines with a pair of directive' do
      method_length_disabled_lines =
        disabled_lines_of_cop('Metrics/MethodLength')
      expected_part = (1..4).to_a
      expect(method_length_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'supports enabling/disabling multiple cops in a single directive' do
      not_disabled_lines = disabled_lines_of_cop('Style/Not')
      tab_disabled_lines = disabled_lines_of_cop('Layout/IndentationStyle')

      expect(not_disabled_lines).to eq(tab_disabled_lines)
      expected_part = (27..39).to_a
      expect(not_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'supports enabling/disabling multiple cops along with a comment' do
      {
        'Style/Send' => 40..42,
        'Lint/RandOne' => 40..43,
        'Layout/BlockAlignment' => 41..42
      }.each do |cop_name, expected|
        actual = disabled_lines_of_cop(cop_name)
        expect(actual & expected.to_a).to eq(expected.to_a)
      end
    end

    it 'supports enabling/disabling cops without a prefix' do
      empty_interpolation_disabled_lines =
        disabled_lines_of_cop('Lint/EmptyInterpolation')

      expected = (44..46).to_a

      expect(empty_interpolation_disabled_lines & expected).to eq(expected)
    end

    it 'supports disabling all lines after a directive' do
      for_disabled_lines = disabled_lines_of_cop('Style/For')
      expected_part = (27..source.lines.size).to_a
      expect(for_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'just ignores unpaired enabling directives' do
      void_disabled_lines = disabled_lines_of_cop('Lint/Void')
      expected_part = (25..source.lines.size).to_a
      expect((void_disabled_lines & expected_part).empty?).to be(true)
    end

    it 'supports disabling single line with a directive at end of line' do
      eval_disabled_lines = disabled_lines_of_cop('Security/Eval')
      expect(eval_disabled_lines).to include(12)
      expect(eval_disabled_lines).not_to include(13)
    end

    it 'handles indented single line' do
      line_length_disabled_lines = disabled_lines_of_cop('Layout/LineLength')
      expect(line_length_disabled_lines).to include(16)
      expect(line_length_disabled_lines).not_to include(18)
    end

    it 'does not confuse a comment directive embedded in a string literal ' \
       'with a real comment' do
      loop_disabled_lines = disabled_lines_of_cop('Loop')
      expect(loop_disabled_lines).not_to include(20)
    end

    it 'supports disabling all cops except Lint/RedundantCopDisableDirective ' \
       'with keyword all' do
      expected_part = (7..8).to_a

      cops = RuboCop::Cop::Cop.all.reject do |klass|
        klass == RuboCop::Cop::Lint::RedundantCopDisableDirective
      end

      cops.each do |cop|
        disabled_lines = disabled_lines_of_cop(cop)
        expect(disabled_lines & expected_part).to eq(expected_part)
      end
    end

    it 'does not confuse a cop name including "all" with all cops' do
      alias_disabled_lines = disabled_lines_of_cop('Alias')
      expect(alias_disabled_lines).not_to include(23)
    end

    it 'can handle double disable of one cop' do
      expect(disabled_lines_of_cop('Style/ClassVars'))
        .to eq([7, 8, 9] + (31..source.lines.size).to_a)
    end

    it 'supports disabling cops with multiple uppercase letters' do
      expect(disabled_lines_of_cop('RSpec/Example')).to include(47)
    end

    it 'supports disabling cops with numbers in their name' do
      expect(disabled_lines_of_cop('Custom2/Number9')).to include(48)
    end

    it 'supports disabling cops on a comment line with an EOL comment' do
      expect(disabled_lines_of_cop('Layout/LeadingCommentSpace'))
        .to eq([7, 8, 9, 50])
    end
  end

  describe '#cop_config_at_line' do
    let(:source) { <<~RUBY }
      # rubocop:set Metrics/AbcSize{Max: 20}
      def method1
      end

      # rubocop:set Metrics/AbcSize{Max: 30}
      def method2
      end

      # rubocop:reset Metrics/AbcSize

      def method3
      end

      # rubocop:set Metrics/AbcSize{Max: 8}
      def method4 # rubocop:set Metrics/AbcSize{Max: 16}
      end
    RUBY

    def cop_config_per_line(cop)
      (1..source.lines.count)
        .map { |line_number| [line_number, comment_config.cop_config_at_line(cop, line_number)] }
        .to_h
    end

    def config_ranges(hash)
      hash.flat_map { |key_range, val| Array(key_range).map { |key| [key, val] } }.to_h
    end

    it 'sets the cop line-by-line' do
      expect(cop_config_per_line('Metrics/AbcSize')).to eq config_ranges(
        1..4 => { 'Max' => 20 },
        5..9 => { 'Max' => 30 },
        10..13 => nil,
        14 => { 'Max' => 8 },
        15 => { 'Max' => 16 },
        16 => { 'Max' => 8 }
      )
    end
  end
end
