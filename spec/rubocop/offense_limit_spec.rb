# frozen_string_literal: true

RSpec.describe RuboCop::OffenseLimit do
  subject(:limit) { described_class.new(2) }

  def offenses(*cop_names)
    cop_names.map { |name| instance_double(RuboCop::Cop::Offense, cop_name: name) }
  end

  it 'keeps each cop up to the maximum, counting across calls' do
    first = limit.filter(offenses('Style/A', 'Style/B', 'Style/A'))
    second = limit.filter(offenses('Style/A', 'Style/B', 'Style/B'))

    expect(first.map(&:cop_name)).to eq(%w[Style/A Style/B Style/A])
    expect(second.map(&:cop_name)).to eq(%w[Style/B])
  end

  it 'counts the offenses it left out per cop, sorted by cop name' do
    limit.filter(offenses('Style/Z', 'Style/Z', 'Style/Z', 'Style/A', 'Style/A', 'Style/A'))

    expect(limit.elided_per_cop).to eq('Style/A' => 1, 'Style/Z' => 1)
    expect(limit.elided_per_cop.keys).to eq(%w[Style/A Style/Z])
  end

  it 'reports nothing left out when every cop stays within the maximum' do
    limit.filter(offenses('Style/A'))

    expect(limit.elided_per_cop).to be_empty
  end
end
