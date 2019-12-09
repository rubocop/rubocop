# frozen_string_literal: true

RSpec.describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  before do
    RuboCop::ConfigLoader.default_configuration = nil
  end

  it 'does not correct ExtraSpacing in a hash that would be changed back' do
    create_file('.rubocop.yml', <<~YAML)
      Layout/HashAlignment:
        EnforcedColonStyle: table
      Style/FrozenStringLiteralComment:
        Enabled: false
    YAML
    source = <<~RUBY
      hash = {
        alice: {
          age:  23,
          role: 'Director'
        },
        bob:   {
          age:  25,
          role: 'Consultant'
        }
      }
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb')).to eq(source)
  end

  it 'plays nicely with default cops in complex ExtraSpacing scenarios' do
    create_file('.rubocop.yml', <<~YAML)
      # These cops change indentation and thus need disabling in order for the
      # ExtraSpacing rules to apply to this scenario.

      Layout/BlockAlignment:
        Enabled: false

      Layout/ExtraSpacing:
        ForceEqualSignAlignment: true

      Layout/MultilineMethodCallBraceLayout:
        Enabled: false
    YAML

    source = <<~RUBY
      def batch
        @areas = params[:param].map do
                        var_1 = 123_456
                        variable_2 = 456_123
                   end
        @another = params[:param].map do
                     char_1 = begin
                                variable_1_1     = 'a'
                                variable_1_20  = 'b'

                                variable_1_300    = 'c'
                                # A Comment
                                variable_1_4000      = 'd'

                                variable_1_50000     = 'e'
                                puts 'a non-assignment statement without a blank line'
                                some_other_length_variable     = 'f'
                              end
                     var_2 = 456_123
                   end

        render json: @areas
      end
    RUBY

    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)

    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      def batch
        @areas   = params[:param].map do
                     var_1      = 123_456
                     variable_2 = 456_123
                   end
        @another = params[:param].map do
                     char_1 = begin
                                variable_1_1  = 'a'
                                variable_1_20 = 'b'

                                variable_1_300  = 'c'
                                # A Comment
                                variable_1_4000 = 'd'

                                variable_1_50000           = 'e'
                                puts 'a non-assignment statement without a blank line'
                                some_other_length_variable = 'f'
                              end
                     var_2  = 456_123
                   end

        render json: @areas
      end
    RUBY
  end

  it 'does not correct SpaceAroundOperators in a hash that would be ' \
     'changed back' do
    create_file('.rubocop.yml', <<~YAML)
      Style/HashSyntax:
        EnforcedStyle: hash_rockets

      Layout/HashAlignment:
        EnforcedHashRocketStyle: table
    YAML
    source = <<~RUBY
      a = { 1=>2, a => b }
      hash = {
        :alice => {
          :age  => 23,
          :role => 'Director'
        },
        :bob   => {
          :age  => 25,
          :role => 'Consultant'
        }
      }
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)

    # 1=>2 is changed to 1 => 2. The rest is unchanged.
    # SpaceAroundOperators leaves it to HashAlignment when the style is table.
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      a = { 1 => 2, a => b }
      hash = {
        :alice => {
          :age  => 23,
          :role => 'Director'
        },
        :bob   => {
          :age  => 25,
          :role => 'Consultant'
        }
      }
    RUBY
  end

  describe 'trailing comma cops' do
    let(:source) do
      <<~RUBY
        func({
          @abc => 0,
          @xyz => 1
        })
        func(
          {
            abc: 0
          }
        )
        func(
          {},
          {
            xyz: 1
          }
        )
      RUBY
    end

    let(:config) do
      {
        'Style/TrailingCommaInArguments' => {
          'EnforcedStyleForMultiline' => comma_style
        },
        'Style/TrailingCommaInArrayLiteral' => {
          'EnforcedStyleForMultiline' => comma_style
        },
        'Style/TrailingCommaInHashLiteral' => {
          'EnforcedStyleForMultiline' => comma_style
        },
        'Style/BracesAroundHashParameters' =>
          braces_around_hash_parameters_config
      }
    end

    before do
      create_file('example.rb', source)
      create_file('.rubocop.yml', YAML.dump(config))
    end

    shared_examples 'corrects offenses without producing a double comma' do
      it 'corrects TrailingCommaInLiteral and TrailingCommaInArguments ' \
         'without producing a double comma' do
        cli.run(['--auto-correct'])

        expect(IO.read('example.rb'))
          .to eq(expected_corrected_source)

        expect($stderr.string).to eq('')
      end
    end

    context 'when the style is `comma`' do
      let(:comma_style) do
        'comma'
      end

      context 'and Style/BracesAroundHashParameters is disabled' do
        let(:braces_around_hash_parameters_config) do
          {
            'Enabled' => false,
            'AutoCorrect' => false,
            'EnforcedStyle' => 'braces'
          }
        end

        let(:expected_corrected_source) do
          <<~RUBY
            # frozen_string_literal: true

            func({
                   @abc => 0,
                   @xyz => 1,
                 })
            func(
              {
                abc: 0,
              },
            )
            func(
              {},
              {
                xyz: 1,
              },
            )
          RUBY
        end

        include_examples 'corrects offenses without producing a double comma'
      end

      context 'and BracesAroundHashParameters style is `no_braces`' do
        let(:braces_around_hash_parameters_config) do
          {
            'EnforcedStyle' => 'no_braces'
          }
        end

        let(:expected_corrected_source) do
          <<~RUBY
            # frozen_string_literal: true

            func(
              @abc => 0,
              @xyz => 1,
            )
            func(
              abc: 0,
            )
            func(
              {},
              xyz: 1,
            )
          RUBY
        end

        include_examples 'corrects offenses without producing a double comma'
      end

      context 'and BracesAroundHashParameters style is `context_dependent`' do
        let(:braces_around_hash_parameters_config) do
          {
            'EnforcedStyle' => 'context_dependent'
          }
        end

        let(:expected_corrected_source) do
          <<~RUBY
            # frozen_string_literal: true

            func(
              @abc => 0,
              @xyz => 1,
            )
            func(
              abc: 0,
            )
            func(
              {},
              {
                xyz: 1,
              },
            )
          RUBY
        end

        include_examples 'corrects offenses without producing a double comma'
      end
    end

    context 'when the style is `consistent_comma`' do
      let(:comma_style) do
        'consistent_comma'
      end

      context 'and Style/BracesAroundHashParameters is disabled' do
        let(:braces_around_hash_parameters_config) do
          {
            'Enabled' => false,
            'AutoCorrect' => false,
            'EnforcedStyle' => 'braces'
          }
        end

        let(:expected_corrected_source) do
          <<~RUBY
            # frozen_string_literal: true

            func({
                   @abc => 0,
                   @xyz => 1,
                 })
            func(
              {
                abc: 0,
              },
            )
            func(
              {},
              {
                xyz: 1,
              },
            )
          RUBY
        end

        include_examples 'corrects offenses without producing a double comma'
      end

      context 'and BracesAroundHashParameters style is `no_braces`' do
        let(:braces_around_hash_parameters_config) do
          {
            'EnforcedStyle' => 'no_braces'
          }
        end

        let(:expected_corrected_source) do
          <<~RUBY
            # frozen_string_literal: true

            func(
              @abc => 0,
              @xyz => 1,
            )
            func(
              abc: 0,
            )
            func(
              {},
              xyz: 1,
            )
          RUBY
        end

        include_examples 'corrects offenses without producing a double comma'
      end

      context 'and BracesAroundHashParameters style is `context_dependent`' do
        let(:braces_around_hash_parameters_config) do
          {
            'EnforcedStyle' => 'context_dependent'
          }
        end

        let(:expected_corrected_source) do
          <<~RUBY
            # frozen_string_literal: true

            func(
              @abc => 0,
              @xyz => 1,
            )
            func(
              abc: 0,
            )
            func(
              {},
              {
                xyz: 1,
              },
            )
          RUBY
        end

        include_examples 'corrects offenses without producing a double comma'
      end
    end
  end

  context 'space_inside_bracket cops' do
    let(:source) do
      <<~RUBY
        [ a[b], c[ d ], [1, 2] ]
        foo[[ 3, 4 ], [5, 6] ]
      RUBY
    end

    let(:config) do
      {
        'Layout/SpaceInsideArrayLiteralBrackets' => {
          'EnforcedStyle' => array_style
        },
        'Layout/SpaceInsideReferenceBrackets' => {
          'EnforcedStyle' => reference_style
        }
      }
    end

    before do
      create_file('example.rb', source)
      create_file('.rubocop.yml', YAML.dump(config))
    end

    shared_examples 'corrects offenses' do
      it 'corrects SpaceInsideArrayLiteralBrackets and ' \
         'SpaceInsideReferenceBrackets' do
        cli.run(['--auto-correct'])

        expect(IO.read('example.rb'))
          .to eq(corrected_source)

        expect($stderr.string).to eq('')
      end
    end

    context 'when array style is space & reference style is no space' do
      let(:array_style) { 'space' }
      let(:reference_style) { 'no_space' }

      let(:corrected_source) do
        <<~RUBY
          # frozen_string_literal: true

          [ a[b], c[d], [ 1, 2 ] ]
          foo[[ 3, 4 ], [ 5, 6 ]]
        RUBY
      end

      include_examples 'corrects offenses'
    end

    context 'when array style is no_space & reference style is space' do
      let(:array_style) { 'no_space' }
      let(:reference_style) { 'space' }

      let(:corrected_source) do
        <<~RUBY
          # frozen_string_literal: true

          [a[ b ], c[ d ], [1, 2]]
          foo[ [3, 4], [5, 6] ]
        RUBY
      end

      include_examples 'corrects offenses'
    end

    context 'when array style is compact & reference style is no_space' do
      let(:array_style) { 'compact' }
      let(:reference_style) { 'no_space' }

      let(:corrected_source) do
        <<~RUBY
          # frozen_string_literal: true

          [ a[b], c[d], [ 1, 2 ]]
          foo[[ 3, 4 ], [ 5, 6 ]]
        RUBY
      end

      include_examples 'corrects offenses'
    end

    context 'when array style is compact & reference style is space' do
      let(:array_style) { 'compact' }
      let(:reference_style) { 'space' }

      let(:corrected_source) do
        <<~RUBY
          # frozen_string_literal: true

          [ a[ b ], c[ d ], [ 1, 2 ]]
          foo[ [ 3, 4 ], [ 5, 6 ] ]
        RUBY
      end

      include_examples 'corrects offenses'
    end
  end

  it 'corrects IndentationWidth, RedundantBegin, and ' \
     'RescueEnsureAlignment offenses' do
    source = <<~RUBY
      def verify_section
            begin
            scroll_down_until_element_exists
            rescue StandardError
              scroll_down_until_element_exists
              end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<~RUBY
      # frozen_string_literal: true

      def verify_section
        scroll_down_until_element_exists
      rescue StandardError
        scroll_down_until_element_exists
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects LineEndConcatenation offenses leaving the ' \
     'RedundantInterpolation offense unchanged' do
    # If we change string concatenation from plus to backslash, the string
    # literal that follows must remain a string literal.
    source = <<~'RUBY'
      puts 'foo' +
           "#{bar}"
      puts 'a' +
        'b'
      "#{c}"
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ['# frozen_string_literal: true',
                 '',
                 "puts 'foo' \\",
                 '     "#{bar}"',
                 # Expressions that need correction from only one of these cops
                 # are corrected as expected.
                 "puts 'a' \\",
                 "     'b'",
                 'c.to_s',
                 ''].join("\n")
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects Style/InverseMethods and Style/Not offenses' do
    source = <<~'RUBY'
      x.select {|y| not y.z }
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--auto-correct',
                     '--only', 'Style/InverseMethods,Style/Not'
                   ])).to eq(0)
    corrected = <<~'RUBY'
      x.reject {|y|  y.z }
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects Style/Next and Style/SafeNavigation offenses' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 2.3
    YAML
    source = <<~'RUBY'
      until x
        if foo
          foo.some_method do
            y
          end
        end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--auto-correct',
                     '--only', 'Style/Next,Style/SafeNavigation'
                   ])).to eq(0)
    corrected = <<~'RUBY'
      until x
        next unless foo
        foo.some_method do
          y
        end
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects `Lint/Lambda` and `Lint/UnusedBlockArgument` offenses' do
    source = <<~'RUBY'
      c = -> event do
        puts 'Hello world'
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--auto-correct',
                     '--only', 'Lint/Lambda,Lint/UnusedBlockArgument'
                   ])).to eq(0)
    corrected = <<~'RUBY'
      c = lambda do |_event|
        puts 'Hello world'
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  describe 'caching' do
    let(:cache) do
      instance_double(RuboCop::ResultCache, 'valid?' => true,
                                            'load' => cached_offenses)
    end
    let(:source) { %(puts "Hi"\n) }

    before do
      allow(RuboCop::ResultCache).to receive(:new) { cache }
      create_file('example.rb', source)
    end

    context 'with no offenses in the cache' do
      let(:cached_offenses) { [] }

      it "doesn't correct offenses" do
        expect(cli.run(['--auto-correct'])).to eq(0)
        expect(IO.read('example.rb')).to eq(source)
      end
    end

    context 'with an offense in the cache' do
      let(:cached_offenses) { ['Style/StringLiterals: ...'] }

      it 'corrects offenses' do
        allow(cache).to receive(:save)
        expect(cli.run(['--auto-correct'])).to eq(0)
        expect(IO.read('example.rb')).to eq(<<~RUBY)
          # frozen_string_literal: true

          puts 'Hi'
        RUBY
      end
    end
  end

  %i[line_count_based semantic braces_for_chaining].each do |style|
    context "when BlockDelimiters has #{style} style" do
      it 'corrects SpaceBeforeBlockBraces, SpaceInsideBlockBraces offenses' do
        source = <<~RUBY
          r = foo.map{|a|
            a.bar.to_s
          }
          foo.map{|a|
            a.bar.to_s
          }.baz
        RUBY
        create_file('example.rb', source)
        create_file('.rubocop.yml', <<~YAML)
          Style/BlockDelimiters:
            EnforcedStyle: #{style}
        YAML
        expect(cli.run(['--auto-correct'])).to eq(1)
        corrected = case style
                    when :semantic
                      <<~RUBY
                        # frozen_string_literal: true

                        r = foo.map { |a|
                          a.bar.to_s
                        }
                        foo.map { |a|
                          a.bar.to_s
                        }.baz
                      RUBY
                    when :braces_for_chaining
                      <<~RUBY
                        # frozen_string_literal: true

                        r = foo.map do |a|
                          a.bar.to_s
                        end
                        foo.map { |a|
                          a.bar.to_s
                        }.baz
                      RUBY
                    when :line_count_based
                      <<~RUBY
                        # frozen_string_literal: true

                        r = foo.map do |a|
                          a.bar.to_s
                        end
                        foo.map do |a|
                          a.bar.to_s
                        end.baz
                      RUBY
                    end
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(corrected)
      end
    end
  end

  it 'corrects InitialIndentation offenses' do
    source = <<~RUBY
      # comment 1

      # comment 2
      def func
        begin
          foo
          bar
        rescue StandardError
          baz
        end
      end
    RUBY
    create_file('example.rb', source)
    create_file('.rubocop.yml', <<~YAML)
      Layout/DefEndAlignment:
        AutoCorrect: true
    YAML
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<~RUBY
      # frozen_string_literal: true

      # comment 1

      # comment 2
      def func
        foo
        bar
      rescue StandardError
        baz
      end
    RUBY
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects RedundantCopDisableDirective offenses' do
    source = <<~RUBY
      class A
        # rubocop:disable Metrics/MethodLength
        def func
          # rubocop:enable Metrics/MethodLength
          x = foo # rubocop:disable Lint/UselessAssignment,Style/For
          # rubocop:disable all
          # rubocop:disable Style/ClassVars
          @@bar = "3"
        end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(%w[--auto-correct --format simple])).to eq(1)
    expect($stdout.string).to eq(<<~RESULT)
      == example.rb ==
      C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing magic comment # frozen_string_literal: true.
      C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.
      C:  3:  1: Style/Documentation: Missing top-level class documentation comment.
      W:  4:  3: [Corrected] Lint/RedundantCopDisableDirective: Unnecessary disabling of Metrics/MethodLength.
      C:  5:  1: [Corrected] Layout/EmptyLinesAroundMethodBody: Extra empty line detected at method body beginning.
      C:  5:  1: [Corrected] Layout/TrailingWhitespace: Trailing whitespace detected.
      W:  5: 22: [Corrected] Lint/RedundantCopEnableDirective: Unnecessary enabling of Metrics/MethodLength.
      W:  7: 54: [Corrected] Lint/RedundantCopDisableDirective: Unnecessary disabling of Style/For.
      W:  9:  5: [Corrected] Lint/RedundantCopDisableDirective: Unnecessary disabling of Style/ClassVars.

      1 file inspected, 9 offenses detected, 8 offenses corrected
    RESULT
    corrected = <<~RUBY
      # frozen_string_literal: true

      class A
        def func
          x = foo # rubocop:disable Lint/UselessAssignment
          # rubocop:disable all
          @@bar = "3"
        end
      end
    RUBY
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects RedundantBegin offenses and fixes indentation etc' do
    source = <<~RUBY
        def func
          begin
            foo
            bar
          rescue
            baz
          end
        end

        def func; begin; x; y; rescue; z end end

      def method
        begin
          BlockA do |strategy|
            foo
          end

          BlockB do |portfolio|
            foo
          end

        rescue => e # some problem
          bar
        end
      end

      def method
        begin # comment 1
          do_some_stuff
        rescue # comment 2
        end # comment 3
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)
    corrected = <<~RUBY
      # frozen_string_literal: true

      def func
        foo
        bar
      rescue StandardError
        baz
        end

      def func
        x; y; rescue StandardError; z
      end

      def method
        BlockA do |_strategy|
          foo
        end

        BlockB do |_portfolio|
          foo
        end
      rescue StandardError => e # some problem
        bar
      end

      def method
        # comment 1
        do_some_stuff
      rescue StandardError # comment 2
        # comment 3
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects Tab and IndentationConsistency offenses' do
    source = <<~RUBY
        render_views
          describe 'GET index' do
      \t    it 'returns http success' do
      \t    end
      \tdescribe 'admin user' do
           before(:each) do
      \t    end
      \tend
          end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<~RUBY
      # frozen_string_literal: true

      render_views
      describe 'GET index' do
        it 'returns http success' do
        end
        describe 'admin user' do
          before(:each) do
          end
        end
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects IndentationWidth and IndentationConsistency offenses' do
    source = <<~RUBY
      require 'spec_helper'
      describe ArticlesController do
        render_views
          describe "GET \'index\'" do
                  it "returns http success" do
                  end
              describe "admin user" do
                   before(:each) do
                  end
              end
          end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<~RUBY
      # frozen_string_literal: true

      require 'spec_helper'
      describe ArticlesController do
        render_views
        describe \"GET 'index'\" do
          it 'returns http success' do
          end
          describe 'admin user' do
            before(:each) do
            end
          end
        end
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects IndentationWidth and IndentationConsistency offenses' \
     'when using `EnforcedStyle: outdent` and ' \
     '`EnforcedStyle: indented_internal_methods`' do
    create_file('.rubocop.yml', <<~YAML)
      Layout/AccessModifierIndentation:
        EnforcedStyle: outdent
      Layout/IndentationConsistency:
        EnforcedStyle: indented_internal_methods
    YAML

    source = <<~'RUBY'
      class Foo
                         private

          def do_something
            # something
          end
      end
    RUBY
    create_file('example.rb', source)

    expect(cli.run([
                     '--auto-correct',
                     '--only',
                     [
                       'Layout/AccessModifierIndentation',
                       'Layout/IndentationConsistency',
                       'Layout/IndentationWidth'
                     ].join(',')
                   ])).to eq(0)

    corrected = <<~'RUBY'
      class Foo
      private

        def do_something
          # something
        end
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects SymbolProc and SpaceBeforeBlockBraces offenses' do
    source = ['foo.map{ |a| a.nil? }']
    create_file('example.rb', source)
    expect(cli.run(['-D', '--auto-correct'])).to eq(0)
    corrected = "# frozen_string_literal: true\n\nfoo.map(&:nil?)\n"
    expect(IO.read('example.rb')).to eq(corrected)
    uncorrected = $stdout.string.split($RS).select do |line|
      line.include?('example.rb:') && !line.include?('[Corrected]')
    end
    expect(uncorrected.empty?).to be(true) # Hence exit code 0.
  end

  it 'corrects only IndentationWidth without crashing' do
    source = <<~RUBY
      foo = if bar
        something
      elsif baz
        other_thing
      else
        raise
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(%w[--only IndentationWidth --auto-correct])).to eq(0)
    corrected = <<~RUBY
      foo = if bar
              something
      elsif baz
        other_thing
      else
        raise
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects complicated cases conservatively' do
    # Two cops make corrections here; Style/BracesAroundHashParameters, and
    # Layout/HashAlignment. Because they make minimal corrections relating only
    # to their specific areas, and stay away from cleaning up extra
    # whitespace in the process, the combined changes don't interfere with
    # each other and the result is semantically the same as the starting
    # point.
    source = <<~RUBY
      expect(subject[:address]).to eq({
        street1:     '1 Market',
        street2:     '#200',
        city:        'Some Town',
        state:       'CA',
        postal_code: '99999-1111'
      })
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['-D', '--auto-correct'])).to eq(0)
    corrected =
      <<~RUBY
        # frozen_string_literal: true

        expect(subject[:address]).to eq(
          street1: '1 Market',
          street2: '#200',
          city: 'Some Town',
          state: 'CA',
          postal_code: '99999-1111'
        )
      RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'honors Exclude settings in individual cops' do
    source = 'puts %x(ls)'
    create_file('example.rb', source)
    create_file('.rubocop.yml', <<~YAML)
      Style/CommandLiteral:
        Exclude:
          - example.rb
      Style/FrozenStringLiteralComment:
        Enabled: false
    YAML
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect($stdout.string).to include('no offenses detected')
    expect(IO.read('example.rb')).to eq("#{source}\n")
  end

  it 'corrects code with indentation problems' do
    create_file('example.rb', <<~RUBY)
      module Bar
      class Goo
        def something
          first call
            do_other 'things'
            if other > 34
              more_work
            end
        end
      end
      end

      module Foo
      class Bar

        stuff = [
                  {
                    some: 'hash',
                  },
                       {
                    another: 'hash',
                    with: 'more'
                  },
                ]
      end
      end
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        # frozen_string_literal: true

        module Bar
          class Goo
            def something
              first call
              do_other 'things'
              more_work if other > 34
            end
          end
        end

        module Foo
          class Bar
            stuff = [
              {
                some: 'hash'
              },
              {
                another: 'hash',
                with: 'more'
              }
            ]
          end
        end
      RUBY
  end

  it 'can change block comments and indent them' do
    create_file('example.rb', <<~RUBY)
      module Foo
      class Bar
      =begin
      This is a nice long
      comment
      which spans a few lines
      =end
        def baz
          do_something
        end
      end
      end
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        # frozen_string_literal: true

        module Foo
          class Bar
            # This is a nice long
            # comment
            # which spans a few lines
            def baz
              do_something
            end
          end
        end
      RUBY
  end

  it 'can correct two problems with blocks' do
    # {} should be do..end and space is missing.
    create_file('example.rb', <<~RUBY)
      (1..10).each{ |i|
        puts i
      }
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        # frozen_string_literal: true

        (1..10).each do |i|
          puts i
        end
      RUBY
  end

  it 'can handle spaces when removing braces' do
    create_file('example.rb',
                ["assert_post_status_code 400, 's', {:type => 'bad'}"])
    exit_status = cli.run(
      %w[--auto-correct --format emacs
         --only SpaceInsideHashLiteralBraces,BracesAroundHashParameters]
    )
    expect(exit_status).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        assert_post_status_code 400, 's', :type => 'bad'
      RUBY
    e = abs('example.rb')
    # TODO: Don't report that a problem is corrected when it
    # actually went away due to another correction.
    expect($stdout.string).to eq(<<~RESULT)
      #{e}:1:35: C: [Corrected] Layout/SpaceInsideHashLiteralBraces: Space inside { missing.
      #{e}:1:35: C: [Corrected] Style/BracesAroundHashParameters: Redundant curly braces around a hash parameter.
      #{e}:1:50: C: [Corrected] Layout/SpaceInsideHashLiteralBraces: Space inside } missing.
    RESULT
  end

  # A case where two cops, EmptyLinesAroundBody and EmptyLines, try to
  # remove the same line in autocorrect.
  it 'can correct two empty lines at end of class body' do
    create_file('example.rb', <<~RUBY)
      class Test
        def f
        end


      end
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      class Test
        def f; end
      end
    RUBY
  end

  # A case where WordArray's correction can be clobbered by
  # AccessModifierIndentation's correction.
  it 'can correct indentation and another thing' do
    create_file('example.rb', <<~RUBY)
      class Dsl
      private
        A = ["git", "path",]
      end
    RUBY
    exit_status = cli.run(
      %w[--auto-correct --format emacs --only] << %w[
        WordArray AccessModifierIndentation
        Documentation TrailingCommaInArrayLiteral
      ].join(',')
    )
    expect(exit_status).to eq(1)
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      class Dsl
        private
        A = %w[git path]
      end
    RUBY
    e = abs('example.rb')
    expect($stdout.string).to eq(<<~RESULT)
      #{e}:1:1: C: Style/Documentation: Missing top-level class documentation comment.
      #{e}:2:1: C: [Corrected] Layout/AccessModifierIndentation: Indent access modifiers like `private`.
      #{e}:3:7: C: [Corrected] Style/WordArray: Use `%w` or `%W` for an array of words.
      #{e}:3:21: C: [Corrected] Style/TrailingCommaInArrayLiteral: Avoid comma after the last item of an array.
    RESULT
  end

  # A case where the same cop could try to correct an offense twice in one
  # place.
  it 'can correct empty line inside special form of nested modules' do
    create_file('example.rb', <<~RUBY)
      module A module B

      end end
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      module A
        module B
      end end
    RUBY
    uncorrected = $stdout.string.split($RS).select do |line|
      line.include?('example.rb:') && !line.include?('[Corrected]')
    end
    expect(uncorrected.empty?).to be(false) # Hence exit code 1.
  end

  it 'can correct single line methods' do
    create_file('example.rb', <<~RUBY)
      def func1; do_something end # comment
      def func2() do_1; do_2; end
    RUBY
    exit_status = cli.run(
      %w[--auto-correct --format offenses --only] << %w[
        SingleLineMethods Semicolon EmptyLineBetweenDefs
        DefWithParentheses TrailingWhitespace
      ].join(',')
    )
    expect(exit_status).to eq(0)
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # comment
      def func1
        do_something
      end

      def func2
        do_1
        do_2
      end
    RUBY
    expect($stdout.string).to eq(<<~RESULT)

      6   Layout/TrailingWhitespace
      3   Style/Semicolon
      2   Style/SingleLineMethods
      1   Layout/EmptyLineBetweenDefs
      1   Style/DefWithParentheses
      --
      13  Total

    RESULT
  end

  # In this example, the auto-correction (changing "fail" to "raise")
  # creates a new problem (alignment of parameters), which is also
  # corrected automatically.
  it 'can correct a problems and the problem it creates' do
    create_file('example.rb', <<~RUBY)
      fail NotImplementedError,
           'Method should be overridden in child classes'
    RUBY
    expect(cli.run(['--auto-correct', '--only',
                    'SignalException,ArgumentAlignment'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        raise NotImplementedError,
              'Method should be overridden in child classes'
      RUBY
    expect($stdout.string).to eq(<<~RESULT)
      Inspecting 1 file
      C

      Offenses:

      example.rb:1:1: C: [Corrected] Style/SignalException: Always use raise to signal exceptions.
      fail NotImplementedError,
      ^^^^
      example.rb:2:6: C: [Corrected] Layout/ArgumentAlignment: Align the arguments of a method call if they span more than one line.
           'Method should be overridden in child classes'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

      1 file inspected, 2 offenses detected, 2 offenses corrected
    RESULT
  end

  # Thanks to repeated auto-correction, we can get rid of the trailing
  # spaces, and then the extra empty line.
  it 'can correct two problems in the same place' do
    create_file('example.rb',
                ['# Example class.',
                 'class Klass',
                 '  ',
                 '  def f; end',
                 'end'])
    expect(cli.run(['--auto-correct', '--only',
                    'Layout/TrailingWhitespace,' \
                    'Layout/EmptyLinesAroundClassBody'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        # Example class.
        class Klass
          def f; end
        end
      RUBY
    expect($stderr.string).to eq('')
    expect($stdout.string).to eq(<<~RESULT)
      Inspecting 1 file
      C

      Offenses:

      example.rb:3:1: C: [Corrected] Layout/EmptyLinesAroundClassBody: Extra empty line detected at class body beginning.
      example.rb:3:1: C: [Corrected] Layout/TrailingWhitespace: Trailing whitespace detected.

      1 file inspected, 2 offenses detected, 2 offenses corrected
    RESULT
  end

  it 'can correct MethodDefParentheses and other offense' do
    create_file('example.rb', <<~RUBY)
      def primes limit
        1.upto(limit).select { |i| i.even? }
      end
    RUBY
    expect(cli.run(%w[-D --auto-correct
                      --only Style/MethodDefParentheses,Style/SymbolProc]))
      .to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      def primes(limit)
        1.upto(limit).select(&:even?)
      end
    RUBY
    expect($stdout.string).to eq(<<~RESULT)
      Inspecting 1 file
      C

      Offenses:

      example.rb:1:12: C: [Corrected] Style/MethodDefParentheses: Use def with parentheses when there are parameters.
      def primes limit
                 ^^^^^
      example.rb:2:24: C: [Corrected] Style/SymbolProc: Pass &:even? as an argument to select instead of a block.
        1.upto(limit).select { |i| i.even? }
                             ^^^^^^^^^^^^^^^

      1 file inspected, 2 offenses detected, 2 offenses corrected
    RESULT
  end

  it 'can correct WordArray and SpaceAfterComma offenses' do
    create_file('example.rb', <<~RUBY)
      f(type: ['offline','offline_payment'],
        bar_colors: ['958c12','953579','ff5800','0085cc'])
    RUBY
    expect(cli.run(%w[-D --auto-correct --format o
                      --only WordArray,SpaceAfterComma])).to eq(0)
    expect($stdout.string)
      .to eq(<<~RESULT)

        4  Layout/SpaceAfterComma
        2  Style/WordArray
        --
        6  Total

      RESULT
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        f(type: %w[offline offline_payment],
          bar_colors: %w[958c12 953579 ff5800 0085cc])
      RUBY
  end

  it 'can correct SpaceAfterComma and HashSyntax offenses' do
    create_file('example.rb',
                "I18n.t('description',:property_name => property.name)")
    expect(cli.run(%w[-D --auto-correct --format emacs
                      --only SpaceAfterComma,HashSyntax])).to eq(0)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:21: C: [Corrected] " \
              'Layout/SpaceAfterComma: Space missing after comma.',
              "#{abs('example.rb')}:1:22: C: [Corrected] " \
              'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
              ''].join("\n"))
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      I18n.t('description', property_name: property.name)
    RUBY
  end

  it 'can correct HashSyntax and SpaceAroundOperators offenses' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w[-D --auto-correct --format emacs
                      --only HashSyntax,SpaceAroundOperators])).to eq(0)
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      { b: 1 }
    RUBY
    expect($stdout.string)
      .to eq(<<~RESULT)
        #{abs('example.rb')}:1:3: C: [Corrected] Style/HashSyntax: Use the new Ruby 1.9 hash syntax.
        #{abs('example.rb')}:1:5: C: [Corrected] Layout/SpaceAroundOperators: Surrounding space missing for operator `=>`.
      RESULT
  end

  it 'can correct HashSyntax when --only is used' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w[--auto-correct -f emacs
                      --only Style/HashSyntax])).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("{ b: 1 }\n")
    expect($stdout.string)
      .to eq("#{abs('example.rb')}:1:3: C: [Corrected] Style/HashSyntax: " \
              "Use the new Ruby 1.9 hash syntax.\n")
  end

  it 'can correct TrailingEmptyLines and TrailingWhitespace offenses' do
    create_file('example.rb',
                ['# frozen_string_literal: true',
                 '',
                 '  ',
                 '',
                 ''])
    expect(cli.run(%w[--auto-correct --format emacs])).to eq(0)
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true
    RUBY
    expect($stdout.string).to eq(<<~RESULT)
      #{abs('example.rb')}:2:1: C: [Corrected] Layout/TrailingEmptyLines: 3 trailing blank lines detected.
      #{abs('example.rb')}:3:1: C: [Corrected] Layout/TrailingWhitespace: Trailing whitespace detected.
    RESULT
  end

  it 'can correct MethodCallWithoutArgsParentheses and EmptyLiteral offenses' do
    create_file('example.rb', 'Hash.new()')
    exit_status = cli.run(
      %w[--auto-correct --format emacs
         --only Style/MethodCallWithoutArgsParentheses,Style/EmptyLiteral]
    )
    expect(exit_status).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      {}
    RUBY
    expect($stdout.string).to eq(<<~RESULT)
      #{abs('example.rb')}:1:1: C: [Corrected] Style/EmptyLiteral: Use hash literal `{}` instead of `Hash.new`.
      #{abs('example.rb')}:1:9: C: [Corrected] Style/MethodCallWithoutArgsParentheses: Do not use parentheses for method calls with no arguments.
    RESULT
  end

  it 'can correct IndentHash offenses with separator style' do
    create_file('example.rb', <<~RUBY)
      CONVERSION_CORRESPONDENCE = {
                    match_for_should: :match,
                match_for_should_not: :match_when_negated,
          failure_message_for_should: :failure_message,
      failure_message_for_should_not: :failure_message_when
      }
    RUBY
    create_file('.rubocop.yml', <<~YAML)
      Layout/HashAlignment:
        EnforcedColonStyle: separator
    YAML
    expect(cli.run(%w[--auto-correct])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<~RUBY)
        # frozen_string_literal: true

        CONVERSION_CORRESPONDENCE = {
                        match_for_should: :match,
                    match_for_should_not: :match_when_negated,
              failure_message_for_should: :failure_message,
          failure_message_for_should_not: :failure_message_when
        }.freeze
      RUBY
  end

  it 'does not say [Corrected] if correction was avoided' do
    src = <<~RUBY
      func a do b end
      Signal.trap('TERM') { system(cmd); exit }
      def self.some_method(foo, bar: 1)
        log.debug(foo)
      end
    RUBY
    corrected = <<~RUBY
      func a do b end
      Signal.trap('TERM') { system(cmd); exit }
      def self.some_method(foo, bar: 1)
        log.debug(foo)
      end
    RUBY
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 2.3
    YAML
    create_file('example.rb', src)
    exit_status = cli.run(
      %w[-a -f simple
         --only Style/BlockDelimiters,Style/Semicolon,Lint/UnusedMethodArgument]
    )
    expect(exit_status).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected)
    expect($stdout.string).to eq(<<~RESULT)
      == example.rb ==
      C:  1:  8: Style/BlockDelimiters: Prefer {...} over do...end for single-line blocks.
      C:  2: 34: Style/Semicolon: Do not use semicolons to terminate expressions.
      W:  3: 27: Lint/UnusedMethodArgument: Unused method argument - bar.

      1 file inspected, 3 offenses detected
    RESULT
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideParens' do
    create_file('example.rb', 'some_method(a, )')
    Timeout.timeout(10) do
      expect(cli.run(%w[--auto-correct])).to eq(0)
    end
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      some_method(a)
    RUBY
  end

  it 'does not hang SpaceAfterPunctuation and ' \
     'SpaceInsideArrayLiteralBrackets' do
    create_file('example.rb', 'puts [1, ]')
    Timeout.timeout(10) do
      expect(cli.run(%w[--auto-correct])).to eq(0)
    end
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      puts [1]
    RUBY
  end

  it 'can be disabled for any cop in configuration' do
    create_file('example.rb', 'puts "Hello", 123456')
    create_file('.rubocop.yml', <<~YAML)
      Style/StringLiterals:
        AutoCorrect: false
    YAML
    expect(cli.run(%w[--auto-correct])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      puts \"Hello\", 123_456
    RUBY
  end

  it 'handles different SpaceInsideBlockBraces and ' \
     'SpaceInsideHashLiteralBraces' do
    create_file('example.rb', <<~RUBY)
      {foo: bar,
       bar: baz,}
      foo.each {bar;}
    RUBY
    create_file('.rubocop.yml', <<~YAML)
      Layout/SpaceInsideBlockBraces:
        EnforcedStyle: space
      Layout/SpaceInsideHashLiteralBraces:
        EnforcedStyle: no_space
      Style/TrailingCommaInHashLiteral:
        EnforcedStyleForMultiline: consistent_comma
    YAML
    expect(cli.run(%w[--auto-correct])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      {foo: bar,
       bar: baz,}
      foo.each { bar; }
    RUBY
  end

  it 'corrects Style/BlockDelimiters offenses when specifing' \
     'Layout/SpaceInsideBlockBraces together' do
    create_file('example.rb', <<~RUBY)
      each {
      }
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/SpaceInsideBlockBraces:
        EnforcedStyle: space
      Style/BlockDelimiters:
        EnforcedStyle: line_count_based
    YAML

    expect(cli.run(%w[--auto-correct])).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      each do
      end
    RUBY
  end

  it 'corrects Style/BlockDelimiters offenses when specifying' \
     'Layout/SpaceBeforeBlockBraces with `EnforcedStyle: no_space` together' do
    create_file('example.rb', <<~RUBY)
      foo {
        bar
      }
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/SpaceBeforeBlockBraces:
        EnforcedStyle: no_space
    YAML

    expect(cli.run([
                     '--auto-correct',
                     '--only',
                     'Style/BlockDelimiters,Layout/SpaceBeforeBlockBraces'
                   ])).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      foo do
        bar
      end
    RUBY
  end

  it 'corrects BracesAroundHashParameters offenses leaving the ' \
     'MultilineHashBraceLayout offense unchanged' do
    create_file('example.rb', <<~RUBY)
      def method_a
        do_something({ a: 1,
        })
      end
    RUBY

    expect($stderr.string).to eq('')
    expect(cli.run(%w[--auto-correct])).to eq(0)
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      def method_a
        do_something(a: 1)
      end
    RUBY
  end

  it 'corrects HeredocArgumentClosingParenthesis offenses and ' \
     'ignores TrailingCommaInArguments offense' do
    create_file('example.rb', <<~RUBY)
      result = foo(
        # comment
        <<~SQL.squish
          SELECT * FROM bar
        SQL
      )
    RUBY
    create_file('.rubocop.yml', <<~YAML)
      Layout/HeredocArgumentClosingParenthesis:
        Enabled: true
      Style/TrailingCommaInArguments:
        Enabled: true
        EnforcedStyleForMultiline: comma
    YAML

    expect(cli.run(%w[--auto-correct])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      result = foo(
        # comment
        <<~SQL.squish)
          SELECT * FROM bar
        SQL
    RUBY
  end

  it 'corrects TrailingCommaIn(Array|Hash)Literal and ' \
     'Multiline(Array|Hash)BraceLayout offenses' do
    create_file('.rubocop.yml', <<~YAML)
      Style/TrailingCommaInArrayLiteral:
        EnforcedStyleForMultiline: consistent_comma
      Style/TrailingCommaInHashLiteral:
        EnforcedStyleForMultiline: consistent_comma
    YAML

    source_file = Pathname('example.rb')
    source = <<~RUBY
      [ 1,
        2
      ].to_s

      { foo: 1,
        bar: 2
      }.to_s
    RUBY
    create_file(source_file, source)

    status = cli.run(
      [
        '--auto-correct',
        '--only',
        [
          'Style/TrailingCommaInArrayLiteral',
          'Style/TrailingCommaInHashLiteral',
          'Layout/MultilineArrayBraceLayout',
          'Layout/MultilineHashBraceLayout'
        ].join(',')
      ]
    )
    expect(status).to eq(0)

    corrected = <<~RUBY
      [ 1,
        2,].to_s

      { foo: 1,
        bar: 2,}.to_s
    RUBY
    expect(source_file.read).to eq(corrected)
  end
end
