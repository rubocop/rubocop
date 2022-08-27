# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSort, :config do
  it 'registers an offense when first is called with sort' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort.first
                ^^^^^^^^^^ Use `min` instead of `sort...first`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].min
    RUBY
  end

  it 'registers an offense when last is called with sort' do
    expect_offense(<<~RUBY)
      [1, 2].sort.last
             ^^^^^^^^^ Use `max` instead of `sort...last`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2].max
    RUBY
  end

  it 'registers an offense when last is called on sort with comparator' do
    expect_offense(<<~RUBY)
      foo.sort { |a, b| b <=> a }.last
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max` instead of `sort...last`.
    RUBY

    expect_correction(<<~RUBY)
      foo.max { |a, b| b <=> a }
    RUBY
  end

  it 'registers an offense when first is called on sort_by' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort_by { |x| x.length }.first
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].min_by { |x| x.length }
    RUBY
  end

  it 'registers an offense when last is called on sort_by' do
    expect_offense(<<~RUBY)
      foo.sort_by { |x| x.something }.last
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...last`.
    RUBY

    expect_correction(<<~RUBY)
      foo.max_by { |x| x.something }
    RUBY
  end

  it 'registers an offense when first is called on sort_by with line breaks' do
    expect_offense(<<~RUBY)
      [1, 2, 3]
        .sort_by { |x| x.length }
         ^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
        .first
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3]
        .min_by { |x| x.length }
      #{'  '}
    RUBY
  end

  it 'registers an offense when first is called on sort_by with line breaks and `||` operator' do
    expect_offense(<<~RUBY)
      [1, 2, 3]
        .sort_by { |x| x.length }
         ^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
        .first || []
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3]
        .min_by { |x| x.length } ||
          []
    RUBY
  end

  it 'registers an offense when first is called on sort_by with line breaks and `&&` operator' do
    expect_offense(<<~RUBY)
      [1, 2, 3]
        .sort_by { |x| x.length }
         ^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
        .first && []
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3]
        .min_by { |x| x.length } &&
          []
    RUBY
  end

  it 'registers an offense when first is called on sort_by with line breaks and `or` operator' do
    expect_offense(<<~RUBY)
      [1, 2, 3]
        .sort_by { |x| x.length }
         ^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
        .first or []
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3]
        .min_by { |x| x.length } or
          []
    RUBY
  end

  it 'registers an offense when first is called on sort_by with line breaks and `and` operator' do
    expect_offense(<<~RUBY)
      [1, 2, 3]
        .sort_by { |x| x.length }
         ^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
        .first and []
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3]
        .min_by { |x| x.length } and
          []
    RUBY
  end

  it 'registers an offense when first is called on sort_by no block' do
    expect_offense(<<~RUBY)
      [1, 2].sort_by(&:something).first
             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2].min_by(&:something)
    RUBY
  end

  it 'registers an offense when last is called on sort_by no block' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort_by(&:length).last
                ^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...last`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].max_by(&:length)
    RUBY
  end

  it 'registers an offense when at(-1) is called with sort' do
    expect_offense(<<~RUBY)
      [1, 2].sort.at(-1)
             ^^^^^^^^^^^ Use `max` instead of `sort...at(-1)`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2].max
    RUBY
  end

  it 'registers an offense when slice(0) is called on sort' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort.slice(0)
                ^^^^^^^^^^^^^ Use `min` instead of `sort...slice(0)`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].min
    RUBY
  end

  it 'registers an offense when [0] is called on sort' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort[0]
                ^^^^^^^ Use `min` instead of `sort...[0]`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].min
    RUBY
  end

  it 'registers an offense when [](0) is called on sort' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort.[](0)
                ^^^^^^^^^^ Use `min` instead of `sort...[](0)`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].min
    RUBY
  end

  it 'registers an offense when [](-1) is called on sort_by' do
    expect_offense(<<~RUBY)
      foo.sort_by { |x| x.foo }.[](-1)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...[](-1)`.
    RUBY

    expect_correction(<<~RUBY)
      foo.max_by { |x| x.foo }
    RUBY
  end

  it 'registers an offense when at(0) is called on sort_by' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort_by(&:foo).at(0)
                ^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...at(0)`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].min_by(&:foo)
    RUBY
  end

  it 'registers an offense when slice(0) is called on sort_by' do
    expect_offense(<<~RUBY)
      [1, 2].sort_by(&:foo).slice(0)
             ^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...slice(0)`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2].min_by(&:foo)
    RUBY
  end

  it 'registers an offense when slice(-1) is called on sort_by' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort_by(&:foo).slice(-1)
                ^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...slice(-1)`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].max_by(&:foo)
    RUBY
  end

  it 'registers an offense when [-1] is called on sort' do
    expect_offense(<<~RUBY)
      [1, 2, 3].sort[-1]
                ^^^^^^^^ Use `max` instead of `sort...[-1]`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].max
    RUBY
  end

  it 'registers an offense when [0] is called on sort_by' do
    expect_offense(<<~RUBY)
      [1, 2].sort_by(&:foo)[0]
             ^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...[0]`.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2].min_by(&:foo)
    RUBY
  end

  it 'registers an offense when [-1] is called on sort_by' do
    expect_offense(<<~RUBY)
      foo.sort_by { |x| x.foo }[-1]
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...[-1]`.
    RUBY

    expect_correction(<<~RUBY)
      foo.max_by { |x| x.foo }
    RUBY
  end

  # Arguments get too complicated to handle easily, e.g.
  # '[1, 2, 3].sort.last(2)' is not equivalent to '[1, 2, 3].max(2)',
  # so we don't register an offense.
  it 'does not register an offense when first has an argument' do
    expect_no_offenses('[1, 2, 3].sort.first(1)')
  end

  # Some gems like mongo provides sort method with an argument
  it 'does not register an offense when sort has an argument' do
    expect_no_offenses('mongo_client["users"].find.sort(_id: 1).first')
  end

  it 'does not register an offense for sort!.first' do
    expect_no_offenses('[1, 2, 3].sort!.first')
  end

  it 'does not register an offense for sort_by!(&:something).last' do
    expect_no_offenses('[1, 2, 3].sort_by!(&:something).last')
  end

  it 'does not register an offense when sort_by is used without first' do
    expect_no_offenses('[1, 2, 3].sort_by { |x| -x }')
  end

  it 'does not register an offense when first is used without sort_by' do
    expect_no_offenses('[1, 2, 3].first')
  end

  it 'does not register an offense when first is used before sort' do
    expect_no_offenses('[[1, 2], [3, 4]].first.sort')
  end

  # `[2, 1, 3].sort_by(&:size).first` is not equivalent to `[2, 1, 3].first`, but this
  # cop would "correct" it to `[2, 1, 3].min_by`.
  it 'does not register an offense when sort_by is not given a block' do
    expect_no_offenses('[2, 1, 3].sort_by.first')
  end

  it 'registers an offense with `sort_by { a || b }`' do
    expect_offense(<<~RUBY)
      x.sort_by { |y| y.foo || bar }.last
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...last`.
    RUBY

    expect_correction(<<~RUBY)
      x.max_by { |y| y.foo || bar }
    RUBY
  end

  context 'when not taking first or last element' do
    it 'does not register an offense when [1] is called on sort' do
      expect_no_offenses('[1, 2, 3].sort[1]')
    end

    it 'does not register an offense when at(-2) is called on sort_by' do
      expect_no_offenses('[1, 2, 3].sort_by(&:foo).at(-2)')
    end

    it 'does not register an offense when [-1] is called on sort with an argument' do
      expect_no_offenses('mongo_client["users"].find.sort(_id: 1)[-1]')
    end
  end

  context '>= Ruby 2.7', :ruby27 do
    context 'when using numbered parameter' do
      it 'registers an offense and corrects when last is called on sort with comparator' do
        expect_offense(<<~RUBY)
          foo.sort { _2 <=> _1 }.last
              ^^^^^^^^^^^^^^^^^^^^^^^ Use `max` instead of `sort...last`.
        RUBY

        expect_correction(<<~RUBY)
          foo.max { _2 <=> _1 }
        RUBY
      end

      it 'registers an offense and corrects when first is called on sort_by' do
        expect_offense(<<~RUBY)
          [1, 2, 3].sort_by { _1.length }.first
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].min_by { _1.length }
        RUBY
      end

      it 'registers an offense and corrects when at(0) is called on sort_by' do
        expect_offense(<<~RUBY)
          [1, 2, 3].sort_by { _1.foo }.at(0)
                    ^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...at(0)`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].min_by { _1.foo }
        RUBY
      end
    end
  end
end
