# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --auto-gen-config', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  def generated_todo
    YAML.safe_load_file('.rubocop_todo.yml', permitted_classes: [Regexp], aliases: true) || {}
  end

  def generated_todo_with_total_allowances
    generated_todo.transform_values do |cop_config|
      allowance = cop_config['AllowedOffenses']
      next cop_config unless allowance.is_a?(Hash)

      cop_config.merge('AllowedOffenses' => allowance.values.sum)
    end
  end

  def generated_allowance_count(cop_name)
    generated_todo.dig(cop_name, 'AllowedOffenses').values.sum
  end

  def run_auto_gen_with_allowed_offenses(*options)
    cli.run(['--auto-gen-config', '--auto-gen-allowed-offenses', *options])
  end

  def create_auto_gen_allowance_test_files
    create_file('a.rb', "puts 1 \n")
    create_file('b.rb', "puts 2 \nputs 3 \n")
    create_file(
      'long_method.rb',
      ['# frozen_string_literal: true', '', 'def too_long',
       *Array.new(11) { |number| "  puts '#{number}'" }, 'end']
    )
  end

  def expect_default_auto_gen_config
    expect(cli.run(['--auto-gen-config'])).to eq(0)
    expect_default_generated_todo
    expect_default_line_length_prepass
  end

  def expect_default_generated_todo
    expect_default_trailing_whitespace_config
    expect_default_metrics_max
  end

  def expect_default_trailing_whitespace_config
    default_config = generated_todo.fetch('Layout/TrailingWhitespace')
    expect(default_config).not_to have_key('AllowedOffenses')
    expect(default_config['Exclude']).to include('a.rb', 'b.rb')
  end

  def expect_default_metrics_max
    method_length_config = generated_todo.fetch('Metrics/MethodLength')
    expect(method_length_config).not_to have_key('AllowedOffenses')
    expect(method_length_config.fetch('Max')).to be > 10
  end

  def expect_default_line_length_prepass
    expect($stdout.string).to include("Phase 1 of 2: run Layout/LineLength cop\n")
  end

  def clear_generated_auto_gen_config
    File.delete('.rubocop.yml')
    File.delete('.rubocop_todo.yml')
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
  end

  def expect_per_file_auto_gen_config
    expect(run_auto_gen_with_allowed_offenses).to eq(0)
    expect_per_file_trailing_whitespace_allowance
    expect_max_based_method_length
    expect_allowed_offenses_command
  end

  def expect_per_file_trailing_whitespace_allowance
    allowances = generated_todo.dig('Layout/TrailingWhitespace', 'AllowedOffenses')
    expect(allowances).to eq('a.rb' => 1, 'b.rb' => 2)
  end

  def expect_max_based_method_length
    method_length_config = generated_todo.fetch('Metrics/MethodLength')
    expect(method_length_config.fetch('Max')).to be > 10
    expect(method_length_config).not_to have_key('AllowedOffenses')
  end

  def expect_allowed_offenses_command
    expect(File.readlines('.rubocop_todo.yml')[1].chomp)
      .to eq('# `rubocop --auto-gen-config --auto-gen-allowed-offenses`')
  end

  describe '--auto-gen-config' do
    before do
      RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
      RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    end

    shared_examples 'LineLength handling' do |ctx, initial_dotfile, exp_dotfile|
      context ctx do
        it 'uses the observed maximum for line-length offenses' do
          if initial_dotfile
            initial_config = YAML.safe_load(initial_dotfile.join($RS)) || {}
            inherited_files = Array(initial_config['inherit_from'])
            (inherited_files - ['.rubocop.yml']).each { |f| create_empty_file(f) }

            create_file('.rubocop.yml', initial_dotfile)
            create_file('.rubocop_todo.yml', [''])
          end
          create_file('example.rb', <<~RUBY)
            # frozen_string_literal: true

            def f
            #{'  #' * 46}
              if #{'a' * 120}
                return y
              end

              z
            end
          RUBY
          expect(run_auto_gen_with_allowed_offenses).to eq(0)
          expect_default_line_length_prepass
          expect(generated_todo.dig('Layout/LineLength', 'Max')).to be > 120
          expect(generated_todo['Layout/LineLength']).not_to have_key('AllowedOffenses')
          expect(generated_allowance_count('Style/IfUnlessModifier')).to eq(1)
          expect(File.read('.rubocop_todo.yml')).to include('Max:')
          expect(File.read('.rubocop.yml').strip).to eq(exp_dotfile.join($RS))
          $stdout = StringIO.new
          expect(RuboCop::CLI.new.run([])).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to include('no offenses detected')
        end
      end
    end

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml does not exist',
                    nil,
                    ['inherit_from: .rubocop_todo.yml']

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml is empty',
                    [''],
                    ['inherit_from: .rubocop_todo.yml']

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml inherits only from .rubocop_todo.yml',
                    ['inherit_from: .rubocop_todo.yml'],
                    ['inherit_from: .rubocop_todo.yml']

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml inherits only from .rubocop_todo.yml ' \
                    'in an array',
                    ['inherit_from:',
                     '  - .rubocop_todo.yml'],
                    ['inherit_from:',
                     '  - .rubocop_todo.yml']

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml inherits from another file and ' \
                    '.rubocop_todo.yml',
                    ['inherit_from:',
                     '  - common.yml',
                     '  - .rubocop_todo.yml'],
                    ['inherit_from:',
                     '  - common.yml',
                     '  - .rubocop_todo.yml']

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml inherits from two other files',
                    ['inherit_from:',
                     '  - common1.yml',
                     '  - common2.yml'],
                    ['inherit_from:',
                     '  - .rubocop_todo.yml',
                     '  - common1.yml',
                     '  - common2.yml']

    it_behaves_like 'LineLength handling',
                    'when .rubocop.yml inherits from another file',
                    ['inherit_from: common.yml'],
                    ['inherit_from:',
                     '  - .rubocop_todo.yml',
                     '  - common.yml']

    it_behaves_like 'LineLength handling',
                    "when .rubocop.yml doesn't inherit",
                    ['Style/For:',
                     '  Enabled: false'],
                    ['inherit_from: .rubocop_todo.yml',
                     '',
                     'Style/For:',
                     '  Enabled: false']

    it 'generates per-file allowances for cops without threshold parameters' do
      create_auto_gen_allowance_test_files
      expect_default_auto_gen_config
      clear_generated_auto_gen_config
      expect_per_file_auto_gen_config
    end

    it 'keeps the max-based setting for ModuleLength in allowed-offense mode' do
      9.times do |index|
        create_file(
          "long_module_#{index}.rb",
          ["module LongModule#{index}",
           *Array.new(105) { |line| "  VALUE_#{line} = #{line}" },
           'end']
        )
      end

      expect(run_auto_gen_with_allowed_offenses('--only', 'Metrics/ModuleLength')).to eq(0)

      module_length_config = generated_todo.fetch('Metrics/ModuleLength')
      expect(module_length_config.fetch('Max')).to be > 100
      expect(module_length_config).not_to have_key('AllowedOffenses')
    end

    it 'only includes files selected for auto-generation' do
      create_file('a.rb', "puts 1 \n")
      create_file('b.rb', "puts 2 \n")

      expect(run_auto_gen_with_allowed_offenses('a.rb')).to eq(0)
      allowance = generated_todo.dig('Layout/TrailingWhitespace', 'AllowedOffenses')
      expect(allowance).to eq('a.rb' => 1)
    end

    context 'with Layout/LineLength:Max overridden' do
      before do
        create_file('.rubocop.yml', ['Layout/LineLength:',
                                     "  Max: #{line_length_max}",
                                     "  Enabled: #{line_length_enabled}"])
        create_file('.rubocop_todo.yml', [''])
        create_file('example.rb', <<~RUBY)
          def f
          #{'  #' * 33}
            if #{'a' * 80}
              return y
            end

            z
          end
        RUBY
      end

      context 'when .rubocop.yml has Layout/LineLength:Max less than code base max' do
        let(:line_length_max) { 90 }
        let(:line_length_enabled) { true }

        it 'keeps the configured maximum and generates an allowance for its offenses' do
          expect(run_auto_gen_with_allowed_offenses).to eq(0)
          expect($stdout.string).to include(<<~YAML)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
            Phase 1 of 2: run Layout/LineLength cop (skipped because the default Layout/LineLength:Max is overridden)
            Phase 2 of 2: run all cops
          YAML
          expect(generated_allowance_count('Layout/LineLength')).to eq(1)
          expect(File.read('.rubocop_todo.yml')).not_to include('Max:')
          expect(File.read('.rubocop.yml')).to eq(<<~YAML)
            inherit_from: .rubocop_todo.yml

            Layout/LineLength:
              Max: 90
              Enabled: true
          YAML
          expect(RuboCop::CLI.new.run([])).to eq(0)
        end
      end

      context 'when .rubocop.yml has Layout/LineLength disabled' do
        let(:line_length_max) { 90 }
        let(:line_length_enabled) { false }

        it 'does not generate an allowance for a disabled cop' do
          expect(run_auto_gen_with_allowed_offenses).to eq(0)
          expect($stdout.string).to include(<<~YAML)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
            Phase 1 of 2: run Layout/LineLength cop (skipped because Layout/LineLength is disabled)
            Phase 2 of 2: run all cops
          YAML

          expect(generated_todo).not_to have_key('Layout/LineLength')
          expect(File.read('.rubocop_todo.yml')).not_to include('Max:')
          expect(File.read('.rubocop.yml')).to eq(<<~YAML)
            inherit_from: .rubocop_todo.yml

            Layout/LineLength:
              Max: 90
              Enabled: false
          YAML
          $stdout = StringIO.new
          expect(RuboCop::CLI.new.run(%w[--format simple])).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to eq(<<~OUTPUT)

            1 file inspected, no offenses detected
          OUTPUT
        end
      end

      context 'when .rubocop.yml has Layout/LineLength:Max more than code base max' do
        let(:line_length_max) { 150 }
        let(:line_length_enabled) { true }

        it 'does not generate line-length configuration when the limit is high enough' do
          expect(run_auto_gen_with_allowed_offenses).to eq(0)
          expect($stdout.string).to include(<<~YAML)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
            Phase 1 of 2: run Layout/LineLength cop (skipped because the default Layout/LineLength:Max is overridden)
            Phase 2 of 2: run all cops
          YAML
          expect(generated_todo).not_to have_key('Layout/LineLength')
          expect(File.read('.rubocop_todo.yml')).not_to include('Max:')
          expect(File.read('.rubocop.yml')).to eq(<<~YAML)
            inherit_from: .rubocop_todo.yml

            Layout/LineLength:
              Max: 150
              Enabled: true
          YAML
          $stdout = StringIO.new
          expect(RuboCop::CLI.new.run(%w[--format simple])).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to eq(<<~OUTPUT)

            1 file inspected, no offenses detected
          OUTPUT
        end
      end
    end

    shared_examples 'overwrites todo file' do |description, code|
      context "when .rubocop.yml contains #{description}" do
        it 'overwrites an existing todo file' do
          create_file('example1.rb', ['# frozen_string_literal: true',
                                      '',
                                      'x= 0 ',
                                      '#' * 125,
                                      'y ',
                                      'puts x'])
          create_file('example2.rb', <<~RUBY)
            # frozen_string_literal: true

            module M1::M2
              class C # :nodoc:
                def m
                  puts '!'
                end
              end
            end
          RUBY
          create_file('.rubocop_todo.yml', <<~YAML)
            Layout/LineLength:
              Enabled: false
          YAML
          create_empty_file('other.yml')
          create_file('.rubocop.yml', code)
          expect(run_auto_gen_with_allowed_offenses).to eq(0)
          expect(generated_todo_with_total_allowances).to eq(
            'Layout/SpaceAroundOperators' => { 'AllowedOffenses' => 1 },
            'Layout/TrailingWhitespace' => { 'AllowedOffenses' => 2 },
            'Style/ClassAndModuleChildren' => { 'AllowedOffenses' => 1 },
            'Layout/LineLength' => { 'Max' => 125 }
          )
          expect(File.readlines('.rubocop.yml').map(&:chomp)).to eq(code)

          # Create new CLI instance to avoid using cached configuration.
          new_cli = RuboCop::CLI.new

          expect(new_cli.run(['example1.rb'])).to eq(0)
        end
      end
    end

    it_behaves_like 'overwrites todo file',
                    'only the inherit_from line',
                    ['inherit_from: .rubocop_todo.yml']

    # Makes the shared example work the same with the conditional as without.
    ENV['HZPKCEAXTFQLOWB'] = 'true'

    it_behaves_like 'overwrites todo file',
                    'a single line inherit_from in an ERB conditional',
                    ['<% if ENV["HZPKCEAXTFQLOWB"] %>',
                     'inherit_from: .rubocop_todo.yml',
                     '<% end %>']

    it_behaves_like 'overwrites todo file',
                    'a multiline inherit_from in an ERB conditional',
                    ['<% if ENV["HZPKCEAXTFQLOWB"] %>',
                     'inherit_from:',
                     '  - .rubocop_todo.yml',
                     '  - other.yml',
                     '<% end %>']

    it 'honors rubocop:disable comments' do
      create_file('example1.rb', ['#' * 121,
                                  '# rubocop:disable LineLength',
                                  '#' * 125,
                                  'y ',
                                  'puts 123456',
                                  '# rubocop:enable LineLength'])
      create_file('.rubocop.yml', ['inherit_from: .rubocop_todo.yml'])
      create_file('.rubocop_todo.yml', [''])
      expect(run_auto_gen_with_allowed_offenses).to eq(0)
      expect(generated_todo_with_total_allowances).to eq(
        'Layout/TrailingWhitespace' => { 'AllowedOffenses' => 1 },
        'Migration/DepartmentName' => { 'AllowedOffenses' => 2 },
        'Style/FrozenStringLiteralComment' => { 'AllowedOffenses' => 1 },
        'Style/NumericLiterals' => { 'MinDigits' => 7 },
        'Layout/LineLength' => { 'Max' => 121 }
      )
    end

    context 'when --only is used' do
      before do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          class MyClass
            def initialize
              p "No documentation for class"
            end
          end

          def f
          #{'  #' * 46}
            if #{'a' * 120}
              return y
            end

            z
          end
        RUBY
      end

      context 'when --only does not contain Layout/LineLength' do
        it 'generates TODO only for the mentioned cop' do
          $stdout = StringIO.new
          expect(run_auto_gen_with_allowed_offenses('--only', 'Style/Documentation')).to eq(0)
          expect(generated_allowance_count('Style/Documentation')).to eq(1)
          expect(generated_todo).not_to have_key('Layout/LineLength')
          expect($stderr.string).to eq('')
          expect($stdout.string).to eq(<<~STRING)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
            Phase 1 of 2: run Layout/LineLength cop (skipped because a list of cops is passed to the `--only` flag)
            Phase 2 of 2: run all cops
            Inspecting 1 file
            C

            1 file inspected, 1 offense detected
            Created .rubocop_todo.yml.
          STRING
        end
      end

      context 'when --only contains Layout/LineLength' do
        it 'generates TODO for every cop listed in the --only flag' do
          $stdout = StringIO.new
          expect(
            run_auto_gen_with_allowed_offenses('--only', 'Layout/LineLength,Style/Documentation')
          ).to eq(0)
          expect(generated_todo.dig('Layout/LineLength', 'Max')).to be > 120
          expect(generated_todo['Layout/LineLength']).not_to have_key('AllowedOffenses')
          expect(generated_allowance_count('Style/Documentation')).to eq(1)
          expect($stderr.string).to eq('')
          expect($stdout.string).to eq(<<~STRING)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
            Phase 1 of 2: run Layout/LineLength cop (skipped because a list of cops is passed to the `--only` flag)
            Phase 2 of 2: run all cops
            Inspecting 1 file
            C

            1 file inspected, 3 offenses detected
            Created .rubocop_todo.yml.
          STRING
        end
      end
    end

    context 'when --config is used' do
      it 'can generate a todo list' do
        create_file('example1.rb', ['$x = 0 ', '#' * 90, 'y ', 'puts x'])
        create_file('dir/cop_config.yml', <<~YAML)
          Layout/TrailingWhitespace:
            Enabled: false
          Layout/LineLength:
            Max: 95
        YAML
        expect(run_auto_gen_with_allowed_offenses('--config', 'dir/cop_config.yml')).to eq(0)
        expect(Dir['.*']).to include('.rubocop_todo.yml')
        expect(generated_todo_with_total_allowances).to eq(
          'Style/FrozenStringLiteralComment' => { 'AllowedOffenses' => 1 },
          'Style/GlobalVars' => { 'AllowedOffenses' => 1 }
        )
        expect(File.read('dir/cop_config.yml')).to eq(<<~YAML)
          inherit_from: ../.rubocop_todo.yml

          Layout/TrailingWhitespace:
            Enabled: false
          Layout/LineLength:
            Max: 95
        YAML
        # Checks that the command can be run again with config modified by itself.
        expect(run_auto_gen_with_allowed_offenses('--config', 'dir/cop_config.yml')).to eq(0)
      end

      context 'when --config is used with an absolute path' do
        it 'can generate a todo list' do
          create_file('example1.rb', ['$x = 0 ', '#' * 90, 'y ', 'puts x'])
          create_empty_file('.rubocop.yml')
          config_path = File.absolute_path('.rubocop.yml')
          expect(run_auto_gen_with_allowed_offenses('--config', config_path)).to eq(0)
          expect(Dir['.*']).to include('.rubocop_todo.yml')

          expect(generated_todo_with_total_allowances['Style/GlobalVars'])
            .to eq('AllowedOffenses' => 1)
          expect(File.read('.rubocop.yml')).to include('inherit_from: .rubocop_todo.yml')
          # Checks that the command can be run again with config modified by itself.
          expect(run_auto_gen_with_allowed_offenses('--config', config_path)).to eq(0)
        end
      end

      it 'can generate a todo list if default .rubocop.yml exists' do
        create_file('example1.rb', ['def foo', '  # bar', '  end'])
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            DisabledByDefault: true

          Layout/DefEndAlignment:
            Enabled: true
        YAML
        create_empty_file('cop_config.yml')

        expect(run_auto_gen_with_allowed_offenses('--config', 'cop_config.yml')).to eq(0)
        expect(Dir['.*']).to include('.rubocop_todo.yml')
        expect(generated_todo_with_total_allowances).to eq(
          'Layout/CommentIndentation' => { 'AllowedOffenses' => 1 },
          'Layout/DefEndAlignment' => { 'AllowedOffenses' => 1 },
          'Style/FrozenStringLiteralComment' => { 'AllowedOffenses' => 1 }
        )
        expect(File.read('cop_config.yml')).to eq(<<~YAML)
          inherit_from: .rubocop_todo.yml
        YAML
      end
    end

    context 'when working with a cop who do not support autocorrection' do
      it 'can generate a todo list' do
        create_file('example1.rb', <<~RUBY)
          def fooBar; end
        RUBY
        create_file('.rubocop.yml', <<~YAML)
          # The following cop does not support autocorrection.
          Naming/MethodName:
            Enabled: true
        YAML
        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        expect($stderr.string).to eq('')
        # expect($stdout.string).to include('Created .rubocop_todo.yml.')
        expect(Dir['.*']).to include('.rubocop_todo.yml')
        todo_contents = File.read('.rubocop_todo.yml').lines[8..].join
        expect(todo_contents).to eq(<<~YAML)
          # Offense count: 1
          # Configuration parameters: AllowedPatterns, ForbiddenIdentifiers, ForbiddenPatterns.
          # SupportedStyles: snake_case, camelCase
          # ForbiddenIdentifiers: __id__, __send__
          Naming/MethodName:
            EnforcedStyle: camelCase

          # Offense count: 1
          # This cop supports unsafe autocorrection (--autocorrect-all).
          # Configuration parameters: EnforcedStyle.
          # SupportedStyles: always, always_true, never
          Style/FrozenStringLiteralComment:
            AllowedOffenses:
              example1.rb: 1
        YAML
        expect(File.read('.rubocop.yml')).to eq(<<~YAML)
          inherit_from: .rubocop_todo.yml

          # The following cop does not support autocorrection.
          Naming/MethodName:
            Enabled: true
        YAML
      end
    end

    context 'when cop is not safe to autocorrect' do
      it 'can generate a todo list, with the appropriate flag' do
        create_file('example1.rb', <<~RUBY)
          # frozen_string_literal: true

          users = (user.name + ' ' + user.email) * 5
          puts users
        RUBY
        create_file('.rubocop.yml', <<~YAML)
          # The following cop supports autocorrection but is not safe
          Style/StringConcatenation:
            Enabled: true
        YAML
        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        expect($stderr.string).to eq('')
        expect(Dir['.*']).to include('.rubocop_todo.yml')
        todo_contents = File.read('.rubocop_todo.yml').lines[8..].join
        expect(todo_contents).to eq(<<~YAML)
          # Offense count: 1
          # This cop supports unsafe autocorrection (--autocorrect-all).
          # Configuration parameters: Mode.
          Style/StringConcatenation:
            AllowedOffenses:
              example1.rb: 1
        YAML
        expect(File.read('.rubocop.yml')).to eq(<<~YAML)
          inherit_from: .rubocop_todo.yml

          # The following cop supports autocorrection but is not safe
          Style/StringConcatenation:
            Enabled: true
        YAML
      end
    end

    context 'when existing config file has a YAML document start header' do
      it 'inserts `inherit_from` key after header' do
        create_file('example1.rb', <<~RUBY)
          def foo; end
        RUBY
        create_file('.rubocop.yml', <<~YAML)
          # rubocop config file
          ---  # YAML document start
          # The following cop does not support autocorrection.
          Naming/MethodName:
            Enabled: true
        YAML
        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        expect($stderr.string).to eq('')
        expect(Dir['.*']).to include('.rubocop_todo.yml')
        todo_contents = File.read('.rubocop_todo.yml').lines[8..].join
        expect(todo_contents).to eq(<<~YAML)
          # Offense count: 1
          # This cop supports unsafe autocorrection (--autocorrect-all).
          # Configuration parameters: EnforcedStyle.
          # SupportedStyles: always, always_true, never
          Style/FrozenStringLiteralComment:
            AllowedOffenses:
              example1.rb: 1
        YAML
        expect(File.read('.rubocop.yml')).to eq(<<~YAML)
          # rubocop config file
          ---  # YAML document start
          inherit_from: .rubocop_todo.yml

          # The following cop does not support autocorrection.
          Naming/MethodName:
            Enabled: true
        YAML
      end
    end

    context 'when working in a subdirectory' do
      it 'can generate a todo list' do
        create_file('dir/example1.rb', ['$x = 0 ', '#' * 90, 'y ', 'puts x'])
        create_file('dir/.rubocop.yml', <<~YAML)
          inherit_from: ../.rubocop.yml
        YAML
        create_file('.rubocop.yml', <<~YAML)
          Layout/TrailingWhitespace:
            Enabled: false
          Layout/LineLength:
            Max: 95
        YAML
        Dir.chdir('dir') do
          expect(run_auto_gen_with_allowed_offenses).to eq(0)
          expect(YAML.safe_load_file('.rubocop_todo.yml')).to eq(
            'Style/FrozenStringLiteralComment' => {
              'AllowedOffenses' => { 'example1.rb' => 1 }
            },
            'Style/GlobalVars' => { 'AllowedOffenses' => { 'example1.rb' => 1 } }
          )
        end
        expect($stderr.string).to eq('')
        # expect($stdout.string).to include('Created .rubocop_todo.yml.')
        expect(Dir['dir/.*']).to include('dir/.rubocop_todo.yml')
        expect(File.read('dir/.rubocop.yml')).to eq(<<~YAML)
          inherit_from:
            - .rubocop_todo.yml
            - ../.rubocop.yml
        YAML
      end
    end

    context 'when inheriting from a URL' do
      let(:remote_config_url) { 'https://example.com/foo/bar' }

      before do
        stub_request(:get, remote_config_url)
          .to_return(status: 200, body: "Style/Encoding:\n    Enabled: true")
      end

      context 'when there is a single entry' do
        it 'can generate a todo list' do
          create_file('dir/example1.rb', ['$x = 0 ', '#' * 90, 'y ', 'puts x'])
          create_file('.rubocop.yml', <<~YAML)
            inherit_from: #{remote_config_url}
          YAML
          expect(cli.run(%w[--auto-gen-config])).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to include(<<~YAML)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
          YAML
          expect(File.read('.rubocop.yml')).to eq(<<~YAML)
            inherit_from:
              - .rubocop_todo.yml
              - #{remote_config_url}
          YAML
        end
      end

      context 'when there are multiple entries' do
        it 'can generate a todo list' do
          create_file('dir/example1.rb', ['$x = 0 ', '#' * 90, 'y ', 'puts x'])
          create_file('.rubocop.yml', <<~YAML)
            inherit_from:
              - #{remote_config_url}
          YAML
          expect(cli.run(%w[--auto-gen-config])).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to include(<<~YAML)
            Added inheritance from `.rubocop_todo.yml` in `.rubocop.yml`.
          YAML
          expect(File.read('.rubocop.yml')).to eq(<<~YAML)
            inherit_from:
              - .rubocop_todo.yml
              - #{remote_config_url}
          YAML
        end
      end
    end

    it 'can generate a todo list' do
      create_file('example1.rb', ['# frozen_string_literal: true',
                                  '',
                                  '$x= 0 ',
                                  '#' * 130,
                                  '#' * 125,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', <<~RUBY)
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

      expect(run_auto_gen_with_allowed_offenses).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string).to include('Created .rubocop_todo.yml.')
      expect(generated_todo_with_total_allowances).to eq(
        'Layout/CommentIndentation' => { 'AllowedOffenses' => 1 },
        'Layout/IndentationConsistency' => { 'AllowedOffenses' => 2 },
        'Layout/IndentationStyle' => { 'AllowedOffenses' => 1 },
        'Layout/InitialIndentation' => { 'AllowedOffenses' => 1 },
        'Layout/SpaceAroundOperators' => { 'AllowedOffenses' => 1 },
        'Layout/TrailingWhitespace' => { 'AllowedOffenses' => 2 },
        'Style/Documentation' => { 'AllowedOffenses' => 1 },
        'Style/GlobalVars' => { 'AllowedOffenses' => 1 },
        'Layout/LineLength' => { 'Max' => 130 }
      )
    end

    it 'falls back to existing settings when the allowance file limit is exceeded' do
      create_file('example1.rb', ['# frozen_string_literal: true',
                                  '',
                                  '$x= 0 ',
                                  '#' * 130,
                                  '#' * 125,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', ['# frozen_string_literal: true',
                                  '',
                                  '#' * 125,
                                  "\tx = 0",
                                  'puts x '])
      expect(run_auto_gen_with_allowed_offenses('--exclude-limit', '1')).to eq(0)

      expect(generated_todo.dig('Layout/TrailingWhitespace', 'Enabled')).to be(false)
      expect(generated_todo.dig('Layout/TrailingWhitespace', 'AllowedOffenses')).to be_nil
      expect(generated_todo.dig('Layout/LineLength', 'AllowedOffenses')).to be_nil
      expect(generated_todo.dig('Layout/LineLength', 'Max')).to be_a(Integer)
      expect(generated_todo.dig('Style/GlobalVars', 'AllowedOffenses')).to eq('example1.rb' => 1)
    end

    context 'for existing configuration with Exclude' do
      before do
        create_file('example1.rb', ['# frozen_string_literal: true', '', 'y '])
        create_file('example2.rb', ['# frozen_string_literal: true', '', 'x = 0 ', 'puts x'])
      end

      it 'generates Excludes that appear in .rubocop.yml' do
        create_file('.rubocop.yml', <<~YAML)
          Layout/TrailingWhitespace:
            Exclude:
              - 'example1.rb'
        YAML
        expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude'])).to eq(0)
        expect($stderr.string.chomp)
          .to eq('`Layout/TrailingWhitespace: Exclude` in `.rubocop.yml` overrides a generated ' \
                 '`Exclude` in `.rubocop_todo.yml`. Either remove ' \
                 '`Layout/TrailingWhitespace: Exclude` or add `inherit_mode: merge: - Exclude`.')
        expected = <<~YAML
          Layout/TrailingWhitespace:
            Exclude:
              - 'example1.rb'
              - 'example2.rb'
        YAML
        actual = File.read('.rubocop_todo.yml').lines.grep_v(/^(#.*)?$/)
        expect(actual.join).to eq(expected)

        $stdout = StringIO.new
        expect(cli.run(['--format', 'offenses'])).to eq(1)
        expect($stdout.string.lines.grep(%r{/})).to eq(
          ["1  Layout/TrailingWhitespace [Safe Correctable]\n"]
        )
      end

      shared_examples 'leaves out Excludes' do |merge_style, config|
        it "leaves out Excludes that appear in .rubocop.yml but are merged #{merge_style}" do
          create_file('.rubocop.yml', config)
          expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude'])).to eq(0)
          expect($stderr.string).to eq('')
          expected = <<~YAML
            Layout/TrailingWhitespace:
              Exclude:
                - 'example2.rb'
          YAML
          actual = File.read('.rubocop_todo.yml').lines.grep_v(/^(#.*)?$/)
          expect(actual.join).to eq(expected)

          # NOTE: Reload CLI to ensure updated config with rubocop_todo is properly picked up.
          #       ConfigStore#for_pwd caches results; re-create CLI to avoid using stale config.
          fresh_cli = RuboCop::CLI.new
          expect(fresh_cli.run([])).to eq(0)
        end
      end

      it_behaves_like 'leaves out Excludes', 'globally', <<~YAML
        inherit_mode:
          merge:
            - Exclude

        Layout/TrailingWhitespace:
          Exclude:
            - 'example1.rb'
      YAML
      it_behaves_like 'leaves out Excludes', 'for the cop', <<~YAML
        Layout/TrailingWhitespace:
          inherit_mode:
            merge:
              - Exclude

          Exclude:
            - 'example1.rb'
      YAML
      it_behaves_like 'leaves out Excludes', 'because `Preview` is on', <<~YAML
        AllCops:
          Preview: true

        Layout/TrailingWhitespace:
          Exclude:
            - 'example1.rb'
      YAML

      it 'records --preview in the regeneration command' do
        create_file('.rubocop.yml', <<~YAML)
          Layout/TrailingWhitespace:
            Exclude:
              - 'example1.rb'
        YAML
        expect(cli.run(['--preview', '--auto-gen-config', '--auto-gen-only-exclude'])).to eq(0)

        expect(File.read('.rubocop_todo.yml'))
          .to include('`rubocop --auto-gen-config --auto-gen-only-exclude --preview`')
      end
    end

    context 'when duplicated default configuration parameter' do
      before do
        RuboCop::ConfigLoader.default_configuration['Naming/MethodParameterName']
                             .merge!('AllowedNames' => %w[at by at])
      end

      it 'parameters are displayed without duplication' do
        create_file('.rubocop.yml', <<~YAML)
          Naming/VariableName:
            Enabled: false
        YAML
        create_file('example1.rb', <<~TEXT)
          # frozen_string_literal: true

          def bar(varOne, varTwo)
            varOne + varTwo
          end
        TEXT

        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        File.readlines('.rubocop_todo.yml')
        expect(File.readlines('.rubocop_todo.yml')[9..].join)
          .to eq(<<~YAML)
            # Configuration parameters: MinNameLength, AllowNamesEndingInNumbers, AllowedNames, ForbiddenNames.
            # AllowedNames: at, by
            Naming/MethodParameterName:
              AllowedOffenses:
                example1.rb: 2
          YAML
      end
    end

    it 'does not generate configuration for the Syntax cop' do
      create_file('example1.rb', <<~RUBY)
        # frozen_string_literal: true

        x = <  # Syntax error
        puts x
      RUBY
      create_file('example2.rb', <<~RUBY)
        # frozen_string_literal: true

        \tx = 0
        puts x
      RUBY
      expect(run_auto_gen_with_allowed_offenses).to eq(0)
      expect($stderr.string).to eq('')
      expect(generated_todo).not_to have_key('Lint/Syntax')
      expect(generated_todo_with_total_allowances).to eq(
        'Layout/CommentIndentation' => { 'AllowedOffenses' => 1 },
        'Layout/IndentationConsistency' => { 'AllowedOffenses' => 1 },
        'Layout/IndentationStyle' => { 'AllowedOffenses' => 1 },
        'Layout/InitialIndentation' => { 'AllowedOffenses' => 1 }
      )
    end

    it 'generates a todo list that removes the reports' do
      create_file('example.rb', ['# frozen_string_literal: true', '', 'y.gsub!(/abc\/xyz/, x)'])
      expect(cli.run(%w[--format emacs])).to eq(1)
      expect($stdout.string).to eq(
        "#{abs('example.rb')}:3:9: C: [Correctable] Style/RegexpLiteral: Use `%r` " \
        "around regular expression.\n"
      )
      expect(run_auto_gen_with_allowed_offenses).to eq(0)
      expect(generated_allowance_count('Style/RegexpLiteral')).to eq(1)
      $stdout = StringIO.new
      result = cli.run(%w[--config .rubocop_todo.yml --format emacs])
      expect($stdout.string).to eq('')
      expect(result).to eq(0)
    end

    it 'does not include offense counts when --no-offense-counts is used' do
      create_file('example1.rb', ['# frozen_string_literal: true',
                                  '',
                                  '$x= 0 ',
                                  '#' * 130,
                                  '#' * 125,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', <<~RUBY)
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

      expect(run_auto_gen_with_allowed_offenses('--no-offense-counts')).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string).to include('Created .rubocop_todo.yml.')
      expect(File.read('.rubocop_todo.yml')).not_to include('# Offense count:')
      expect(generated_todo_with_total_allowances).to eq(
        'Layout/CommentIndentation' => { 'AllowedOffenses' => 1 },
        'Layout/IndentationConsistency' => { 'AllowedOffenses' => 2 },
        'Layout/IndentationStyle' => { 'AllowedOffenses' => 1 },
        'Layout/InitialIndentation' => { 'AllowedOffenses' => 1 },
        'Layout/SpaceAroundOperators' => { 'AllowedOffenses' => 1 },
        'Layout/TrailingWhitespace' => { 'AllowedOffenses' => 2 },
        'Style/Documentation' => { 'AllowedOffenses' => 1 },
        'Style/GlobalVars' => { 'AllowedOffenses' => 1 },
        'Layout/LineLength' => { 'Max' => 130 }
      )
    end

    it 'generates Exclude instead of Max when --auto-gen-only-exclude is used' do
      create_file('example1.rb', ['#' * 130, '#' * 130, 'puts 123456'])
      create_file('example2.rb', <<~RUBY)
        def function(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
          puts 123456
        end
      RUBY
      # Make ConfigLoader reload the default configuration so that its
      # absolute Exclude paths will point into this example's work directory.
      RuboCop::ConfigLoader.default_configuration = nil

      $stdout = StringIO.new
      expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude',
                      '--exclude-limit', '1'])).to eq(0)
      expect($stdout.string).to include(<<~STRING)
        Phase 1 of 2: run Layout/LineLength cop (skipped because only excludes will be generated due to `--auto-gen-only-exclude` flag)
        Phase 2 of 2: run all cops
      STRING
      actual = File.read('.rubocop_todo.yml').split($RS)

      # With --exclude-limit 1 we get MinDigits generated for NumericLiterals
      # because there's one offense in each file. The other cops have offenses
      # in just one file, even though there may be more than one offense for
      # the same cop in a single file. Exclude properties are generated for
      # them.
      expect(actual.grep(/^[^#]/).join($RS)).to eq(<<~YAML.chomp)
        Layout/LineLength:
          Exclude:
            - 'example1.rb'
        Lint/UnusedMethodArgument:
          Exclude:
            - 'example2.rb'
        Metrics/ParameterLists:
          Exclude:
            - 'example2.rb'
        Style/FrozenStringLiteralComment:
          Enabled: false
        Style/NumericLiterals:
          MinDigits: 7
      YAML
    end

    it 'does not duplicate `Layout/LineLength` with --auto-gen-only-exclude when it is disabled inline and other offense' do
      create_file('example1.rb', <<~RUBY)
        # frozen_string_literal: true

        # Documentation comment
        class Foo
          def foo
            puts #{'a' * 150}
          end

          # rubocop:disable Layout/LineLength
          def bar
            puts #{'a' * 150}
          end
          # rubocop:enable Layout/LineLength
        end
      RUBY

      expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude'])).to eq(0)
      actual = File.read('.rubocop_todo.yml').split($RS)

      expect(actual.grep(/^[^#]/).join($RS)).to eq(<<~YAML.chomp)
        Layout/LineLength:
          Exclude:
            - 'example1.rb'
      YAML
    end

    it 'includes --auto-gen-only-exclude in the command comment when given' do
      create_file('example1.rb', ['$!'])
      expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude',
                      '--exclude-limit', '1'])).to eq(0)

      command = '# `rubocop --auto-gen-config --auto-gen-only-exclude --exclude-limit 1`'
      expect(File.readlines('.rubocop_todo.yml')[1].chomp).to eq(command)
    end

    it 'does not include a timestamp when --no-auto-gen-timestamp is used' do
      create_file('example1.rb', ['$!'])
      expect(cli.run(['--auto-gen-config', '--no-auto-gen-timestamp'])).to eq(0)
      expect(File.readlines('.rubocop_todo.yml')[2]).to match(/# using RuboCop version .*/)
    end

    describe 'when --no-exclude-limit is given' do
      let(:offending_files_count) do
        RuboCop::Options::DEFAULT_MAXIMUM_EXCLUSION_ITEMS + 1
      end

      context 'for a cop without Max configuration' do
        before do
          offending_files_count.times do |i|
            create_file("example#{i}.rb", [' '])
          end
        end

        it 'always prefers Exclude to Enabled' do
          expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude',
                          '--no-exclude-limit'])).to eq(0)
          lines = File.readlines('.rubocop_todo.yml')
          expect(lines[1]).to eq(
            "# `rubocop --auto-gen-config --auto-gen-only-exclude --no-exclude-limit`\n"
          )
          expect(lines[9..12].join).to eq(
            <<~YAML
              # This cop supports safe autocorrection (--autocorrect).
              # Configuration parameters: AllowInHeredoc.
              Layout/TrailingWhitespace:
                Exclude:
            YAML
          )
          expect(lines[13..]).to eq(
            Array.new(offending_files_count) do |i|
              "    - 'example#{i}.rb'\n"
            end.sort
          )
        end
      end

      context 'for a cop with Max config' do
        before do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              DisabledByDefault: true
            Metrics/ClassLength:
              Enabled: true
          YAML
          offending_files_count.times do |i|
            max_lines = RuboCop::ConfigLoader.default_configuration['Metrics/ClassLength']['Max']
            create_file("example#{i}.rb", ['class Foo', *Array.new(max_lines + 1, '  bar'), 'end'])
          end
        end

        it 'always prefers Exclude to Enabled' do
          expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude',
                          '--no-exclude-limit'])).to eq(0)
          lines = File.readlines('.rubocop_todo.yml')
          expect(lines[9..11].join).to eq(
            <<~YAML
              # Configuration parameters: CountComments, Max, CountAsOne.
              Metrics/ClassLength:
                Exclude:
            YAML
          )
          expect(lines[12..]).to eq(
            Array.new(offending_files_count) do |i|
              "    - 'example#{i}.rb'\n"
            end.sort
          )
        end
      end
    end

    describe 'when different styles appear in different files' do
      before do
        create_file('example1.rb', ['$!'])
        create_file('example2.rb', ['$!'])
        create_file('example3.rb', ['$ERROR_INFO'])
      end

      it 'disables cop if --exclude-limit is exceeded' do
        expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude',
                        '--exclude-limit', '1'])).to eq(0)
        expect(File.readlines('.rubocop_todo.yml')[8..].join)
          .to eq(<<~YAML)
            # Offense count: 3
            # This cop supports unsafe autocorrection (--autocorrect-all).
            # Configuration parameters: EnforcedStyle.
            # SupportedStyles: always, always_true, never
            Style/FrozenStringLiteralComment:
              Enabled: false

            # Offense count: 2
            # This cop supports unsafe autocorrection (--autocorrect-all).
            # Configuration parameters: RequireEnglish, EnforcedStyle.
            # SupportedStyles: use_perl_names, use_english_names, use_builtin_english_names
            Style/SpecialGlobalVars:
              Enabled: false
          YAML
      end

      it 'generates Exclude list if --exclude-limit is not exceeded' do
        create_file('example4.rb', ['$!'])
        expect(cli.run(['--auto-gen-config', '--auto-gen-only-exclude',
                        '--exclude-limit', '10'])).to eq(0)
        expect(File.readlines('.rubocop_todo.yml')[8..].join)
          .to eq(<<~YAML)
            # Offense count: 4
            # This cop supports unsafe autocorrection (--autocorrect-all).
            # Configuration parameters: EnforcedStyle.
            # SupportedStyles: always, always_true, never
            Style/FrozenStringLiteralComment:
              Exclude:
                - '**/*.arb'
                - 'example1.rb'
                - 'example2.rb'
                - 'example3.rb'
                - 'example4.rb'

            # Offense count: 3
            # This cop supports unsafe autocorrection (--autocorrect-all).
            # Configuration parameters: RequireEnglish, EnforcedStyle.
            # SupportedStyles: use_perl_names, use_english_names, use_builtin_english_names
            Style/SpecialGlobalVars:
              Exclude:
                - 'example1.rb'
                - 'example2.rb'
                - 'example4.rb'
          YAML
      end
    end

    describe 'console output' do
      before { create_file('example1.rb', ['# frozen_string_literal: true', '', '$!']) }

      it 'displays report summary but no offenses' do
        expect(cli.run(['--auto-gen-config'])).to eq(0)

        expect($stdout.string).to include(<<~OUTPUT)
          Inspecting 1 file
          C

          1 file inspected, 1 offense detected, 1 offense autocorrectable
          Created .rubocop_todo.yml.
        OUTPUT
      end
    end

    describe 'when `--auto-gen-enforced-style` is given' do
      it 'generates EnforcedStyle parameter if it solves all offenses' do
        create_file('example1.rb', ['# frozen_string_literal: true', '', 'h(:a => 1)'])

        expect(cli.run(['--auto-gen-config', '--auto-gen-enforced-style'])).to eq(0)
        expect(File.readlines('.rubocop_todo.yml')[10..].join)
          .to eq(<<~YAML)
            # Configuration parameters: EnforcedShorthandSyntax, UseHashRocketsWithSymbolValues, PreferHashRocketsForNonAlnumEndingSymbols.
            # SupportedStyles: ruby19, hash_rockets, no_mixed_keys, ruby19_no_mixed_keys
            # SupportedShorthandSyntax: always, never, either, consistent, either_consistent
            Style/HashSyntax:
              EnforcedStyle: hash_rockets
          YAML
      end

      it 'generates an allowance if no EnforcedStyle solves all offenses' do
        create_file('example1.rb', ['# frozen_string_literal: true', '', 'h(:a => 1)', 'h(b: 2)'])

        expect(run_auto_gen_with_allowed_offenses('--auto-gen-enforced-style')).to eq(0)
        expect(generated_allowance_count('Style/HashSyntax')).to eq(1)
      end
    end

    describe 'when `--no-auto-gen-enforced-style` is given' do
      it 'generates an allowance when style inference is disabled' do
        create_file('example1.rb', ['# frozen_string_literal: true', '', 'h(:a => 1)'])

        expect(run_auto_gen_with_allowed_offenses('--no-auto-gen-enforced-style')).to eq(0)
        expect(generated_allowance_count('Style/HashSyntax')).to eq(1)
      end

      it 'generates an allowance if no EnforcedStyle solves all offenses' do
        create_file('example1.rb', ['# frozen_string_literal: true', '', 'h(:a => 1)', 'h(b: 2)'])

        expect(run_auto_gen_with_allowed_offenses('--no-auto-gen-enforced-style')).to eq(0)
        expect(generated_allowance_count('Style/HashSyntax')).to eq(1)
      end

      it 'generates an allowance instead of an omitted EnforcedStyle' do
        create_file('example1.rb', ['# frozen_string_literal: true', '', 'h{}'])

        expect(run_auto_gen_with_allowed_offenses('--no-auto-gen-enforced-style')).to eq(0)
        expect(generated_allowance_count('Layout/SpaceBeforeBlockBraces')).to eq(1)
      end
    end

    context 'when hash value omission enabled', :ruby31 do
      it 'generates an allowance when the enforced style does not resolve the offense' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            NewCops: enable
            TargetRubyVersion: 3.1
          Style/HashSyntax:
            EnforcedShorthandSyntax: always
        YAML
        create_file('example1.rb', ['# frozen_string_literal: true', '', '{ a: a }'])

        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        expect(generated_allowance_count('Style/HashSyntax')).to eq(1)
      end
    end

    context 'when there is code conforming to chosen enforced style and code not conforming to any supported style' do
      it 'generates an allowance for unsupported style offenses' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            DisabledByDefault: true

          Naming/MethodName:
            Enabled: true
        YAML

        create_file('bad.rb', ['def Bad', 'end'])
        create_file('good.rb', ['def good', 'end'])

        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        expect(generated_allowance_count('Naming/MethodName')).to eq(1)
      end
    end

    it 'can be called when there are no files to inspection' do
      expect(cli.run(['--auto-gen-config'])).to eq(0)
    end

    context 'when Max configuration is overridden in .rubocop.yml' do
      it 'generates an allowance instead of changing Max' do
        create_file('.rubocop.yml', <<~YAML)
          Metrics/ClassLength:
            Max: 250
          Layout/EmptyLinesAroundClassBody:
            Enabled: false
        YAML
        create_file(
          'file.rb',
          [
            '# A long class',
            'class TooLong',
            *Array.new(100) { |i| ["  def method#{i}", "    #{i}", '  end', ''] },
            'end'
          ].flatten
        )
        expect(run_auto_gen_with_allowed_offenses).to eq(0)
        expect(generated_todo_with_total_allowances).to eq(
          'Metrics/ClassLength' => { 'AllowedOffenses' => 1 },
          'Style/FrozenStringLiteralComment' => { 'AllowedOffenses' => 1 }
        )

        # NOTE: Reload CLI to ensure updated config with rubocop_todo is properly picked up.
        #       ConfigStore#for_pwd caches results; re-create CLI to avoid using stale config.
        fresh_cli = RuboCop::CLI.new
        expect(fresh_cli.run([])).to eq(0)
      end
    end
  end
end
