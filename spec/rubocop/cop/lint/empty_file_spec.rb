# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyFile, :config do
  let(:commissioner) { RuboCop::Cop::Commissioner.new([cop]) }
  let(:offenses) { commissioner.investigate(processed_source).offenses }
  let(:file) { Tempfile.new('') }
  let(:filename) { file.path.split('/').last }

  context 'when AllowComments is true' do
    let(:cop_config) { { 'AllowComments' => true } }
    let(:source) { '' }

    it 'registers an offense when the file is empty' do
      File.write(file.path, source)

      expect_offense(<<~RUBY, file)
        ^{} Empty file detected.
      RUBY

      expect_no_corrections
      expect(File).not_to exist(file.path)
    end

    it 'does not register an offense when the file contains code' do
      expect_no_offenses(<<~RUBY)
        foo.bar
      RUBY
    end

    it 'does not register an offense when the file contains comments' do
      expect_no_offenses(<<~RUBY)
        # comment
      RUBY
    end
  end

  context 'when AllowComments is false' do
    let(:cop_config) { { 'AllowComments' => false } }
    let(:source) { '# comment' }

    it 'registers an offense when the file contains comments' do
      File.write(file.path, source)

      expect_offense(<<~RUBY, file)
        # comment
        ^{} Empty file detected.
      RUBY

      expect_no_corrections
      expect(File).not_to exist(file.path)
    end
  end
end
