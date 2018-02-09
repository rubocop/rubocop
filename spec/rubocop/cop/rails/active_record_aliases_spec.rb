# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordAliases do
  subject(:cop) { described_class.new }

  describe '#update_attributes' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        book.update_attributes(author: "Alice")
             ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
      RUBY
    end

    it 'is autocorrected' do
      new_source = autocorrect_source(
        'book.update_attributes(author: "Alice")'
      )
      expect(new_source).to eq 'book.update(author: "Alice")'
    end
  end

  describe '#update_attributes!' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        book.update_attributes!(author: "Bob")
             ^^^^^^^^^^^^^^^^^^ Use `update!` instead of `update_attributes!`.
      RUBY
    end

    it 'is autocorrected' do
      new_source = autocorrect_source(
        'book.update_attributes!(author: "Bob")'
      )
      expect(new_source).to eq 'book.update!(author: "Bob")'
    end
  end

  describe '#update' do
    it 'does not register an offense' do
      expect_no_offenses('book.update(author: "Alice")')
    end

    it 'is not autocorrected' do
      source = 'book.update(author: "Alice")'
      new_source = autocorrect_source(source)
      expect(new_source).to eq source
    end
  end

  describe '#update!' do
    it 'does not register an offense' do
      expect_no_offenses('book.update!(author: "Bob")')
    end

    it 'is not autocorrected' do
      source = 'book.update!(author: "Bob")'
      new_source = autocorrect_source(source)
      expect(new_source).to eq source
    end
  end

  describe 'other use of the `update_attributes` string' do
    it 'does not autocorrect the other usage' do
      new_source = autocorrect_source(
        'update_attributes_book.update_attributes(author: "Alice")'
      )
      expect(new_source).to eq 'update_attributes_book.update(author: "Alice")'
    end
  end
end
