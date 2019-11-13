# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Migration::DepartmentName do
  subject(:cop) { described_class.new }

  context 'when todo/enable comments have cop names without departments' do
    let(:tip) { 'Run `rubocop -a --only Migration/DepartmentName` to fix.' }
    let(:warning) do
      <<~OUTPUT
        file.rb: Warning: no department given for Alias. #{tip}
        file.rb: Warning: no department given for LineLength. #{tip}
        file.rb: Warning: no department given for Alias. #{tip}
        file.rb: Warning: no department given for LineLength. #{tip}
      OUTPUT
    end

    it 'registers offenses and corrects' do
      expect do
        expect_offense(<<~RUBY, 'file.rb')
          # rubocop:todo Alias, LineLength
                                ^^^^^^^^^^ Department name is missing.
                         ^^^^^ Department name is missing.
          alias :ala :bala
          # rubocop:enable Alias, LineLength
                                  ^^^^^^^^^^ Department name is missing.
                           ^^^^^ Department name is missing.
        RUBY
      end.to output(warning).to_stderr

      expect_correction(<<~RUBY)
        # rubocop:todo Style/Alias, Layout/LineLength
        alias :ala :bala
        # rubocop:enable Style/Alias, Layout/LineLength
      RUBY
    end
  end

  context 'when a disable comment has cop names with departments' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        alias :ala :bala # rubocop:disable all
        # rubocop:disable Style/Alias
      RUBY
    end
  end
end
