# frozen_string_literal: true

describe RuboCop::Cop::Lint::ScriptPermission do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new }

  before do
    file_stat = double('file_stat')
    allow(file_stat).to receive(:executable?).and_return(execution)
    allow(File).to receive(:stat).and_return(file_stat)
  end

  context 'with file permission 0644' do
    let(:execution) { false }

    it 'registers an offense for script permission' do
      if RuboCop::Platform.windows?
        expect_no_offenses(<<-RUBY.strip_indent)
          #!/usr/bin/ruby
        RUBY
      else
        expect_offense(<<-RUBY.strip_indent)
          #!/usr/bin/ruby
          ^^^^^^^^^^^^^^^ Script file example.rb doesn't have execute permission.
        RUBY
      end
    end
  end

  context 'with file permission 0755' do
    let(:execution) { true }

    it 'accepts with shebang line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        #!/usr/bin/ruby
      RUBY
    end

    it 'accepts without shebang line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        puts "hello"
      RUBY
    end

    it 'accepts with blank' do
      expect_no_offenses('')
    end
  end
end
