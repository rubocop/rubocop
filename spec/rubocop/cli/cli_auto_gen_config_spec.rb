# frozen_string_literal: true

require 'timeout'

describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  describe '--auto-gen-config' do
    before do
      RuboCop::Formatter::DisabledConfigFormatter
        .config_to_allow_offenses = {}
    end

    shared_examples 'LineLength handling' do |ctx, initial_dotfile, exp_dotfile|
      context ctx do
        # Since there is a line with length 99 in the inspected code,
        # Style/IfUnlessModifier will register an offense when
        # Metrics/LineLength:Max has been set to 99. With a lower
        # LineLength:Max there would be no IfUnlessModifier offense.
        it "bases other cops' configuration on the code base's current " \
           'maximum line length' do
          if initial_dotfile
            initial_config = YAML.safe_load(initial_dotfile.join($RS)) || {}
            inherited_files = Array(initial_config['inherit_from'])
            (inherited_files - ['.rubocop.yml']).each { |f| create_file(f, '') }

            create_file('.rubocop.yml', initial_dotfile)
            create_file('.rubocop_todo.yml', [''])
          end
          create_file('example.rb', <<-RUBY.strip_indent)
            def f
            #{'  #' * 33}
              if #{'a' * 80}
                return y
              end
              z
            end
          RUBY
          expect(cli.run(['--auto-gen-config'])).to eq(1)
          expect(IO.readlines('.rubocop_todo.yml')
                   .drop_while { |line| line.start_with?('#') }.join)
            .to eq(<<-YAML.strip_indent)

              # Offense count: 1
              # Cop supports --auto-correct.
              Style/IfUnlessModifier:
                Exclude:
                  - 'example.rb'

              # Offense count: 2
              # Configuration parameters: AllowHeredoc, AllowURI, URISchemes, IgnoreCopDirectives, IgnoredPatterns.
              # URISchemes: http, https
              Metrics/LineLength:
                Max: 99
          YAML
          expect(IO.read('.rubocop.yml').strip).to eq(exp_dotfile.join($RS))
          $stdout = StringIO.new
          expect(described_class.new.run([])).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to include('no offenses detected')
        end
      end
    end

    include_examples 'LineLength handling',
                     'when .rubocop.yml does not exist',
                     nil,
                     ['inherit_from: .rubocop_todo.yml']

    include_examples 'LineLength handling',
                     'when .rubocop.yml is empty',
                     [''],
                     ['inherit_from: .rubocop_todo.yml']

    include_examples 'LineLength handling',
                     'when .rubocop.yml inherits only from .rubocop_todo.yml',
                     ['inherit_from: .rubocop_todo.yml'],
                     ['inherit_from: .rubocop_todo.yml']

    include_examples 'LineLength handling',
                     'when .rubocop.yml inherits only from .rubocop_todo.yml ' \
                     'in an array',
                     ['inherit_from:',
                      '  - .rubocop_todo.yml'],
                     ['inherit_from:',
                      '  - .rubocop_todo.yml']

    include_examples 'LineLength handling',
                     'when .rubocop.yml inherits from another file and ' \
                     '.rubocop_todo.yml',
                     ['inherit_from:',
                      '  - common.yml',
                      '  - .rubocop_todo.yml'],
                     ['inherit_from:',
                      '  - common.yml',
                      '  - .rubocop_todo.yml']

    include_examples 'LineLength handling',
                     'when .rubocop.yml inherits from two other files',
                     ['inherit_from:',
                      '  - common1.yml',
                      '  - common2.yml'],
                     ['inherit_from:',
                      '  - .rubocop_todo.yml',
                      '  - common1.yml',
                      '  - common2.yml']

    include_examples 'LineLength handling',
                     'when .rubocop.yml inherits from another file',
                     ['inherit_from: common.yml'],
                     ['inherit_from:',
                      '  - .rubocop_todo.yml',
                      '  - common.yml']

    include_examples 'LineLength handling',
                     "when .rubocop.yml doesn't inherit",
                     ['Style/For:',
                      '  Enabled: false'],
                     ['inherit_from: .rubocop_todo.yml',
                      '',
                      'Style/For:',
                      '  Enabled: false']

    it 'overwrites an existing todo file' do
      create_file('example1.rb', ['x= 0 ',
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('.rubocop_todo.yml', <<-YAML.strip_indent)
        Metrics/LineLength:
          Enabled: false
      YAML
      create_file('.rubocop.yml', ['inherit_from: .rubocop_todo.yml'])
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect(IO.readlines('.rubocop_todo.yml')[8..-1].map(&:chomp))
        .to eq(['# Offense count: 1',
                '# Cop supports --auto-correct.',
                '# Configuration parameters: AllowForAlignment.',
                'Layout/SpaceAroundOperators:',
                '  Exclude:',
                "    - 'example1.rb'",
                '',
                '# Offense count: 2',
                '# Cop supports --auto-correct.',
                'Layout/TrailingWhitespace:',
                '  Exclude:',
                "    - 'example1.rb'",
                '',
                '# Offense count: 1',
                '# Configuration parameters: AllowHeredoc, AllowURI, ' \
                'URISchemes, IgnoreCopDirectives, IgnoredPatterns.',
                '# URISchemes: http, https',
                'Metrics/LineLength:',
                '  Max: 85'])

      # Create new CLI instance to avoid using cached configuration.
      new_cli = described_class.new

      expect(new_cli.run(['example1.rb'])).to eq(0)
    end

    it 'honors rubocop:disable comments' do
      create_file('example1.rb', ['#' * 81,
                                  '# rubocop:disable LineLength',
                                  '#' * 85,
                                  'y ',
                                  'puts 123456',
                                  '# rubocop:enable LineLength'])
      create_file('.rubocop.yml', ['inherit_from: .rubocop_todo.yml'])
      create_file('.rubocop_todo.yml', [''])
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
        .to eq(['# Offense count: 1',
                '# Cop supports --auto-correct.',
                'Layout/TrailingWhitespace:',
                '  Exclude:',
                "    - 'example1.rb'",
                '',
                '# Offense count: 1',
                '# Cop supports --auto-correct.',
                '# Configuration parameters: Strict.',
                'Style/NumericLiterals:',
                '  MinDigits: 7',
                '',
                '# Offense count: 1',
                '# Configuration parameters: AllowHeredoc, AllowURI, ' \
                'URISchemes, IgnoreCopDirectives, IgnoredPatterns.',
                '# URISchemes: http, https',
                'Metrics/LineLength:',
                '  Max: 81',
                ''].join("\n"))
    end

    it 'can generate a todo list' do
      create_file('example1.rb', ['$x= 0 ',
                                  '#' * 90,
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', <<-RUBY.strip_indent)
        # frozen_string_literal: true

        \tx = 0
        puts x

        class A
          def a; end
        end
      RUBY
      # Make ConfigLoader reload the default configuration so that its
      # absolute Exclude paths will point into this example's work directory.
      RuboCop::ConfigLoader.default_configuration = nil

      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string).to include('Created .rubocop_todo.yml.')
      expected =
        ['# This configuration was generated by',
         '# `rubocop --auto-gen-config`',
         /# on .* using RuboCop version .*/,
         '# The point is for the user to remove these configuration records',
         '# one by one as the offenses are removed from the code base.',
         '# Note that changes in the inspected code, or installation of new',
         '# versions of RuboCop, may require this file to be generated ' \
         'again.',
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         'Layout/CommentIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 2',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: EnforcedStyle.',
         '# SupportedStyles: normal, rails',
         'Layout/IndentationConsistency:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         'Layout/InitialIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: AllowForAlignment.',
         'Layout/SpaceAroundOperators:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: IndentationWidth.',
         'Layout/Tab:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 2',
         '# Cop supports --auto-correct.',
         'Layout/TrailingWhitespace:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Offense count: 1',
         'Style/Documentation:',
         '  Exclude:',
         "    - 'spec/**/*'", # Copied from default configuration
         "    - 'test/**/*'", # Copied from default configuration
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Configuration parameters: AllowedVariables.',
         'Style/GlobalVars:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Offense count: 2',
         '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes, ' \
         'IgnoreCopDirectives, IgnoredPatterns.',
         '# URISchemes: http, https',
         'Metrics/LineLength:',
         '  Max: 90']
      actual = IO.read('.rubocop_todo.yml').split($RS)
      expected.each_with_index do |line, ix|
        if line.is_a?(String)
          expect(actual[ix]).to eq(line)
        else
          expect(actual[ix]).to match(line)
        end
      end
      expect(actual.size).to eq(expected.size)
    end

    it 'can generate Exclude properties with a given limit' do
      create_file('example1.rb', ['$x= 0 ',
                                  '#' * 90,
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', ['# frozen_string_literal: true',
                                  '',
                                  '#' * 85,
                                  "\tx = 0",
                                  'puts x '])
      expect(cli.run(['--auto-gen-config', '--exclude-limit', '1'])).to eq(1)
      expected =
        ['# This configuration was generated by',
         '# `rubocop --auto-gen-config --exclude-limit 1`',
         /# on .* using RuboCop version .*/,
         '# The point is for the user to remove these configuration records',
         '# one by one as the offenses are removed from the code base.',
         '# Note that changes in the inspected code, or installation of new',
         '# versions of RuboCop, may require this file to be generated ' \
         'again.',
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         'Layout/CommentIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: EnforcedStyle.',
         '# SupportedStyles: normal, rails',
         'Layout/IndentationConsistency:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         'Layout/InitialIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: AllowForAlignment.',
         'Layout/SpaceAroundOperators:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: IndentationWidth.',
         'Layout/Tab:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 3',
         '# Cop supports --auto-correct.',
         'Layout/TrailingWhitespace:',
         '  Enabled: false', # Offenses in 2 files, limit is 1, so no Exclude
         '',
         '# Offense count: 1',
         '# Configuration parameters: AllowedVariables.',
         'Style/GlobalVars:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Offense count: 3',
         '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes, ' \
         'IgnoreCopDirectives, IgnoredPatterns.',
         '# URISchemes: http, https',
         'Metrics/LineLength:',
         '  Max: 90']
      actual = IO.read('.rubocop_todo.yml').split($RS)
      expected.each_with_index do |line, ix|
        if line.is_a?(String)
          expect(actual[ix]).to eq(line)
        else
          expect(actual[ix]).to match(line)
        end
      end
      expect(actual.size).to eq(expected.size)
    end

    it 'does not generate configuration for the Syntax cop' do
      create_file('example1.rb', <<-RUBY.strip_indent)
        # frozen_string_literal: true

        x = <  # Syntax error
        puts x
      RUBY
      create_file('example2.rb', <<-RUBY.strip_indent)
        # frozen_string_literal: true

        \tx = 0
        puts x
      RUBY
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect($stderr.string).to eq('')
      expected =
        ['# This configuration was generated by',
         '# `rubocop --auto-gen-config`',
         /# on .* using RuboCop version .*/,
         '# The point is for the user to remove these configuration records',
         '# one by one as the offenses are removed from the code base.',
         '# Note that changes in the inspected code, or installation of new',
         '# versions of RuboCop, may require this file to be generated ' \
         'again.',
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         'Layout/CommentIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: EnforcedStyle.',
         '# SupportedStyles: normal, rails',
         'Layout/IndentationConsistency:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         'Layout/InitialIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: IndentationWidth.',
         'Layout/Tab:',
         '  Exclude:',
         "    - 'example2.rb'"]
      actual = IO.read('.rubocop_todo.yml').split($RS)
      expect(actual.length).to eq(expected.length)
      expected.each_with_index do |line, ix|
        if line.is_a?(String)
          expect(actual[ix]).to eq(line)
        else
          expect(actual[ix]).to match(line)
        end
      end
      expect(actual.size).to eq(expected.size)
    end

    it 'generates a todo list that removes the reports' do
      create_file('example.rb', 'y.gsub!(/abc\/xyz/, x)')
      expect(cli.run(%w[--format emacs])).to eq(1)
      expect($stdout.string).to eq(
        "#{abs('example.rb')}:1:9: C: Style/RegexpLiteral: Use `%r` " \
        "around regular expression.\n"
      )
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expected =
        ['# This configuration was generated by',
         '# `rubocop --auto-gen-config`',
         /# on .* using RuboCop version .*/,
         '# The point is for the user to remove these configuration records',
         '# one by one as the offenses are removed from the code base.',
         '# Note that changes in the inspected code, or installation of new',
         '# versions of RuboCop, may require this file to be generated ' \
         'again.',
         '',
         '# Offense count: 1',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: EnforcedStyle, AllowInnerSlashes.',
         '# SupportedStyles: slashes, percent_r, mixed',
         'Style/RegexpLiteral:',
         '  Exclude:',
         "    - 'example.rb'"]
      actual = IO.read('.rubocop_todo.yml').split($RS)
      expected.each_with_index do |line, ix|
        if line.is_a?(String)
          expect(actual[ix]).to eq(line)
        else
          expect(actual[ix]).to match(line)
        end
      end
      expect(actual.size).to eq(expected.size)
      $stdout = StringIO.new
      result = cli.run(%w[--config .rubocop_todo.yml --format emacs])
      expect($stdout.string).to eq('')
      expect(result).to eq(0)
    end

    it 'does not include offense counts when --no-offense-counts is used' do
      create_file('example1.rb', ['$x= 0 ',
                                  '#' * 90,
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', <<-RUBY.strip_indent)
        # frozen_string_literal: true

        \tx = 0
        puts x

        class A
          def a; end
        end
      RUBY
      # Make ConfigLoader reload the default configuration so that its
      # absolute Exclude paths will point into this example's work directory.
      RuboCop::ConfigLoader.default_configuration = nil

      expect(cli.run(['--auto-gen-config', '--no-offense-counts'])).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string).to include('Created .rubocop_todo.yml.')
      expected =
        ['# This configuration was generated by',
         '# `rubocop --auto-gen-config --no-offense-counts`',
         /# on .* using RuboCop version .*/,
         '# The point is for the user to remove these configuration records',
         '# one by one as the offenses are removed from the code base.',
         '# Note that changes in the inspected code, or installation of new',
         '# versions of RuboCop, may require this file to be generated ' \
         'again.',
         '',
         '# Cop supports --auto-correct.',
         'Layout/CommentIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: EnforcedStyle.',
         '# SupportedStyles: normal, rails',
         'Layout/IndentationConsistency:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Cop supports --auto-correct.',
         'Layout/InitialIndentation:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: AllowForAlignment.',
         'Layout/SpaceAroundOperators:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Cop supports --auto-correct.',
         '# Configuration parameters: IndentationWidth.',
         'Layout/Tab:',
         '  Exclude:',
         "    - 'example2.rb'",
         '',
         '# Cop supports --auto-correct.',
         'Layout/TrailingWhitespace:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         'Style/Documentation:',
         '  Exclude:',
         "    - 'spec/**/*'", # Copied from default configuration
         "    - 'test/**/*'", # Copied from default configuration
         "    - 'example2.rb'",
         '',
         '# Configuration parameters: AllowedVariables.',
         'Style/GlobalVars:',
         '  Exclude:',
         "    - 'example1.rb'",
         '',
         '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes, ' \
         'IgnoreCopDirectives, IgnoredPatterns.',
         '# URISchemes: http, https',
         'Metrics/LineLength:',
         '  Max: 90']
      actual = IO.read('.rubocop_todo.yml').split($RS)
      expected.each_with_index do |line, ix|
        if line.is_a?(String)
          expect(actual[ix]).to eq(line)
        else
          expect(actual[ix]).to match(line)
        end
      end
      expect(actual.size).to eq(expected.size)
    end

    describe 'when different styles appear in different files' do
      before do
        create_file('example1.rb', ['$!'])
        create_file('example2.rb', ['$!'])
        create_file('example3.rb', ['$ERROR_INFO'])
      end

      it 'disables cop if --exclude-limit is exceeded' do
        expect(cli.run(['--auto-gen-config', '--exclude-limit', '1'])).to eq(1)
        expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
          .to eq(<<-YAML.strip_indent)
            # Offense count: 2
            # Cop supports --auto-correct.
            # Configuration parameters: EnforcedStyle.
            # SupportedStyles: use_perl_names, use_english_names
            Style/SpecialGlobalVars:
              Enabled: false
          YAML
      end

      it 'generates Exclude list if --exclude-limit is not exceeded' do
        create_file('example4.rb', ['$!'])
        expect(cli.run(['--auto-gen-config', '--exclude-limit', '10'])).to eq(1)
        expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
          .to eq(<<-YAML.strip_indent)
            # Offense count: 3
            # Cop supports --auto-correct.
            # Configuration parameters: EnforcedStyle.
            # SupportedStyles: use_perl_names, use_english_names
            Style/SpecialGlobalVars:
              Exclude:
                - 'example1.rb'
                - 'example2.rb'
                - 'example4.rb'
          YAML
      end
    end

    it 'can be called when there are no files to inspection' do
      expect(cli.run(['--auto-gen-config'])).to eq(0)
    end
  end
end
