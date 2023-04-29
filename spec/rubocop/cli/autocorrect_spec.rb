# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --autocorrect', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  before do
    RuboCop::ConfigLoader.default_configuration = nil
    RuboCop::ConfigLoader.default_configuration.for_all_cops['SuggestExtensions'] = false
  end

  it 'does not correct ExtraSpacing in a hash that would be changed back' do
    create_file('.rubocop.yml', <<~YAML)
      Layout/HashAlignment:
        EnforcedColonStyle: table
      Lint/UselessAssignment:
        Enabled: false
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
    expect(File.read('example.rb')).to eq(source)
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

      Lint/UselessAssignment:
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
    expect(cli.run(['--autocorrect-all'])).to eq(1)

    expect(File.read('example.rb')).to eq(<<~RUBY)
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

  it 'corrects `Layout/SpaceAroundOperators` and `Layout/ExtraSpacing` ' \
     'offenses when using `ForceEqualSignAlignment: true`' do
    create_file('.rubocop.yml', <<~YAML)
      Layout/ExtraSpacing:
        ForceEqualSignAlignment: true
      Lint/UselessAssignment:
        Enabled: false
    YAML

    create_file('example.rb', <<~RUBY)
      test123456                = nil
      test1234                   = nil
      test1_test2_test3_test4_12 =nil
    RUBY

    expect(cli.run(['--autocorrect-all'])).to eq(1)

    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      test123456                 = nil
      test1234                   = nil
      test1_test2_test3_test4_12 = nil
    RUBY
  end

  it 'does not correct SpaceAroundOperators in a hash that would be changed back' do
    create_file('.rubocop.yml', <<~YAML)
      Style/HashSyntax:
        EnforcedStyle: hash_rockets

      Layout/HashAlignment:
        EnforcedHashRocketStyle: table

      Lint/UselessAssignment:
        Enabled: false
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)

    # 1=>2 is changed to 1 => 2. The rest is unchanged.
    # SpaceAroundOperators leaves it to HashAlignment when the style is table.
    expect(File.read('example.rb')).to eq(<<~RUBY)
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

  it 'corrects `EnforcedStyle: hash_rockets` of `Style/HashSyntax` with `Layout/HashAlignment`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/HashSyntax:
        EnforcedStyle: hash_rockets
    YAML
    source = <<~RUBY
      some_method(a: 'abc', b: 'abc',
              c: 'abc', d: 'abc'
              )
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect-all',
                     '--only', 'Style/HashSyntax,Style/HashAlignment'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      some_method(:a => 'abc', :b => 'abc',
                  :c => 'abc', :d => 'abc'
              )
    RUBY
  end

  it 'corrects `EnforcedShorthandSyntax: always` of `Style/HashSyntax` with `Style/RedundantParentheses` when using Ruby 3.1' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 3.1
      Style/HashSyntax:
        EnforcedShorthandSyntax: always
      Style/RedundantParentheses:
        Enabled: true
      Style/MethodCallWithArgsParentheses:
        Enabled: true
        EnforcedStyle: omit_parentheses
    YAML
    source = <<~RUBY
      it 'fails' do
        foo = create :foo, bar: bar, other: (create :other, bar: bar)
        quux = (doo bar: bar).baz
        pass
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--autocorrect', '--only',
                    'Style/HashSyntax,' \
                    'Style/RedundantParentheses,' \
                    'Style/MethodCallWithArgsParentheses'])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      it 'fails' do
        foo = create :foo, bar:, other: (create :other, bar:)
        quux = (doo bar:).baz
        pass
      end
    RUBY
  end

  it 'corrects `EnforcedShorthandSyntax: always` of `Style/HashSyntax` with `Style/IfUnlessModifier` when using Ruby 3.1' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 3.1
      Style/HashSyntax:
        EnforcedShorthandSyntax: always
    YAML
    source = <<~RUBY
      if condition
        do_something foo: foo
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--autocorrect', '--only', 'Style/HashSyntax,Style/IfUnlessModifier'])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      do_something(foo:) if condition
    RUBY
  end

  it 'corrects `EnforcedStyle: line_count_based` of `Style/BlockDelimiters` with `Style/CommentedKeyword` and `Layout/BlockEndNewline`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/BlockDelimiters:
        EnforcedStyle: line_count_based
    YAML
    source = <<~RUBY
      foo {
      bar } # This comment should be kept.
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect',
                     '--only', 'Style/BlockDelimiters,Style/CommentedKeyword,Layout/BlockEndNewline'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # This comment should be kept.
      foo do
      bar
      end
    RUBY
  end

  it 'corrects `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with `Style/NestedParenthesizedCalls`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/MethodCallWithArgsParentheses:
        EnforcedStyle: require_parentheses
    YAML
    source = <<~RUBY
      a(b 1)
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect-all',
                     '--only', 'Style/MethodCallWithArgsParentheses,Style/NestedParenthesizedCalls'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      a(b(1))
    RUBY
  end

  it 'corrects `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with `Style/RescueModifier`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/MethodCallWithArgsParentheses:
        EnforcedStyle: require_parentheses
    YAML
    source = <<~RUBY
      do_something arg rescue nil
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect-all',
                     '--only', 'Style/MethodCallWithArgsParentheses,Style/RescueModifier'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      begin
        do_something(arg)
      rescue
        nil
      end
    RUBY
  end

  it 'corrects `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with ' \
     '`EnforcedStyle: conditionals` of `Style/AndOr`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/MethodCallWithArgsParentheses:
        EnforcedStyle: require_parentheses
      Style/AndOr:
        EnforcedStyle: conditionals
    YAML
    create_file('example.rb', <<~RUBY)
      if foo and bar :arg
      end
    RUBY
    expect(
      cli.run(['--autocorrect-all', '--only', 'Style/MethodCallWithArgsParentheses,Style/AndOr'])
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      if foo && bar(:arg)
      end
    RUBY
  end

  it 'corrects `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with ' \
     '`Lint/AmbiguousOperator`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/MethodCallWithArgsParentheses:
        EnforcedStyle: require_parentheses
    YAML
    create_file('example.rb', <<~RUBY)
      def foo(&block)
        do_something &block
      end
    RUBY
    expect(
      cli.run(
        ['--autocorrect', '--only', 'Style/MethodCallWithArgsParentheses,Lint/AmbiguousOperator']
      )
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      def foo(&block)
        do_something(&block)
      end
    RUBY
  end

  it 'corrects `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with ' \
     '`Layout/SpaceBeforeFirstArg`' do
    create_file('.rubocop.yml', <<~YAML)
      Style/MethodCallWithArgsParentheses:
        EnforcedStyle: require_parentheses
    YAML
    create_file('example.rb', <<~RUBY)
      obj.do_something"message"
    RUBY
    expect(
      cli.run(
        [
          '--autocorrect',
          '--only', 'Style/MethodCallWithArgsParentheses,Layout/SpaceBeforeFirstArg'
        ]
      )
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      obj.do_something("message")
    RUBY
  end

  it 'corrects `Style/IfUnlessModifier` with `Style/SoleNestedConditional`' do
    source = <<~RUBY
      def foo
        # NOTE: comment
        if a? && b?
          puts "looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong message" unless c?
        end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect-all',
                     '--only', 'Style/IfUnlessModifier,Style/SoleNestedConditional'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      def foo
        # NOTE: comment
        if a? && b? && !c?
            puts "looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong message"
          end
      end
    RUBY
  end

  it 'corrects `Style/SoleNestedConditional` with `Style/InverseMethods` and `Style/IfUnlessModifier`' do
    source = <<~RUBY
      unless foo.to_s == 'foo'
        if condition
          return foo
        end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(
             [
               '--autocorrect-all',
               '--only', 'Style/SoleNestedConditional,Style/InverseMethods,Style/IfUnlessModifier'
             ]
           )).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      return foo if foo.to_s != 'foo' && condition
    RUBY
  end

  it 'corrects `Lint/UnusedMethodArgument` with `Style/ExplicitBlockArgument`' do
    source = <<~RUBY
      def foo(&block)
        bar { yield }
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect',
                     '--only', 'Lint/UnusedMethodArgument,Style/ExplicitBlockArgument'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      def foo(&block)
        bar(&block)
      end
    RUBY
  end

  it 'corrects `Naming/BlockForwarding` with `Lint/AmbiguousOperator`' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 3.1
    YAML
    source = <<~RUBY
      def foo(options, &block)
        bar **options, &block
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect',
                     '--only', 'Naming/BlockForwarding,Lint/AmbiguousOperator'
                   ])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      def foo(options, &)
        bar(**options, &)
      end
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
        }
      }
    end

    before do
      create_file('example.rb', source)
      create_file('.rubocop.yml', YAML.dump(config))
    end

    shared_examples 'corrects offenses without producing a double comma' do
      it 'corrects TrailingCommaInLiteral and TrailingCommaInArguments ' \
         'without producing a double comma' do
        cli.run(['--autocorrect-all'])

        expect(File.read('example.rb')).to eq(expected_corrected_source)

        expect($stderr.string).to eq('')
      end
    end

    context 'when the style is `comma`' do
      let(:comma_style) { 'comma' }
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

    context 'when the style is `consistent_comma`' do
      let(:comma_style) { 'consistent_comma' }
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
  end

  context 'space_inside_bracket cops' do
    let(:source) do
      <<~RUBY
        puts [ a[b], c[ d ], [1, 2] ]
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
      it 'corrects SpaceInsideArrayLiteralBrackets and SpaceInsideReferenceBrackets' do
        cli.run(['--autocorrect-all'])

        expect(File.read('example.rb')).to eq(corrected_source)

        expect($stderr.string).to eq('')
      end
    end

    context 'when array style is space & reference style is no space' do
      let(:array_style) { 'space' }
      let(:reference_style) { 'no_space' }

      let(:corrected_source) do
        <<~RUBY
          # frozen_string_literal: true

          puts [ a[b], c[d], [ 1, 2 ] ]
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

          puts [a[ b ], c[ d ], [1, 2]]
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

          puts [ a[b], c[d], [ 1, 2 ]]
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

          puts [ a[ b ], c[ d ], [ 1, 2 ]]
          foo[ [ 3, 4 ], [ 5, 6 ] ]
        RUBY
      end

      include_examples 'corrects offenses'
    end
  end

  it 'corrects IndentationWidth, RedundantBegin, and RescueEnsureAlignment offenses' do
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
    corrected = <<~RUBY
      # frozen_string_literal: true

      def verify_section
        scroll_down_until_element_exists
      rescue StandardError
        scroll_down_until_element_exists
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects `Style/RedundantBegin` with `Style/MultilineMemoization`' do
    source = <<~RUBY
      @memo ||= begin
                  if condition
                    do_something
                  end
                end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['-a', '--only', 'Style/RedundantBegin,Style/MultilineMemoization'])).to eq(0)
    corrected = <<~RUBY
      @memo ||= if condition
                    do_something
                  end
      #{trailing_whitespace * 10}
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects `Layout/SpaceAroundKeyword` with `Layout/SpaceInsideRangeLiteral`' do
    source = <<~RUBY
      def method
        1..super
      end
    RUBY
    create_file('example.rb', source)
    expect(
      cli.run(['-a', '--only', 'Layout/SpaceAroundKeyword,Layout/SpaceInsideRangeLiteral'])
    ).to eq(0)
    expect($stdout.string.include?('no offenses detected')).to be(true)
    expect(File.read('example.rb')).to eq(source)
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
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
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects Style/InverseMethods and Style/Not offenses' do
    source = <<~RUBY
      x.select {|y| not y.z }
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--autocorrect-all', '--only', 'Style/InverseMethods,Style/Not'])).to eq(0)
    corrected = <<~RUBY
      x.reject {|y|  y.z }
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects Style/Next and Style/SafeNavigation offenses' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 2.7
    YAML
    source = <<~RUBY
      until x
        if foo
          foo.some_method do
            y
          end
        end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--autocorrect-all', '--only', 'Style/Next,Style/SafeNavigation'])).to eq(0)
    corrected = <<~RUBY
      until x
        next unless foo
        foo.some_method do
          y
        end
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects `Lint/Lambda` and `Lint/UnusedBlockArgument` offenses' do
    source = <<~RUBY
      c = -> event do
        puts 'Hello world'
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run([
                     '--autocorrect-all',
                     '--only', 'Lint/Lambda,Lint/UnusedBlockArgument'
                   ])).to eq(0)
    corrected = <<~RUBY
      c = lambda do |_event|
        puts 'Hello world'
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  describe 'caching' do
    let(:cache) do
      instance_double(RuboCop::ResultCache, 'valid?' => true, 'load' => cached_offenses)
    end
    let(:source) { %(puts "Hi"\n) }

    before do
      allow(RuboCop::ResultCache).to receive(:new) { cache }
      create_file('example.rb', source)
    end

    context 'with no offenses in the cache' do
      let(:cached_offenses) { [] }

      it "doesn't correct offenses" do
        expect(cli.run(['--autocorrect-all'])).to eq(0)
        expect(File.read('example.rb')).to eq(source)
      end
    end

    context 'with an offense in the cache' do
      let(:cached_offenses) { ['Style/StringLiterals: ...'] }

      it 'corrects offenses' do
        allow(cache).to receive(:save)
        expect(cli.run(['--autocorrect-all'])).to eq(0)
        expect(File.read('example.rb')).to eq(<<~RUBY)
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
          Lint/UselessAssignment:
            Enabled: false
          Style/BlockDelimiters:
            EnforcedStyle: #{style}
        YAML
        expect(cli.run(['--autocorrect-all'])).to eq(0)
        # rubocop:disable Style/HashLikeCase
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
        # rubocop:enable Style/HashLikeCase
        expect($stderr.string).to eq('')
        expect(File.read('example.rb')).to eq(corrected)
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
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
    expect(File.read('example.rb')).to eq(corrected)
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
    expect(cli.run(%w[--autocorrect-all --format simple])).to eq(1)
    expect($stdout.string).to eq(<<~RESULT)
      == example.rb ==
      C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
      C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.
      C:  3:  1: Style/Documentation: Missing top-level documentation comment for class A.
      W:  4:  3: [Corrected] Lint/RedundantCopDisableDirective: Unnecessary disabling of Metrics/MethodLength.
      C:  5:  3: [Corrected] Layout/IndentationWidth: Use 2 (not 6) spaces for indentation.
      W:  5: 22: [Corrected] Lint/RedundantCopEnableDirective: Unnecessary enabling of Metrics/MethodLength.
      W:  7: 54: [Corrected] Lint/RedundantCopDisableDirective: Unnecessary disabling of Style/For.
      W:  9:  5: [Corrected] Lint/RedundantCopDisableDirective: Unnecessary disabling of Style/ClassVars.

      1 file inspected, 8 offenses detected, 7 offenses corrected
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
    expect(File.read('example.rb')).to eq(corrected)
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
    expect(cli.run(['--autocorrect-all'])).to eq(1)
    corrected = <<~RUBY
      # frozen_string_literal: true

      def func
        foo
        bar
      rescue StandardError
        baz
      end

      def func
        x
        y
      rescue StandardError
        z
      end

      def method
        BlockA do |_strategy|
          foo
        end

        BlockB do |_portfolio|
          foo
        end
      rescue StandardError # some problem
        bar
      end

      def method
        # comment 1

        do_some_stuff
      rescue StandardError # comment 2
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
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
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects IndentationWidth and IndentationConsistency offenses' do
    source = <<~RUBY
      require 'spec_helper'
      describe ArticlesController do
        render_views
          describe "GET 'index'" do
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
    corrected = <<~RUBY
      # frozen_string_literal: true

      require 'spec_helper'
      describe ArticlesController do
        render_views
        describe "GET 'index'" do
          it 'returns http success' do
          end
          describe 'admin user' do
            before(:each) do
            end
          end
        end
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
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

    source = <<~RUBY
      class Foo
                         private

          def do_something
            # something
          end
      end
    RUBY
    create_file('example.rb', source)

    expect(cli.run([
                     '--autocorrect-all',
                     '--only',
                     [
                       'Layout/AccessModifierIndentation',
                       'Layout/IndentationConsistency',
                       'Layout/IndentationWidth'
                     ].join(',')
                   ])).to eq(0)

    corrected = <<~RUBY
      class Foo
      private

        def do_something
          # something
        end
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects IndentationWidth and IndentationConsistency offenses' \
     'without correcting `Style/TrailingBodyOnClass`' do
    source = <<~RUBY
      class Test foo
          def func1
          end
            def func2
            end
      end
    RUBY
    create_file('example.rb', source)

    expect(cli.run([
                     '--autocorrect-all',
                     '--only',
                     ['Layout/IndentationConsistency', 'Layout/IndentationWidth'].join(',')
                   ])).to eq(0)

    corrected = <<~RUBY
      class Test foo
                 def func1
                 end
                 def func2
                 end
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
  end

  it 'corrects SymbolProc and SpaceBeforeBlockBraces offenses' do
    source = ['foo.map{ |a| a.nil? }']
    create_file('example.rb', source)
    expect(cli.run(['-D', '--autocorrect-all'])).to eq(0)
    corrected = "# frozen_string_literal: true\n\nfoo.map(&:nil?)\n"
    expect(File.read('example.rb')).to eq(corrected)
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
    expect(cli.run(%w[--only IndentationWidth --autocorrect-all])).to eq(0)
    corrected = <<~RUBY
      foo = if bar
              something
      elsif baz
        other_thing
      else
        raise
      end
    RUBY
    expect(File.read('example.rb')).to eq(corrected)
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
    expect($stdout.string.include?('no offenses detected')).to be(true)
    expect(File.read('example.rb')).to eq("#{source}\n")
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

        STUFF = [
                  {
                    some: 'hash',
                  },
                       {
                    another: 'hash',
                    with: 'more'
                  },
                ].freeze
      end
      end
    RUBY
    expect(cli.run(['--autocorrect-all'])).to eq(1)
    expect(File.read('example.rb'))
      .to eq(<<~RUBY)
        # frozen_string_literal: true

        module Bar
          class Goo
            def something
              first call
              do_other 'things'
              return unless other > 34

              more_work
            end
          end
        end

        module Foo
          class Bar
            STUFF = [
              {
                some: 'hash'
              },
              {
                another: 'hash',
                with: 'more'
              }
            ].freeze
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
    expect(cli.run(['--autocorrect-all'])).to eq(1)
    expect(File.read('example.rb'))
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
    expect(cli.run(['--autocorrect-all'])).to eq(0)
    expect(File.read('example.rb'))
      .to eq(<<~RUBY)
        # frozen_string_literal: true

        (1..10).each do |i|
          puts i
        end
      RUBY
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
    expect(cli.run(['--autocorrect-all'])).to eq(1)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
      %w[--autocorrect-all --format emacs --only] << %w[
        WordArray AccessModifierIndentation
        Documentation TrailingCommaInArrayLiteral
      ].join(',')
    )
    expect(exit_status).to eq(1)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      class Dsl
        private
        A = %w[git path]
      end
    RUBY
    e = abs('example.rb')
    expect($stdout.string).to eq(<<~RESULT)
      #{e}:1:1: C: Style/Documentation: Missing top-level documentation comment for `class Dsl`.
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
    expect(cli.run(['--autocorrect-all'])).to eq(1)
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
    create_file('.rubocop.yml', <<~YAML)
      Style/EndlessMethod:
        EnforcedStyle: disallow
    YAML
    create_file('example.rb', <<~RUBY)
      def func1; do_something end # comment
      def func2() do_1; do_2; end
    RUBY
    exit_status = cli.run(
      %w[--autocorrect-all --format offenses --only] << %w[
        SingleLineMethods Semicolon EmptyLineBetweenDefs
        DefWithParentheses TrailingWhitespace TrailingBodyOnMethodDefinition
        DefEndAlignment IndentationConsistency
      ].join(',')
    )
    expect(exit_status).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
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

      4   Layout/TrailingWhitespace
      3   Style/Semicolon
      2   Layout/IndentationConsistency
      2   Style/SingleLineMethods
      1   Layout/DefEndAlignment
      1   Layout/EmptyLineBetweenDefs
      1   Style/DefWithParentheses
      1   Style/TrailingBodyOnMethodDefinition
      --
      15  Total in 1 files

    RESULT
  end

  # In this example, the autocorrection (changing "fail" to "raise")
  # creates a new problem (alignment of parameters), which is also
  # corrected automatically.
  it 'can correct a problems and the problem it creates' do
    create_file('example.rb', <<~RUBY)
      fail NotImplementedError,
           'Method should be overridden in child classes'
    RUBY
    expect(cli.run(['--autocorrect-all', '--only', 'SignalException,ArgumentAlignment'])).to eq(0)
    expect(File.read('example.rb'))
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

  # Thanks to repeated autocorrection, we can get rid of the trailing
  # spaces, and then the extra empty line.
  it 'can correct two problems in the same place' do
    create_file('example.rb', ['# Example class.', 'class Klass', '  ', '  def f; end', 'end'])
    expect(cli.run(['--autocorrect-all', '--only',
                    'Layout/TrailingWhitespace,' \
                    'Layout/EmptyLinesAroundClassBody'])).to eq(0)
    expect(File.read('example.rb'))
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
    expect(cli.run(%w[-D --autocorrect-all
                      --only Style/MethodDefParentheses,Style/SymbolProc]))
      .to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
    expect(cli.run(%w[-D --autocorrect-all --format o --only WordArray,SpaceAfterComma])).to eq(0)
    expect($stdout.string)
      .to eq(<<~RESULT)

        4  Layout/SpaceAfterComma
        2  Style/WordArray
        --
        6  Total in 1 files

      RESULT
    expect(File.read('example.rb'))
      .to eq(<<~RUBY)
        f(type: %w[offline offline_payment],
          bar_colors: %w[958c12 953579 ff5800 0085cc])
      RUBY
  end

  it 'can correct SpaceAfterComma and HashSyntax offenses' do
    create_file('example.rb', "I18n.t('description',:property_name => property.name)")
    expect(cli.run(%w[-D --autocorrect-all --format emacs
                      --only SpaceAfterComma,HashSyntax])).to eq(0)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:21: C: [Corrected] " \
              'Layout/SpaceAfterComma: Space missing after comma.',
              "#{abs('example.rb')}:1:22: C: [Corrected] " \
              'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
              ''].join("\n"))
    expect(File.read('example.rb')).to eq(<<~RUBY)
      I18n.t('description', property_name: property.name)
    RUBY
  end

  it 'can correct HashSyntax and SpaceAroundOperators offenses' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w[-D --autocorrect-all --format emacs
                      --only HashSyntax,SpaceAroundOperators])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
    expect(cli.run(%w[--autocorrect-all -f emacs --only Style/HashSyntax])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq("{ b: 1 }\n")
    expect($stdout.string)
      .to eq("#{abs('example.rb')}:1:3: C: [Corrected] Style/HashSyntax: " \
             "Use the new Ruby 1.9 hash syntax.\n")
  end

  it 'can correct TrailingEmptyLines and TrailingWhitespace offenses' do
    create_file('example.rb', ['# frozen_string_literal: true', '', '  ', '', ''])
    expect(cli.run(%w[--autocorrect-all --format emacs])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
      %w[--autocorrect-all --format emacs
         --only Style/MethodCallWithoutArgsParentheses,Style/EmptyLiteral]
    )
    expect(exit_status).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
    expect(cli.run(%w[--autocorrect-all])).to eq(0)
    expect(File.read('example.rb'))
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

  it 'does not say [Corrected] if correction is not possible' do
    src = <<~RUBY
      func a do b end
      Signal.trap('TERM') { system(cmd); exit }
      def self.some_method(foo, bar: 1)
        log.debug(foo)
      end
    RUBY
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 2.7
      Style/Semicolon:
        AutoCorrect: false
    YAML
    create_file('example.rb', src)
    exit_status = cli.run(
      %w[-a -f simple
         --only Style/BlockDelimiters,Style/Semicolon,Lint/UnusedMethodArgument]
    )
    expect(exit_status).to eq(1)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(src)
    expect($stdout.string).to eq(<<~RESULT)
      == example.rb ==
      C:  1:  8: Style/BlockDelimiters: Prefer {...} over do...end for single-line blocks.
      C:  2: 34: Style/Semicolon: Do not use semicolons to terminate expressions.
      W:  3: 27: Lint/UnusedMethodArgument: Unused method argument - bar.

      1 file inspected, 3 offenses detected
    RESULT
  end

  it 'says [Correctable] if correction is unsafe' do
    src = <<~RUBY
      var = :false
      %w('foo', "bar")
    RUBY
    corrected = <<~RUBY
      var = :false
      %w('foo', "bar")
    RUBY
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 2.7
    YAML
    create_file('example.rb', src)
    exit_status = cli.run(%w[-a -f simple --only Lint/BooleanSymbol,Lint/PercentStringArray])
    expect(exit_status).to eq(1)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(corrected)
    expect($stdout.string).to eq(<<~RESULT)
      == example.rb ==
      W:  1:  7: [Correctable] Lint/BooleanSymbol: Symbol with a boolean name - you probably meant to use false.
      W:  2:  1: [Correctable] Lint/PercentStringArray: Within %w/%W, quotes and ',' are unnecessary and may be unwanted in the resulting strings.

      1 file inspected, 2 offenses detected, 2 more offenses can be corrected with `rubocop -A`
    RESULT
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideParens' do
    create_file('example.rb', 'some_method(a, )')
    Timeout.timeout(10) { expect(cli.run(%w[--autocorrect-all])).to eq(0) }
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      some_method(a)
    RUBY
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideArrayLiteralBrackets' do
    create_file('example.rb', 'puts [1, ]')
    Timeout.timeout(10) { expect(cli.run(%w[--autocorrect-all])).to eq(0) }
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
    expect(cli.run(%w[--autocorrect-all])).to eq(1)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      puts "Hello", 123_456
    RUBY
  end

  it 'handles different SpaceInsideBlockBraces and SpaceInsideHashLiteralBraces' do
    create_file('example.rb', <<~RUBY)
      puts({foo: bar,
       bar: baz,})
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
    expect(cli.run(%w[--autocorrect-all])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      puts({foo: bar,
            bar: baz,})
      foo.each { bar }
    RUBY
  end

  it 'corrects Style/BlockDelimiters offenses when specifying' \
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

    expect(cli.run(%w[--autocorrect-all])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
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
                     '--autocorrect-all',
                     '--only',
                     'Style/BlockDelimiters,Layout/SpaceBeforeBlockBraces'
                   ])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      foo do
        bar
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

    expect(cli.run(%w[--autocorrect-all])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      foo(
        # comment
        <<~SQL.squish)
          SELECT * FROM bar
        SQL
    RUBY
  end

  it 'corrects `Style/InverseMethods` offenses when specifying `IncludeSemanticChanges: false` of ' \
     '`Style/NonNilCheck` and `EnforcedStyle: comparison` of `Style/NilComparison`' do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      !(foo == nil)
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Style/NilComparison:
        Enabled: true
        EnforcedStyle: comparison # alternative config

      Style/NonNilCheck:
        Enabled: true
        IncludeSemanticChanges: false # default config
    YAML

    expect(cli.run([
                     '--autocorrect-all',
                     '--only',
                     'Style/InverseMethods,Style/NonNilCheck,Style/NilComparison'
                   ])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      foo != nil
    RUBY
  end

  it 'corrects Lint/ParenthesesAsGroupedExpression and offenses and ' \
     'accepts Style/RedundantParentheses' do
    create_file('example.rb', <<~RUBY)
      do_something (argument)
    RUBY
    expect(
      cli.run(
        [
          '--autocorrect',
          '--only', 'Lint/ParenthesesAsGroupedExpression,Style/RedundantParentheses'
        ]
      )
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      do_something(argument)
    RUBY
  end

  it 'corrects `Style/TernaryParentheses` offenses and accepts `Lint/ParenthesesAsGroupedExpression`' do
    create_file('example.rb', <<~RUBY)
      json.asdf (foo || bar) ? 1 : 2
    RUBY
    expect(
      cli.run(
        [
          '--autocorrect',
          '--only', 'Lint/ParenthesesAsGroupedExpression,Style/TernaryParentheses'
        ]
      )
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      json.asdf foo || bar ? 1 : 2
    RUBY
  end

  %i[
    consistent_relative_to_receiver
    special_for_inner_method_call
    special_for_inner_method_call_in_parentheses
  ].each do |style|
    it 'does not crash `Layout/ArgumentAlignment` and offenses and accepts `Layout/FirstArgumentIndentation` ' \
       'when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` ' \
       "and `EnforcedStyle: #{style}` of `Layout/FirstArgumentIndentation`" do
      create_file('example.rb', <<~RUBY)
        # frozen_string_literal: true

        expect(response).to redirect_to(path(
          obj1,
          id: obj2.id
        ))
      RUBY

      create_file('.rubocop.yml', <<~YAML)
        Layout/ArgumentAlignment:
          EnforcedStyle: with_fixed_indentation
        Layout/FirstArgumentIndentation:
          EnforcedStyle: #{style} # Not `EnforcedStyle: consistent`.
      YAML

      expect(cli.run([
                       '--autocorrect',
                       '--only',
                       'Layout/ArgumentAlignment,Layout/FirstArgumentIndentation'
                     ])).to eq(0)
      expect($stderr.string).to eq('')
      expect(File.read('example.rb')).to eq(<<~RUBY)
        # frozen_string_literal: true

        expect(response).to redirect_to(path(
          obj1,
          id: obj2.id
        ))
      RUBY
    end
  end

  it 'registers an offense and corrects when using `Layout/ArgumentAlignment`, `Layout/FirstArgumentIndentation`, and `Layout/FirstMethodArgumentLineBreak` ' \
     'and specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` ' \
     'and `EnforcedStyle: consistent` of `Layout/FirstArgumentIndentation`' do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      it do
          expect(do_something).to eq([
          'foo',
          'bar'
        ])
      end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_fixed_indentation
      Layout/FirstArgumentIndentation:
        EnforcedStyle: consistent
      Layout/FirstMethodArgumentLineBreak:
        Enabled: true
    YAML

    expect(cli.run(['--autocorrect', '--only', %w[
      Layout/ArgumentAlignment Layout/FirstArgumentIndentation Layout/FirstMethodArgumentLineBreak
      Layout/IndentationWidth
    ].join(',')])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      it do
        expect(do_something).to eq(
          [
            'foo',
            'bar'
          ])
      end
    RUBY
  end

  it 'corrects when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and ' \
     '`EnforcedStyle: consistent` of `Layout/FirstArgumentIndentation`' do
    create_file('example.rb', <<~RUBY)
            # frozen_string_literal: true

            def do_even_more_stuff
            foo = begin
      do_stuff(
                      a: 1,
                               b: 2,
                               c: 3
                              )
                                    rescue StandardError
                             nil
      end
        foo
      end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_fixed_indentation
      Layout/FirstArgumentIndentation:
        EnforcedStyle: consistent
    YAML

    expect(cli.run(['--autocorrect'])).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      # frozen_string_literal: true

      def do_even_more_stuff
        do_stuff(
          a: 1,
          b: 2,
          c: 3
        )
      rescue StandardError
        nil
      end
    RUBY
  end

  it 'corrects when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and ' \
     '`Layout/HashAlignment`' do
    create_file('example.rb', <<~RUBY)
      update(foo: bar,
          baz: boo,
          pony: party)

      self&.update(foo: bar,
          baz: boo,
          pony: party)

      foo
       .do_something(foo: bar,
                     baz: qux)

      do_something.(foo: bar, baz: qux,
                    quux: corge)

      do_something(
        arg, foo: bar,
          baz: qux
      )
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_fixed_indentation
    YAML

    expect(
      cli.run(['--autocorrect', '--only', 'Layout/ArgumentAlignment,Layout/HashAlignment'])
    ).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      update(foo: bar,
        baz: boo,
        pony: party)

      self&.update(foo: bar,
        baz: boo,
        pony: party)

      foo
       .do_something(foo: bar,
         baz: qux)

      do_something.(foo: bar, baz: qux,
        quux: corge)

      do_something(
        arg, foo: bar,
        baz: qux
      )
    RUBY
  end

  it 'corrects when specifying `EnforcedStyle: with_first_argument` of `Layout/ArgumentAlignment` and ' \
     '`EnforcedColonStyle: separator` of `Layout/HashAlignment`' do
    create_file('example.rb', <<~RUBY)
      attr_reader_with_default componentList: ['all'],
                         componentFileFilter: { 'all' => nil },
                             componentOption: { 'all' => { run_postinstall: true } },
                             descriptionList: {}
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_first_argument
      Layout/HashAlignment:
        EnforcedColonStyle: separator
    YAML

    expect(
      cli.run(['--autocorrect', '--only', 'Layout/ArgumentAlignment,Layout/HashAlignment'])
    ).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      attr_reader_with_default componentList: ['all'],
                         componentFileFilter: { 'all' => nil },
                             componentOption: { 'all' => { run_postinstall: true } },
                             descriptionList: {}
    RUBY
  end

  it 'corrects when specifying `EnforcedStyle: with_first_argument` of `Layout/ArgumentAlignment` and ' \
     '`EnforcedColonStyle: separator` of `Layout/HashAlignment` (`EnforcedColonStyle` is array)' do
    create_file('example.rb', <<~RUBY)
      attr_reader_with_default componentList: ['all'],
                         componentFileFilter: { 'all' => nil },
                             componentOption: { 'all' => { run_postinstall: true } },
                             descriptionList: {}
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_first_argument
      Layout/HashAlignment:
        AllowMultipleStyles: true
        EnforcedColonStyle:
          - separator
    YAML

    expect(
      cli.run(['--autocorrect', '--only', 'Layout/ArgumentAlignment,Layout/HashAlignment'])
    ).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      attr_reader_with_default componentList: ['all'],
                         componentFileFilter: { 'all' => nil },
                             componentOption: { 'all' => { run_postinstall: true } },
                             descriptionList: {}
    RUBY
  end

  it 'corrects when specifying `EnforcedStyle: with_first_argument` of `Layout/ArgumentAlignment` and ' \
     '`EnforcedHashRocketStyle: separator` of `Layout/HashAlignment`' do
    create_file('example.rb', <<~RUBY)
      attr_reader_with_default :componentList => ['all'],
                         :componentFileFilter => { 'all' => nil },
                             :componentOption => { 'all' => { run_postinstall: true } },
                             :descriptionList => {}
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_first_argument
      Layout/HashAlignment:
        EnforcedHashRocketStyle: separator
    YAML

    expect(
      cli.run(['--autocorrect', '--only', 'Layout/ArgumentAlignment,Layout/HashAlignment'])
    ).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      attr_reader_with_default :componentList => ['all'],
                         :componentFileFilter => { 'all' => nil },
                             :componentOption => { 'all' => { run_postinstall: true } },
                             :descriptionList => {}
    RUBY
  end

  it 'corrects when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and ' \
     '`Layout/HashAlignment` and `Layout/FirstHashElementIndentation`' do
    create_file('example.rb', <<~RUBY)
      do_something(
        {
            foo: 'bar',
            baz: 'qux'
        }
      )

      do_something(
            foo: 'bar',
            baz: 'qux'
      )
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/ArgumentAlignment:
        EnforcedStyle: with_fixed_indentation
    YAML

    expect(
      cli.run(
        [
          '--autocorrect',
          '--only',
          'Layout/ArgumentAlignment,Layout/HashAlignment,Layout/FirstHashElementIndentation'
        ]
      )
    ).to eq(0)
    expect($stderr.string).to eq('')
    expect(File.read('example.rb')).to eq(<<~RUBY)
      do_something(
        {
          foo: 'bar',
          baz: 'qux'
        }
      )

      do_something(
        foo: 'bar',
        baz: 'qux'
      )
    RUBY
  end

  it 'does not crash Lint/SafeNavigationWithEmpty and offenses and accepts Style/SafeNavigation ' \
     'when checking `foo&.empty?` in a conditional' do
    create_file('example.rb', <<~RUBY)
      do_something if ENV['VERSION'] && ENV['VERSION'].empty?
    RUBY
    expect(
      cli.run(
        [
          '--autocorrect',
          '--only', 'Lint/SafeNavigationWithEmpty,Style/SafeNavigation'
        ]
      )
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      do_something if ENV['VERSION'] && ENV['VERSION'].empty?
    RUBY
  end

  it 'does not crash when using Lint/SafeNavigationWithEmpty and Layout/EmptyLinesAroundBlockBody' do
    create_file('example.rb', <<~RUBY)
      FactoryBot.define do
        factory :model do
          name { 'value' }

          private { value }
        end
      end
    RUBY

    expect(
      cli.run(
        [
          '--autocorrect',
          '--only', 'Layout/EmptyLinesAroundAccessModifier,Layout/EmptyLinesAroundBlockBody'
        ]
      )
    ).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      FactoryBot.define do
        factory :model do
          name { 'value' }

          private { value }
        end
      end
    RUBY
  end

  it 'corrects TrailingCommaIn(Array|Hash)Literal and Multiline(Array|Hash)BraceLayout offenses' do
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
        '--autocorrect-all',
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

  it 'corrects Layout/RedundantLineBreak and Layout/SingleLineBlockChain offenses' do
    create_file('.rubocop.yml', <<~YAML)
      Layout/RedundantLineBreak:
        Enabled: true
      Layout/SingleLineBlockChain:
        Enabled: true
    YAML

    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      example.select { |item| item.cond? && other }.join('-')
    RUBY

    expect(cli.run(['--autocorrect-all'])).to eq(0)

    expect(source_file.read).to eq(<<~RUBY)
      # frozen_string_literal: true

      example.select { |item| item.cond? && other }
             .join('-')
    RUBY
  end

  it 'corrects `Layout/DotPosition` and `Layout/SingleLineBlockChain` offenses' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      example.select { |item| item.cond? }.
              join('-')
    RUBY

    expect(cli.run(['-a', '--only', 'Layout/DotPosition,Layout/SingleLineBlockChain'])).to eq(0)

    expect(source_file.read).to eq(<<~RUBY)
      example.select { |item| item.cond? }
              .join('-')
    RUBY
  end

  it 'corrects `Layout/DotPosition` and `Style/RedundantSelf` offenses' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      var = self.
        do_something
    RUBY

    expect(cli.run(['-a', '--only', 'Layout/DotPosition,Style/RedundantSelf'])).to eq(0)

    expect(source_file.read).to eq("var = \n  do_something\n")
  end

  it 'does not correct Style/IfUnlessModifier offense disabled by a comment directive and ' \
     'does not fire Lint/RedundantCopDisableDirective offense even though that directive ' \
     'would make the modifier form too long' do
    create_file('.rubocop.yml', <<~YAML)
      Style/FrozenStringLiteralComment:
        Enabled: false
    YAML

    source_file = Pathname('example.rb')
    source = <<~RUBY
      if i > 1 # rubocop:disable Style/IfUnlessModifier
        raise '_______________________________________________________________________'
      end
    RUBY
    create_file(source_file, source)

    status = cli.run(['--autocorrect-all'])
    expect(status).to eq(0)
    expect(source_file.read).to eq(source)
  end

  it 'corrects indentation for a begin/rescue/else/ensure/end block properly' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      def my_func
        puts 'do something outside block'
        begin
        puts 'do something error prone'
        rescue SomeException, SomeOther
         puts 'wrongly indented error handling'
        rescue StandardError
         puts 'another wrongly indented error handling'
        else
           puts 'wrongly indented normal case handling'
        ensure
            puts 'wrongly indented common handling'
        end
      end
    RUBY

    status = cli.run(
      [
        '--autocorrect',
        '--only',
        'Layout/IndentationWidth,Layout/RescueEnsureAlignment,Layout/ElseAlignment'
      ]
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      def my_func
        puts 'do something outside block'
        begin
          puts 'do something error prone'
        rescue SomeException, SomeOther
          puts 'wrongly indented error handling'
        rescue StandardError
          puts 'another wrongly indented error handling'
        else
          puts 'wrongly indented normal case handling'
        ensure
          puts 'wrongly indented common handling'
        end
      end
    RUBY
  end

  it 'consistently quotes symbol keys in a hash using `Lint/SymbolConversion` ' \
     'with `EnforcedStyle: consistent` and `Style/QuotedSymbols`' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      {
        a: 1,
        b: 2,
        'c-d': 3
      }
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Lint/SymbolConversion:
        EnforcedStyle: consistent
      Style/QuotedSymbols:
        EnforcedStyle: double_quotes
    YAML

    status = cli.run(['--autocorrect', '--only', 'Lint/SymbolConversion,Style/QuotedSymbols'])
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      {
        "a": 1,
        "b": 2,
        "c-d": 3
      }
    RUBY
  end

  it 'avoids adding extra spaces when both `Style/Semicolon` and `Style/SingleLineMethods`' \
     'both apply' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      def foo(a) x(1); y(2); z(3); end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Style/Semicolon:
        AllowAsExpressionSeparator: false
    YAML

    status = cli.run(
      %w[--autocorrect --only] << %w[
        Semicolon SingleLineMethods TrailingBodyOnMethodDefinition
        DefEndAlignment TrailingWhitespace IndentationConsistency
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      def foo(a)
        x(1)
        y(2)
        z(3)
      end
    RUBY
  end

  it 'properly corrects when `Style/SoleNestedConditional` and one of ' \
     '`Style/NegatedIf` or `Style/NegatedUnless` detect offenses' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      if !foo?
        if bar?
          do_something
        end
      end

      unless !foo?
        if bar?
          do_something
        end
      end
    RUBY

    status = cli.run(
      %w[--autocorrect --only] << %w[
        NegatedIf NegatedUnless SoleNestedConditional
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      if !foo? && bar?
          do_something
        end

      if !!foo? && bar?
          do_something
        end
    RUBY
  end

  it 'corrects properly when both `Style/MapToHash` and `Style/HashTransformKeys`' \
     'or `Style/HashTransformValues` registers' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      { foo: :bar }.map { |k, v| [k.to_s, v] }.to_h
      { foo: :bar }.map { |k, v| [k, v.to_s] }.to_h
    RUBY

    status = cli.run(
      %w[--autocorrect-all --only] << %w[
        Style/MapToHash Style/HashTransformKeys Style/HashTransformValues
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      { foo: :bar }.transform_keys { |k| k.to_s }
      { foo: :bar }.transform_values { |v| v.to_s }
    RUBY
  end

  it 'does not crash when using `Layout/CaseIndentation` and `Layout/ElseAlignment`' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      case thing
      when 3 then 1
      when 2 then 2
      else 3 end

      case thing
      when 3 then 1
      when 2 then 2 end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/BeginEndAlignment:
        EnforcedStyleAlignWith: start_of_line
        AutoCorrect: true

      Layout/CaseIndentation:
        EnforcedStyle: end
    YAML

    status = cli.run(
      %w[--autocorrect-all -d --only] << %w[
        Layout/CaseIndentation Layout/ElseAlignment
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      case thing
      when 3 then 1
      when 2 then 2
      else 3 end

      case thing
      when 3 then 1
      when 2 then 2 end
    RUBY
  end

  it 'breaks line at the beginning of trailing class/module body without removing a semicolon in the body' \
     'when using `Style/TrailingBodyOnClass` and `Style/TrailingBodyOnModule`' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      class Foo def bar; end
      end
      class Foo bar
        a; b
      end

      module Foo def bar; end
      end
      module Foo bar
        a; b
      end
    RUBY

    status = cli.run(
      %w[--autocorrect --only] << %w[
        Style/TrailingBodyOnClass Style/TrailingBodyOnModule
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      class Foo#{trailing_whitespace}
        def bar; end
      end
      class Foo#{trailing_whitespace}
        bar
        a; b
      end

      module Foo#{trailing_whitespace}
        def bar; end
      end
      module Foo#{trailing_whitespace}
        bar
        a; b
      end
    RUBY
  end

  it 'corrects `Naming/RescuedExceptionsVariableName` and `, `Style/RescueStandardError`' \
     'and `Lint/OverwriteByRescue` offenses' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      begin
        something
      rescue => StandardError
      end
    RUBY

    status = cli.run(
      %w[--autocorrect-all --only] << %w[
        Naming/RescuedExceptionsVariableName
        Style/RescueStandardError
        Lint/ConstantOverwrittenInRescue
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      begin
        something
      rescue StandardError
      end
    RUBY
  end

  it 'indents the elements of a hash in hash based on the parent hash key ' \
     'when the parent hash is a method argument and has following other sibling pairs' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      desc 'Returns your public timeline.' do
        headers XAuthToken: {
          required: true,
          description: 'Validates your identity'
        },
                XOptionalHeader: {
                  required: false,
                  description: 'Not really needed'
                }
      end
      func x: [
        :a,
             :b
      ],
           y: [
        :c,
             :d
      ]
    RUBY

    status = cli.run(
      %w[--autocorrect --only] << %w[
        Layout/FirstHashElementIndentation
        Layout/FirstArrayElementIndentation
        Layout/HashAlignment
        Layout/ArrayAlignment
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      desc 'Returns your public timeline.' do
        headers XAuthToken: {
                  required: true,
                  description: 'Validates your identity'
                },
                XOptionalHeader: {
                  required: false,
                  description: 'Not really needed'
                }
      end
      func x: [
             :a,
             :b
           ],
           y: [
             :c,
             :d
           ]
    RUBY
  end

  it 'properly autocorrects when `Style/TernaryParentheses` requires parentheses ' \
     'that `Style/RedundantParentheses` would otherwise remove' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      foo ? bar : baz
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Style/TernaryParentheses:
        EnforcedStyle: require_parentheses
      Style/RedundantParentheses:
        Enabled: true
    YAML

    status = cli.run(
      %w[--autocorrect-all --only] << %w[
        Style/TernaryParentheses
        Style/RedundantParentheses
      ].join(',')
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      (foo) ? bar : baz
    RUBY
  end

  it 'respects `Lint/ConstantResolution` over `Style/RedundantConstantBase` when enabling`Lint/ConstantResolution`' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      ::RSpec.configure do |config|
      end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Lint/ConstantResolution:
        Enabled: true
    YAML

    status = cli.run(
      %w[--autocorrect-all --only Lint/ConstantResolution,Style/RedundantConstantBase]
    )
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      ::RSpec.configure do |config|
      end
    RUBY
  end

  it 'respects `Style/RedundantConstantBase` over `Lint/ConstantResolution` when disabling`Lint/ConstantResolution`' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      ::RSpec.configure do |config|
      end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Lint/ConstantResolution:
        Enabled: false
    YAML

    status = cli.run(
      %w[--autocorrect-all --only Lint/ConstantResolution,Style/RedundantConstantBase]
    )
    expect(status).to eq(1)
    expect(source_file.read).to eq(<<~RUBY)
      RSpec.configure do |config|
      end
    RUBY
  end

  it 'corrects `Style/AccessModifierDeclarations` offenses when multiple groupable access modifiers are defined' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      class Test
        private def foo; end
        private def bar; end
        def baz; end
      end
    RUBY
    status = cli.run(%w[--autocorrect-all --only Style/AccessModifierDeclarations])
    expect($stdout.string).to eq(<<~RESULT)
      Inspecting 1 file
      C

      Offenses:

      example.rb:2:3: C: [Corrected] Style/AccessModifierDeclarations: private should not be inlined in method definitions.
        private def foo; end
        ^^^^^^^
      example.rb:3:3: C: [Corrected] Style/AccessModifierDeclarations: private should not be inlined in method definitions.
        private def bar; end
        ^^^^^^^

      1 file inspected, 2 offenses detected, 2 offenses corrected
    RESULT
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      class Test
        def baz; end
      private

      def foo; end

      def bar; end
      end
    RUBY
  end

  it 'corrects `Layout/EndAlignment` when `end` is not aligned with beginning of a singleton class definition ' \
     'and EnforcedStyleAlignWith is set to `keyword` style' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      class << self
        end
      puts 1; class << self
        end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/EndAlignment:
        EnforcedStyleAlignWith: keyword
    YAML

    status = cli.run(%w[--autocorrect --only Layout/EndAlignment])
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      class << self
      end
      puts 1; class << self
              end
    RUBY
  end

  it 'corrects `Layout/EndAlignment` when `end` is not aligned with beginning of a singleton class definition ' \
     'and EnforcedStyleAlignWith is set to `variable` style' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      class << self
        end
      puts 1; class << self
        end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/EndAlignment:
        EnforcedStyleAlignWith: variable
    YAML

    status = cli.run(%w[--autocorrect --only Layout/EndAlignment])
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      class << self
      end
      puts 1; class << self
              end
    RUBY
  end

  it 'corrects `Layout/EndAlignment` when `end` is not aligned with start of line ' \
     'and EnforcedStyleAlignWith is set to `start_of_line` style' do
    source_file = Pathname('example.rb')
    create_file(source_file, <<~RUBY)
      class << self
        end
      puts 1; class << self
        end
    RUBY

    create_file('.rubocop.yml', <<~YAML)
      Layout/EndAlignment:
        EnforcedStyleAlignWith: start_of_line
    YAML

    status = cli.run(%w[--autocorrect --only Layout/EndAlignment])
    expect(status).to eq(0)
    expect(source_file.read).to eq(<<~RUBY)
      class << self
      end
      puts 1; class << self
      end
    RUBY
  end
end
