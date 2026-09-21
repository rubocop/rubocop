# frozen_string_literal: true

RSpec.describe RuboCop::CachedData, :isolated_environment do
  include FileHelper

  subject(:cached_data) { described_class.new(filename) }

  let(:filename) { File.expand_path('example.rb') }
  let(:source) { %(x = "hello"\n) }
  let(:buffer) do
    Parser::Source::Buffer.new(filename, source: source)
  end
  let(:location) { Parser::Source::Range.new(buffer, 4, 11) }

  before { create_file(filename, source) }

  def round_trip(offense)
    cached_data.from_json(cached_data.to_json([offense])).first
  end

  it 'restores an offense that has no correction' do
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName')

    restored = round_trip(offense)

    expect(restored.corrections).to be_empty
    expect(restored.correction_safe).to be(true)
  end

  # The corrector itself cannot be serialized, so without the edits being cached
  # separately a cache hit would report a correctable offense with no edits.
  it 'restores the edits of a correctable offense' do
    corrector = RuboCop::Cop::Corrector.new(buffer).tap { |c| c.replace(location, "'hello'") }
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName',
                                        :uncorrected, corrector)

    restored = round_trip(offense)

    expect(restored.corrections.map(&:to_a)).to eq([[4, 11, "'hello'"]])
    expect(restored.correction_safe).to be(true)
  end

  it 'restores the unsafety of a correction' do
    corrector = RuboCop::Cop::Corrector.new(buffer).tap { |c| c.replace(location, "'hello'") }
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName',
                                        :uncorrected, corrector, correction_safe: false)

    expect(round_trip(offense).correction_safe).to be(false)
  end

  it 'serializes a correction whose replacement is a `Symbol`' do
    corrector = RuboCop::Cop::Corrector.new(buffer).tap { |c| c.replace(location, :$stdout) }
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName',
                                        :uncorrected, corrector)

    expect(round_trip(offense).corrections.map(&:to_a)).to eq([[4, 11, '$stdout']])
  end

  it 'replaces bytes a correction cannot represent as UTF-8' do
    corrector = RuboCop::Cop::Corrector.new(buffer).tap { |c| c.replace(location, "\xAA".b) }
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName',
                                        :uncorrected, corrector)

    expect(round_trip(offense).corrections.map(&:to_a)).to eq([[4, 11, '�']])
  end

  it 'transcodes a correction encoded in something other than UTF-8' do
    replacement = (+"\xAA").force_encoding(Encoding::ISO_8859_1)
    corrector = RuboCop::Cop::Corrector.new(buffer).tap { |c| c.replace(location, replacement) }
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName',
                                        :uncorrected, corrector)

    expect(round_trip(offense).corrections.map(&:to_a)).to eq([[4, 11, 'ª']])
  end

  it 'replaces bytes a justification cannot represent as UTF-8' do
    offense = RuboCop::Cop::Offense.new(:convention, location, 'message', 'CopName',
                                        :disabled, nil, justification: "\xAA".b)

    expect(round_trip(offense).justification).to eq('�')
  end

  it 'restores an offense cached before corrections were stored' do
    legacy = JSON.dump(
      [{ 'severity' => 'convention',
         'location' => { 'begin_pos' => 4, 'end_pos' => 11 },
         'message' => 'message',
         'cop_name' => 'CopName',
         'status' => 'uncorrected' }]
    )

    restored = cached_data.from_json(legacy).first

    expect(restored.corrections).to be_empty
    expect(restored.correction_safe).to be(true)
  end
end
