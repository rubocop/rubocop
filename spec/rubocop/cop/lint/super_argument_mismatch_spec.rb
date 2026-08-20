# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SuperArgumentMismatch, :config do
  it 'does not register an offense without a project index' do
    expect_no_offenses(<<~RUBY)
      class Widget < Base
        def initialize(name)
          super(name)
        end
      end
    RUBY
  end

  context 'with a project index', :project_index do
    # The cop anchors the enclosing class to the inspected file, so the child's
    # index URI must round-trip through the same path expansion the runner
    # applies - drive-less fake paths behave differently on Windows.
    let(:child_path) { File.expand_path('child.rb') }

    def file_uri(path)
      path.start_with?('/') ? "file://#{path}" : "file:///#{path}"
    end

    # Index the parent definitions together with the inspected file. This
    # mirrors production, where the file being linted is part of the
    # whole-project index.
    def index_with_child(child, parents)
      cop.project_index = build_index(parents.merge(file_uri(child_path) => child))
    end

    context 'for a fixed-arity overridden method' do
      let(:parent) do
        { 'file:///base.rb' => <<~RUBY }
          class Base
            def initialize(name, size); end
          end
        RUBY
      end

      it 'registers an offense when too few arguments are given' do
        source = <<~RUBY
          class Widget < Base
            def initialize(name)
              super(name)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Widget < Base
            def initialize(name)
              super(name)
              ^^^^^ Wrong number of arguments to `super` (given 1, expected 2 for `Base#initialize`).
            end
          end
        RUBY
      end

      it 'registers an offense when too many arguments are given' do
        source = <<~RUBY
          class Widget < Base
            def initialize(name)
              super(name, 1, 2)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Widget < Base
            def initialize(name)
              super(name, 1, 2)
              ^^^^^ Wrong number of arguments to `super` (given 3, expected 2 for `Base#initialize`).
            end
          end
        RUBY
      end

      it 'registers an offense for `super()` with no arguments' do
        source = <<~RUBY
          class Widget < Base
            def initialize(name)
              super()
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Widget < Base
            def initialize(name)
              super()
              ^^^^^ Wrong number of arguments to `super` (given 0, expected 2 for `Base#initialize`).
            end
          end
        RUBY
      end

      it 'does not register an offense when the arity matches' do
        source = <<~RUBY
          class Widget < Base
            def initialize(name)
              super(name, 0)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_no_offenses(source, child_path)
      end

      it 'does not register an offense for bare `super`' do
        source = <<~RUBY
          class Widget < Base
            def initialize(name)
              super
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_no_offenses(source, child_path)
      end

      it 'does not register an offense when arguments are forwarded' do
        source = <<~RUBY
          class Widget < Base
            def initialize(*args)
              super(*args)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_no_offenses(source, child_path)
      end

      it 'ignores a trailing block-pass argument' do
        source = <<~RUBY
          class Widget < Base
            def initialize(name, &block)
              super(name, &block)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Widget < Base
            def initialize(name, &block)
              super(name, &block)
              ^^^^^ Wrong number of arguments to `super` (given 1, expected 2 for `Base#initialize`).
            end
          end
        RUBY
      end
    end

    context 'for optional and rest parameters' do
      let(:parent) do
        { 'file:///base.rb' => <<~RUBY }
          class Base
            def add(a, b = 0); end
            def sum(first, *rest); end
          end
        RUBY
      end

      it 'accepts a call within the optional range' do
        source = <<~RUBY
          class Child < Base
            def add(a)
              super(a)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_no_offenses(source, child_path)
      end

      it 'registers an offense past the optional maximum' do
        source = <<~RUBY
          class Child < Base
            def add(a)
              super(a, 1, 2)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Child < Base
            def add(a)
              super(a, 1, 2)
              ^^^^^ Wrong number of arguments to `super` (given 3, expected 1..2 for `Base#add`).
            end
          end
        RUBY
      end

      it 'reports the minimum with a trailing plus for a rest parameter' do
        source = <<~RUBY
          class Child < Base
            def sum(first)
              super()
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Child < Base
            def sum(first)
              super()
              ^^^^^ Wrong number of arguments to `super` (given 0, expected 1+ for `Base#sum`).
            end
          end
        RUBY
      end
    end

    context 'with keyword arguments' do
      it 'folds keywords into a positional hash when the parent has none' do
        source = <<~RUBY
          class Child < Base
            def opts(hash)
              super(a: 1, b: 2)
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => <<~RUBY)
          class Base
            def opts(hash); end
          end
        RUBY

        expect_no_offenses(source, child_path)
      end

      it 'does not count keywords as positional when the parent declares them' do
        source = <<~RUBY
          class Child < Base
            def build(name)
              super(name, size: 1)
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => <<~RUBY)
          class Base
            def build(name, size:); end
          end
        RUBY

        expect_no_offenses(source, child_path)
      end

      it 'skips a call that forwards a double splat' do
        source = <<~RUBY
          class Child < Base
            def build(name, **opts)
              super(name, extra, **opts)
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => <<~RUBY)
          class Base
            def build(name); end
          end
        RUBY

        expect_no_offenses(source, child_path)
      end
    end

    context 'with modules in the ancestry' do
      it 'resolves the implementation through an included module' do
        source = <<~RUBY
          class Child < Base
            include Extras

            def run(a)
              super(a)
            end
          end
        RUBY
        index_with_child(
          source,
          'file:///base.rb' => "class Base\n  def run(a, b); end\nend\n",
          'file:///extras.rb' => "module Extras\n  def run(a, b, c); end\nend\n"
        )

        expect_offense(<<~RUBY, child_path)
          class Child < Base
            include Extras

            def run(a)
              super(a)
              ^^^^^ Wrong number of arguments to `super` (given 1, expected 3 for `Extras#run`).
            end
          end
        RUBY
      end

      it 'skips a method defined in a prepended module of the same class' do
        source = <<~RUBY
          class Child < Base
            prepend Wrapper

            def run(a)
              super(a)
            end
          end
        RUBY
        index_with_child(
          source,
          'file:///base.rb' => "class Base\n  def run(a); end\nend\n",
          'file:///wrapper.rb' => "module Wrapper\n  def run(a, b); end\nend\n"
        )

        # `super` from `Child#run` skips the prepended `Wrapper#run` and
        # dispatches to `Base#run`, whose arity matches.
        expect_no_offenses(source, child_path)
      end

      it 'does not check `super` inside a method defined in a module' do
        source = <<~RUBY
          module Helper
            def run(a)
              super(a)
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => "class Base\n  def run(a, b); end\nend\n")

        expect_no_offenses(source, child_path)
      end
    end

    context 'when the context is not statically known' do
      let(:parent) do
        { 'file:///base.rb' => <<~RUBY }
          class Base
            def run(a, b); end
          end
        RUBY
      end

      it 'does not check `super` inside a singleton method' do
        source = <<~RUBY
          class Child < Base
            def self.run(a)
              super(a)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_no_offenses(source, child_path)
      end

      it 'does not check `super` inside `define_method`' do
        source = <<~RUBY
          class Child < Base
            define_method(:run) do |a|
              super(a)
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_no_offenses(source, child_path)
      end

      it 'checks `super` inside an ordinary block' do
        source = <<~RUBY
          class Child < Base
            def run(a)
              [a].each { |x| super(x) }
            end
          end
        RUBY
        index_with_child(source, parent)

        expect_offense(<<~RUBY, child_path)
          class Child < Base
            def run(a)
              [a].each { |x| super(x) }
                             ^^^^^ Wrong number of arguments to `super` (given 1, expected 2 for `Base#run`).
            end
          end
        RUBY
      end
    end

    context 'when the overridden implementation is not checkable' do
      it 'does not register an offense when no indexed ancestor defines the method' do
        source = <<~RUBY
          class Child < Base
            def to_s
              super()
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => "class Base\nend\n")

        expect_no_offenses(source, child_path)
      end

      it 'does not use a method the index attributes to `Object` as the target' do
        source = <<~RUBY
          class Child < Base
            def run(a)
              super(a)
            end
          end
        RUBY
        # `def run` inside a block at the top level is indexed under `Object`
        # even though it actually defines a method on the anonymous struct.
        index_with_child(
          source,
          'file:///base.rb' => "class Base\nend\n",
          'file:///post.rb' => "Post = Struct.new(:title) do\n  def run(a, b); end\nend\n"
        )

        expect_no_offenses(source, child_path)
      end

      it 'does not register an offense when the ancestry is not fully resolved' do
        source = <<~RUBY
          class Child < Unknown
            def run(a)
              super(a)
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => "class Base\n  def run(a, b); end\nend\n")

        expect_no_offenses(source, child_path)
      end

      it 'does not register an offense when the parent method is an attr writer pair' do
        source = <<~RUBY
          class Child < Base
            def value(a)
              super(a)
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => "class Base\n  attr_reader :value\nend\n")

        expect_no_offenses(source, child_path)
      end

      it 'does not register an offense when parent definitions disagree on arity' do
        source = <<~RUBY
          class Child < Base
            def run(a)
              super(a)
            end
          end
        RUBY
        index_with_child(
          source,
          'file:///base.rb' => "class Base\n  def run(a, b); end\nend\n",
          'file:///base_ext.rb' => "class Base\n  def run(a, b, c); end\nend\n"
        )

        expect_no_offenses(source, child_path)
      end
    end

    context 'for a nested class' do
      it 'resolves the enclosing class through the lexical nesting' do
        source = <<~RUBY
          module App
            class Child < Base
              def run(a)
                super(a)
              end
            end
          end
        RUBY
        index_with_child(source, 'file:///base.rb' => <<~RUBY)
          module App
            class Base
              def run(a, b); end
            end
          end
        RUBY

        expect_offense(<<~RUBY, child_path)
          module App
            class Child < Base
              def run(a)
                super(a)
                ^^^^^ Wrong number of arguments to `super` (given 1, expected 2 for `App::Base#run`).
              end
            end
          end
        RUBY
      end
    end
  end
end
