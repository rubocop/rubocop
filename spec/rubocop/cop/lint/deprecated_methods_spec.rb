# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedMethods, :config do
  context 'with the default (empty) configuration' do
    it 'does not register an offense for any method call' do
      expect_no_offenses(<<~RUBY)
        Book.find(1)
        book.serialize
        legacy_export
      RUBY
    end
  end

  context 'when `Rules` is nil' do
    let(:cop_config) { { 'Rules' => nil } }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        book.serialize
      RUBY
    end
  end

  context 'with a `Method` rule' do
    let(:cop_config) do
      { 'Rules' => [{ 'Method' => 'serialize', 'Replacement' => 'serialize_with_codec' }] }
    end

    it 'registers an offense and corrects when calling the method without a receiver' do
      expect_offense(<<~RUBY)
        serialize
        ^^^^^^^^^ Use `serialize_with_codec` instead of `serialize`.
      RUBY

      expect_correction(<<~RUBY)
        serialize_with_codec
      RUBY
    end

    it 'registers an offense and corrects keeping receiver, arguments and block in place' do
      expect_offense(<<~RUBY)
        book.serialize(:json) { |codec| codec }
             ^^^^^^^^^ Use `serialize_with_codec` instead of `serialize`.
      RUBY

      expect_correction(<<~RUBY)
        book.serialize_with_codec(:json) { |codec| codec }
      RUBY
    end

    it 'registers an offense and corrects when calling the method with safe navigation' do
      expect_offense(<<~RUBY)
        book&.serialize
              ^^^^^^^^^ Use `serialize_with_codec` instead of `serialize`.
      RUBY

      expect_correction(<<~RUBY)
        book&.serialize_with_codec
      RUBY
    end

    it 'does not register an offense when calling another method' do
      expect_no_offenses(<<~RUBY)
        book.deserialize
      RUBY
    end
  end

  context 'with a `Method` rule without `Replacement` and `Message`' do
    let(:cop_config) { { 'Rules' => [{ 'Method' => 'legacy_export' }] } }

    it 'registers an offense with the default message without correcting' do
      expect_offense(<<~RUBY)
        legacy_export(:csv)
        ^^^^^^^^^^^^^ `legacy_export` is deprecated.
      RUBY

      expect_no_corrections
    end
  end

  context 'with a `Method` rule with a `Message`' do
    let(:cop_config) do
      { 'Rules' => [{ 'Method' => 'legacy_export', 'Message' => 'Exports are deprecated.' }] }
    end

    it 'registers an offense with the configured message' do
      expect_offense(<<~RUBY)
        legacy_export(:csv)
        ^^^^^^^^^^^^^ Exports are deprecated.
      RUBY
    end
  end

  context 'with a `Method` rule with a `Receiver`' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Method' => 'find', 'Receiver' => 'Book', 'Replacement' => 'BookRepository.fetch' }
        ]
      }
    end

    it 'registers an offense and corrects when calling the method on the constant' do
      expect_offense(<<~RUBY)
        Book.find(1)
        ^^^^^^^^^ Use `BookRepository.fetch` instead of `Book.find`.
      RUBY

      expect_correction(<<~RUBY)
        BookRepository.fetch(1)
      RUBY
    end

    it 'registers an offense and corrects when the constant has a leading `::`' do
      expect_offense(<<~RUBY)
        ::Book.find(1)
        ^^^^^^^^^^^ Use `BookRepository.fetch` instead of `::Book.find`.
      RUBY

      expect_correction(<<~RUBY)
        BookRepository.fetch(1)
      RUBY
    end

    it 'does not register an offense when calling the method on another constant' do
      expect_no_offenses(<<~RUBY)
        Magazine.find(1)
        Library::Book.find(1)
      RUBY
    end

    it 'does not register an offense when calling the method on a non-constant receiver' do
      expect_no_offenses(<<~RUBY)
        book.find(1)
      RUBY
    end

    it 'does not register an offense when calling the method without a receiver' do
      expect_no_offenses(<<~RUBY)
        find(1)
      RUBY
    end
  end

  context 'with a `Method` rule with a namespaced `Receiver`' do
    let(:cop_config) do
      { 'Rules' => [{ 'Method' => 'find', 'Receiver' => 'Library::Book' }] }
    end

    it 'registers an offense when calling the method on the namespaced constant' do
      expect_offense(<<~RUBY)
        Library::Book.find(1)
        ^^^^^^^^^^^^^^^^^^ `Library::Book.find` is deprecated.
      RUBY
    end

    it 'does not register an offense when calling the method on the unqualified constant' do
      expect_no_offenses(<<~RUBY)
        Book.find(1)
      RUBY
    end
  end

  context 'with a `Method` rule with a `Receiver` with a leading `::`' do
    let(:cop_config) do
      { 'Rules' => [{ 'Method' => 'find', 'Receiver' => '::Book' }] }
    end

    it 'registers an offense when calling the method on the constant' do
      expect_offense(<<~RUBY)
        Book.find(1)
        ^^^^^^^^^ `Book.find` is deprecated.
      RUBY
    end
  end

  context 'with a `Method` rule for an operator method' do
    let(:cop_config) do
      { 'Rules' => [{ 'Method' => '+', 'Replacement' => 'plus' }] }
    end

    it 'registers an offense without correcting' do
      expect_offense(<<~RUBY)
        1 + 2
          ^ Use `plus` instead of `+`.
      RUBY

      expect_no_corrections
    end
  end

  context 'with a `Method` rule for an assignment method' do
    let(:cop_config) do
      { 'Rules' => [{ 'Method' => 'name=', 'Replacement' => 'title=' }] }
    end

    it 'registers an offense without correcting' do
      expect_offense(<<~RUBY)
        book.name = 'Ruby'
             ^^^^ Use `title=` instead of `name`.
      RUBY

      expect_no_corrections
    end
  end

  context 'with a `Pattern` rule without `Replacement` and `Message`' do
    let(:cop_config) { { 'Rules' => [{ 'Pattern' => '(send nil? :legacy_export ...)' }] } }

    it 'registers an offense with the default message' do
      expect_offense(<<~RUBY)
        legacy_export(:csv)
        ^^^^^^^^^^^^^^^^^^^ `legacy_export(:csv)` is deprecated.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense when calling the method on a receiver' do
      expect_no_offenses(<<~RUBY)
        exporter.legacy_export(:csv)
      RUBY
    end
  end

  context 'with a `Pattern` rule with a `Replacement` using a capture' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Pattern' => '(call (const {cbase nil?} :Book) :find $_)',
            'Replacement' => 'BookRepository.find($1)' }
        ]
      }
    end

    it 'registers an offense with a message built from the replacement and corrects' do
      expect_offense(<<~RUBY)
        Book.find(1)
        ^^^^^^^^^^^^ Use `BookRepository.find(1)` instead of `Book.find(1)`.
      RUBY

      expect_correction(<<~RUBY)
        BookRepository.find(1)
      RUBY
    end

    it 'registers an offense and corrects when the constant has a leading `::`' do
      expect_offense(<<~RUBY)
        ::Book.find(1)
        ^^^^^^^^^^^^^^ Use `BookRepository.find(1)` instead of `::Book.find(1)`.
      RUBY

      expect_correction(<<~RUBY)
        BookRepository.find(1)
      RUBY
    end

    it 'does not register an offense when calling the method on another constant' do
      expect_no_offenses(<<~RUBY)
        Magazine.find(1)
        Library::Book.find(1)
      RUBY
    end

    it 'does not register an offense when calling the method with a different arity' do
      expect_no_offenses(<<~RUBY)
        Book.find(1, 2)
      RUBY
    end
  end

  context 'with a `Pattern` rule matching a specific keyword argument' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Pattern' => '(call (const {cbase nil?} :Book) :find_by (hash (pair (sym :id) $_)))',
            'Replacement' => 'BookRepository.find_by_custom_id!($1)' }
        ]
      }
    end

    it 'registers an offense and corrects when calling the method with the keyword argument' do
      expect_offense(<<~RUBY)
        Book.find_by(id: 42)
        ^^^^^^^^^^^^^^^^^^^^ Use `BookRepository.find_by_custom_id!(42)` instead of `Book.find_by(id: 42)`.
      RUBY

      expect_correction(<<~RUBY)
        BookRepository.find_by_custom_id!(42)
      RUBY
    end

    it 'does not register an offense when calling the method with another keyword argument' do
      expect_no_offenses(<<~RUBY)
        Book.find_by(title: 'Ruby')
      RUBY
    end
  end

  context 'with a `Pattern` rule using multiple captures' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Pattern' => '(call $_ :merge_into $_)',
            'Replacement' => '$2.merge($1)',
            'Message' => 'Use `merge` instead of `merge_into`.' }
        ]
      }
    end

    it 'registers an offense and corrects using both captures' do
      expect_offense(<<~RUBY)
        defaults.merge_into(options)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `merge` instead of `merge_into`.
      RUBY

      expect_correction(<<~RUBY)
        options.merge(defaults)
      RUBY
    end
  end

  context 'with a `Pattern` rule using a `$...` capture' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Pattern' => '(send nil? :legacy_export $...)',
            'Replacement' => 'export($1)' }
        ]
      }
    end

    it 'expands the capture to a comma-separated argument list' do
      expect_offense(<<~RUBY)
        legacy_export(:csv, headers: true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `export(:csv, headers: true)` instead of `legacy_export(:csv, headers: true)`.
      RUBY

      expect_correction(<<~RUBY)
        export(:csv, headers: true)
      RUBY
    end

    it 'expands the capture to an empty string when there are no arguments' do
      expect_offense(<<~RUBY)
        legacy_export
        ^^^^^^^^^^^^^ Use `export()` instead of `legacy_export`.
      RUBY

      expect_correction(<<~RUBY)
        export()
      RUBY
    end
  end

  context 'with a `Pattern` rule capturing a non-node value' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Pattern' => '(send nil? ${:old_save :old_save!} ...)',
            'Message' => '`$1` is deprecated.' }
        ]
      }
    end

    it 'expands the capture in the message' do
      expect_offense(<<~RUBY)
        old_save!(record)
        ^^^^^^^^^^^^^^^^^ `old_save!` is deprecated.
      RUBY
    end
  end

  context 'with multiple rules matching the same call' do
    let(:cop_config) do
      {
        'Rules' => [
          { 'Method' => 'find', 'Receiver' => 'Book', 'Replacement' => 'BookRepository.fetch' },
          { 'Method' => 'find', 'Message' => '`find` is deprecated.' }
        ]
      }
    end

    it 'applies only the first matching rule' do
      expect_offense(<<~RUBY)
        Book.find(1)
        ^^^^^^^^^ Use `BookRepository.fetch` instead of `Book.find`.
      RUBY

      expect_correction(<<~RUBY)
        BookRepository.fetch(1)
      RUBY
    end

    it 'falls through to later rules for calls not matching earlier rules' do
      expect_offense(<<~RUBY)
        book.find(1)
             ^^^^ `find` is deprecated.
      RUBY
    end
  end

  context 'with an invalid configuration' do
    shared_examples 'invalid configuration' do |error_message|
      it "raises a validation error matching #{error_message.inspect}" do
        expect { cop }.to raise_error(RuboCop::ValidationError, error_message)
      end
    end

    context 'when a rule is not a hash' do
      let(:cop_config) { { 'Rules' => ['serialize'] } }

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 must be a mapping with a `Method` or ' \
                      '`Pattern` key, found `"serialize"`.'
    end

    context 'when a rule has neither `Method` nor `Pattern`' do
      let(:cop_config) { { 'Rules' => [{ 'Message' => 'Do not.' }] } }

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 is missing a `Method` or `Pattern` key.'
    end

    context 'when a rule has both `Method` and `Pattern`' do
      let(:cop_config) do
        { 'Rules' => [{ 'Method' => 'find', 'Pattern' => '(send nil? :find)' }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 contains both `Method` and `Pattern` ' \
                      'keys, use either one or the other.'
    end

    context 'when a rule has both `Receiver` and `Pattern`' do
      let(:cop_config) do
        { 'Rules' => [{ 'Pattern' => '(send nil? :find)', 'Receiver' => 'Book' }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 contains a `Receiver` key, which can ' \
                      'only be used together with `Method`.'
    end

    context 'when a rule has an unknown key' do
      let(:cop_config) do
        { 'Rules' => [{ 'Method' => 'serialize', 'Replacment' => 'bar' }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 contains unknown key `Replacment`, ' \
                      'valid keys are `Method`, `Receiver`, `Pattern`, `Replacement`, `Message`.'
    end

    context 'when `Method` is not a string' do
      let(:cop_config) { { 'Rules' => [{ 'Method' => 42 }] } }

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 `Method` must be a string.'
    end

    context 'when `Receiver` is not a string' do
      let(:cop_config) { { 'Rules' => [{ 'Method' => 'find', 'Receiver' => 42 }] } }

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 `Receiver` must be a string.'
    end

    context 'when a `Method` rule references a capture' do
      let(:cop_config) do
        { 'Rules' => [{ 'Method' => 'find', 'Replacement' => 'fetch($1)' }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 `Replacement` references capture `$1`, ' \
                      'but captures can only be used together with `Pattern`.'
    end

    context 'when a rule has an invalid pattern' do
      let(:cop_config) { { 'Rules' => [{ 'Pattern' => '(send nil? :foo' }] } }

      it_behaves_like 'invalid configuration',
                      %r{\ALint/DeprecatedMethods: rule 1 contains an invalid `Pattern`:}
    end

    context 'when a pattern uses a custom `#method` call' do
      let(:cop_config) { { 'Rules' => [{ 'Pattern' => '(send #global_const?(:Book) :find)' }] } }

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 uses a custom `#method` call in ' \
                      '`Pattern`, which is not supported.'
    end

    context 'when a pattern uses a `%` parameter' do
      let(:cop_config) { { 'Rules' => [{ 'Pattern' => '(send nil? %1)' }] } }

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 uses a `%` parameter in `Pattern`, ' \
                      'which is not supported.'
    end

    context 'when `Replacement` references a capture the pattern does not have' do
      let(:cop_config) do
        { 'Rules' => [{ 'Pattern' => '(send nil? :foo $_)', 'Replacement' => 'bar($2)' }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 `Replacement` references capture `$2`, ' \
                      'but `Pattern` contains 1 capture.'
    end

    context 'when `Message` references capture `$0`' do
      let(:cop_config) do
        { 'Rules' => [{ 'Pattern' => '(send nil? :foo)', 'Message' => 'Do not use `$0`.' }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 `Message` references capture `$0`, ' \
                      'but `Pattern` contains 0 captures.'
    end

    context 'when `Replacement` is not a string' do
      let(:cop_config) do
        { 'Rules' => [{ 'Method' => 'foo', 'Replacement' => 42 }] }
      end

      it_behaves_like 'invalid configuration',
                      'Lint/DeprecatedMethods: rule 1 `Replacement` must be a string.'
    end
  end
end
