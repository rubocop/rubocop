# frozen_string_literal: true

RSpec.describe 'RuboCop Project', type: :feature do
  let(:cop_names) do
    RuboCop::Cop::Cop
      .registry
      .without_department(:Test)
      .without_department(:Test2)
      .without_department(:InternalAffairs)
      .cops
      .map(&:cop_name)
  end

  version_regexp = /\A\d+\.\d+\z|\A<<next>>\z/

  describe 'default configuration file' do
    matcher :match_all_cops do
      def expected
        %w[AllCops] + cop_names
      end

      match { |actual| (expected.to_set ^ actual.to_set).none? }

      failure_message do
        diff = RSpec::Support::Differ.new.diff_as_object(expected.sort, actual.sort)
        "Cop registry does not match configuration keys.\n" \
          'Check if a new cop is missing configuration, or if cops were accidentally ' \
          "added to the registry in another test.\n\nDiff:\n#{diff}"
      end
    end

    subject(:config) { RuboCop::ConfigLoader.load_file('config/default.yml') }

    let(:configuration_keys) { config.keys }

    it 'has configuration for all cops' do
      expect(configuration_keys).to match_all_cops
    end

    it 'has a nicely formatted description for all cops' do
      cop_names.each do |name|
        description = config.dig(name, 'Description')
        expect(description.nil?).to(be(false),
                                    "`Description` configuration is required for `#{name}`.")
        expect(description.include?("\n")).to be(false)

        start_with_subject = description.match(/\AThis cop (?<verb>.+?) .*/)
        suggestion = start_with_subject[:verb]&.capitalize if start_with_subject
        suggestion ||= 'a verb'
        expect(start_with_subject).to(be_nil,
                                      "`Description` for `#{name}` should be started " \
                                      "with `#{suggestion}` instead of `This cop ...`.")
      end
    end

    it 'requires a nicely formatted `VersionAdded` metadata for all cops' do
      cop_names.each do |name|
        version = config.dig(name, 'VersionAdded')
        expect(version.nil?).to(be(false),
                                "`VersionAdded` configuration is required for `#{name}`.")
        expect(version).to(match(version_regexp),
                           "#{version} should be format ('X.Y' or '<<next>>') for #{name}.")
      end
    end

    %w[VersionChanged VersionRemoved].each do |version_type|
      it "requires a nicely formatted `#{version_type}` metadata for all cops" do
        cop_names.each do |name|
          version = config.dig(name, version_type)
          next unless version

          expect(version).to(match(version_regexp),
                             "#{version} should be format ('X.Y' or '<<next>>') for #{name}.")
        end
      end
    end

    it 'has a period at EOL of description' do
      cop_names.each do |name|
        next unless config[name]

        description = config[name]['Description']
        expect(description).to match(/\.\z/)
      end
    end

    it 'sorts configuration keys alphabetically' do
      expected = configuration_keys.sort
      configuration_keys.each_with_index { |key, idx| expect(key).to eq expected[idx] }
    end

    # rubocop:disable RSpec/NoExpectationExample
    it 'has a SupportedStyles for all EnforcedStyle and EnforcedStyle is valid' do
      errors = []
      cop_names.each do |name|
        next unless config[name]

        enforced_styles = config[name].select { |key, _| key.start_with?('Enforced') }
        enforced_styles.each do |style_name, style|
          supported_key = RuboCop::Cop::Util.to_supported_styles(style_name)
          valid = config[name][supported_key]
          unless valid
            errors.push("#{supported_key} is missing for #{name}")
            next
          end
          next if valid.include?(style)

          errors.push("invalid #{style_name} '#{style}' for #{name} found")
        end
      end

      raise errors.join("\n") unless errors.empty?
    end
    # rubocop:enable RSpec/NoExpectationExample

    # rubocop:disable RSpec/NoExpectationExample
    it 'does not have any duplication' do
      fname = File.expand_path('../config/default.yml', __dir__)
      content = File.read(fname)
      RuboCop::YAMLDuplicationChecker.check(content, fname) do |key1, key2|
        raise "#{fname} has duplication of #{key1.value} " \
              "on line #{key1.start_line} and line #{key2.start_line}"
      end
    end
    # rubocop:enable RSpec/NoExpectationExample

    %w[Safe SafeAutoCorrect AutoCorrect].each do |metadata|
      it "does not include `#{metadata}: true`" do
        cop_names.each do |cop_name|
          safe = config.dig(cop_name, metadata)
          expect(safe).not_to be(true), "`#{cop_name}` has unnecessary `#{metadata}: true` config."
        end
      end
    end

    it 'is expected that all cops documented with `@safety` are `Safe: false` or `SafeAutoCorrect: false`' do
      require 'yard'

      YARD::Registry.load!

      unsafe_cops = YARD::Registry.all(:class).select do |example|
        example.tags.any? { |tag| tag.tag_name == 'safety' }
      end

      unsafe_cop_names = unsafe_cops.map do |cop|
        department_and_cop_names = cop.path.split('::')[2..] # Drop `RuboCop::Cop` from class name.

        department_and_cop_names.join('/')
      end

      unsafe_cop_names.each do |cop_name|
        cop_config = config[cop_name]
        unsafe = cop_config['Safe'] == false || cop_config['SafeAutoCorrect'] == false

        expect(unsafe).to(
          be(true),
          "`#{cop_name}` cop should be set `Safe: false` or `SafeAutoCorrect: false` " \
          'because `@safety` YARD tag exists.'
        )
      end
    end
  end

  describe 'cop message' do
    let(:cops) { RuboCop::Cop::Registry.all }

    it 'end with a period or a question mark' do
      cops.each do |cop|
        begin
          msg = cop.const_get(:MSG)
        rescue NameError
          next
        end
        expect(msg).to match(/(?:[.?]|(?:\[.+\])|%s)$/)
      end
    end
  end

  shared_examples 'has Changelog format' do
    let(:lines) { changelog.each_line }

    let(:non_reference_lines) { lines.take_while { |line| !line.start_with?('[@') } }

    it 'has newline at end of file' do
      expect(changelog.end_with?("\n")).to be true
    end

    it 'has either entries, headers, empty lines, or comments' do
      expect(non_reference_lines).to all(match(/^(\*|#|$|<!---|-->|  )/))
    end

    describe 'entry' do
      it 'has a whitespace between the * and the body' do
        expect(entries).to all(match(/^\* \S/))
      end

      describe 'link to related issue' do
        let(:issues) do
          entries.filter_map do |entry|
            entry.match(%r{
              (?<=^\*\s)
              \[(?<ref>(?:(?<repo>rubocop/[a-z_-]+)?\#(?<number>\d+))|.*)\]
              \((?<url>[^)]+)\)
            }x)
          end
        end

        it 'has a reference' do
          issues.each { |issue| expect(issue[:ref].blank?).to be(false) }
        end

        it 'has a valid issue number prefixed with #' do
          issues.each { |issue| expect(issue[:number]).to match(/^\d+$/) }
        end

        it 'has a valid URL' do
          issues.each do |issue|
            number = issue[:number]&.gsub(/\D/, '')
            repo = issue[:repo] || 'rubocop/rubocop'
            pattern = %r{^https://github\.com/#{repo}/(?:issues|pull)/#{number}$}
            expect(issue[:url]).to match(pattern)
          end
        end

        it 'has a colon and a whitespace at the end' do
          entries_including_issue_link = entries.select { |entry| entry.match(/^\*\s*\[/) }

          expect(entries_including_issue_link).to all(include('): '))
        end
      end

      describe 'contributor name' do
        subject(:contributor_names) { lines.grep(/\A\[@/).map(&:chomp) }

        it 'has a unique contributor name' do
          expect(contributor_names.uniq.size).to eq contributor_names.size
        end
      end

      describe 'body' do
        let(:bodies) do
          entries.map do |entry|
            entry.gsub(/`[^`]+`/, '``').sub(/^\*\s*(?:\[.+?\):\s*)?/, '').sub(/\s*\([^)]+\)$/, '')
          end
        end

        it 'does not start with a lower case' do
          bodies.each { |body| expect(body).not_to match(/^[a-z]/) }
        end

        it 'ends with a punctuation' do
          expect(bodies).to all(match(/[.!]$/))
        end

        it 'does not include a [Fix #x] directive' do
          bodies.each { |body| expect(body).not_to match(/\[Fix(es)? \#.*?\]/i) }
        end
      end
    end
  end

  describe 'Changelog' do
    subject(:changelog) { File.read(path) }

    let(:path) { File.expand_path('../CHANGELOG.md', __dir__) }
    let(:entries) { lines.grep(/^\*/).map(&:chomp) }

    include_examples 'has Changelog format'

    context 'future entries' do
      let(:allowed_cop_names) do
        existing_cop_names.to_set.union(legacy_cop_names)
      end

      let(:existing_cop_names) do
        RuboCop::Cop::Cop
          .registry
          .without_department(:Test)
          .without_department(:Test2)
          .cops
          .map(&:cop_name)
      end

      let(:legacy_cop_names) do
        RuboCop::ConfigObsoletion.legacy_cop_names
      end

      dir = File.expand_path('../changelog', __dir__)

      Dir["#{dir}/*.md"].each do |path|
        context "For #{path}" do
          let(:path) { path }

          include_examples 'has Changelog format'

          it 'has a link to the issue or pull request address at the beginning' do
            repo = 'rubocop/rubocop'
            address_pattern = %r{\A\* \[#\d+\]\(https://github\.com/#{repo}/(issues|pull)/\d+\):}

            expect(entries).to all(match(address_pattern))
          end

          it 'has a link to the contributors at the end' do
            expect(entries).to all(match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/))
          end

          it 'has a single line' do
            expect(File.foreach(path).count).to eq(1)
          end

          it 'starts with `new_`, `fix_`, or `change_`' do
            expect(File.basename(path)).to(match(/\A(new|fix|change)_.+/))
          end

          it 'has valid cop name with backticks', :aggregate_failures do
            entries.each do |entry|
              entry.scan(%r{\b[A-Z]\w+(?:/[A-Z]\w+)+\b}) do |cop_name|
                expect(allowed_cop_names.include?(cop_name))
                  .to be(true), "Invalid cop name #{cop_name}."
                expect(entry.include?("`#{cop_name}`"))
                  .to be(true), "Missing backticks for #{cop_name}."
              end
            end
          end
        end
      end
    end

    it 'has link definitions for all implicit links' do
      implicit_link_names = changelog.scan(/\[([^\]]+)\]\[\]/).flatten.uniq
      implicit_link_names.each do |name|
        expect(changelog.include?("[#{name}]: http"))
          .to be(true), "missing a link for #{name}. " \
                        'Please add this link to the bottom of the file.'
      end
    end

    context 'after version 0.14.0' do
      let(:lines) { changelog.each_line.take_while { |line| !line.start_with?('## 0.14.0') } }

      it 'has a link to the contributors at the end' do
        expect(entries).to all(match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/))
      end
    end
  end

  describe 'requiring all of `lib` with verbose warnings enabled' do
    it 'emits no warnings' do
      warnings = `ruby -Ilib -w -W2 lib/rubocop.rb 2>&1`
                 .lines
                 .grep(%r{/lib/rubocop}) # ignore warnings from dependencies

      expect(warnings).to eq []
    end
  end
end
