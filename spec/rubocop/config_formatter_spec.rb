# frozen_string_literal: true

require 'rubocop/config_formatter'

RSpec.describe RuboCop::ConfigFormatter do
  let(:config) do
    {
      'AllCops' => {
        'Setting' => 'fourty two'
      },
      'Style/Foo' => {
        'Config' => 2,
        'Enabled' => true
      },
      'Style/Bar' => {
        'Enabled' => true
      }
    }
  end

  let(:descriptions) do
    {
      'Style/Foo' => {
        'Description' => 'Blah'
      },
      'Style/Bar' => {
        'Description' => 'Wow'
      }
    }
  end

  it 'builds a YAML dump with spacing between cops' do
    formatter = described_class.new(config, descriptions)

    expect(formatter.dump).to eql(<<-YAML.gsub(/^\s+\|/, ''))
      |---
      |AllCops:
      |  Setting: fourty two
      |
      |Style/Foo:
      |  Config: 2
      |  Enabled: true
      |  Description: Blah
      |
      |Style/Bar:
      |  Enabled: true
      |  Description: Wow
    YAML
  end
end
