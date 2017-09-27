# frozen_string_literal: true

describe RuboCop::Cop::Rails::Present, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |source, correction, message|
    it 'registers an offense' do
      inspect_source(source)

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq([source])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq(correction)
    end
  end

  context 'NotNilAndNotEmpty set to true' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => true,
        'NotBlank' => false,
        'UnlessBlank' => false }
    end

    it 'accepts checking nil?' do
      expect_no_offenses('foo.nil?')
    end

    it 'accepts checking empty?' do
      expect_no_offenses('foo.empty?')
    end

    it 'accepts checking nil? || empty? on different objects' do
      expect_no_offenses('foo.nil? || bar.empty?')
    end

    it 'accepts checking existance && not empty? on different objects' do
      expect_no_offenses('foo && !bar.empty?')
    end

    it_behaves_like :offense, 'foo && !foo.empty?',
                    'foo.present?',
                    'Use `foo.present?` instead of `foo && !foo.empty?`.'
    it_behaves_like :offense, '!foo.nil? && !foo.empty?',
                    'foo.present?',
                    'Use `foo.present?` instead of `!foo.nil? && !foo.empty?`.'
    it_behaves_like :offense, '!nil? && !empty?',
                    'present?',
                    'Use `present?` instead of `!nil? && !empty?`.'
    it_behaves_like :offense, 'foo != nil && !foo.empty?',
                    'foo.present?',
                    'Use `foo.present?` instead of `foo != nil && !foo.empty?`.'
    it_behaves_like :offense, '!!foo && !foo.empty?',
                    'foo.present?',
                    'Use `foo.present?` instead of `!!foo && !foo.empty?`.'

    context 'checking all variable types' do
      it_behaves_like :offense, '!foo.nil? && !foo.empty?',
                      'foo.present?',
                      'Use `foo.present?` instead of ' \
                      '`!foo.nil? && !foo.empty?`.'
      it_behaves_like :offense, '!foo.bar.nil? && !foo.bar.empty?',
                      'foo.bar.present?',
                      'Use `foo.bar.present?` instead of ' \
                      '`!foo.bar.nil? && !foo.bar.empty?`.'
      it_behaves_like :offense, '!FOO.nil? && !FOO.empty?',
                      'FOO.present?',
                      'Use `FOO.present?` instead of ' \
                      '`!FOO.nil? && !FOO.empty?`.'
      it_behaves_like :offense, '!Foo.nil? && !Foo.empty?',
                      'Foo.present?',
                      'Use `Foo.present?` instead of ' \
                      '`!Foo.nil? && !Foo.empty?`.'
      it_behaves_like :offense, '!@foo.nil? && !@foo.empty?',
                      '@foo.present?',
                      'Use `@foo.present?` instead of ' \
                      '`!@foo.nil? && !@foo.empty?`.'
      it_behaves_like :offense, '!$foo.nil? && !$foo.empty?',
                      '$foo.present?',
                      'Use `$foo.present?` instead of ' \
                      '`!$foo.nil? && !$foo.empty?`.'
      it_behaves_like :offense, '!@@foo.nil? && !@@foo.empty?',
                      '@@foo.present?',
                      'Use `@@foo.present?` instead of ' \
                      '`!@@foo.nil? && !@@foo.empty?`.'
      it_behaves_like :offense, '!foo[bar].nil? && !foo[bar].empty?',
                      'foo[bar].present?',
                      'Use `foo[bar].present?` instead of ' \
                      '`!foo[bar].nil? && !foo[bar].empty?`.'
      it_behaves_like :offense, '!Foo::Bar.nil? && !Foo::Bar.empty?',
                      'Foo::Bar.present?',
                      'Use `Foo::Bar.present?` instead of ' \
                      '`!Foo::Bar.nil? && !Foo::Bar.empty?`.'
      it_behaves_like :offense, '!foo(bar).nil? && !foo(bar).empty?',
                      'foo(bar).present?',
                      'Use `foo(bar).present?` instead of ' \
                      '`!foo(bar).nil? && !foo(bar).empty?`.'
    end
  end

  context 'NotBlank set to true' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => false,
        'NotBlank' => true,
        'UnlessBlank' => false }
    end

    it_behaves_like :offense, '!foo.blank?',
                    'foo.present?',
                    'Use `foo.present?` instead of `!foo.blank?`.'

    it_behaves_like :offense, 'not foo.blank?',
                    'foo.present?',
                    'Use `foo.present?` instead of `not foo.blank?`.'
    it_behaves_like :offense, '!blank?',
                    'present?',
                    'Use `present?` instead of `!blank?`.'
  end

  context 'UnlessBlank set to true' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => false,
        'NotBlank' => false,
        'UnlessBlank' => true }
    end

    it 'accepts modifier if blank?' do
      expect_no_offenses('something if foo.blank?')
    end

    it 'accepts modifier unless present?' do
      expect_no_offenses('something unless foo.present?')
    end

    it 'accepts normal if blank?' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if foo.blank?
          something
        end
      RUBY
    end

    it 'accepts normal unless present?' do
      expect_no_offenses(<<-RUBY.strip_indent)
        unless foo.present?
          something
        end
      RUBY
    end

    context 'unless blank?' do
      context 'modifier unless' do
        context 'with a receiver' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              something unless foo.blank?
                        ^^^^^^^^^^^^^^^^^ Use `if foo.present?` instead of `unless foo.blank?`.
            RUBY
          end

          it 'auto-corrects' do
            new_source = autocorrect_source('something unless foo.blank?')

            expect(new_source).to eq('something if foo.present?')
          end
        end

        context 'without a receiver' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              something unless blank?
                        ^^^^^^^^^^^^^ Use `if present?` instead of `unless blank?`.
            RUBY
          end

          it 'auto-corrects' do
            new_source = autocorrect_source('something unless blank?')

            expect(new_source).to eq('something if present?')
          end
        end
      end

      context 'normal unless blank?' do
        let(:source) do
          <<-RUBY.strip_indent
            unless foo.blank?
              something
            end
          RUBY
        end

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            unless foo.blank?
            ^^^^^^^^^^^^^^^^^ Use `if foo.present?` instead of `unless foo.blank?`.
              something
            end
          RUBY
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(source)

          expect(new_source).to eq(<<-RUBY.strip_indent)
            if foo.present?
              something
            end
          RUBY
        end
      end

      context 'unless blank? with an else' do
        let(:source) do
          <<-RUBY.strip_indent
            unless foo.blank?
              something
            else
              something_else
            end
          RUBY
        end

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            unless foo.blank?
            ^^^^^^^^^^^^^^^^^ Use `if foo.present?` instead of `unless foo.blank?`.
              something
            else
              something_else
            end
          RUBY
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(source)

          expect(new_source).to eq(<<-RUBY.strip_indent)
            if foo.present?
              something
            else
              something_else
            end
          RUBY
        end
      end
    end
  end

  context 'NotNilAndNotEmpty set to false' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => false,
        'NotBlank' => true,
        'UnlessBlank' => true }
    end

    it 'accepts checking nil? || empty?' do
      expect_no_offenses('foo.nil? || foo.empty?')
    end
  end

  context 'NotBlank set to false' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => true,
        'NotBlank' => false,
        'UnlessBlank' => true }
    end

    it 'accepts !...blank?' do
      expect_no_offenses('!foo.blank?')
    end
  end

  context 'UnlessBlank set to false' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => true,
        'NotBlank' => true,
        'UnlessBlank' => false }
    end

    it 'accepts unless blank?' do
      expect_no_offenses('something unless foo.blank?')
    end
  end
end
