# frozen_string_literal: true

describe RuboCop::Cop::Style::TrailingUnderscoreVariable do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common functionality' do
    it 'registers an offense when the last variable of parallel assignment ' \
       'is an underscore' do
      inspect_source('a, b, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, b, = foo()`.'])
    end

    it 'registers an offense when multiple underscores are used '\
       'as the last variables of parallel assignment ' do
      inspect_source('a, _, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    it 'registers an offense for splat underscore as the last variable' do
      inspect_source('a, *_ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    it 'registers an offense when underscore is the second to last variable ' \
       'and blank is the last variable' do
      inspect_source('a, _, = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    it 'registers an offense when underscore is the only variable ' \
       'in parallel assignment' do
      inspect_source('_, = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `foo()`.'])
    end

    it 'registers an offense for an underscore as the last param ' \
       'when there is also an underscore as the first param' do
      inspect_source('_, b, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `_, b, = foo()`.'])
    end

    it 'does not register an offense when there are no underscores' do
      inspect_source('a, b, c = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for underscores at the beginning' do
      inspect_source('_, a, b = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for an underscore preceded by a ' \
       'splat variable anywhere in the argument chain' do
      inspect_source('*a, b, _ = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for an underscore preceded by a ' \
       'splat variable' do
      inspect_source('a, *b, _ = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for an underscore preceded by a ' \
       'splat variable and another underscore' do
      inspect_source('_, *b, _ = *foo')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for multiple underscores preceded by a ' \
       'splat variable' do
      inspect_source('a, *b, _, _ = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for multiple named underscores ' \
       'preceded by a splat variable' do
      inspect_source('a, *b, _c, _d = foo()')

      expect(cop.messages).to be_empty
    end

    it 'registers an offense for multiple underscore variables preceded by ' \
       'a splat underscore variable' do
      inspect_source('a, *_, _, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    it 'does not register an offense for a named underscore variable ' \
       'preceded by a splat variable' do
      inspect_source('a, *b, _c = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for a named variable preceded by a ' \
       'names splat underscore variable' do
      inspect_source('a, *b, _c = foo()')

      expect(cop.messages).to be_empty
    end

    describe 'autocorrect' do
      it 'removes trailing underscores automatically' do
        new_source = autocorrect_source(cop, 'a, b, _ = foo()')

        expect(new_source).to eq('a, b, = foo()')
      end

      it 'removes trailing underscores and commas' do
        new_source = autocorrect_source(cop, 'a, b, _, = foo()')

        expect(new_source).to eq('a, b, = foo()')
      end

      it 'removes multiple trailing underscores' do
        new_source = autocorrect_source(cop, 'a, _, _ = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes trailing underscores and commas and preserves assignments' do
        new_source = autocorrect_source(cop, 'a, _, _, = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes trailing comma when it is the only variable' do
        new_source = autocorrect_source(cop, '_, = foo()')

        expect(new_source).to eq('foo()')
      end

      it 'removes all assignments when every assignment is to `_`' do
        new_source = autocorrect_source(cop, '_, _, _, = foo()')

        expect(new_source).to eq('foo()')
      end

      it 'remove splat underscore' do
        new_source = autocorrect_source(cop, 'a, *_ = foo()')

        expect(new_source).to eq('a, = foo()')
      end
    end
  end

  context 'configured to allow named underscore variables' do
    include_examples 'common functionality'

    let(:config) do
      RuboCop::Config.new('Style/TrailingUnderscoreVariable' => {
                            'Enabled' => true,
                            'AllowNamedUnderscoreVariables' => true
                          })
    end

    it 'does not register an offense for an underscore variable preceded ' \
       'by a named splat underscore variable' do
      inspect_source('a, *_b, _ = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for named variables ' \
       'that start with an underscore' do
      inspect_source('a, b, _c = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for a named splat underscore ' \
       'as the last variable' do
      inspect_source('a, *_b = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for an underscore preceded by ' \
       'a named splat underscore' do
      inspect_source('a, *_b, _ = foo()')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for multiple underscore variables ' \
       'preceded by a named splat underscore variable' do
      inspect_source('a, *_b, _, _ = foo()')

      expect(cop.messages).to be_empty
    end
  end

  context 'configured to not allow named underscore variables' do
    include_examples 'common functionality'

    let(:config) do
      RuboCop::Config.new('Style/TrailingUnderscoreVariable' => {
                            'Enabled' => true,
                            'AllowNamedUnderscoreVariables' => false
                          })
    end

    it 'registers an offense for named variables ' \
       'that start with an underscore' do
      inspect_source('a, b, _c = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, b, = foo()`.'])
    end

    it 'registers an offense for a named splat underscore ' \
       'as the last variable' do
      inspect_source('a, *_b = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    it 'does not register an offense for a named underscore preceded by a ' \
       'splat variable' do
      inspect_source('a, *b, _c = foo()')

      expect(cop.messages).to be_empty
    end

    it 'registers an offense for an underscore variable preceded ' \
       'by a named splat underscore variable' do
      inspect_source('a, *_b, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    it 'registers an offense for an underscore preceded by ' \
       'a named splat underscore' do
      inspect_source('a, b, *_c, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, b, = foo()`.'])
    end

    it 'registers an offense for multiple underscore variables ' \
       'preceded by a named splat underscore variable' do
      inspect_source('a, *_b, _, _ = foo()')

      expect(cop.messages)
        .to eq(['Do not use trailing `_`s in parallel assignment. ' \
                'Prefer `a, = foo()`.'])
    end

    context 'autocorrect' do
      it 'removes named underscore variables' do
        new_source = autocorrect_source(cop, 'a, _b = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes named splat underscore variables' do
        new_source = autocorrect_source(cop, 'a, *_b = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes named splat underscore and named underscore variables' do
        new_source = autocorrect_source(cop, 'a, *_b, _c = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'works when last underscore is followed by a comma' do
        new_source = autocorrect_source(cop, 'a, _, = foo()')

        expect(new_source).to eq('a, = foo()')
      end
    end
  end
end
