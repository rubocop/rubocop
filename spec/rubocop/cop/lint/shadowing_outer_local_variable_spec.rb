# frozen_string_literal: true

describe RuboCop::Cop::Lint::ShadowingOuterLocalVariable do
  subject(:cop) { described_class.new }

  context 'when a block argument has same name ' \
          'as an outer scope variable' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          1.times do |foo|
          end
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Shadowing outer local variable - `foo`.')
      expect(cop.offenses.first.line).to eq(4)
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a splat block argument has same name ' \
          'as an outer scope variable' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          1.times do |*foo|
          end
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Shadowing outer local variable - `foo`.')
      expect(cop.offenses.first.line).to eq(4)
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a block block argument has same name ' \
          'as an outer scope variable' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          proc_taking_block = proc do |&foo|
          end
          proc_taking_block.call do
          end
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Shadowing outer local variable - `foo`.')
      expect(cop.offenses.first.line).to eq(4)
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a block local variable has same name ' \
          'as an outer scope variable' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          1.times do |i; foo|
            puts foo
          end
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Shadowing outer local variable - `foo`.')
      expect(cop.offenses.first.line).to eq(4)
    end

    include_examples 'mimics MRI 2.1', 'shadowing'
  end

  context 'when a block argument has different name ' \
          'with outer scope variables' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          1.times do |bar|
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when an outer scope variable is reassigned in a block' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          1.times do
            foo = 2
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when an outer scope variable is referenced in a block' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          foo = 1
          puts foo
          1.times do
            puts foo
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when multiple block arguments have same name "_"' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          1.times do |_, foo, _|
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when multiple block arguments have ' \
          'a same name starts with "_"' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          1.times do |_foo, bar, _foo|
          end
        end
      RUBY
    end

    include_examples 'accepts' unless RUBY_VERSION < '2.0'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a block argument has same name "_" ' \
          'as outer scope variable "_"' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          _ = 1
          puts _
          1.times do |_|
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a block argument has a same name starts with "_" ' \
          'as an outer scope variable' do
    let(:source) do
      <<-RUBY.strip_indent
        def some_method
          _foo = 1
          puts _foo
          1.times do |_foo|
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a method argument has same name ' \
          'as an outer scope variable' do
    let(:source) do
      <<-RUBY.strip_indent
        class SomeClass
          foo = 1
          puts foo
          def some_method(foo)
          end
        end
      RUBY
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end
end
