# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FetchEnvVar, :config do
  let(:cop_config) { { 'ExceptedEnvVars' => [] } }

  context 'when it is evaluated with no default values' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ENV['X']
        ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY

      expect_correction(<<~RUBY)
        ENV.fetch('X', nil)
      RUBY

      expect_offense(<<~RUBY)
        ENV['X' + 'Y']
        ^^^^^^^^^^^^^^ Use `ENV.fetch('X' + 'Y')` or `ENV.fetch('X' + 'Y', nil)` instead of `ENV['X' + 'Y']`.
      RUBY

      expect_correction(<<~RUBY)
        ENV.fetch('X' + 'Y', nil)
      RUBY
    end
  end

  context 'with negation' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        !ENV['X']
      RUBY
    end
  end

  context 'when it receives a message' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        ENV['X'].some_method
      RUBY
    end
  end

  context 'when it receives a message with safe navigation' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        ENV['X']&.some_method
      RUBY
    end
  end

  context 'when it is compared `==` with other object' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        ENV['X'] == 1
      RUBY
    end
  end

  context 'when it is compared `!=` with other object' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        ENV['X'] != 1
      RUBY
    end
  end

  context 'when the node is a receiver of `||=`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        ENV['X'] ||= y
        x ||= ENV['X'] ||= y
      RUBY
    end
  end

  context 'when the node is a receiver of `&&=`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        ENV['X'] &&= y
        x &&= ENV['X'] ||= y
      RUBY
    end
  end

  context 'when the node is a assigned by `||=`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        y ||= ENV['X']
              ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY
    end
  end

  context 'when the node is a assigned by `&&=`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        y &&= ENV['X']
              ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY
    end
  end

  context 'when it is an argument of a method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        some_method(ENV['X'])
                    ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY

      expect_correction(<<~RUBY)
        some_method(ENV.fetch('X', nil))
      RUBY

      expect_offense(<<~RUBY)
        x.some_method(ENV['X'])
                      ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY

      expect_correction(<<~RUBY)
        x.some_method(ENV.fetch('X', nil))
      RUBY

      expect_offense(<<~RUBY)
        some_method(
          ENV['A'].some_method,
          ENV['B'] || ENV['C'],
                      ^^^^^^^^ Use `ENV.fetch('C')` or `ENV.fetch('C', nil)` instead of `ENV['C']`.
          ENV['X'],
          ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
          ENV['Y']
          ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
        )
      RUBY

      expect_correction(<<~RUBY)
        some_method(
          ENV['A'].some_method,
          ENV['B'] || ENV.fetch('C', nil),
          ENV.fetch('X', nil),
          ENV.fetch('Y', nil)
        )
      RUBY
    end
  end

  context 'when it is assigned to a variable' do
    it 'registers an offense when using single assignment' do
      expect_offense(<<~RUBY)
        x = ENV['X']
            ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY

      expect_correction(<<~RUBY)
        x = ENV.fetch('X', nil)
      RUBY
    end

    it 'registers an offense when using multiple assignment' do
      expect_offense(<<~RUBY)
        x, y = ENV['X'],
               ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
               ENV['Y']
               ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
      RUBY

      expect_correction(<<~RUBY)
        x, y = ENV.fetch('X', nil),
               ENV.fetch('Y', nil)
      RUBY
    end
  end

  context 'when it is an array element' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        [
          ENV['X'],
          ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
          ENV['Y']
          ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
        ]
      RUBY

      expect_correction(<<~RUBY)
        [
          ENV.fetch('X', nil),
          ENV.fetch('Y', nil)
        ]
      RUBY
    end
  end

  context 'when it is a hash key' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        {
          ENV['X'] => :x,
          ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
          ENV['Y'] => :y
          ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          ENV.fetch('X', nil) => :x,
          ENV.fetch('Y', nil) => :y
        }
      RUBY
    end
  end

  context 'when it is a hash value' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        {
          x: ENV['X'],
             ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
          y: ENV['Y']
             ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          x: ENV.fetch('X', nil),
          y: ENV.fetch('Y', nil)
        }
      RUBY
    end
  end

  context 'when it is used in an interpolation' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        "\#{ENV['X']}"
           ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY

      expect_correction(<<~RUBY)
        "\#{ENV.fetch('X', nil)}"
      RUBY
    end
  end

  context 'when using `fetch` instead of `[]`' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        ENV.fetch('X')
      RUBY

      expect_no_offenses(<<~RUBY)
        ENV.fetch('X', default_value)
      RUBY
    end
  end

  context 'when it is used in a conditional expression' do
    it 'registers no offenses with `if`' do
      expect_no_offenses(<<~RUBY)
        if ENV['X']
          puts x
        end
      RUBY
    end

    it 'registers no offenses with `unless`' do
      expect_no_offenses(<<~RUBY)
        unless ENV['X']
          puts x
        end
      RUBY
    end

    it 'registers no offenses with ternary operator' do
      expect_no_offenses(<<~RUBY)
        ENV['X'] ? x : y
      RUBY
    end

    it 'registers an offense with `case`' do
      expect_offense(<<~RUBY)
        case ENV['X']
             ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
        when ENV['Y']
             ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
          puts x
        end
      RUBY

      expect_correction(<<~RUBY)
        case ENV.fetch('X', nil)
        when ENV.fetch('Y', nil)
          puts x
        end
      RUBY
    end

    it 'registers no offenses when using the same `ENV` var as `if` condition in the body' do
      expect_no_offenses(<<~RUBY)
        if ENV['X']
          puts ENV['X']
        end
      RUBY
    end

    it 'registers no offenses when using the same `ENV` var as `if` condition in the body with other conditions' do
      expect_no_offenses(<<~RUBY)
        if foo? || ENV["X"]
          puts ENV.fetch("X")
        end
        if ENV["Y"] || bar?
          puts ENV.fetch("Y")
        end
        if foo? && ENV["X"]
          puts ENV.fetch("X")
        end
        if ENV["Y"] && bar?
          puts ENV.fetch("Y")
        end
      RUBY
    end

    it 'registers no offenses when using the same `ENV` var as `if` condition in the body with operator' do
      expect_no_offenses(<<~RUBY)
        if ENV['X'] == foo
          puts ENV['X']
        end
        if ENV['X'] != foo
          puts ENV['X']
        end
      RUBY
    end

    it 'registers no offenses when using the same `ENV` var as `if` condition in the body with predicate method' do
      expect_no_offenses(<<~RUBY)
        if ENV["X"].present?
          puts ENV["X"]
        end
        if ENV["X"].in?(%w[A B C])
          puts ENV["X"]
        end
        if %w[A B C].include?(ENV["X"])
          puts ENV["X"]
        end
        if ENV.key?("X")
          puts ENV["X"]
        end
      RUBY
    end

    it 'registers an offense when using an `ENV` var that is different from `if` condition in the body' do
      expect_offense(<<~RUBY)
        if ENV['X']
          puts ENV['Y']
               ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
        end
      RUBY

      expect_correction(<<~RUBY)
        if ENV['X']
          puts ENV.fetch('Y', nil)
        end
      RUBY
    end

    it 'registers no offenses when using the same `ENV` var as `if` condition in the body with assignment method' do
      expect_no_offenses(<<~RUBY)
        if ENV['X'] = x
          puts ENV['X']
        end
      RUBY
    end

    it 'registers an offense with using an `ENV` var as `if` condition in the body with assignment method' do
      expect_offense(<<~RUBY)
        if ENV['X'] = x
          puts ENV['Y']
               ^^^^^^^^ Use `ENV.fetch('Y')` or `ENV.fetch('Y', nil)` instead of `ENV['Y']`.
        end
      RUBY

      expect_correction(<<~RUBY)
        if ENV['X'] = x
          puts ENV.fetch('Y', nil)
        end
      RUBY
    end
  end

  it 'registers an offense when using `ENV && x` that is different from `if` condition in the body' do
    expect_offense(<<~RUBY)
      if ENV && x
        ENV[x]
        ^^^^^^ Use `ENV.fetch(x)` or `ENV.fetch(x, nil)` instead of `ENV[x]`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if ENV && x
        ENV.fetch(x, nil)
      end
    RUBY
  end

  it 'registers an offense when using `ENV || x` that is different from `if` condition in the body' do
    expect_offense(<<~RUBY)
      if ENV || x
        ENV[x]
        ^^^^^^ Use `ENV.fetch(x)` or `ENV.fetch(x, nil)` instead of `ENV[x]`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if ENV || x
        ENV.fetch(x, nil)
      end
    RUBY
  end

  it 'registers an offense when using an `ENV` at `if` condition in the body' do
    expect_offense(<<~RUBY)
      if a == b
        ENV['X']
        ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if a == b
        ENV.fetch('X', nil)
      end
    RUBY
  end

  it 'registers an offense with using an `ENV` at multiple `if` condition in the body' do
    expect_offense(<<~RUBY)
      if a || b && c
        puts ENV['X']
             ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if a || b && c
        puts ENV.fetch('X', nil)
      end
    RUBY
  end

  context 'when the env val is excluded from the inspection by the config' do
    let(:cop_config) { { 'AllowedVars' => ['X'] } }

    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        ENV['X']
      RUBY
    end
  end

  context 'when `ENV[]` is the right end of `||` chains' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        y || ENV['X']
             ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.

        y || z || ENV['X']
                  ^^^^^^^^ Use `ENV.fetch('X')` or `ENV.fetch('X', nil)` instead of `ENV['X']`.
      RUBY

      expect_correction(<<~RUBY)
        y || ENV.fetch('X', nil)

        y || z || ENV.fetch('X', nil)
      RUBY
    end
  end

  context 'when `ENV[]` is the LHS of `||`' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        ENV['X'] || y

        z || ENV['X'] || y
      RUBY
    end
  end
end
