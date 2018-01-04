# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Presence do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  shared_examples :offense do |source, correction, first_line, end_line|
    it 'registers an offense' do
      inspect_source(source)

      expect(cop.offenses.count).to eq 1
      expect(cop.offenses).to all(
        have_attributes(
          first_line: first_line,
          last_line: end_line
        )
      )
      expect(cop.offenses).to all(
        have_attributes(
          message: "Use `#{correction}` instead of `#{source}`."
        )
      )
    end

    it 'auto correct' do
      expect(autocorrect_source(source)).to eq(correction)
    end
  end

  it_behaves_like :offense, 'a.present? ? a : nil', 'a.presence', 1, 1
  it_behaves_like :offense, '!a.present? ? nil: a', 'a.presence', 1, 1
  it_behaves_like :offense, 'a.blank? ? nil : a', 'a.presence', 1, 1
  it_behaves_like :offense, '!a.blank? ? a : nil', 'a.presence', 1, 1
  it_behaves_like :offense, 'a.present? ? a : b', 'a.presence || b', 1, 1
  it_behaves_like :offense, '!a.present? ? b : a', 'a.presence || b', 1, 1
  it_behaves_like :offense, 'a.blank? ? b : a', 'a.presence || b', 1, 1
  it_behaves_like :offense, '!a.blank? ? a : b', 'a.presence || b', 1, 1

  it_behaves_like :offense,
                  'a(:bar).map(&:baz).present? ? a(:bar).map(&:baz) : nil',
                  'a(:bar).map(&:baz).presence',
                  1, 1

  it_behaves_like :offense, <<-RUBY.strip_indent.chomp, 'a.presence', 1, 5
    if a.present?
      a
    else
      nil
    end
  RUBY

  it_behaves_like :offense, 'a if a.present?', 'a.presence', 1, 1
  it_behaves_like :offense, 'a unless a.blank?', 'a.presence', 1, 1
  it_behaves_like :offense, <<-RUBY.strip_indent.chomp, <<-FIXED.strip_indent.chomp, 1, 7 # rubocop:disable Metrics/LineLength
    if [1, 2, 3].map { |num| num + 1 }
                .map { |num| num + 2 }
                .present?
      [1, 2, 3].map { |num| num + 1 }.map { |num| num + 2 }
    else
      b
    end
  RUBY
    [1, 2, 3].map { |num| num + 1 }
                .map { |num| num + 2 }.presence || b
  FIXED

  it 'does not register an offense when using `#presence`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a.presence
    RUBY
  end

  it 'does not register an offense when the expression does not ' \
     'return the receiver of `#present?`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a.present? ? b : nil
    RUBY

    expect_no_offenses(<<-RUBY.strip_indent)
      puts foo if present?
      puts foo if !present?
    RUBY
  end

  it 'does not register an offense when the expression does not ' \
     'return the receiver of `#blank?`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a.blank? ? nil : b
    RUBY

    expect_no_offenses(<<-RUBY.strip_indent)
      puts foo if blank?
      puts foo if !blank?
    RUBY
  end

  it 'does not register an offense when if or unless modifier is used ' do
    [
      'a if a.blank?',
      'a unless a.present?'
    ].each { |source| expect_no_offenses(source) }
  end

  it 'does not register an offense when the else block is multiline' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a.present?
        a
      else
        something
        something
        something
      end
    RUBY
  end

  it 'does not register an offense when the else block has multiple ' \
     'statements' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a.present?
        a
      else
        something; something; something
      end
    RUBY
  end

  it 'does not register an offense when including the elsif block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a.present?
        a
      elsif b
        b
      end
    RUBY
  end

  it 'does not register an offense when the else block has `if` node' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a.present?
        a
      else
        b if c
      end
    RUBY
  end

  it 'does not register an offense when the else block has `rescue` node' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if something_method.present?
        something_method
      else
        invalid_method rescue StandardError
      end
    RUBY
  end

  it 'does not register an offense when the else block has `while` node' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a.present?
        a
      else
        fetch_state while waiting?
      end
    RUBY
  end
end
