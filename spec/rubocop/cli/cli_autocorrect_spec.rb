# frozen_string_literal: true

describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  before(:each) do
    RuboCop::ConfigLoader.default_configuration = nil
  end

  it 'does not correct ExtraSpacing in a hash that would be changed back' do
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Layout/AlignHash:
        EnforcedColonStyle: table
    YAML
    source = <<-RUBY.strip_indent
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

  it 'does not correct SpaceAroundOperators in a hash that would be ' \
     'changed back' do
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/HashSyntax:
        EnforcedStyle: hash_rockets

      Layout/AlignHash:
        EnforcedHashRocketStyle: table
    YAML
    source = <<-RUBY.strip_indent
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
    # SpaceAroundOperators leaves it to AlignHash when the style is table.
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
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
      <<-RUBY.strip_indent
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
        'Style/TrailingCommaInLiteral' => {
          'EnforcedStyleForMultiline' => comma_style
        },
        'Style/BracesAroundHashParameters' =>
          braces_around_hash_parameters_config
      }
    end

    before do
      create_file('example.rb', source)
    end

    before do
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
          <<-RUBY.strip_indent
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
          <<-RUBY.strip_indent
            func(@abc => 0,
                 @xyz => 1)
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
          <<-RUBY.strip_indent
            func(@abc => 0,
                 @xyz => 1)
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
          <<-RUBY.strip_indent
            func({
                   @abc => 0,
                   @xyz => 1,
                 },)
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
          <<-RUBY.strip_indent
            func(@abc => 0,
                 @xyz => 1,)
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
          <<-RUBY.strip_indent
            func(@abc => 0,
                 @xyz => 1,)
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

  it 'corrects IndentationWidth, RedundantBegin, and ' \
     'RescueEnsureAlignment offenses' do
    source = <<-RUBY.strip_indent
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
    corrected = <<-RUBY.strip_indent
      def verify_section
        scroll_down_until_element_exists
      rescue StandardError
        scroll_down_until_element_exists
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects LineEndConcatenation offenses leaving the ' \
     'UnneededInterpolation offense unchanged' do
    # If we change string concatenation from plus to backslash, the string
    # literal that follows must remain a string literal.
    source = <<-'RUBY'.strip_indent
      puts 'foo' +
           "#{bar}"
      puts 'a' +
        'b'
      "#{c}"
    RUBY
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ["puts 'foo' \\",
                 '     "#{bar}"',
                 # Expressions that need correction from only one of these cops
                 # are corrected as expected.
                 "puts 'a' \\",
                 "     'b'",
                 'c.to_s',
                 ''].join("\n")
    expect(IO.read('example.rb')).to eq(corrected)
  end

  %i[line_count_based semantic braces_for_chaining].each do |style|
    context "when BlockDelimiters has #{style} style" do
      it 'corrects SpaceBeforeBlockBraces, SpaceInsideBlockBraces offenses' do
        source = <<-RUBY.strip_indent
          r = foo.map{|a|
            a.bar.to_s
          }
          foo.map{|a|
            a.bar.to_s
          }.baz
        RUBY
        create_file('example.rb', source)
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Style/BlockDelimiters:
            EnforcedStyle: #{style}
        YAML
        expect(cli.run(['--auto-correct'])).to eq(1)
        corrected = case style
                    when :semantic
                      <<-RUBY.strip_indent
                        r = foo.map { |a|
                          a.bar.to_s
                        }
                        foo.map { |a|
                          a.bar.to_s
                        }.baz
                      RUBY
                    when :braces_for_chaining
                      <<-RUBY.strip_indent
                        r = foo.map do |a|
                          a.bar.to_s
                        end
                        foo.map { |a|
                          a.bar.to_s
                        }.baz
                      RUBY
                    when :line_count_based
                      <<-RUBY.strip_indent
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
    source = <<-RUBY.strip_indent
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
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Lint/DefEndAlignment:
        AutoCorrect: true
    YAML
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<-RUBY.strip_indent
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

  it 'corrects UnneededDisable offenses' do
    source = <<-RUBY.strip_indent
      class A
        # rubocop:disable Metrics/MethodLength
        def func
          x = foo # rubocop:disable Lint/UselessAssignment,Style/For
          # rubocop:disable all
          # rubocop:disable Style/ClassVars
          @@bar = "3"
        end
      end
    RUBY
    create_file('example.rb', source)
    expect(cli.run(%w[--auto-correct --format simple])).to eq(1)
    expect($stdout.string).to eq(<<-RESULT.strip_indent)
      == example.rb ==
      C:  1:  1: Missing top-level class documentation comment.
      W:  2:  3: [Corrected] Unnecessary disabling of Metrics/MethodLength.
      W:  4: 54: [Corrected] Unnecessary disabling of Style/For.
      W:  6:  5: [Corrected] Unnecessary disabling of Style/ClassVars.

      1 file inspected, 4 offenses detected, 3 offenses corrected
    RESULT
    corrected = <<-RUBY.strip_indent
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
    source = <<-RUBY.strip_indent
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
    corrected = <<-RUBY.strip_indent
      def func
        foo
        bar
        rescue
          baz
        end

      def func
        x; y; rescue; z
      end

      def method
        BlockA do |_strategy|
          foo
        end

        BlockB do |_portfolio|
          foo
        end
      rescue => e # some problem
        bar
      end

      def method
        # comment 1
        do_some_stuff
      rescue # comment 2
        # comment 3
      end
    RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects Tab and IndentationConsistency offenses' do
    source = <<-RUBY.strip_indent
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
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/MethodCallWithArgsParentheses:
        Enabled: false
    YAML
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<-RUBY.strip_indent
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
    source = <<-RUBY.strip_indent
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
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/MethodCallWithArgsParentheses:
        Enabled: false
    YAML
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = <<-RUBY.strip_indent
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

  it 'corrects SymbolProc and SpaceBeforeBlockBraces offenses' do
    source = ['foo.map{ |a| a.nil? }']
    create_file('example.rb', source)
    expect(cli.run(['-D', '--auto-correct'])).to eq(0)
    corrected = "foo.map(&:nil?)\n"
    expect(IO.read('example.rb')).to eq(corrected)
    uncorrected = $stdout.string.split($RS).select do |line|
      line.include?('example.rb:') && !line.include?('[Corrected]')
    end
    expect(uncorrected).to be_empty # Hence exit code 0.
  end

  it 'corrects only IndentationWidth without crashing' do
    source = <<-RUBY.strip_indent
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
    corrected = <<-RUBY.strip_indent
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
    # Style/AlignHash. Because they make minimal corrections relating only
    # to their specific areas, and stay away from cleaning up extra
    # whitespace in the process, the combined changes don't interfere with
    # each other and the result is semantically the same as the starting
    # point.
    source = <<-RUBY.strip_indent
      expect(subject[:address]).to eq({
        street1:     '1 Market',
        street2:     '#200',
        city:        'Some Town',
        state:       'CA',
        postal_code: '99999-1111'
      })
    RUBY
    create_file('example.rb', source)
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/MethodCallWithArgsParentheses:
        Enabled: false
    YAML
    expect(cli.run(['-D', '--auto-correct'])).to eq(0)
    corrected =
      <<-RUBY.strip_indent
        expect(subject[:address]).to eq(street1:     '1 Market',
                                        street2:     '#200',
                                        city:        'Some Town',
                                        state:       'CA',
                                        postal_code: '99999-1111')
      RUBY
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'honors Exclude settings in individual cops' do
    source = 'puts %x(ls)'
    create_file('example.rb', source)
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/CommandLiteral:
        Exclude:
          - example.rb
    YAML
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect($stdout.string).to include('no offenses detected')
    expect(IO.read('example.rb')).to eq("#{source}\n")
  end

  it 'corrects code with indentation problems' do
    create_file('example.rb', <<-RUBY.strip_indent)
      module Bar
      class Goo
        def something
          first(call)
            do_other('things')
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
      .to eq(<<-RUBY.strip_indent)
        module Bar
          class Goo
            def something
              first(call)
              do_other('things')
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
    create_file('example.rb', <<-RUBY.strip_indent)
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
      .to eq(<<-RUBY.strip_indent)
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
    create_file('example.rb', <<-RUBY.strip_indent)
      (1..10).each{ |i|
        puts i
      }
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        (1..10).each do |i|
          puts i
        end
      RUBY
  end

  it 'can handle spaces when removing braces' do
    create_file('example.rb',
                ["assert_post_status_code 400, 's', {:type => 'bad'}"])
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/MethodCallWithArgsParentheses:
        Enabled: false
    YAML
    expect(cli.run(%w[--auto-correct --format emacs])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        assert_post_status_code 400, 's', type: 'bad'
      RUBY
    e = abs('example.rb')
    # TODO: Don't report that a problem is corrected when it
    # actually went away due to another correction.
    expect($stdout.string)
      .to eq(["#{e}:1:35: C: [Corrected] Space inside { missing.",
              "#{e}:1:35: C: [Corrected] Redundant curly braces around " \
              'a hash parameter.',
              "#{e}:1:36: C: [Corrected] Use the new Ruby 1.9 hash " \
              'syntax.',
              "#{e}:1:50: C: [Corrected] Space inside } missing.",
              ''].join("\n"))
  end

  # A case where two cops, EmptyLinesAroundBody and EmptyLines, try to
  # remove the same line in autocorrect.
  it 'can correct two empty lines at end of class body' do
    create_file('example.rb', <<-RUBY.strip_indent)
      class Test
        def f
        end


      end
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      class Test
        def f; end
      end
    RUBY
  end

  # A case where WordArray's correction can be clobbered by
  # AccessModifierIndentation's correction.
  it 'can correct indentation and another thing' do
    create_file('example.rb', <<-RUBY.strip_indent)
      class Dsl
      private
        A = ["git", "path",]
      end
    RUBY
    expect(cli.run(%w[--auto-correct --format emacs])).to eq(1)
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      class Dsl
        private

        A = %w[git path].freeze
      end
    RUBY
    e = abs('example.rb')
    expect($stdout.string)
      .to eq(["#{e}:1:1: C: Missing top-level class documentation " \
              'comment.',
              "#{e}:2:1: C: [Corrected] Indent access modifiers like " \
              '`private`.',
              "#{e}:2:1: C: [Corrected] Keep a blank line after `private`.",
              "#{e}:2:3: W: Useless `private` access modifier.",
              "#{e}:3:7: C: [Corrected] Freeze mutable objects assigned " \
              'to constants.',
              "#{e}:3:7: C: [Corrected] Use `%w` or `%W` " \
              'for an array of words.',
              "#{e}:3:8: C: [Corrected] Prefer single-quoted strings " \
              "when you don't need string interpolation or special " \
              'symbols.',
              "#{e}:3:15: C: [Corrected] Prefer single-quoted strings " \
              "when you don't need string interpolation or special " \
              'symbols.',
              "#{e}:3:21: C: [Corrected] Avoid comma after the last item " \
              'of an array.',
              "#{e}:4:7: C: [Corrected] Use `%w` or `%W` " \
              'for an array of words.',
              ''].join("\n"))
  end

  # A case where the same cop could try to correct an offense twice in one
  # place.
  it 'can correct empty line inside special form of nested modules' do
    create_file('example.rb', <<-RUBY.strip_indent)
      module A module B

      end end
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      module A module B
      end end
    RUBY
    uncorrected = $stdout.string.split($RS).select do |line|
      line.include?('example.rb:') && !line.include?('[Corrected]')
    end
    expect(uncorrected).not_to be_empty # Hence exit code 1.
  end

  it 'can correct single line methods' do
    create_file('example.rb', <<-RUBY.strip_indent)
      def func1; do_something end # comment
      def func2() do_1; do_2; end
    RUBY
    expect(cli.run(%w[--auto-correct --format offenses])).to eq(0)
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      # comment
      def func1
        do_something
      end

      def func2
        do_1
        do_2
      end
    RUBY
    expect($stdout.string).to eq(<<-RESULT.strip_indent)

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
    create_file('example.rb', <<-RUBY.strip_indent)
      fail NotImplementedError,
           'Method should be overridden in child classes'
    RUBY
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        raise NotImplementedError,
              'Method should be overridden in child classes'
      RUBY
    expect($stdout.string)
      .to eq(['Inspecting 1 file',
              'C',
              '',
              'Offenses:',
              '',
              'example.rb:1:1: C: [Corrected] Always use raise ' \
              'to signal exceptions.',
              'fail NotImplementedError,',
              '^^^^',
              'example.rb:2:6: C: [Corrected] Align the parameters of a ' \
              'method call if they span more than one line.',
              "     'Method should be overridden in child classes'",
              '     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',
              '',
              '1 file inspected, 2 offenses detected, 2 offenses ' \
              'corrected',
              ''].join("\n"))
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
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        # Example class.
        class Klass
          def f; end
        end
      RUBY
    expect($stderr.string).to eq('')
    expect($stdout.string)
      .to eq(['Inspecting 1 file',
              'C',
              '',
              'Offenses:',
              '',
              'example.rb:3:1: C: [Corrected] Extra empty line detected ' \
              'at class body beginning.',
              'example.rb:3:1: C: [Corrected] Trailing whitespace ' \
              'detected.',
              '',
              '1 file inspected, 2 offenses detected, 2 offenses ' \
              'corrected',
              ''].join("\n"))
  end

  it 'can correct MethodDefParentheses and other offense' do
    create_file('example.rb', <<-RUBY.strip_indent)
      def primes limit
        1.upto(limit).select { |i| i.even? }
      end
    RUBY
    expect(cli.run(%w[-D --auto-correct])).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        def primes(limit)
          1.upto(limit).select(&:even?)
        end
      RUBY
    expect($stdout.string)
      .to eq(['Inspecting 1 file',
              'C',
              '',
              'Offenses:',
              '',
              'example.rb:1:12: C: [Corrected] ' \
              'Style/MethodDefParentheses: ' \
              'Use def with parentheses when there are parameters.',
              'def primes limit',
              '           ^^^^^',
              'example.rb:2:24: C: [Corrected] Style/SymbolProc: ' \
              'Pass &:even? as an argument to select instead of a block.',
              '  1.upto(limit).select { |i| i.even? }',
              '                       ^^^^^^^^^^^^^^^',
              '',
              '1 file inspected, 2 offenses detected, 2 offenses ' \
              'corrected',
              ''].join("\n"))
  end

  it 'can correct WordArray and SpaceAfterComma offenses' do
    create_file('example.rb', <<-RUBY.strip_indent)
      f(type: ['offline','offline_payment'],
        bar_colors: ['958c12','953579','ff5800','0085cc'])
    RUBY
    expect(cli.run(%w[-D --auto-correct --format o])).to eq(0)
    expect($stdout.string)
      .to eq(<<-RESULT.strip_indent)

        4  Layout/SpaceAfterComma
        2  Style/WordArray
        --
        6  Total

      RESULT
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        f(type: %w[offline offline_payment],
          bar_colors: %w[958c12 953579 ff5800 0085cc])
      RUBY
  end

  it 'can correct SpaceAfterComma and HashSyntax offenses' do
    create_file('example.rb',
                "I18n.t('description',:property_name => property.name)")
    expect(cli.run(%w[-D --auto-correct --format emacs])).to eq(0)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:21: C: [Corrected] " \
              'Layout/SpaceAfterComma: Space missing after comma.',
              "#{abs('example.rb')}:1:22: C: [Corrected] " \
              'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
              ''].join("\n"))
    expect(IO.read('example.rb'))
      .to eq("I18n.t('description', property_name: property.name)\n")
  end

  it 'can correct HashSyntax and SpaceAroundOperators offenses' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w[-D --auto-correct --format emacs])).to eq(0)
    expect(IO.read('example.rb')).to eq("{ b: 1 }\n")
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:3: C: [Corrected] " \
              'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
              "#{abs('example.rb')}:1:5: C: [Corrected] " \
              'Layout/SpaceAroundOperators: Surrounding space missing for ' \
              'operator `=>`.',
              ''].join("\n"))
  end

  it 'can correct HashSyntax when --only is used' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w[--auto-correct -f emacs
                      --only Style/HashSyntax])).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("{ b: 1 }\n")
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:3: C: [Corrected] Use the new " \
              'Ruby 1.9 hash syntax.',
              ''].join("\n"))
  end

  it 'can correct TrailingBlankLines and TrailingWhitespace offenses' do
    create_file('example.rb',
                ['# frozen_string_literal: true',
                 '',
                 '  ',
                 '',
                 ''])
    expect(cli.run(%w[--auto-correct --format emacs])).to eq(0)
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      # frozen_string_literal: true
    RUBY
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:2:1: C: [Corrected] 3 trailing " \
              'blank lines detected.',
              "#{abs('example.rb')}:3:1: C: [Corrected] Trailing " \
              'whitespace detected.',
              ''].join("\n"))
  end

  it 'can correct MethodCallWithoutArgsParentheses and EmptyLiteral offenses' do
    create_file('example.rb', 'Hash.new()')
    expect(cli.run(%w[--auto-correct --format emacs])).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("{}\n")
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:1: C: [Corrected] Use hash " \
              'literal `{}` instead of `Hash.new`.',
              "#{abs('example.rb')}:1:9: C: [Corrected] Do not use " \
              'parentheses for method calls with no arguments.',
              ''].join("\n"))
  end

  it 'can correct IndentHash offenses with separator style' do
    create_file('example.rb', <<-RUBY.strip_indent)
      CONVERSION_CORRESPONDENCE = {
                    match_for_should: :match,
                match_for_should_not: :match_when_negated,
          failure_message_for_should: :failure_message,
      failure_message_for_should_not: :failure_message_when
      }
    RUBY
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Layout/AlignHash:
        EnforcedColonStyle: separator
    YAML
    expect(cli.run(%w[--auto-correct])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(<<-RUBY.strip_indent)
        CONVERSION_CORRESPONDENCE = {
                        match_for_should: :match,
                    match_for_should_not: :match_when_negated,
              failure_message_for_should: :failure_message,
          failure_message_for_should_not: :failure_message_when
        }.freeze
      RUBY
  end

  it 'does not say [Corrected] if correction was avoided' do
    src = <<-RUBY.strip_indent
      Signal.trap('TERM') { system(cmd); exit }
      def self.some_method(foo, bar: 1)
        log.debug(foo)
      end
    RUBY
    corrected = <<-RUBY.strip_indent
      Signal.trap('TERM') { system(cmd); exit }
      def self.some_method(foo, bar: 1)
        log.debug(foo)
      end
    RUBY
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      AllCops:
        TargetRubyVersion: 2.1
    YAML
    create_file('example.rb', src)
    expect(cli.run(%w[-a -f simple])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected)
    expect($stdout.string).to eq(<<-RESULT.strip_indent)
      == example.rb ==
      C:  1: 34: Do not use semicolons to terminate expressions.
      W:  2: 27: Unused method argument - bar.

      1 file inspected, 2 offenses detected
    RESULT
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideParens' do
    create_file('example.rb', 'some_method(a, )')
    Timeout.timeout(10) do
      expect(cli.run(%w[--auto-correct])).to eq(0)
    end
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("some_method(a)\n")
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideBrackets' do
    create_file('example.rb', 'puts [1, ]')
    Timeout.timeout(10) do
      expect(cli.run(%w[--auto-correct])).to eq(0)
    end
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("puts [1]\n")
  end

  it 'can be disabled for any cop in configuration' do
    create_file('example.rb', 'puts "Hello", 123456')
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Style/StringLiterals:
        AutoCorrect: false
    YAML
    expect(cli.run(%w[--auto-correct])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("puts \"Hello\", 123_456\n")
  end

  it 'handles different SpaceInsideBlockBraces and ' \
     'SpaceInsideHashLiteralBraces' do
    create_file('example.rb', <<-RUBY.strip_indent)
      {foo: bar,
       bar: baz,}
      foo.each {bar;}
    RUBY
    create_file('.rubocop.yml', <<-YAML.strip_indent)
      Layout/SpaceInsideBlockBraces:
        EnforcedStyle: space
      Layout/SpaceInsideHashLiteralBraces:
        EnforcedStyle: no_space
      Style/TrailingCommaInLiteral:
        EnforcedStyleForMultiline: consistent_comma
    YAML
    expect(cli.run(%w[--auto-correct])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      {foo: bar,
       bar: baz,}
      foo.each { bar; }
    RUBY
  end

  it 'corrects BracesAroundHashParameters offenses leaving the ' \
     'MultilineHashBraceLayout offense unchanged' do
    create_file('example.rb', <<-RUBY.strip_indent)
      def method_a
        do_something({ a: 1,
        })
      end
    RUBY

    expect($stderr.string).to eq('')
    expect(cli.run(%w[--auto-correct])).to eq(0)
    expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
      def method_a
        do_something(a: 1)
      end
    RUBY
  end
end
