# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::FileName do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      { 'AllCops' => { 'Include' => includes },
        described_class.badge.to_s => cop_config },
      '/some/.rubocop.yml'
    )
  end
  let(:cop_config) do
    {
      'IgnoreExecutableScripts' => true,
      'ExpectMatchingDefinition' => false,
      'Regex' => nil
    }
  end

  let(:includes) { ['**/*.rb'] }
  let(:source) { 'print 1' }
  let(:processed_source) { parse_source(source) }
  let(:offenses) { _investigate(cop, processed_source) }
  let(:messages) { offenses.sort.map(&:message) }

  before do
    allow(processed_source.buffer).to receive(:name).and_return(filename)
  end

  context 'with camelCase file names ending in .rb' do
    let(:filename) { '/some/dir/testCase.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with camelCase file names without file extension' do
    let(:filename) { '/some/dir/testCase' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with snake_case file names ending in .rb' do
    let(:filename) { '/some/dir/test_case.rb' }

    it 'reports an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with snake_case file names without file extension' do
    let(:filename) { '/some/dir/test_case' }

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with snake_case file names with non-rb extension' do
    let(:filename) { '/some/dir/some_task.rake' }

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with snake_case file names with multiple extensions' do
    let(:filename) { 'some/dir/some_view.html.slim_spec.rb' }

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with snake_case names which use ? and !' do
    let(:filename) { 'some/dir/file?!.rb' }

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with snake_case names which use +' do
    let(:filename) { 'some/dir/some_file.xlsx+mobile.axlsx' }

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with non-snake-case file names with a shebang' do
    let(:filename) { '/some/dir/test-case' }
    let(:source) { <<~RUBY }
      #!/usr/bin/env ruby
      print 1
    RUBY

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end

    context 'when IgnoreExecutableScripts is disabled' do
      let(:cop_config) { { 'IgnoreExecutableScripts' => false } }

      it 'reports an offense' do
        expect(offenses.size).to eq(1)
      end
    end
  end

  context 'when the file is specified in AllCops/Include' do
    let(:includes) { ['**/Gemfile'] }

    context 'with a non-snake_case file name' do
      let(:filename) { '/some/dir/Gemfile' }

      it 'does not report an offense' do
        expect(offenses.empty?).to be(true)
      end
    end
  end

  context 'when ExpectMatchingDefinition is true' do
    let(:cop_config) do
      {
        'IgnoreExecutableScripts' => true,
        'ExpectMatchingDefinition' => true,
        'CheckDefinitionPathHierarchy' => 'true'
      }
    end

    context 'on a file which defines no class or module at all' do
      %w[lib src test spec].each do |dir|
        context "under #{dir}" do
          let(:filename) { "/some/dir/#{dir}/file/test_case.rb" }

          it 'registers an offense' do
            expect(offenses.size).to eq(1)
            expect(messages).to eq(['test_case.rb should define a class ' \
                                    'or module called `File::TestCase`.'])
          end
        end
      end

      context 'under some other random directory' do
        let(:filename) { '/some/other/dir/test_case.rb' }

        it 'registers an offense' do
          expect(offenses.size).to eq(1)
          expect(messages).to eq(['test_case.rb should define a class ' \
                                  'or module called `TestCase`.'])
        end
      end
    end

    context 'on an empty file' do
      let(:source) { '' }
      let(:filename) { '/lib/rubocop/blah.rb' }

      it 'registers an offense' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(['blah.rb should define a class or module called `Rubocop::Blah`.'])
      end
    end

    context 'on an empty file with a space in its filename' do
      let(:source) { '' }
      let(:filename) { 'a file.rb' }

      it 'registers an offense' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(['The name of this source file (`a file.rb`) ' \
                                'should use snake_case.'])
      end
    end

    shared_examples 'matching module or class' do
      %w[lib src test spec].each do |dir|
        context "in a matching directory under #{dir}" do
          let(:filename) { "/some/dir/#{dir}/a/b.rb" }

          it 'does not register an offense' do
            expect(offenses.empty?).to be(true)
          end
        end

        context "in a non-matching directory under #{dir}" do
          let(:filename) { "/some/dir/#{dir}/c/b.rb" }

          it 'registers an offense' do
            expect(offenses.size).to eq(1)
            expect(messages).to eq(['b.rb should define a class or module called `C::B`.'])
          end
        end

        context "in a directory with multiple instances of #{dir}" do
          let(:filename) { "/some/dir/#{dir}/project/#{dir}/a/b.rb" }

          it 'does not register an offense' do
            expect(offenses.empty?).to be(true)
          end
        end
      end

      context 'in a directory elsewhere which only matches the module name' do
        let(:filename) { '/some/dir/b.rb' }

        it 'does not register an offense' do
          expect(offenses.empty?).to be(true)
        end
      end

      context 'in a directory elsewhere which does not match the module name' do
        let(:filename) { '/some/dir/e.rb' }

        it 'registers an offense' do
          expect(offenses.size).to eq(1)
          expect(messages).to eq(['e.rb should define a class or module called `E`.'])
        end
      end
    end

    context 'on a file which defines a nested module' do
      let(:source) { <<~RUBY }
        module A
          module B
          end
        end
      RUBY

      include_examples 'matching module or class'
    end

    context 'on a file which defines a nested class' do
      let(:source) { <<~RUBY }
        module A
          class B
          end
        end
      RUBY

      include_examples 'matching module or class'
    end

    context 'on a file which uses Name::Spaced::Module syntax' do
      let(:source) { <<~RUBY }
        begin
          module A::B
          end
        end
      RUBY

      include_examples 'matching module or class'
    end

    context 'on a file which defines multiple classes' do
      let(:source) { <<~RUBY }
        class X
        end
        module M
        end
        class A
          class B
          end
        end
      RUBY

      include_examples 'matching module or class'
    end
  end

  context 'when CheckDefinitionPathHierarchy is false' do
    let(:cop_config) do
      {
        'IgnoreExecutableScripts' => true,
        'ExpectMatchingDefinition' => true,
        'CheckDefinitionPathHierarchy' => false
      }
    end

    context 'on a file with a matching class' do
      let(:source) { <<~RUBY }
        begin
          class ImageCollection
          end
        end
      RUBY
      let(:filename) { '/lib/image_collection.rb' }

      it 'does not register an offense' do
        expect(offenses.empty?).to be(true)
      end
    end

    context 'on a file with a non-matching class' do
      let(:source) { <<~RUBY }
        begin
          class PictureCollection
          end
        end
      RUBY
      let(:filename) { '/lib/image_collection.rb' }

      it 'registers an offense' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(['image_collection.rb should define a ' \
                                'class or module called `ImageCollection`.'])
      end
    end

    context 'on an empty file' do
      let(:source) { '' }
      let(:filename) { '/lib/rubocop/foo.rb' }

      it 'registers an offense' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(['foo.rb should define a class or module called `Foo`.'])
      end
    end

    context 'in a non-matching directory, but with a matching class' do
      let(:source) { <<~RUBY }
        begin
          module Foo
          end
        end
      RUBY
      let(:filename) { '/lib/some/path/foo.rb' }

      it 'does not register an offense' do
        expect(offenses.empty?).to be(true)
      end
    end

    context 'with a non-matching module containing a matching class' do
      let(:source) { <<~RUBY }
        begin
          module NonMatching
            class Foo
            end
          end
        end
      RUBY
      let(:filename) { 'lib/foo.rb' }

      it 'does not register an offense' do
        expect(offenses.empty?).to be(true)
      end
    end

    context 'with a matching module containing a non-matching class' do
      let(:source) { <<~RUBY }
        begin
          module Foo
            class NonMatching
            end
          end
        end
      RUBY
      let(:filename) { 'lib/foo.rb' }

      it 'does not register an offense' do
        expect(offenses.empty?).to be(true)
      end
    end
  end

  context 'when Regex is set' do
    let(:cop_config) { { 'Regex' => /\A[aeiou]\z/i } }

    context 'with a matching name' do
      let(:filename) { 'a.rb' }

      it 'does not register an offense' do
        expect(offenses.empty?).to be(true)
      end
    end

    context 'with a non-matching name' do
      let(:filename) { 'z.rb' }

      it 'registers an offense' do
        expect(offenses.size).to eq(1)
        expect(messages).to eq(['`z.rb` should match `(?i-mx:\\A[aeiou]\\z)`.'])
      end
    end
  end

  context 'with acronym namespace' do
    let(:cop_config) do
      {
        'IgnoreExecutableScripts' => true,
        'ExpectMatchingDefinition' => true,
        'AllowedAcronyms' => ['CLI']
      }
    end

    let(:filename) { '/lib/my/cli/admin_user.rb' }

    let(:source) { <<~RUBY }
      module My
        module CLI
          class AdminUser
          end
        end
      end
    RUBY

    it 'does not register an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with acronym class name' do
    let(:cop_config) do
      {
        'IgnoreExecutableScripts' => true,
        'ExpectMatchingDefinition' => true,
        'AllowedAcronyms' => ['CLI']
      }
    end

    let(:filename) { '/lib/my/cli.rb' }

    let(:source) { <<~RUBY }
      module My
        class CLI
        end
      end
    RUBY

    it 'does not register an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with include acronym name' do
    let(:cop_config) do
      {
        'IgnoreExecutableScripts' => true,
        'ExpectMatchingDefinition' => true,
        'AllowedAcronyms' => ['HTTP']
      }
    end

    let(:filename) { '/lib/my/http_server.rb' }

    let(:source) { <<~RUBY }
      module My
        class HTTPServer
        end
      end
    RUBY

    it 'does not register an offense' do
      expect(offenses.empty?).to be(true)
    end
  end

  context 'with dotfiles' do
    let(:filename) { '.pryrc' }

    it 'does not report an offense' do
      expect(offenses.empty?).to be(true)
    end
  end
end
