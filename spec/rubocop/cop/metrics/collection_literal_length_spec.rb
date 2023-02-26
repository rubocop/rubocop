# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::CollectionLiteralLength, :config do
  let(:cop_config) do
    {
      'LengthThreshold' => length_threshold
    }
  end
  let(:length_threshold) { 10 }
  let(:message) do
    'Avoid hard coding large quantities of data in code. ' \
      'Prefer reading the data from an external source.'
  end
  let(:large_array) { (0...length_threshold).to_a }
  let(:large_hash) { (0...length_threshold).to_h { |n| [n, n] } }

  it 'registers an offense when using an `Array` literal with too many entries (on one line)' do
    literal = large_array.to_s
    expect_offense(<<~RUBY)
      #{literal}
      #{'^' * literal.length} #{message}
    RUBY
  end

  it 'registers an offense when using an `Array` literal with too many entries (one per line)' do
    expect_offense(<<~RUBY)
      [
      ^ #{message}
        #{large_array.join(",\n  ")}
      ]
    RUBY
  end

  it 'registers no offense when using an `Array` literal with fewer entries than the threshold (on one line)' do
    literal = large_array.drop(1).to_s
    expect_no_offenses(literal)
  end

  it 'registers no offense when using an `Array` literal with fewer entries than the threshold (one per line)' do
    expect_no_offenses(<<~RUBY)
      [
        #{large_array.drop(1).join(",\n  ")}
      ]
    RUBY
  end

  it 'registers an offense when using an `Hash` literal with too many entries (on one line)' do
    literal = large_hash.to_s
    expect_offense(<<~RUBY)
      #{literal}
      #{'^' * literal.length} #{message}
    RUBY
  end

  it 'registers an offense when using an `Hash` literal with too many entries (one per line)' do
    expect_offense(<<~RUBY)
      {
      ^ #{message}
        #{large_hash.map { |k, v| "#{k} => #{v}" }.join(",\n  ")}
      }
    RUBY
  end

  it 'registers no offense when using an `Hash` literal with fewer entries than the threshold (on one line)' do
    literal = large_hash.drop(1).to_h.to_s
    expect_no_offenses(literal)
  end

  it 'registers no offense when using an `Hash` literal with fewer entries than the threshold (one per line)' do
    expect_no_offenses(<<~RUBY)
      {
        #{large_hash.drop(1).map { |k, v| "#{k} => #{v}" }.join(",\n  ")}
      }
    RUBY
  end

  it 'registers an offense when using an `Set` "literal" with too many entries (on one line)' do
    literal = "Set[#{large_array.join(', ')}]"
    expect_offense(<<~RUBY)
      #{literal}
      #{'^' * literal.length} #{message}
    RUBY
  end

  it 'registers an offense when using an `Set` "literal" with too many entries (one per line)' do
    expect_offense(<<~RUBY)
      Set[
      ^^^^ #{message}
        #{large_array.join(",\n  ")}
      ]
    RUBY
  end

  it 'registers no offense when using an `Set` "literal" with fewer entries than the threshold (on one line)' do
    literal = "Set[#{large_array.drop(1).join(', ')}]"
    expect_no_offenses(literal)
  end

  it 'registers no offense when using an `Set` "literal" with fewer entries than the threshold (one per line)' do
    expect_no_offenses(<<~RUBY)
      Set[
        #{large_array.drop(1).join(",\n  ")}
      ]
    RUBY
  end
end
