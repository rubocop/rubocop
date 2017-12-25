# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Registry do
  subject(:registry) { described_class.new(cops) }

  let(:cops) do
    stub_const('RuboCop::Cop::Test', Module.new)
    stub_const('RuboCop::Cop::RSpec', Module.new)

    module RuboCop
      module Cop
        module Test
          # Create another cop with a different namespace
          class IndentArray < Cop
          end
        end

        module RSpec
          # Define a dummy rspec cop which has special namespace inflection
          class Foo < Cop
          end
        end
      end
    end

    [
      RuboCop::Cop::Lint::ConditionPosition,
      RuboCop::Cop::Lint::DuplicateMethods,
      RuboCop::Cop::Layout::IndentArray,
      RuboCop::Cop::Metrics::MethodLength,
      RuboCop::Cop::RSpec::Foo,
      RuboCop::Cop::Test::IndentArray
    ]
  end

  # `RuboCop::Cop::Cop` mutates its `registry` when inherited from.
  # This can introduce nondeterministic failures in other parts of the
  # specs if this mutation occurs before code that depends on this global cop
  # store. The workaround is to replace the global cop store with a temporary
  # store during these tests
  around do |test|
    registry        = RuboCop::Cop::Cop.registry
    temporary_store = described_class.new(registry.cops)
    RuboCop::Cop::Cop.instance_variable_set(:@registry, temporary_store)

    test.run

    RuboCop::Cop::Cop.instance_variable_set(:@registry, registry)
  end

  it 'exposes cop departments' do
    expect(registry.departments).to eql(%i[Lint Layout Metrics RSpec Test])
  end

  it 'can filter down to one type' do
    expect(registry.with_department(:Lint))
      .to eq(described_class.new(cops.first(2)))
  end

  it 'can filter down to all but one type' do
    expect(registry.without_department(:Lint))
      .to eq(described_class.new(cops.drop(2)))
  end

  context '#contains_cop_matching?' do
    it 'can find cops matching a given name' do
      expect(registry.contains_cop_matching?(['Test/IndentArray'])).to be(true)
    end

    it 'returns false for cops not included in the store' do
      expect(registry.contains_cop_matching?(['Style/NotReal'])).to be(false)
    end
  end

  context '#qualified_cop_name' do
    let(:origin) { '/app/.rubocop.yml' }

    it 'gives back already properly qualified names' do
      expect(registry.qualified_cop_name('Layout/IndentArray', origin))
        .to eql('Layout/IndentArray')
    end

    it 'qualifies names without a namespace' do
      expect(registry.qualified_cop_name('MethodLength', origin))
        .to eql('Metrics/MethodLength')
    end

    it 'qualifies names with the correct namespace' do
      expect(registry.qualified_cop_name('Foo', origin)).to eql('RSpec/Foo')
    end

    it 'emits a warning when namespace is incorrect' do
      warning = '/app/.rubocop.yml: Style/MethodLength has the wrong ' \
                "namespace - should be Metrics\n"
      qualified = nil

      expect do
        qualified = registry.qualified_cop_name('Style/MethodLength', origin)
      end.to output(warning).to_stderr

      expect(qualified).to eql('Metrics/MethodLength')
    end

    it 'raises an error when a cop name is ambiguous' do
      expect { registry.qualified_cop_name('IndentArray', origin) }
        .to raise_error(RuboCop::Cop::AmbiguousCopName).with_message(
          'Ambiguous cop name `IndentArray` used in /app/.rubocop.yml needs ' \
          'department qualifier. Did you mean Layout/IndentArray or ' \
          'Test/IndentArray?'
        )
    end

    it 'returns the provided name if no namespace is found' do
      expect(registry.qualified_cop_name('NotReal', origin)).to eql('NotReal')
    end
  end

  it 'exposes a mapping of cop names to cop classes' do
    expect(registry.to_h).to eql(
      'Lint/ConditionPosition' => [RuboCop::Cop::Lint::ConditionPosition],
      'Lint/DuplicateMethods'  => [RuboCop::Cop::Lint::DuplicateMethods],
      'Layout/IndentArray'     => [RuboCop::Cop::Layout::IndentArray],
      'Metrics/MethodLength'   => [RuboCop::Cop::Metrics::MethodLength],
      'Test/IndentArray'       => [RuboCop::Cop::Test::IndentArray],
      'RSpec/Foo'              => [RuboCop::Cop::RSpec::Foo]
    )
  end

  context '#cops' do
    it 'exposes a list of cops' do
      expect(registry.cops).to eql(cops)
    end
  end

  it 'exposes the number of stored cops' do
    expect(registry.length).to be(6)
  end

  context '#enabled' do
    let(:config) do
      RuboCop::Config.new('Test/IndentArray' => { 'Enabled' => false })
    end

    it 'selects cops which are enabled in the config' do
      expect(registry.enabled(config, [])).to eql(cops.first(5))
    end

    it 'overrides config if :only includes the cop' do
      expect(registry.enabled(config, ['Test/IndentArray'])).to eql(cops)
    end
  end

  it 'exposes a list of cop names' do
    expect(registry.names).to eql(
      [
        'Lint/ConditionPosition',
        'Lint/DuplicateMethods',
        'Layout/IndentArray',
        'Metrics/MethodLength',
        'RSpec/Foo',
        'Test/IndentArray'
      ]
    )
  end
end
