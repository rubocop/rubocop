# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantAllowNil do
  subject(:cop) { described_class.new }

  context 'when not using both `allow_nil` and `allow_blank`' do
    it 'registers no offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        validates :email, presence: true
      RUBY
    end
  end

  context 'when using only `allow_nil`' do
    it 'registers no offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        validates :email, allow_nil: true
      RUBY
    end
  end

  context 'when using only `allow_blank`' do
    it 'registers no offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        validates :email, allow_blank: true
      RUBY
    end
  end

  context 'when both allow_nil and allow_blank are true' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        validates :title, length: { is: 5 }, allow_nil: true, allow_blank: true
                                             ^^^^^^^^^^^^^^^ `allow_nil` is redundant when `allow_blank` has the same value.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        validates :title, length: { is: 5 }, allow_blank: true
      RUBY
    end
  end

  context 'when allow_nil is false and allow_blank is true' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        validates :title, allow_nil: false, allow_blank: true, length: { is: 5 }
                          ^^^^^^^^^^^^^^^^ `allow_nil: false` is redundant when `allow_blank` is true.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        validates :title, allow_blank: true, length: { is: 5 }
      RUBY
    end
  end

  context 'when allow_nil is true and allow_blank is false' do
    it 'registers no offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
          validates :title, length: { is: 5 }, allow_nil: true, allow_blank: false
      RUBY
    end
  end

  context 'when both allow_nil and allow_blank are false' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        validates :title, length: { is: 5 }, allow_blank: false, allow_nil: false
                                                                 ^^^^^^^^^^^^^^^^ `allow_nil` is redundant when `allow_blank` has the same value.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        validates :title, length: { is: 5 }, allow_blank: false
      RUBY
    end
  end
end
