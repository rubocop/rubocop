# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::YAMLFileRead, :config do
  context 'when Ruby >= 3.0', :ruby30 do
    it 'registers an offense when using `YAML.load` with `File.read` argument' do
      expect_offense(<<~RUBY)
        YAML.load(File.read(path))
             ^^^^^^^^^^^^^^^^^^^^^ Use `load_file(path)` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.load_file(path)
      RUBY
    end

    it 'registers an offense when using `YAML.safe_load` with `File.read` argument' do
      expect_offense(<<~RUBY)
        YAML.safe_load(File.read(path))
             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `safe_load_file(path)` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.safe_load_file(path)
      RUBY
    end

    it 'registers an offense when using `YAML.safe_load` with `File.read` and some arguments' do
      expect_offense(<<~RUBY)
        YAML.safe_load(File.read(path), permitted_classes: [Regexp, Symbol], aliases: true)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `safe_load_file(path, permitted_classes: [Regexp, Symbol], aliases: true)` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.safe_load_file(path, permitted_classes: [Regexp, Symbol], aliases: true)
      RUBY
    end

    it 'registers an offense when using `YAML.parse` with `File.read` argument' do
      expect_offense(<<~RUBY)
        YAML.parse(File.read(path))
             ^^^^^^^^^^^^^^^^^^^^^^ Use `parse_file(path)` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.parse_file(path)
      RUBY
    end

    it 'registers an offense when using `::YAML.load` with `::File.read` argument' do
      expect_offense(<<~RUBY)
        ::YAML.load(::File.read(path))
               ^^^^^^^^^^^^^^^^^^^^^^^ Use `load_file(path)` instead.
      RUBY
    end

    it "registers an offense when using `YAML.load` with `File.read(Rails.root.join('foo', 'bar', 'baz'))` argument" do
      expect_offense(<<~RUBY)
        YAML.load(File.read(Rails.root.join('foo', 'bar', 'baz')))
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `load_file(Rails.root.join('foo', 'bar', 'baz'))` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.load_file(Rails.root.join('foo', 'bar', 'baz'))
      RUBY
    end

    it 'does not register an offense when using `YAML.load` with variable argument' do
      expect_no_offenses(<<~RUBY)
        YAML.load(yaml)
      RUBY
    end

    it 'does not register an offense when using `YAML.load_file`' do
      expect_no_offenses(<<~RUBY)
        YAML.load_file(File.read(path))
      RUBY
    end
  end

  context 'when Ruby <= 2.7', :ruby27, unsupported_on: :prism do
    it 'registers an offense when using `YAML.load` with `File.read` argument' do
      expect_offense(<<~RUBY)
        YAML.load(File.read(path))
             ^^^^^^^^^^^^^^^^^^^^^ Use `load_file(path)` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.load_file(path)
      RUBY
    end

    it 'does not register an offense when using `YAML.safe_load` with `File.read` argument' do
      expect_no_offenses(<<~RUBY)
        YAML.safe_load(File.read(path))
      RUBY
    end

    it 'registers an offense when using `YAML.parse` with `File.read` argument' do
      expect_offense(<<~RUBY)
        YAML.parse(File.read(path))
             ^^^^^^^^^^^^^^^^^^^^^^ Use `parse_file(path)` instead.
      RUBY

      expect_correction(<<~RUBY)
        YAML.parse_file(path)
      RUBY
    end
  end
end
