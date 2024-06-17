# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Registry do
  subject(:registry) { described_class.new(cops, options) }

  let(:cops) do
    [
      RuboCop::Cop::Lint::BooleanSymbol,
      RuboCop::Cop::Lint::DuplicateMethods,
      RuboCop::Cop::Layout::FirstArrayElementIndentation,
      RuboCop::Cop::Metrics::MethodLength,
      RuboCop::Cop::RSpec::Foo,
      RuboCop::Cop::Test::FirstArrayElementIndentation
    ]
  end

  let(:options) { {} }

  before do
    stub_const('RuboCop::Cop::Test::FirstArrayElementIndentation', Class.new(RuboCop::Cop::Base))
    stub_const('RuboCop::Cop::RSpec::Foo', Class.new(RuboCop::Cop::Base))
  end

  # `RuboCop::Cop::Base` mutates its `registry` when inherited from.
  # This can introduce nondeterministic failures in other parts of the
  # specs if this mutation occurs before code that depends on this global cop
  # store. The workaround is to replace the global cop store with a temporary
  # store during these tests
  around { |test| described_class.with_temporary_global { test.run } }

  it 'can be cloned' do
    klass = RuboCop::Cop::Metrics::AbcSize
    copy = registry.dup
    copy.enlist(klass)
    expect(copy.cops).to include(klass)
    expect(registry.cops).not_to include(klass)
  end

  context 'when dismissing a cop class' do
    let(:cop_class) { RuboCop::Cop::Metrics::AbcSize }

    before { registry.enlist(cop_class) }

    it 'allows it if done rapidly' do
      registry.dismiss(cop_class)
      expect(registry.cops).not_to include(cop_class)
    end

    it 'disallows it if done too late' do
      expect(registry.cops).to include(cop_class)
      expect { registry.dismiss(cop_class) }.to raise_error(RuntimeError)
    end

    it 'allows re-listing' do
      registry.dismiss(cop_class)
      expect(registry.cops).not_to include(cop_class)
      registry.enlist(cop_class)
      expect(registry.cops).to include(cop_class)
    end
  end

  it 'exposes cop departments' do
    expect(registry.departments).to eql(%i[Lint Layout Metrics RSpec Test])
  end

  it 'can filter down to one type' do
    expect(registry.with_department(:Lint)).to eq(described_class.new(cops.first(2)))
  end

  it 'can filter down to all but one type' do
    expect(registry.without_department(:Lint)).to eq(described_class.new(cops.drop(2)))
  end

  describe '#contains_cop_matching?' do
    it 'can find cops matching a given name' do
      result = registry.contains_cop_matching?(['Test/FirstArrayElementIndentation'])
      expect(result).to be(true)
    end

    it 'returns false for cops not included in the store' do
      expect(registry).not_to be_contains_cop_matching(['Style/NotReal'])
    end
  end

  describe '#qualified_cop_name' do
    let(:origin) { '/app/.rubocop.yml' }

    it 'gives back already properly qualified names' do
      result = registry.qualified_cop_name('Layout/FirstArrayElementIndentation', origin)
      expect(result).to eql('Layout/FirstArrayElementIndentation')
    end

    it 'qualifies names without a namespace' do
      warning = "/app/.rubocop.yml: Warning: no department given for MethodLength.\n"
      qualified = nil

      expect do
        qualified = registry.qualified_cop_name('MethodLength', origin)
      end.to output(warning).to_stderr

      expect(qualified).to eql('Metrics/MethodLength')
    end

    it 'qualifies names with the correct namespace' do
      warning = "/app/.rubocop.yml: Warning: no department given for Foo.\n"
      qualified = nil

      expect do
        qualified = registry.qualified_cop_name('Foo', origin)
      end.to output(warning).to_stderr

      expect(qualified).to eql('RSpec/Foo')
    end

    it 'emits a warning when namespace is incorrect' do
      warning = '/app/.rubocop.yml: Style/MethodLength has the wrong ' \
                "namespace - replace it with Metrics/MethodLength\n"
      qualified = nil

      expect do
        qualified = registry.qualified_cop_name('Style/MethodLength', origin)
      end.to output(warning).to_stderr

      expect(qualified).to eql('Metrics/MethodLength')
    end

    it 'raises an error when a cop name is ambiguous' do
      cop_name = 'FirstArrayElementIndentation'
      expect { registry.qualified_cop_name(cop_name, origin) }
        .to raise_error(RuboCop::Cop::AmbiguousCopName)
        .with_message(
          'Ambiguous cop name `FirstArrayElementIndentation` used in ' \
          '/app/.rubocop.yml needs department qualifier. Did you mean ' \
          'Layout/FirstArrayElementIndentation or ' \
          'Test/FirstArrayElementIndentation?'
        )
        .and output('/app/.rubocop.yml: Warning: no department given for ' \
                    "FirstArrayElementIndentation.\n").to_stderr
    end

    it 'returns the provided name if no namespace is found' do
      expect(registry.qualified_cop_name('NotReal', origin)).to eql('NotReal')
    end
  end

  it 'exposes a mapping of cop names to cop classes' do
    expect(registry.to_h).to eql(
      'Lint/BooleanSymbol' => [RuboCop::Cop::Lint::BooleanSymbol],
      'Lint/DuplicateMethods' => [RuboCop::Cop::Lint::DuplicateMethods],
      'Layout/FirstArrayElementIndentation' => [
        RuboCop::Cop::Layout::FirstArrayElementIndentation
      ],
      'Metrics/MethodLength' => [RuboCop::Cop::Metrics::MethodLength],
      'Test/FirstArrayElementIndentation' => [
        RuboCop::Cop::Test::FirstArrayElementIndentation
      ],
      'RSpec/Foo' => [RuboCop::Cop::RSpec::Foo]
    )
  end

  describe '#cops' do
    it 'exposes a list of cops' do
      expect(registry.cops).to eql(cops)
    end

    context 'with cops having the same inner-most module' do
      let(:cops) { [RuboCop::Cop::Foo::Bar, RuboCop::Cop::Baz::Foo::Bar] }

      before do
        stub_const('RuboCop::Cop::Foo::Bar', Class.new(RuboCop::Cop::Base))
        stub_const('RuboCop::Cop::Baz::Foo::Bar', Class.new(RuboCop::Cop::Base))
      end

      it 'exposes both cops' do
        expect(registry.cops).to contain_exactly(
          RuboCop::Cop::Foo::Bar, RuboCop::Cop::Baz::Foo::Bar
        )
      end
    end
  end

  it 'exposes the number of stored cops' do
    expect(registry.length).to be(6)
  end

  describe '#enabled' do
    subject(:enabled_cops) { registry.enabled(config) }

    let(:config) do
      RuboCop::Config.new(
        'Test/FirstArrayElementIndentation' => { 'Enabled' => false },
        'RSpec/Foo' => { 'Safe' => false }
      )
    end

    it 'selects cops which are enabled in the config' do
      expect(registry.enabled(config)).to eql(cops.first(5))
    end

    it 'overrides config if :only includes the cop' do
      options[:only] = ['Test/FirstArrayElementIndentation']
      expect(enabled_cops).to eql(cops)
    end

    it 'selects only safe cops if :safe passed' do
      options[:safe] = true
      expect(enabled_cops).not_to include(RuboCop::Cop::RSpec::Foo)
    end

    context 'when new cops are introduced' do
      let(:config) { RuboCop::Config.new('Lint/BooleanSymbol' => { 'Enabled' => 'pending' }) }

      it 'does not include them' do
        expect(enabled_cops).not_to include(RuboCop::Cop::Lint::BooleanSymbol)
      end

      it 'overrides config if :only includes the cop' do
        options[:only] = ['Lint/BooleanSymbol']
        expect(enabled_cops).to eql(cops)
      end

      context 'when specifying `--disable-pending-cops` command-line option' do
        let(:options) { { disable_pending_cops: true } }

        it 'does not include them' do
          expect(enabled_cops).not_to include(RuboCop::Cop::Lint::BooleanSymbol)
        end

        context 'when specifying `NewCops: enable` option in .rubocop.yml' do
          let(:config) do
            RuboCop::Config.new(
              'AllCops' => { 'NewCops' => 'enable' },
              'Lint/BooleanSymbol' => { 'Enabled' => 'pending' }
            )
          end

          it 'does not include them because command-line option takes ' \
             'precedence over .rubocop.yml' do
            expect(enabled_cops).not_to include(RuboCop::Cop::Lint::BooleanSymbol)
          end
        end
      end

      context 'when specifying `--enable-pending-cops` command-line option' do
        let(:options) { { enable_pending_cops: true } }

        it 'includes them' do
          expect(enabled_cops).to include(RuboCop::Cop::Lint::BooleanSymbol)
        end

        context 'when specifying `NewCops: disable` option in .rubocop.yml' do
          let(:config) do
            RuboCop::Config.new(
              'AllCops' => { 'NewCops' => 'disable' },
              'Lint/BooleanSymbol' => { 'Enabled' => 'pending' }
            )
          end

          it 'includes them because command-line option takes precedence over .rubocop.yml' do
            expect(enabled_cops).to include(RuboCop::Cop::Lint::BooleanSymbol)
          end
        end
      end

      context 'when specifying `NewCops: pending` option in .rubocop.yml' do
        let(:config) do
          RuboCop::Config.new(
            'AllCops' => { 'NewCops' => 'pending' },
            'Lint/BooleanSymbol' => { 'Enabled' => 'pending' }
          )
        end

        it 'does not include them' do
          expect(enabled_cops).not_to include(RuboCop::Cop::Lint::BooleanSymbol)
        end
      end

      context 'when specifying `NewCops: disable` option in .rubocop.yml' do
        let(:config) do
          RuboCop::Config.new(
            'AllCops' => { 'NewCops' => 'disable' },
            'Lint/BooleanSymbol' => { 'Enabled' => 'pending' }
          )
        end

        it 'does not include them' do
          expect(enabled_cops).not_to include(RuboCop::Cop::Lint::BooleanSymbol)
        end
      end

      context 'when specifying `NewCops: enable` option in .rubocop.yml' do
        let(:config) do
          RuboCop::Config.new(
            'AllCops' => { 'NewCops' => 'enable' },
            'Lint/BooleanSymbol' => { 'Enabled' => 'pending' }
          )
        end

        it 'includes them' do
          expect(enabled_cops).to include(RuboCop::Cop::Lint::BooleanSymbol)
        end
      end
    end
  end

  it 'exposes a list of cop names' do
    expect(registry.names).to eql(
      [
        'Lint/BooleanSymbol',
        'Lint/DuplicateMethods',
        'Layout/FirstArrayElementIndentation',
        'Metrics/MethodLength',
        'RSpec/Foo',
        'Test/FirstArrayElementIndentation'
      ]
    )
  end

  describe '#department?' do
    it 'returns true for department name' do
      expect(registry).to be_department('Lint')
    end

    it 'returns false for other names' do
      expect(registry).not_to be_department('Foo')
    end
  end

  describe 'names_for_department' do
    it 'returns array of cops for specified department' do
      expect(registry.names_for_department('Lint'))
        .to eq %w[Lint/BooleanSymbol Lint/DuplicateMethods]
    end
  end
end
