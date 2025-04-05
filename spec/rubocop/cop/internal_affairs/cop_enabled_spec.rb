# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::CopEnabled, :config do
  context 'with .for_cop' do
    it "registers an offense when using `config.for_cop(...)['Enabled']" do
      expect_offense(<<~RUBY)
        config.for_cop('Foo/Bar')['Enabled']
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `config.cop_enabled?('Foo/Bar')` instead [...]
      RUBY

      expect_correction(<<~RUBY)
        config.cop_enabled?('Foo/Bar')
      RUBY
    end

    it "registers an offense when using `@config.for_cop(...)['Enabled']" do
      expect_offense(<<~RUBY)
        @config.for_cop('Foo/Bar')['Enabled']
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `@config.cop_enabled?('Foo/Bar')` instead [...]
      RUBY

      expect_correction(<<~RUBY)
        @config.cop_enabled?('Foo/Bar')
      RUBY
    end

    it 'maintains existing quote style when correcting' do
      expect_offense(<<~RUBY)
        @config.for_cop("Foo/Bar")["Enabled"]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `@config.cop_enabled?("Foo/Bar")` instead [...]
      RUBY

      expect_correction(<<~RUBY)
        @config.cop_enabled?("Foo/Bar")
      RUBY
    end

    it 'does not register an offense when :Enabled is a symbol' do
      expect_no_offenses(<<~RUBY)
        @config.for_cop('Foo/Bar')[:Enabled]
      RUBY
    end
  end

  context "when checking `*_config['Enabled']`" do
    it 'registers an offense and does not correct with a method call' do
      expect_offense(<<~RUBY)
        return false unless argument_alignment_config['Enabled']
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider replacing uses of `argument_alignment_config` with `config.for_enabled_cop`.

        argument_alignment_config['EnforcedStyle'] == 'with_fixed_indentation'
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not correct with a local variable' do
      expect_offense(<<~RUBY)
        argument_alignment_config = config.for_cop('Layout/ArgumentAlignment')
        return false unless argument_alignment_config['Enabled']
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider replacing uses of `argument_alignment_config` with `config.for_enabled_cop`.

        argument_alignment_config['EnforcedStyle'] == 'with_fixed_indentation'
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not correct with an instance variable' do
      expect_offense(<<~RUBY)
        @argument_alignment_config = config.for_cop('Layout/ArgumentAlignment')
        return false unless @argument_alignment_config['Enabled']
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider replacing uses of `@argument_alignment_config` with `config.for_enabled_cop`.

        @argument_alignment_config['EnforcedStyle'] == 'with_fixed_indentation'
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense when the hash name does not end with `_config`' do
      expect_no_offenses(<<~RUBY)
        foo['Enabled']
      RUBY
    end
  end
end
