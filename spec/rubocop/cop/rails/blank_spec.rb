# frozen_string_literal: true

describe RuboCop::Cop::Rails::Blank, :config do
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

  context 'NilOrEmpty set to true' do
    let(:cop_config) do
      { 'NilOrEmpty' => true }
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

    # Bug: https://github.com/bbatsov/rubocop/issues/4171
    it 'does not break when RHS of `or` is a naked falsiness check' do
      inspect_source(cop, 'foo.empty? || bar')

      expect(cop.offenses).to be_empty
    end

    it 'does not break when LHS of `or` is a naked falsiness check' do
      inspect_source(cop, 'bar || foo.empty?')

      expect(cop.offenses).to be_empty
    end

    context 'nil or empty' do
      it_behaves_like :offense, 'foo.nil? || foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of `foo.nil? || foo.empty?`.'
      it_behaves_like :offense, 'foo == nil || foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of `foo == nil || foo.empty?`.'
      it_behaves_like :offense, 'nil == foo || foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of `nil == foo || foo.empty?`.'
      it_behaves_like :offense, '!foo || foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of `!foo || foo.empty?`.'

      it_behaves_like :offense, 'foo.nil? || !!foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of `foo.nil? || !!foo.empty?`.'
      it_behaves_like :offense, 'foo == nil || !!foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of ' \
                      '`foo == nil || !!foo.empty?`.'
      it_behaves_like :offense, 'nil == foo || !!foo.empty?',
                      'foo.blank?',
                      'Use `foo.blank?` instead of ' \
                      '`nil == foo || !!foo.empty?`.'
    end

    context 'checking all variable types' do
      it_behaves_like :offense, 'foo.bar.nil? || foo.bar.empty?',
                      'foo.bar.blank?',
                      'Use `foo.bar.blank?` instead of ' \
                      '`foo.bar.nil? || foo.bar.empty?`.'
      it_behaves_like :offense, 'FOO.nil? || FOO.empty?',
                      'FOO.blank?',
                      'Use `FOO.blank?` instead of `FOO.nil? || FOO.empty?`.'
      it_behaves_like :offense, 'Foo.nil? || Foo.empty?',
                      'Foo.blank?',
                      'Use `Foo.blank?` instead of `Foo.nil? || Foo.empty?`.'
      it_behaves_like :offense, 'Foo::Bar.nil? || Foo::Bar.empty?',
                      'Foo::Bar.blank?',
                      'Use `Foo::Bar.blank?` instead of ' \
                      '`Foo::Bar.nil? || Foo::Bar.empty?`.'
      it_behaves_like :offense, '@foo.nil? || @foo.empty?',
                      '@foo.blank?',
                      'Use `@foo.blank?` instead of `@foo.nil? || @foo.empty?`.'
      it_behaves_like :offense, '$foo.nil? || $foo.empty?',
                      '$foo.blank?',
                      'Use `$foo.blank?` instead of `$foo.nil? || $foo.empty?`.'
      it_behaves_like :offense, '@@foo.nil? || @@foo.empty?',
                      '@@foo.blank?',
                      'Use `@@foo.blank?` instead of ' \
                      '`@@foo.nil? || @@foo.empty?`.'
      it_behaves_like :offense, 'foo[bar].nil? || foo[bar].empty?',
                      'foo[bar].blank?',
                      'Use `foo[bar].blank?` instead of ' \
                      '`foo[bar].nil? || foo[bar].empty?`.'
      it_behaves_like :offense, 'foo(bar).nil? || foo(bar).empty?',
                      'foo(bar).blank?',
                      'Use `foo(bar).blank?` instead of ' \
                      '`foo(bar).nil? || foo(bar).empty?`.'
    end
  end

  context 'NotPresent set to true' do
    let(:cop_config) do
      { 'NotPresent' => true }
    end

    it_behaves_like :offense, '!foo.present?',
                    'foo.blank?',
                    'Use `foo.blank?` instead of `!foo.present?`.'
    it_behaves_like :offense, 'not foo.present?',
                    'foo.blank?',
                    'Use `foo.blank?` instead of `not foo.present?`.'
    it_behaves_like :offense, '!present?',
                    'blank?',
                    'Use `blank?` instead of `!present?`.'
  end

  context 'UnlessPresent set to true' do
    let(:cop_config) do
      { 'UnlessPresent' => true }
    end

    it 'accepts modifier if present?' do
      inspect_source(cop, 'something if foo.present?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts modifier unless blank?' do
      inspect_source(cop, 'something unless foo.blank?')

      expect(cop.offenses).to be_empty
    end

    it 'accepts normal if present?' do
      inspect_source(cop, <<-END.strip_indent)
        if foo.present?
          something
        end
      END

      expect(cop.offenses).to be_empty
    end

    it 'accepts normal unless blank?' do
      inspect_source(cop, <<-END.strip_indent)
        unless foo.blank?
          something
        end
      END

      expect(cop.offenses).to be_empty
    end

    it 'accepts elsif present?' do
      inspect_source(cop, <<-END.strip_indent)
        if bar.present?
          something
        elsif bar.present?
          something_else
        end
      END

      expect(cop.offenses).to be_empty
    end

    context 'modifier unless' do
      let(:source) { 'something unless foo.present?' }

      it 'registers an offense' do
        inspect_source(cop, source)

        expect(cop.messages)
          .to eq(['Use `if foo.blank?` instead of `unless foo.present?`.'])
        expect(cop.highlights).to eq(['unless foo.present?'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq('something if foo.blank?')
      end
    end

    context 'normal unless present?' do
      let(:source) do
        <<-END.strip_indent
          unless foo.present?
            something
          end
        END
      end

      it 'registers an offense' do
        inspect_source(cop, source)

        expect(cop.messages)
          .to eq(['Use `if foo.blank?` instead of `unless foo.present?`.'])
        expect(cop.highlights).to eq(['unless foo.present?'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(<<-END.strip_indent)
          if foo.blank?
            something
          end
        END
      end
    end

    context 'unless present? with an else' do
      let(:source) do
        <<-END.strip_indent
          unless foo.present?
            something
          else
            something_else
          end
        END
      end

      it 'registers an offense' do
        inspect_source(cop, source)

        expect(cop.messages)
          .to eq(['Use `if foo.blank?` instead of `unless foo.present?`.'])
        expect(cop.highlights).to eq(['unless foo.present?'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(<<-END.strip_indent)
          if foo.blank?
            something
          else
            something_else
          end
        END
      end
    end
  end

  context 'NilOrEmpty set to false' do
    let(:cop_config) do
      { 'NilOrEmpty' => false,
        'NotPresent' => true,
        'UnlessPresent' => true }
    end

    it 'accepts checking nil? || empty?' do
      inspect_source(cop, 'foo.nil? || foo.empty?')

      expect(cop.offenses).to be_empty
    end
  end

  context 'NotPresent set to false' do
    let(:cop_config) do
      { 'NilOrEmpty' => true,
        'NotPresent' => false,
        'UnlessPresent' => true }
    end

    it 'accepts !present?' do
      inspect_source(cop, '!foo.present?')

      expect(cop.offenses).to be_empty
    end
  end

  context 'UnlessPresent set to false' do
    let(:cop_config) do
      { 'NilOrEmpty' => true,
        'NotPresent' => true,
        'UnlessPresent' => false }
    end

    it 'accepts unless present?' do
      inspect_source(cop, 'something unless foo.present?')

      expect(cop.offenses).to be_empty
    end
  end
end
