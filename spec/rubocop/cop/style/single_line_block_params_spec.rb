# frozen_string_literal: true

describe RuboCop::Cop::Style::SingleLineBlockParams, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'Methods' =>
      [{ 'reduce' => %w[a e] },
       { 'test' => %w[x y] }] }
  end

  it 'finds wrong argument names in calls with different syntax' do
    inspect_source(cop, <<-END.strip_indent)
      def m
        [0, 1].reduce { |c, d| c + d }
        [0, 1].reduce{ |c, d| c + d }
        [0, 1].reduce(5) { |c, d| c + d }
        [0, 1].reduce(5){ |c, d| c + d }
        [0, 1].reduce (5) { |c, d| c + d }
        [0, 1].reduce(5) { |c, d| c + d }
        ala.test { |x, z| bala }
      end
    END
    expect(cop.offenses.size).to eq(7)
    expect(cop.offenses.map(&:line).sort).to eq((2..8).to_a)
    expect(cop.messages.first)
      .to eq('Name `reduce` block params `|a, e|`.')
  end

  it 'allows calls with proper argument names' do
    expect_no_offenses(<<-END.strip_indent)
      def m
        [0, 1].reduce { |a, e| a + e }
        [0, 1].reduce{ |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        [0, 1].reduce(5){ |a, e| a + e }
        [0, 1].reduce (5) { |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        ala.test { |x, y| bala }
      end
    END
  end

  it 'allows an unused parameter to have a leading underscore' do
    expect_no_offenses('File.foreach(filename).reduce(0) { |a, _e| a + 1 }')
  end

  it 'finds incorrectly named parameters with leading underscores' do
    expect_offense(<<-RUBY.strip_indent)
      File.foreach(filename).reduce(0) { |_x, _y| }
                                         ^^^^^^^^ Name `reduce` block params `|a, e|`.
    RUBY
  end

  it 'ignores do..end blocks' do
    expect_no_offenses(<<-END.strip_indent)
      def m
        [0, 1].reduce do |c, d|
          c + d
        end
      end
    END
  end

  it 'ignores :reduce symbols' do
    expect_no_offenses(<<-END.strip_indent)
      def m
        call_method(:reduce) { |a, b| a + b}
      end
    END
  end

  it 'does not report when destructuring is used' do
    expect_no_offenses(<<-END.strip_indent)
      def m
        test.reduce { |a, (id, _)| a + id}
      end
    END
  end

  it 'does not report if no block arguments are present' do
    expect_no_offenses(<<-END.strip_indent)
      def m
        test.reduce { true }
      end
    END
  end
end
