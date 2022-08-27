# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::FileName, :config do
  let(:config) do
    RuboCop::Config.new(
      { 'AllCops' => { 'Include' => includes },
        described_class.badge.to_s => cop_config },
      '/some/.rubocop.yml'
    )
  end
  let(:cop_config) do # matches default.yml
    {
      'IgnoreExecutableScripts' => true,
      'ExpectMatchingDefinition' => false,
      'Regex' => nil,
      'CheckDefinitionPathHierarchy' => true,
      'CheckDefinitionPathHierarchyRoots' => %w[lib spec test src]
    }
  end
  let(:includes) { ['**/*.rb'] }

  context 'with camelCase file names ending in .rb' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, '/some/dir/testCase.rb')
        print 1
        ^ The name of this source file (`testCase.rb`) should use snake_case.
      RUBY
    end
  end

  context 'with camelCase file names without file extension' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, '/some/dir/testCase')
        print 1
        ^ The name of this source file (`testCase`) should use snake_case.
      RUBY
    end
  end

  context 'with snake_case file names ending in .rb' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/some/dir/test_case.rb')
        print 1
      RUBY
    end
  end

  context 'with snake_case file names without file extension' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/some/dir/test_case')
        print 1
      RUBY
    end
  end

  context 'with snake_case file names with non-rb extension' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/some/dir/test_case.rake')
        print 1
      RUBY
    end
  end

  context 'with snake_case file names with multiple extensions' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'some/dir/some_view.html.slim_spec.rb')
        print 1
      RUBY
    end
  end

  context 'with snake_case names which use ? and !' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'some/dir/file?!.rb')
        print 1
      RUBY
    end
  end

  context 'with snake_case names which use +' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'some/dir/some_file.xlsx+mobile.axlsx')
        print 1
      RUBY
    end
  end

  context 'with non-snake-case file names with a shebang' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/some/dir/test-case')
        #!/usr/bin/env ruby
        print 1
      RUBY
    end

    context 'when IgnoreExecutableScripts is disabled' do
      let(:cop_config) { super().merge('IgnoreExecutableScripts' => false) }

      it 'registers an offense' do
        expect_offense(<<~RUBY, '/some/dir/test-case')
          #!/usr/bin/env ruby
          ^ The name of this source file (`test-case`) should use snake_case.
          print 1
        RUBY
      end
    end
  end

  context 'when the file is specified in AllCops/Include' do
    let(:includes) { ['**/Gemfile'] }

    context 'with a non-snake_case file name' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, '/some/dir/Gemfile')
          print 1
        RUBY
      end
    end
  end

  context 'when ExpectMatchingDefinition is true' do
    let(:cop_config) { super().merge('ExpectMatchingDefinition' => true) }

    context 'on a file which defines no class or module at all' do
      %w[lib src test spec].each do |dir|
        context "under #{dir}" do
          it 'registers an offense' do
            expect_offense(<<~RUBY, "/some/dir/#{dir}/file/test_case.rb")
              print 1
              ^ `test_case.rb` should define a class or module called `File::TestCase`.
            RUBY
          end
        end
      end

      context 'under lib when not added to root' do
        let(:cop_config) { super().merge('CheckDefinitionPathHierarchyRoots' => ['foo']) }

        it 'registers an offense' do
          expect_offense(<<~RUBY, '/some/other/dir/test_case.rb')
            print 1
            ^ `test_case.rb` should define a class or module called `TestCase`.
          RUBY
        end
      end

      context 'under some other random directory' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, '/some/other/dir/test_case.rb')
            print 1
            ^ `test_case.rb` should define a class or module called `TestCase`.
          RUBY
        end
      end
    end

    context 'on an empty file' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, '/lib/rubocop/blah.rb')
          ^ `blah.rb` should define a class or module called `Rubocop::Blah`.
        RUBY
      end
    end

    context 'on an empty file with a space in its filename' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'a file.rb')
          ^ The name of this source file (`a file.rb`) should use snake_case.
        RUBY
      end
    end

    shared_examples 'matching module or class' do |source|
      %w[lib src test spec].each do |dir|
        context "in a matching directory under #{dir}" do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, "/some/dir/#{dir}/a/b.rb")
              #{source}
            RUBY
          end
        end

        context "in a non-matching directory under #{dir}" do
          it 'registers an offense' do
            expect_offense(<<~RUBY, "/some/dir/#{dir}/c/b.rb")
              # b.rb
              ^ `b.rb` should define a class or module called `C::B`.
              #{source}
            RUBY
          end
        end

        context "in a directory with multiple instances of #{dir}" do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, "/some/dir/#{dir}/project/#{dir}/a/b.rb")
              #{source}
            RUBY
          end
        end
      end

      context 'in a directory elsewhere which only matches the module name' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, '/some/dir/b.rb')
            #{source}
          RUBY
        end
      end

      context 'in a directory elsewhere which does not match the module name' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, '/some/dir/e.rb')
            # start of file
            ^ `e.rb` should define a class or module called `E`.
            #{source}
          RUBY
        end
      end
    end

    context 'on a file which defines a nested module' do
      include_examples 'matching module or class', <<~RUBY
        module A
          module B
          end
        end
      RUBY
    end

    context 'on a file which defines a nested class' do
      include_examples 'matching module or class', <<~RUBY
        module A
          class B
          end
        end
      RUBY
    end

    context 'on a file which uses Name::Spaced::Module syntax' do
      include_examples 'matching module or class', <<~RUBY
        begin
          module A::B
          end
        end
      RUBY
    end

    context 'on a file which defines multiple classes' do
      include_examples 'matching module or class', <<~RUBY
        class X
        end
        module M
        end
        class A
          class B
          end
        end
      RUBY
    end

    context 'on a file which defines a Struct without a block' do
      include_examples 'matching module or class', <<~RUBY
        module A
          B = Struct.new(:foo, :bar)
        end
      RUBY
    end

    context 'on a file which defines a Struct with a block' do
      include_examples 'matching module or class', <<~RUBY
        module A
          B = Struct.new(:foo, :bar) do
          end
        end
      RUBY
    end
  end

  context 'when CheckDefinitionPathHierarchy is false' do
    let(:cop_config) do
      super().merge('ExpectMatchingDefinition' => true, 'CheckDefinitionPathHierarchy' => false)
    end

    context 'on a file with a matching class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, '/lib/image_collection.rb')
          begin
            class ImageCollection
            end
          end
        RUBY
      end
    end

    context 'on a file with a non-matching class' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, '/lib/image_collection.rb')
          begin
          ^ `image_collection.rb` should define a class or module called `ImageCollection`.
            class PictureCollection
            end
          end
        RUBY
      end
    end

    context 'on a file with a matching struct' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, '/lib/image_collection.rb')
          ImageCollection = Struct.new
        RUBY
      end
    end

    context 'on a file with a non-matching struct' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, '/lib/image_collection.rb')
          PictureCollection = Struct.new
          ^ `image_collection.rb` should define a class or module called `ImageCollection`.
        RUBY
      end
    end

    context 'on an empty file' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, '/lib/rubocop/foo.rb')
          ^ `foo.rb` should define a class or module called `Foo`.
        RUBY
      end
    end

    context 'in a non-matching directory, but with a matching class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, '/lib/some/path/foo.rb')
          begin
            module Foo
            end
          end
        RUBY
      end
    end

    context 'with a non-matching module containing a matching class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'lib/foo.rb')
          begin
            module NonMatching
              class Foo
              end
            end
          end
        RUBY
      end
    end

    context 'with a matching module containing a non-matching class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'lib/foo.rb')
          begin
            module Foo
              class NonMatching
              end
            end
          end
        RUBY
      end
    end

    context 'with a non-matching module containing a matching struct' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'lib/foo.rb')
          begin
            module NonMatching
              Foo = Struct.new
            end
          end
        RUBY
      end
    end

    context 'with a matching module containing a non-matching struct' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'lib/foo.rb')
          begin
            module Foo
              NonMatching = Struct.new
            end
          end
        RUBY
      end
    end
  end

  context 'when Regex is set' do
    let(:cop_config) { { 'Regex' => /\A[aeiou]\z/i } }

    context 'with a matching name' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'a.rb')
          print 1
        RUBY
      end
    end

    context 'with a non-matching name' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'z.rb')
          print 1
          ^ `z.rb` should match `(?i-mx:\\A[aeiou]\\z)`.
        RUBY
      end
    end
  end

  context 'with acronym namespace' do
    let(:cop_config) do
      super().merge('ExpectMatchingDefinition' => true, 'AllowedAcronyms' => ['CLI'])
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/lib/my/cli/admin_user.rb')
        module My
          module CLI
            class AdminUser
            end
          end
        end
      RUBY
    end
  end

  context 'with acronym class name' do
    let(:cop_config) do
      super().merge('ExpectMatchingDefinition' => true, 'AllowedAcronyms' => ['CLI'])
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/lib/my/cli.rb')
        module My
          class CLI
          end
        end
      RUBY
    end
  end

  context 'with include acronym name' do
    let(:cop_config) do
      super().merge('ExpectMatchingDefinition' => true, 'AllowedAcronyms' => ['HTTP'])
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/lib/my/http_server.rb')
        module My
          class HTTPServer
          end
        end
      RUBY
    end
  end

  context 'with dotfiles' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '.pryrc')
        print 1
      RUBY
    end
  end

  context 'with non-ascii characters in filename' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '/some/dir/ünbound_sérvér.rb')
        print 1
      RUBY
    end
  end
end
