# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::CommentConfig do
  subject(:comment_config) { described_class.new(parse_source(source)) }

  describe '#cop_enabled_at_line?' do
    let(:source) do
      [
        '# encoding: utf-8',
        '',
        '# rubocop:disable Metrics/MethodLength with a comment why',
        'def some_method',
        "  puts 'foo'",                                      # 5
        'end',
        '# rubocop:enable Metrics/MethodLength',
        '',
        '# rubocop:disable all',
        'some_method',                                       # 10
        '# rubocop:enable all',
        '',
        "code = 'This is evil.'",
        'eval(code) # rubocop:disable Lint/Eval',
        "puts 'This is not evil.'",                          # 15
        '',
        'def some_method',
        "  puts 'Disabling indented single line' # rubocop:disable " \
        'Metrics/LineLength',
        'end',
        '',                                                  # 20
        'string = <<END',
        'This is a string not a real comment # rubocop:disable Style/Loop',
        'END',
        '',
        'foo # rubocop:disable Style/MethodCallParentheses', # 25
        '',
        '# rubocop:enable Lint/Void',
        '',
        '# rubocop:disable Style/For, Style/Not,Style/Tab',
        'foo',                                               # 30
        '',
        'class One',
        '  # rubocop:disable Style/ClassVars',
        '  @@class_var = 1',
        'end',                                               # 35
        '',
        'class Two',
        '  # rubocop:disable Style/ClassVars',
        '  @@class_var = 2',
        'end',                                               # 40
        '# rubocop:enable Style/Not,Style/Tab',
        '# rubocop:disable Style/Send, Lint/RandOne some comment why',
        '# rubocop:disable Lint/BlockAlignment some comment why',
        '# rubocop:enable Style/Send, Lint/BlockAlignment but why?',
        '# rubocop:enable Lint/RandOne foo bar!',            # 45
        '# rubocop:disable FlatMap',
        '[1, 2, 3, 4].map { |e| [e, e] }.flatten(1)',
        '# rubocop:enable FlatMap',
        '# rubocop:disable RSpec/Example',
        '# rubocop:disable Custom2/Number9'                  # 50
      ]
    end

    def disabled_lines_of_cop(cop)
      (1..source.size).each_with_object([]) do |line_number, disabled_lines|
        enabled = comment_config.cop_enabled_at_line?(cop, line_number)
        disabled_lines << line_number unless enabled
      end
    end

    it 'supports disabling multiple lines with a pair of directive' do
      method_length_disabled_lines =
        disabled_lines_of_cop('Metrics/MethodLength')
      expected_part = (3..6).to_a
      expect(method_length_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'supports enabling/disabling multiple cops in a single directive' do
      not_disabled_lines = disabled_lines_of_cop('Style/Not')
      tab_disabled_lines = disabled_lines_of_cop('Style/Tab')

      expect(not_disabled_lines).to eq(tab_disabled_lines)
      expected_part = (29..41).to_a
      expect(not_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'supports enabling/disabling multiple cops along with a comment' do
      {
        'Style/Send' => 42..44,
        'Lint/RandOne' => 42..45,
        'Lint/BlockAlignment' => 43..44
      }.each do |cop_name, expected|
        actual = disabled_lines_of_cop(cop_name)
        expect(actual & expected.to_a).to eq(expected.to_a)
      end
    end

    it 'supports enabling/disabling cops without a prefix' do
      flat_map_disabled_lines = disabled_lines_of_cop('Performance/FlatMap')

      expected = (46..48).to_a

      expect(flat_map_disabled_lines & expected).to eq(expected)
    end

    it 'supports disabling all lines after a directive' do
      for_disabled_lines = disabled_lines_of_cop('Style/For')
      expected_part = (29..source.size).to_a
      expect(for_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'just ignores unpaired enabling directives' do
      void_disabled_lines = disabled_lines_of_cop('Lint/Void')
      expected_part = (27..source.size).to_a
      expect(void_disabled_lines & expected_part).to be_empty
    end

    it 'supports disabling single line with a directive at end of line' do
      eval_disabled_lines = disabled_lines_of_cop('Lint/Eval')
      expect(eval_disabled_lines).to include(14)
      expect(eval_disabled_lines).not_to include(15)
    end

    it 'handles indented single line' do
      line_length_disabled_lines = disabled_lines_of_cop('Metrics/LineLength')
      expect(line_length_disabled_lines).to include(18)
      expect(line_length_disabled_lines).not_to include(19)
    end

    it 'does not confuse a comment directive embedded in a string literal ' \
       'with a real comment' do
      loop_disabled_lines = disabled_lines_of_cop('Loop')
      expect(loop_disabled_lines).not_to include(22)
    end

    it 'supports disabling all cops except Lint/UnneededDisable with ' \
       'keyword all' do
      expected_part = (9..10).to_a

      cops = RuboCop::Cop::Cop.all.reject do |klass|
        klass == RuboCop::Cop::Lint::UnneededDisable
      end

      cops.each do |cop|
        disabled_lines = disabled_lines_of_cop(cop)
        expect(disabled_lines & expected_part).to eq(expected_part)
      end
    end

    it 'does not confuse a cop name including "all" with all cops' do
      alias_disabled_lines = disabled_lines_of_cop('Alias')
      expect(alias_disabled_lines).not_to include(25)
    end

    it 'can handle double disable of one cop' do
      expect(disabled_lines_of_cop('Style/ClassVars'))
        .to eq([9, 10, 11] + (33..source.size).to_a)
    end

    it 'supports disabling cops with multiple uppercase letters' do
      expect(disabled_lines_of_cop('RSpec/Example')).to include(49)
    end

    it 'supports disabling cops with numbers in their name' do
      expect(disabled_lines_of_cop('Custom2/Number9')).to include(50)
    end
  end
end
