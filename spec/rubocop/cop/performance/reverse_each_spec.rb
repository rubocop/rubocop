# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::ReverseEach do
  subject(:cop) { described_class.new }

  it 'registers an offense when each is called on reverse' do
    expect_offense(<<-RUBY.strip_indent)
      [1, 2, 3].reverse.each { |e| puts e }
                ^^^^^^^^^^^^ Use `reverse_each` instead of `reverse.each`.
    RUBY
  end

  it 'registers an offense when each is called on reverse on a variable' do
    expect_offense(<<-RUBY.strip_indent)
      arr = [1, 2, 3]
      arr.reverse.each { |e| puts e }
          ^^^^^^^^^^^^ Use `reverse_each` instead of `reverse.each`.
    RUBY
  end

  it 'registers an offense when each is called on reverse on a method call' do
    expect_offense(<<-RUBY.strip_indent)
      def arr
        [1, 2, 3]
      end

      arr.reverse.each { |e| puts e }
          ^^^^^^^^^^^^ Use `reverse_each` instead of `reverse.each`.
    RUBY
  end

  it 'does not register an offense when reverse is used without each' do
    expect_no_offenses('[1, 2, 3].reverse')
  end

  it 'does not register an offense when each is used without reverse' do
    expect_no_offenses('[1, 2, 3].each { |e| puts e }')
  end

  context 'autocorrect' do
    it 'corrects reverse.each to reverse_each' do
      new_source = autocorrect_source('[1, 2].reverse.each { |e| puts e }')

      expect(new_source).to eq('[1, 2].reverse_each { |e| puts e }')
    end

    it 'corrects reverse.each to reverse_each on a variable' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        arr = [1, 2]
        arr.reverse.each { |e| puts e }
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        arr = [1, 2]
        arr.reverse_each { |e| puts e }
      RUBY
    end

    it 'corrects reverse.each to reverse_each on a method call' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def arr
          [1, 2]
        end

        arr.reverse.each { |e| puts e }
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def arr
          [1, 2]
        end

        arr.reverse_each { |e| puts e }
      RUBY
    end
  end
end
