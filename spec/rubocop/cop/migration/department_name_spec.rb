# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Migration::DepartmentName, :config do
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

    it 'registers offenses and corrects when there is space around `:`' do
      expect do
        expect_offense(<<~RUBY, 'file.rb')
          # rubocop : todo Alias, LineLength
                                  ^^^^^^^^^^ Department name is missing.
                           ^^^^^ Department name is missing.
          alias :ala :bala
          # rubocop : enable Alias, LineLength
                                    ^^^^^^^^^^ Department name is missing.
                             ^^^^^ Department name is missing.
        RUBY
      end.to output(warning).to_stderr

      expect_correction(<<~RUBY)
        # rubocop : todo Style/Alias, Layout/LineLength
        alias :ala :bala
        # rubocop : enable Style/Alias, Layout/LineLength
      RUBY
    end

    it 'registers offenses and corrects when using a legacy cop name' do
      expect_offense(<<~RUBY, 'file.rb')
        # rubocop:disable SingleSpaceBeforeFirstArg, Layout/LineLength
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Department name is missing.
        name             "apache_kafka"
      RUBY

      # `Style/SingleSpaceBeforeFirstArg` is a legacy name that has been
      # renamed to `Layout/SpaceBeforeFirstArg`. In the autocorrection,
      # the department name is complemented by the legacy cop name.
      # Migration to the new name is expected to be modified using Gry gem.
      expect_correction(<<~RUBY)
        # rubocop:disable Style/SingleSpaceBeforeFirstArg, Layout/LineLength
        name             "apache_kafka"
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

  context 'when a disable comment contains a plain comment' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Style/Alias # Plain code comment
        alias :ala :bala
      RUBY
    end
  end

  context 'when a disable comment contains an unexpected character for department name' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Style/Alias -- because something, something, and something
        alias :ala :bala
      RUBY
    end
  end

  # `Migration/DepartmentName` cop's role is to complement a department name.
  # The role would be simple if another feature could detect unexpected
  # disable comment format.
  context 'when an unexpected disable comment format' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Style:Alias
        alias :ala :bala
      RUBY
    end
  end

  context 'when only department name has given' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Style
        alias :ala :bala
      RUBY
    end
  end
end
