# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordAliases do
  subject(:cop) { described_class.new }

  describe '#update_attributes' do
    it 'registers an offense and corrects' do
      expect_offense(<<-RUBY.strip_indent)
        book.update_attributes(author: "Alice")
             ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        book.update(author: "Alice")
      RUBY
    end

    context 'when using safe navigation operator', :ruby23 do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
        book&.update_attributes(author: "Alice")
              ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
        RUBY
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          'book&.update_attributes(author: "Alice")'
        )
        expect(new_source).to eq 'book&.update(author: "Alice")'
      end
    end
  end

  describe '#update_attributes!' do
    it 'registers an offense and corrects' do
      expect_offense(<<-RUBY.strip_indent)
        book.update_attributes!(author: "Bob")
             ^^^^^^^^^^^^^^^^^^ Use `update!` instead of `update_attributes!`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        book.update!(author: "Bob")
      RUBY
    end
  end

  describe '#update' do
    it 'does not register an offense' do
      expect_no_offenses('book.update(author: "Alice")')
    end
  end

  describe '#update!' do
    it 'does not register an offense' do
      expect_no_offenses('book.update!(author: "Bob")')
    end
  end

  describe 'other use of the `update_attributes` string' do
    it 'does not autocorrect the other usage' do
      expect_offense(<<-RUBY.strip_indent)
        update_attributes_book.update_attributes(author: "Alice")
                               ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        update_attributes_book.update(author: "Alice")
      RUBY
    end
  end
end
