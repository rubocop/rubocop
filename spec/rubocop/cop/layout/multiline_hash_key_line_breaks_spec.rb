# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineHashKeyLineBreaks do
  subject(:cop) { described_class.new }

  context 'when on same line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        {foo: 1, bar: "2"}
      RUBY
    end
  end

  context 'when on different lines than brackets but keys on one' do
    it 'does not add any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        {
          foo: 1, bar: "2"
        }
      RUBY
    end
  end

  context 'when on all keys on one line different than brackets' do
    it 'does not add any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        {
          foo => 1, bar => "2"
        }
      RUBY
    end
  end

  context 'when key starts on same line as another' do
    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        {
          foo: 1,
          baz: 3, bar: "2"}
                  ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        {
          foo: 1,
          baz: 3, bar: "2"}
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        {
          foo: 1,
          baz: 3,\s
        bar: "2"}
      RUBY
    end
  end

  context 'when key starts on same line as another with rockets' do
    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        {
          foo => 1,
          baz => 3, bar: "2"}
                    ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        {
          foo => 1,
          baz => 3, bar => "2"}
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        {
          foo => 1,
          baz => 3,\s
        bar => "2"}
      RUBY
    end
  end

  context 'when key starts on same line as another' do
    it 'adds an offense' do
      expect_offense(
        <<-RUBY
          {foo: 1,
            baz: 3, bar: "2"}
                    ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
        RUBY
      )
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        {foo: 1,
          baz: 3, bar: "2"}
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        {foo: 1,
          baz: 3,\s
        bar: "2"}
      RUBY
    end
  end

  context 'when nested hashes' do
    it 'adds an offense' do
      expect_offense(
        <<-RUBY
          {foo: 1,
            baz: {
              as: 12,
            }, bar: "2"}
               ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
        RUBY
      )
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        {foo: 1,
          baz: {
            as: 12,
          }, bar: "2"}
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        {foo: 1,
          baz: {
            as: 12,
          },\s
        bar: "2"}
      RUBY
    end
  end
end
