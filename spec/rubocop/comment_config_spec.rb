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

    context 'temporarily disable a cop for a problematic block' do
      let(:source) do
        <<~RUBY
          def process_data(input)
            result = input.upcase
            # rubocop:push
            # rubocop:disable Style/GuardClause
            if result.present?
              return result.strip
            end
            # rubocop:pop
            nil
          end
        RUBY
      end

      it 'disables GuardClause only inside push/pop block' do
        disabled = disabled_lines_of_cop('Style/GuardClause')

        # Lines 4-7 should be disabled (push to pop)
        expect(disabled).to include(4, 5, 6, 7)
        # Lines outside push/pop should be enabled
        expect(disabled).not_to include(1, 2, 3, 8, 9, 10)
      end
    end

    context 'enable a disabled cop temporarily' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Metrics/MethodLength
          def long_method
            line1
            line2
            # rubocop:push
            # rubocop:enable Metrics/MethodLength
            def short_method
              line3
            end
            # rubocop:pop
            line4
            line5
          end
        RUBY
      end

      it 'enables MethodLength only inside push/pop block' do
        disabled = disabled_lines_of_cop('Metrics/MethodLength')

        # Lines 1-6 should be disabled (before and including enable)
        expect(disabled).to include(1, 2, 3, 4, 5, 6)
        # Lines 7-9 should be enabled (after enable, inside push/pop)
        expect(disabled).not_to include(7, 8, 9)
        # Lines 10-13 should be disabled (after pop restores state)
        expect(disabled).to include(10, 11, 12, 13)
      end
    end

    context 'multiple cops disabled then one enabled in push/pop' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Style/For, Style/Not
          for x in [1, 2, 3]
            not x.nil?
          end
          # rubocop:push
          # rubocop:enable Style/For
          for y in [4, 5, 6]
            not y.nil?
          end
          # rubocop:pop
          for z in [7, 8, 9]
            not z.nil?
          end
        RUBY
      end

      it 'enables only Style/For inside push/pop, keeps Style/Not disabled' do
        for_disabled = disabled_lines_of_cop('Style/For')
        not_disabled = disabled_lines_of_cop('Style/Not')

        # Style/For: disabled 1-6 (including enable line), enabled 7-9, disabled 10-13
        expect(for_disabled).to include(1, 2, 3, 4, 5, 6)
        expect(for_disabled).not_to include(7, 8, 9)
        expect(for_disabled).to include(10, 11, 12, 13)

        # Style/Not: disabled everywhere (never enabled)
        expect(not_disabled).to include(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
      end
    end

    context 'disable new cop in push/pop, original stays enabled' do
      let(:source) do
        <<~RUBY
          def process
            x = 1
            y = 2
            # rubocop:push
            # rubocop:disable Style/NumericPredicate
            if x.size == 0
              puts 'empty'
            end
            # rubocop:pop
            if y.size == 0
              puts 'also empty'
            end
          end
        RUBY
      end

      it 'disables NumericPredicate only inside push/pop' do
        disabled = disabled_lines_of_cop('Style/NumericPredicate')

        # Lines 5-8 should be disabled (inside push/pop)
        expect(disabled).to include(5, 6, 7, 8)
        # Lines outside should be enabled
        expect(disabled).not_to include(1, 2, 3, 4, 9, 10, 11, 12)
      end
    end

    context 'nested push/pop for complex refactoring' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Metrics/MethodLength
          def complex_method
            step1
            # rubocop:push
            # rubocop:enable Metrics/MethodLength
            # rubocop:disable Style/GuardClause
            def helper_method
              # rubocop:push
              # rubocop:enable Style/GuardClause
              if condition
                return value
              end
              # rubocop:pop
              other_code
            end
            # rubocop:pop
            step2
          end
        RUBY
      end

      it 'handles nested enable/disable correctly' do
        method_length_disabled = disabled_lines_of_cop('Metrics/MethodLength')
        guard_clause_disabled = disabled_lines_of_cop('Style/GuardClause')

        # Metrics/MethodLength: disabled 1-5 (including enable line),
        # enabled 6-15 (after enable), disabled 16-18 (after pop)
        expect(method_length_disabled).to include(1, 2, 3, 4, 5)
        expect(method_length_disabled).not_to include(6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
        expect(method_length_disabled).to include(16, 17, 18)

        # Style/GuardClause: enabled 1-5, disabled 6-9 (including enable line),
        # enabled 10-12, disabled 13-15 (after nested pop), enabled 16-18
        expect(guard_clause_disabled).not_to include(1, 2, 3, 4, 5)
        expect(guard_clause_disabled).to include(6, 7, 8, 9)
        expect(guard_clause_disabled).not_to include(10, 11, 12)
        expect(guard_clause_disabled).to include(13, 14, 15)
        expect(guard_clause_disabled).not_to include(16, 17, 18)
      end
    end

    context 'disable cop for multi-line assignment with push/pop' do
      let(:source) do
        <<~RUBY
          def configure(stage)
            # rubocop:push
            # rubocop:disable Layout/SpaceAroundMethodCallOperator
            self.stage =
              if    'macro'  .start_with? stage; Langeod::MACRO
              elsif 'dynamic'.start_with? stage; Langeod::DYNAMIC
              elsif 'static' .start_with? stage; Langeod::STATIC
              else raise ArgumentError, "invalid stage: \#{stage}"
              end
            # rubocop:pop
            validate_stage
          end
        RUBY
      end

      it 'disables SpaceAroundMethodCallOperator only inside push/pop block' do
        disabled = disabled_lines_of_cop('Layout/SpaceAroundMethodCallOperator')

        # Lines 3-9 should be disabled (from disable to before pop)
        expect(disabled).to include(3, 4, 5, 6, 7, 8, 9)
        # Lines outside push/pop should be enabled
        expect(disabled).not_to include(1, 2, 10, 11, 12)
      end
    end

    context 'push with inline arguments: disable cop temporarily' do
      let(:source) do
        <<~RUBY
          def process_data(input)
            result = input.upcase
            # rubocop:push -Style/GuardClause
            if result.present?
              return result.strip
            end
            # rubocop:pop
            nil
          end
        RUBY
      end

      it 'disables GuardClause only inside push/pop block' do
        disabled = disabled_lines_of_cop('Style/GuardClause')

        # Lines 3-6 should be disabled (from push line to before pop)
        expect(disabled).to include(3, 4, 5, 6)
        # Lines outside push/pop should be enabled
        expect(disabled).not_to include(1, 2, 7, 8, 9)
      end
    end

    context 'push with inline arguments: enable cop temporarily' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Metrics/MethodLength
          def long_method
            line1
            line2
            # rubocop:push +Metrics/MethodLength
            def short_method
              line3
            end
            # rubocop:pop
            line4
            line5
          end
        RUBY
      end

      it 'enables MethodLength only inside push/pop block' do
        disabled = disabled_lines_of_cop('Metrics/MethodLength')

        # Lines 1-4 should be disabled (before push)
        expect(disabled).to include(1, 2, 3, 4)
        # Lines 6-8 should be enabled (after +enable, inside push/pop)
        expect(disabled).not_to include(6, 7, 8)
        # Lines 10-12 should be disabled (after pop restores state)
        expect(disabled).to include(10, 11, 12)
      end
    end

    context 'push with multiple inline arguments' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Style/For, Style/Not
          for x in [1, 2, 3]
            not x.nil?
          end
          # rubocop:push +Style/For -Style/GuardClause
          for y in [4, 5, 6]
            not y.nil?
            if true
              return 1
            end
          end
          # rubocop:pop
          for z in [7, 8, 9]
            not z.nil?
          end
        RUBY
      end

      it 'enables Style/For and disables Style/GuardClause inside push/pop' do
        for_disabled = disabled_lines_of_cop('Style/For')
        not_disabled = disabled_lines_of_cop('Style/Not')
        guard_disabled = disabled_lines_of_cop('Style/GuardClause')

        # Style/For: disabled 1-5, enabled 5-11, disabled 12-16
        expect(for_disabled).to include(1, 2, 3, 4, 5)
        expect(for_disabled).not_to include(6, 7, 8, 9, 10, 11)
        expect(for_disabled).to include(12, 13, 14, 15, 16)

        # Style/Not: disabled everywhere (never enabled)
        expect(not_disabled).to include(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)

        # Style/GuardClause: only disabled inside push/pop (5-11)
        expect(guard_disabled).to include(5, 6, 7, 8, 9, 10, 11)
        expect(guard_disabled).not_to include(1, 2, 3, 4, 12, 13, 14, 15, 16)
      end
    end

    context 'push with arguments should work without separate enable/disable lines' do
      let(:source) do
        <<~RUBY
          def process
            x = 1
            y = 2
            # rubocop:push -Style/NumericPredicate +Metrics/MethodLength
            if x.size == 0
              puts 'empty'
            end
            if y.size == 1
              puts 'one'
            end
            # rubocop:pop
            if y.size == 2
              puts 'two'
            end
          end
        RUBY
      end

      it 'disables NumericPredicate and enables MethodLength only inside push/pop' do
        numeric_disabled = disabled_lines_of_cop('Style/NumericPredicate')
        method_disabled = disabled_lines_of_cop('Metrics/MethodLength')

        # Style/NumericPredicate: disabled 4-10
        expect(numeric_disabled).to include(4, 5, 6, 7, 8, 9, 10)
        expect(numeric_disabled).not_to include(1, 2, 3, 11, 12, 13, 14, 15, 16)

        # Metrics/MethodLength: enabled 4-10
        expect(method_disabled).not_to include(4, 5, 6, 7, 8, 9, 10)
      end
    end
  end
end
