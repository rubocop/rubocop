# frozen_string_literal: true

describe RuboCop::Cop::Rails::Present, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |source, correction, message|
    it 'registers an offense' do
      inspect_source(cop, source)

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq([source])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, source)

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
      inspect_source(cop, 'foo.nil?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts checking empty?' do
      inspect_source(cop, 'foo.empty?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts checking nil? || empty? on different objects' do
      inspect_source(cop, 'foo.nil? || bar.empty?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts checking existance && not empty? on different objects' do
      inspect_source(cop, 'foo && !bar.empty?')

      expect(cop.offenses).to be_empty
    end

    it_behaves_like :offense, 'foo && !foo.empty?',
                    'foo.present?',
                    'Use `foo.present?` instead of `foo && !foo.empty?`.'
    it_behaves_like :offense, '!foo.nil? && !foo.empty?',
                    'foo.present?',
                    'Use `foo.present?` instead of `!foo.nil? && !foo.empty?`.'
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
      inspect_source(cop, 'something if foo.blank?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts modifier unless present?' do
      inspect_source(cop, 'something unless foo.present?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts normal if blank?' do
      inspect_source(cop, ['if foo.blank?',
                           '  something',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts normal unless present?' do
      inspect_source(cop, ['unless foo.present?',
                           '  something',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    context 'unless blank?' do
      context 'modifier unless' do
        let(:source) { 'something unless foo.blank?' }

        it 'registers an offense' do
          inspect_source(cop, source)

          expect(cop.messages)
            .to eq(['Use `if foo.present?` instead of `unless foo.blank?`.'])
          expect(cop.highlights).to eq(['unless foo.blank?'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq('something if foo.present?')
        end
      end

      context 'normal unless blank?' do
        let(:source) do
          ['unless foo.blank?',
           '  something',
           'end']
        end

        it 'registers an offense' do
          inspect_source(cop, source)

          expect(cop.messages)
            .to eq(['Use `if foo.present?` instead of `unless foo.blank?`.'])
          expect(cop.highlights).to eq(['unless foo.blank?'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(['if foo.present?',
                                    '  something',
                                    'end'].join("\n"))
        end
      end

      context 'unless blank? with an else' do
        let(:source) do
          ['unless foo.blank?',
           '  something',
           'else',
           '  something_else',
           'end']
        end

        it 'registers an offense' do
          inspect_source(cop, source)

          expect(cop.messages)
            .to eq(['Use `if foo.present?` instead of `unless foo.blank?`.'])
          expect(cop.highlights).to eq(['unless foo.blank?'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(['if foo.present?',
                                    '  something',
                                    'else',
                                    '  something_else',
                                    'end'].join("\n"))
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
      inspect_source(cop, 'foo.nil? || foo.empty?')

      expect(cop.offenses).to be_empty
    end
  end

  context 'NotBlank set to false' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => true,
        'NotBlank' => false,
        'UnlessBlank' => true }
    end

    it 'accepts !...blank?' do
      inspect_source(cop, '!foo.blank?')

      expect(cop.offenses).to be_empty
    end
  end

  context 'UnlessBlank set to false' do
    let(:cop_config) do
      { 'NotNilAndNotEmpty' => true,
        'NotBlank' => true,
        'UnlessBlank' => false }
    end

    it 'accepts unless blank?' do
      inspect_source(cop, 'something unless foo.blank?')

      expect(cop.offenses).to be_empty
    end
  end
end
