# frozen_string_literal: true

RSpec.describe RuboCop::CommentConfig do
  subject(:comment_config) { described_class.new(parse_source(source)) }

  describe '#cop_enabled_at_line?' do
    let(:source) do
      # rubocop:disable Lint/EmptyExpression, Lint/EmptyInterpolation
      <<~RUBY
        # rubocop:disable Metrics/MethodLength with a comment why
        def some_method
          puts 'foo'                                                        # 03
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable all
        some_method                                                         # 08
        # rubocop:enable all

        code = 'This is evil.'
        eval(code) # rubocop:disable Security/Eval
        puts 'This is not evil.'                                            # 12

        def some_method
          puts 'Disabling indented single line' # rubocop:disable Layout/LineLength
        end
                                                                            # 18
        string = <<~END
        This is a string not a real comment # rubocop:disable Style/Loop
        END

        foo # rubocop:disable Style/MethodCallWithoutArgsParentheses        # 23

        # rubocop:enable Lint/Void

        # rubocop:disable Style/For, Style/Not,Layout/IndentationStyle
        foo                                                                 # 28

        class One
          # rubocop:disable Style/ClassVars
          @@class_var = 1
        end                                                                 # 33

        class Two
          # rubocop:disable Style/ClassVars
          @@class_var = 2
        end                                                                 # 38
        # rubocop:enable Style/Not,Layout/IndentationStyle
        # rubocop:disable Style/Send, Lint/RandOne some comment why
        # rubocop:disable Layout/BlockAlignment some comment why
        # rubocop:enable Style/Send, Layout/BlockAlignment but why?
        # rubocop:enable Lint/RandOne foo bar!                              # 43
        # rubocop:disable Lint/EmptyInterpolation
        "result is #{}"
        # rubocop:enable Lint/EmptyInterpolation
        # rubocop:disable RSpec/Example
        # rubocop:disable Custom2/Number9                                   # 48

        #=SomeDslDirective # rubocop:disable Layout/LeadingCommentSpace
        # rubocop:disable RSpec/Rails/HttpStatus
        it { is_expected.to have_http_status 200 }                          # 52
        # rubocop:enable RSpec/Rails/HttpStatus
      RUBY
      # rubocop:enable Lint/EmptyExpression, Lint/EmptyInterpolation
    end

    def disabled_lines_of_cop(cop)
      (1..source.size).each_with_object([]) do |line_number, disabled_lines|
        enabled = comment_config.cop_enabled_at_line?(cop, line_number)
        disabled_lines << line_number unless enabled
      end
    end

    it 'supports disabling multiple lines with a pair of directive' do
      method_length_disabled_lines = disabled_lines_of_cop('Metrics/MethodLength')
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

    it 'supports disabling cops with multiple levels in department name' do
      disabled_lines = disabled_lines_of_cop('RSpec/Rails/HttpStatus')
      expected_part = (51..53).to_a
      expect(disabled_lines & expected_part).to eq(expected_part)
    end

    it 'supports enabling/disabling cops without a prefix' do
      empty_interpolation_disabled_lines = disabled_lines_of_cop('Lint/EmptyInterpolation')

      expected = (44..46).to_a

      expect(empty_interpolation_disabled_lines & expected).to eq(expected)
    end

    it 'supports disabling all lines after a directive' do
      for_disabled_lines = disabled_lines_of_cop('Style/For')
      expected_part = (27..source.size).to_a
      expect(for_disabled_lines & expected_part).to eq(expected_part)
    end

    it 'just ignores unpaired enabling directives' do
      void_disabled_lines = disabled_lines_of_cop('Lint/Void')
      expected_part = (25..source.size).to_a
      expect(void_disabled_lines & expected_part).to be_empty
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

    it 'does not confuse a comment directive embedded in a string literal with a real comment' do
      loop_disabled_lines = disabled_lines_of_cop('Loop')
      expect(loop_disabled_lines).not_to include(20)
    end

    it 'supports disabling all cops except Lint/RedundantCopDisableDirective and Lint/Syntax with keyword all' do
      expected_part = (7..8).to_a

      excluded = [RuboCop::Cop::Lint::RedundantCopDisableDirective, RuboCop::Cop::Lint::Syntax]
      cops = RuboCop::Cop::Registry.all - excluded
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
      expect(disabled_lines_of_cop('Style/ClassVars')).to eq([7, 8, 9] + (31..source.size).to_a)
    end

    it 'supports disabling cops with multiple uppercase letters' do
      expect(disabled_lines_of_cop('RSpec/Example')).to include(47)
    end

    it 'supports disabling cops with numbers in their name' do
      expect(disabled_lines_of_cop('Custom2/Number9')).to include(48)
    end

    it 'supports disabling cops on a comment line with an EOL comment' do
      expect(disabled_lines_of_cop('Layout/LeadingCommentSpace')).to eq([7, 8, 9, 50])
    end
  end

  describe '#cop_disabled_line_ranges' do
    subject(:range) { comment_config.cop_disabled_line_ranges }

    let(:source) do
      <<~RUBY
        # rubocop:disable Metrics/MethodLength with a comment why
        def some_method
          puts 'foo'
        end
        # rubocop:enable Metrics/MethodLength

        code = 'This is evil.'
        eval(code) # rubocop:disable Security/Eval
        puts 'This is not evil.'
      RUBY
    end

    it 'collects line ranges by disabled cops' do
      expect(range).to eq({ 'Metrics/MethodLength' => [1..5], 'Security/Eval' => [8..8] })
    end
  end

  describe '#extra_enabled_comments' do
    subject(:extra) { comment_config.extra_enabled_comments }

    let(:source) do
      <<~RUBY
        # rubocop:enable Metrics/MethodLength, Security/Eval
        def some_method
          puts 'foo'
        end
      RUBY
    end

    it 'has keys as instances of Parser::Source::Comment for extra enabled comments' do
      key = extra.keys.first

      expect(key).to be_a(Parser::Source::Comment)
      expect(key.text).to eq '# rubocop:enable Metrics/MethodLength, Security/Eval'
    end

    it 'has values as arrays of extra enabled cops' do
      expect(extra.values.first).to eq ['Metrics/MethodLength', 'Security/Eval']
    end
  end

  describe 'comment_only_line?' do
    let(:source) do
      <<~RUBY
        # rubocop:disable Metrics/MethodLength                                01
        def some_method
          puts 'foo'
        end
        # rubocop:enable Metrics/MethodLength                                 05

        code = 'This is evil.'
        eval(code) # rubocop:disable Security/Eval
      RUBY
    end

    context 'when line contains only comment' do
      [1, 5].each do |line_number|
        it 'returns true' do
          expect(comment_config).to be_comment_only_line(line_number)
        end
      end
    end

    context 'when line is empty' do
      [6].each do |line_number|
        it 'returns true' do
          expect(comment_config).to be_comment_only_line(line_number)
        end
      end
    end

    context 'when line contains only code' do
      [2, 3, 4, 7].each do |line_number|
        it 'returns false' do
          expect(comment_config).not_to be_comment_only_line(line_number)
        end
      end
    end

    context 'when line contains code and comment' do
      [8].each do |line_number|
        it 'returns false' do
          expect(comment_config).not_to be_comment_only_line(line_number)
        end
      end
    end
  end

  describe 'push/pop directives' do
    def disabled_lines_of_cop(cop)
      (1..source.size).each_with_object([]) do |line_number, disabled_lines|
        enabled = comment_config.cop_enabled_at_line?(cop, line_number)
        disabled_lines << line_number unless enabled
      end
    end

    context 'with basic push/pop' do
      let(:source) do
        <<~RUBY
          x = 'before'                                     # 01
          # rubocop:push disable Style/StringLiterals
          x = "inside push"                                # 03
          # rubocop:pop
          x = 'after'                                      # 05
        RUBY
      end

      it 'disables cop between push and pop' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(3)
        expect(disabled_lines).not_to include(1, 5)
      end
    end

    context 'with nested push/pop' do
      let(:source) do
        <<~RUBY
          x = 'before'                                     # 01
          # rubocop:push disable Style/StringLiterals
          x = "inside first"                               # 03
          # rubocop:push disable Layout/LineLength
          x = "inside both pushes with a very long line that would normally trigger LineLength, and i know what i'm talking about "  # 05
          # rubocop:pop
          x = "after inner pop"                            # 07
          # rubocop:pop
          x = 'after outer pop'                            # 09
        RUBY
      end

      it 'handles nested push/pop correctly' do
        string_disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(string_disabled_lines).to include(3, 5, 7)
        expect(string_disabled_lines).not_to include(1, 9)

        length_disabled_lines = disabled_lines_of_cop('Layout/LineLength')
        expect(length_disabled_lines).to include(5)
        expect(length_disabled_lines).not_to include(1, 3, 7, 9)
      end
    end

    context 'with push without disable action' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Style/StringLiterals
          x = "before push"                                # 02
          # rubocop:push
          x = "inside push"                                # 04
          # rubocop:enable Style/StringLiterals
          x = 'after enable'                               # 06
          # rubocop:pop
          x = "after pop - should be disabled again"      # 08
        RUBY
      end

      it 'saves and restores the disabled state' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(2, 4, 8)
        expect(disabled_lines).not_to include(6)
      end
    end

    context 'with push enable' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Style/StringLiterals
          x = "before push"                                # 02
          # rubocop:push enable Style/StringLiterals
          x = 'inside push - enabled'                      # 04
          # rubocop:pop
          x = "after pop - disabled again"                 # 06
        RUBY
      end

      it 'enables cop inside push/pop block' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(2, 6)
        expect(disabled_lines).not_to include(4)
      end
    end

    context 'with multiple cops in push' do
      let(:source) do
        <<~RUBY
          # rubocop:push disable Style/StringLiterals, Layout/LineLength
          x = "test with very long line that would normally be flagged by LineLength cop"  # 02
          # rubocop:pop
          x = 'after'                                      # 04
        RUBY
      end

      it 'disables multiple cops' do
        string_disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(string_disabled_lines).to include(2)
        expect(string_disabled_lines).not_to include(4)

        length_disabled_lines = disabled_lines_of_cop('Layout/LineLength')
        expect(length_disabled_lines).to include(2)
        expect(length_disabled_lines).not_to include(4)
      end
    end

    context 'with deeply nested push/pop (5 levels)' do
      let(:source) do
        <<~RUBY
          # rubocop:push disable Style/StringLiterals
          # rubocop:push disable Layout/LineLength
          # rubocop:push disable Metrics/AbcSize
          # rubocop:push disable Naming/VariableName
          # rubocop:push disable Security/Eval
          x = "deeply nested"                              # 06
          # rubocop:pop
          # rubocop:pop
          # rubocop:pop
          # rubocop:pop
          # rubocop:pop
          x = 'all restored'                               # 12
        RUBY
      end

      it 'handles deeply nested push/pop correctly' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(6)
        expect(disabled_lines).not_to include(12)
      end
    end

    context 'with push on same line as code (inline)' do
      let(:source) do
        <<~RUBY
          x = 'before'                                     # 01
          x = "test" # rubocop:push disable Style/StringLiterals
          x = "inside"                                     # 03
          # rubocop:pop
          x = 'after'                                      # 05
        RUBY
      end

      it 'handles inline push (single line directive)' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        # Inline directives are treated as single-line directives
        # So line 2 itself is disabled, but it's treated specially
        expect(disabled_lines).to include(2)
        expect(disabled_lines).not_to include(1, 3, 5)
      end
    end

    context 'with pop on same line as code (inline)' do
      let(:source) do
        <<~RUBY
          # rubocop:push disable Style/StringLiterals
          x = "inside"                                     # 02
          x = 'after' # rubocop:pop
          x = 'way after'                                  # 04
        RUBY
      end

      it 'handles inline pop (single line directive)' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        # The push at line 1 disables from line 2
        # The pop at line 3 (inline) closes the range at line 3
        expect(disabled_lines).to include(2, 3)
        expect(disabled_lines).not_to include(4)
      end
    end

    context 'with multiple push/pop blocks in sequence' do
      let(:source) do
        <<~RUBY
          # First block
          # rubocop:push disable Style/StringLiterals
          x = "block1"                                     # 03
          # rubocop:pop
          x = 'between'                                    # 05
          # Second block
          # rubocop:push disable Style/StringLiterals
          x = "block2"                                     # 08
          # rubocop:pop
          x = 'after'                                      # 10
        RUBY
      end

      it 'handles multiple independent push/pop blocks' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(3, 8)
        expect(disabled_lines).not_to include(5, 10)
      end
    end

    context 'with push/pop around already disabled cop from config' do
      let(:source) do
        <<~RUBY
          # Assume cop is disabled globally
          x = "before push"                                # 02
          # rubocop:push enable Style/StringLiterals
          x = 'enabled inside'                             # 04
          # rubocop:pop
          x = "after pop - disabled again"                 # 06
        RUBY
      end

      it 'handles push enable when cop was enabled' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        # Without config mocking, all lines are enabled by default
        expect(disabled_lines).not_to include(2, 4, 6)
      end
    end

    context 'with interleaved push/pop for different cops' do
      let(:source) do
        <<~RUBY
          # rubocop:push disable Style/StringLiterals
          x = "string disabled"                            # 02
          # rubocop:push disable Layout/LineLength
          y = "both disabled with very long line here"    # 04
          # rubocop:pop  -- pops LineLength
          x = "only string disabled"                       # 06
          # rubocop:push disable Metrics/AbcSize
          z = "string and abc disabled"                    # 08
          # rubocop:pop  -- pops AbcSize
          x = "only string disabled"                       # 10
          # rubocop:pop  -- pops StringLiterals
          x = 'all enabled'                                # 12
        RUBY
      end

      it 'handles interleaved push/pop for different cops' do
        string_disabled = disabled_lines_of_cop('Style/StringLiterals')
        expect(string_disabled).to include(2, 4, 6, 8, 10)
        expect(string_disabled).not_to include(12)

        length_disabled = disabled_lines_of_cop('Layout/LineLength')
        expect(length_disabled).to include(4)
        expect(length_disabled).not_to include(2, 6, 8, 10, 12)

        abc_disabled = disabled_lines_of_cop('Metrics/AbcSize')
        expect(abc_disabled).to include(8)
        expect(abc_disabled).not_to include(2, 4, 6, 10, 12)
      end
    end

    context 'with push disable all' do
      let(:source) do
        <<~RUBY
          x = 'before'                                     # 01
          # rubocop:push disable all
          x = "everything disabled"                        # 03
          # rubocop:pop
          x = 'after'                                      # 05
        RUBY
      end

      it 'handles push disable all' do
        # Test a few cops to ensure "all" works
        string_disabled = disabled_lines_of_cop('Style/StringLiterals')
        expect(string_disabled).to include(3)
        expect(string_disabled).not_to include(1, 5)

        length_disabled = disabled_lines_of_cop('Layout/LineLength')
        expect(length_disabled).to include(3)
        expect(length_disabled).not_to include(1, 5)
      end
    end

    context 'with empty push (no action)' do
      let(:source) do
        <<~RUBY
          x = 'before'                                     # 01
          # rubocop:push
          x = 'inside empty push'                          # 03
          # rubocop:disable Style/StringLiterals
          x = "disabled"                                   # 05
          # rubocop:pop
          x = 'after - should be enabled'                  # 07
        RUBY
      end

      it 'handles empty push that saves and restores state' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(5)
        expect(disabled_lines).not_to include(1, 3, 7)
      end
    end

    context 'with push/pop inside heredoc (should be ignored)' do
      let(:source) do
        <<~RUBY
          text = <<~TEXT
            # rubocop:push disable Style/StringLiterals
            This is just text, not a real directive
            # rubocop:pop
          TEXT
          x = "after heredoc"                              # 06
        RUBY
      end

      it 'ignores directives inside heredoc' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        # The directives inside heredoc should be ignored
        expect(disabled_lines).not_to include(6)
      end
    end

    context 'with push/pop and departments' do
      let(:source) do
        <<~RUBY
          # rubocop:push disable Style
          x = "style disabled"                             # 02
          # rubocop:pop
          x = 'after'                                      # 04
        RUBY
      end

      it 'handles push/pop with department names' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(2)
        expect(disabled_lines).not_to include(4)
      end
    end

    context 'with rapid push/pop/push/pop sequence' do
      let(:source) do
        <<~RUBY
          # rubocop:push disable Style/StringLiterals
          x = "1"                                          # 02
          # rubocop:pop
          x = 'enabled'                                    # 04
          # rubocop:push disable Style/StringLiterals
          x = "2"                                          # 06
          # rubocop:pop
          x = 'enabled'                                    # 08
          # rubocop:push disable Style/StringLiterals
          x = "3"                                          # 10
          # rubocop:pop
          x = 'enabled'                                    # 12
        RUBY
      end

      it 'handles rapid push/pop sequences' do
        disabled_lines = disabled_lines_of_cop('Style/StringLiterals')
        expect(disabled_lines).to include(2, 6, 10)
        expect(disabled_lines).not_to include(4, 8, 12)
      end
    end
  end
end
