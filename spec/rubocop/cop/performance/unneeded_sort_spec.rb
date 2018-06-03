# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::UnneededSort do
  subject(:cop) { described_class.new }

  it 'registers an offense when first is called with sort' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort.first
                ^^^^^^^^^^ Use `min` instead of `sort...first`.
    RUBY
  end

  it 'registers an offense when last is called on sort with comparator' do
    expect_offense(<<-RUBY.strip_indent)
      foo.sort { |a, b| b <=> a }.last
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max` instead of `sort...last`.
    RUBY
  end

  it 'registers an offense when first is called on sort_by' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort_by { |x| x.length }.first
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
    RUBY
  end

  it 'registers an offense when last is called on sort_by no block' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort_by(&:length).last
                ^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...last`.
    RUBY
  end

  it 'registers an offense when slice(0) is called on sort' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort.slice(0)
                ^^^^^^^^^^^^^ Use `min` instead of `sort...slice(0)`.
    RUBY
  end

  it 'registers an offense when [0] is called on sort' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort[0]
                ^^^^^^^ Use `min` instead of `sort...[0]`.
    RUBY
  end

  it 'registers an offense when [](0) is called on sort' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort.[](0)
                ^^^^^^^^^^ Use `min` instead of `sort...[](0)`.
    RUBY
  end

  it 'registers an offense when at(0) is called on sort_by' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort_by(&:foo).at(0)
                ^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...at(0)`.
    RUBY
  end

  it 'registers an offense when slice(-1) is called on sort_by' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort_by(&:foo).slice(-1)
                ^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...slice(-1)`.
    RUBY
  end

  it 'registers an offense when [-1] is called on sort' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].sort[-1]
                ^^^^^^^^ Use `max` instead of `sort...[-1]`.
    RUBY
  end

  # Arguments get too complicated to handle easily, e.g.
  # '[1, 2, 3].sort.last(2)' is not equivalent to '[1, 2, 3].max(2)',
  # so we don't register an offense.
  it 'does not register an offense when first has an argument' do
    expect_no_offenses('[1, 2, 3].sort.first(1)')
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

  # `[2, 1, 3].sort_by.first` is equivalent to `[2, 1, 3].first`, but this
  # cop would "correct" it to `[2, 1, 3].min_by`.
  it 'does not register an offense when sort_by is not given a block' do
    expect_no_offenses('[2, 1, 3].sort_by.first')
  end

  context 'when not taking first or last element' do
    it 'does not register an offense when [1] is called on sort' do
      expect_no_offenses('[1, 2, 3].sort[1]')
    end

    it 'does not register an offense when at(-2) is called on sort_by' do
      expect_no_offenses('[1, 2, 3].sort_by(&:foo).at(-2)')
    end
  end

  context 'autocorrect' do
    it 'corrects sort.first to min' do
      new_source = autocorrect_source('[1, 2].sort.first')

      expect(new_source).to eq('[1, 2].min')
    end

    it 'corrects sort.last to max' do
      new_source = autocorrect_source('[1, 2].sort.last')

      expect(new_source).to eq('[1, 2].max')
    end

    it 'corrects sort.first (with comparator) to min' do
      new_source = autocorrect_source('[1, 2].sort { |a, b| b <=> a }.first')

      expect(new_source).to eq('[1, 2].min { |a, b| b <=> a }')
    end

    it 'corrects sort.at(-1) to max' do
      new_source = autocorrect_source('[1, 2].sort.at(-1)')

      expect(new_source).to eq('[1, 2].max')
    end

    it 'corrects sort_by(&:foo).slice(0) to min_by(&:foo)' do
      new_source = autocorrect_source('[1, 2].sort_by(&:foo).slice(0)')

      expect(new_source).to eq('[1, 2].min_by(&:foo)')
    end

    it 'corrects sort_by(&:foo)[0] to min_by(&:foo)' do
      new_source = autocorrect_source('[1, 2].sort_by(&:foo)[0]')

      expect(new_source).to eq('[1, 2].min_by(&:foo)')
    end

    it 'corrects sort_by(&:something).first to min_by(&:something)' do
      new_source = autocorrect_source('[1, 2].sort_by(&:something).first')

      expect(new_source).to eq('[1, 2].min_by(&:something)')
    end

    it 'corrects sort_by { |x| x.foo }[-1] to max_by { |x| x.foo }' do
      new_source = autocorrect_source('foo.sort_by { |x| x.foo }[-1]')

      expect(new_source).to eq('foo.max_by { |x| x.foo }')
    end

    it 'corrects sort_by { |x| x.foo }.[](-1) to max_by { |x| x.foo }' do
      new_source = autocorrect_source('foo.sort_by { |x| x.foo }.[](-1)')

      expect(new_source).to eq('foo.max_by { |x| x.foo }')
    end

    it 'corrects sort_by { |x| x.something }.last ' \
       'to max_by { |x| x.something }' do
      new_source = autocorrect_source('foo.sort_by { |x| x.something }.last')

      expect(new_source).to eq('foo.max_by { |x| x.something }')
    end
  end
end
