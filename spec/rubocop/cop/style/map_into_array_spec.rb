# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MapIntoArray, :config do
  it 'registers an offense and corrects when using `each` with `<<` to build an array' do
    expect_offense(<<~RUBY)
      dest = []
      src.each { |e| dest << e * 2 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map { |e| e * 2 }
    RUBY
  end

  it 'registers an offense and corrects when using `each` with `push` to build an array' do
    expect_offense(<<~RUBY)
      dest = []
      src.each { |e| dest.push(e * 2) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map { |e| e * 2 }
    RUBY
  end

  it 'registers an offense and corrects when using `each` with `append` to build an array' do
    expect_offense(<<~RUBY)
      dest = []
      src.each { |e| dest.append(e * 2) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map { |e| e * 2 }
    RUBY
  end

  it 'registers an offense and corrects when a non-related operation precedes an `each` call' do
    expect_offense(<<~RUBY)
      dest = []
      do_something
      src.each { |e| dest << e * 2 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
    RUBY

    expect_correction(<<~RUBY)
      do_something
      dest = src.map { |e| e * 2 }
    RUBY
  end

  it 'registers an offense and corrects when a non-related operation follows an `each` call' do
    expect_offense(<<~RUBY)
      dest = []
      src.each { |e| dest << e * 2 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
      do_something
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map { |e| e * 2 }
      do_something
    RUBY
  end

  it 'registers an offense and corrects when using a numblock' do
    expect_offense(<<~RUBY)
      dest = []
      src.each { dest << _1 * 2 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map { _1 * 2 }
    RUBY
  end

  it 'registers an offense and corrects when the destination initialized multiple times' do
    expect_offense(<<~RUBY)
      dest = []
      do_something(dest)
      dest = []
      src.each { |e| dest << e * 2 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
    RUBY

    expect_correction(<<~RUBY)
      dest = []
      do_something(dest)
      dest = src.map { |e| e * 2 }
    RUBY
  end

  it 'registers an offense and corrects removing a destination reference follows an `each` call' do
    expect_offense(<<~RUBY)
      dest = []
      src.each { |e| dest << e * 2 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
      dest
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map { |e| e * 2 }
    RUBY
  end

  it 'registers an offense and corrects when nested autocorrections required' do
    expect_offense(<<~RUBY)
      dest = []
      src.each do |e|
      ^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
        dest << (
          dest2 = []
          src.each do |e|
          ^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
            dest2 << e
          end
          dest2
        )
      end
    RUBY

    expect_correction(<<~RUBY)
      dest = src.map do |e|
        (
          dest2 = src.map do |e|
            e
          end
        )
      end
    RUBY
  end

  it 'does not register an offense when the destination is not a local variable' do
    expect_no_offenses(<<~RUBY)
      @dest = []
      src.each { |e| @dest << e }
    RUBY
  end

  it 'does not register an offense when `each` is called with non-block arguments' do
    expect_no_offenses(<<~RUBY)
      dest = []
      StringIO.new('foo:bar').each(':') { |e| dest << e }
    RUBY
  end

  it 'does not register an offense and corrects when using `each` without receiver with `<<` to build an array' do
    expect_no_offenses(<<~RUBY)
      dest = []
      each { |e| dest << e * 2 }
    RUBY
  end

  it 'does not register an offense and corrects when using `each` with `self` receiver with `<<` to build an array' do
    expect_no_offenses(<<~RUBY)
      dest = []
      self.each { |e| dest << e * 2 }
    RUBY
  end

  it 'does not register an offense when the parent node of an `each` call is not a begin node' do
    expect_no_offenses(<<~RUBY)
      [
        dest = [],
        src.each { |e| dest << e * 2 },
      ]
    RUBY
  end

  it 'does not register an offense when the destination initialization is not a sibling of an `each` call' do
    expect_no_offenses(<<~RUBY)
      dest = []
      if cond
        src.each { |e| dest << e * 2 }
      end
    RUBY
  end

  it 'does not register an offense when the destination is used before an `each` call' do
    expect_no_offenses(<<~RUBY)
      dest = []
      dest << 0
      src.each { |e| dest << e * 2 }
    RUBY
  end

  it 'does not register an offense when the destination is used in the receiver expression' do
    expect_no_offenses(<<~RUBY)
      dest = []
      (dest << 1).each { |e| dest << e * 2 }
    RUBY
  end

  it 'does not register an offense when the destination is shadowed by a block argument' do
    expect_no_offenses(<<~RUBY)
      dest = []
      src.each { |dest| dest << 1 }
    RUBY
  end

  it 'does not register an offense when the destination is used in the transformation' do
    expect_no_offenses(<<~RUBY)
      dest = []
      src.each { |e| dest << dest.size }
    RUBY
  end

  it 'does not register an offense when pushing splat' do
    expect_no_offenses(<<~RUBY)
      dest = []
      src.each { |e| dest.push(*e) }
    RUBY
  end

  context 'destination initializer' do
    shared_examples 'corrects' do |initializer:|
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          dest = #{initializer}
          src.each { |e| dest << e * 2 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
        RUBY

        expect_correction(<<~RUBY)
          dest = src.map { |e| e * 2 }
        RUBY
      end
    end

    context '[]' do
      it_behaves_like 'corrects', initializer: '[]'
    end

    context 'Array.new' do
      it_behaves_like 'corrects', initializer: 'Array.new'
    end

    context 'Array[]' do
      it_behaves_like 'corrects', initializer: 'Array[]'
    end

    context 'Array([])' do
      it_behaves_like 'corrects', initializer: 'Array([])'
    end

    context 'Array.new([])' do
      it_behaves_like 'corrects', initializer: 'Array.new([])'
    end
  end

  context 'new method name for replacement' do
    context 'when `Style/CollectionMethods` is configured for `map`' do
      let(:other_cops) do
        {
          'Style/CollectionMethods' => {
            'PreferredMethods' => {
              'map' => 'collect'
            }
          }
        }
      end

      it 'registers an offense and corrects using the method specified in `PreferredMethods`' do
        expect_offense(<<~RUBY)
          dest = []
          src.each { |e| dest << e * 2 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `collect` instead of `each` to map elements into an array.
        RUBY

        expect_correction(<<~RUBY)
          dest = src.collect { |e| e * 2 }
        RUBY
      end
    end

    context 'when `Style/CollectionMethods` is configured except for `map`' do
      let(:other_cops) do
        {
          'Style/CollectionMethods' => {
            'PreferredMethods' => {
              'reject' => 'filter'
            }
          }
        }
      end

      it 'registers an offense and corrects using `map` method' do
        expect_offense(<<~RUBY)
          dest = []
          src.each { |e| dest << e * 2 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
        RUBY

        expect_correction(<<~RUBY)
          dest = src.map { |e| e * 2 }
        RUBY
      end
    end
  end

  context 'autocorrection skipping' do
    shared_examples 'corrects' do |template:|
      it 'registers an offense and corrects' do
        expect_offense(format(template, <<~RUBY))
          dest = []
          src.each { |e| dest << e * 2 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
        RUBY

        expect_correction(format(template, <<~RUBY))
          dest = src.map { |e| e * 2 }
        RUBY
      end
    end

    shared_examples 'skip correcting' do |template:|
      it 'registers an offense but does not autocorrect it' do
        expect_offense(format(template, <<~RUBY))
          dest = []
          src.each { |e| dest << e * 2 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `map` instead of `each` to map elements into an array.
        RUBY

        expect_no_corrections
      end
    end

    context 'at the top level' do
      it_behaves_like 'corrects', template: '%s'
    end

    context 'in parentheses' do
      context 'not at the end' do
        context 'parent is used' do
          it_behaves_like 'corrects', template: 'a = (%s; do_someting)'
        end

        context 'parent is not used' do
          it_behaves_like 'corrects', template: '(%s; do_someting)'
        end
      end

      context 'at the end' do
        context 'parent is used' do
          it_behaves_like 'skip correcting', template: 'a = (%s)'
        end

        context 'parent is not used' do
          it_behaves_like 'corrects', template: '(%s)'
        end
      end
    end

    context 'in a begin block' do
      context 'not at the end' do
        context 'parent is used' do
          it_behaves_like 'corrects', template: 'a = begin; %s; do_something end'
        end

        context 'parent is not used' do
          it_behaves_like 'corrects', template: 'begin; %s; do_something end'
        end
      end

      context 'at the end' do
        context 'parent is used' do
          it_behaves_like 'skip correcting', template: 'a = begin; %s end'
        end

        context 'parent is not used' do
          it_behaves_like 'corrects', template: 'begin; %s end'
        end
      end

      context 'in an ensure' do
        it_behaves_like 'corrects', template: 'begin; ensure; %s end'
      end
    end

    context 'in a block' do
      context 'in a void context' do
        it_behaves_like 'corrects', template: 'each { %s }'
      end

      context 'in a non-void context' do
        it_behaves_like 'skip correcting', template: 'block { %s }'
      end
    end

    context 'in a numblock' do
      context 'in a void context' do
        it_behaves_like 'corrects', template: 'each { _1; %s }'
      end

      context 'in a non-void context' do
        it_behaves_like 'skip correcting', template: 'block { _1; %s }'
      end
    end

    context 'in a method' do
      context 'not at the end' do
        it_behaves_like 'corrects', template: 'def foo; %s; do_something end'
      end

      context 'at the end' do
        it_behaves_like 'skip correcting', template: 'def foo; %s end'
      end

      context 'in a constructor' do
        it_behaves_like 'corrects', template: 'def initialize; %s; end'
      end

      context 'in an assignment method' do
        it_behaves_like 'corrects', template: 'def foo=(value); %s; end'
      end
    end

    context 'in a for loop' do
      it_behaves_like 'corrects', template: 'for i in foo; %s; end'
    end
  end
end
