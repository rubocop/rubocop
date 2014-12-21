# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::IfUnlessModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }
  let(:config) do
    hash = { 'Metrics/LineLength' => { 'Max' => 80 } }
    RuboCop::Config.new(hash)
  end

  it 'registers an offense for multiline if that fits on one line' do
    # This if statement fits exactly on one line if written as a
    # modifier.
    condition = 'a' * 38
    body = 'b' * 36
    expect("  #{body} if #{condition}".length).to eq(80)

    inspect_source(cop,
                   ["  if #{condition}",
                    "    #{body}",
                    '  end'])
    expect(cop.messages).to eq(
      ['Favor modifier `if` usage when having a single-line' \
       ' body. Another good alternative is the usage of control flow' \
       ' `&&`/`||`.'])
  end

  it 'registers an offense for short multiline if near an else etc' do
    inspect_source(cop,
                   ['if x',
                    '  y',
                    'elsif x1',
                    '  y1',
                    'else',
                    '  z',
                    'end',
                    'n = a ? 0 : 1',
                    'm = 3 if m0',
                    '',
                    'if a',
                    '  b',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it "accepts multiline if that doesn't fit on one line" do
    check_too_long(cop, 'if')
  end

  it 'accepts multiline if whose body is more than one line' do
    check_short_multiline(cop, 'if')
  end

  it 'registers an offense for multiline unless that fits on one line' do
    inspect_source(cop, ['unless a',
                         '  b',
                         'end'])
    expect(cop.messages).to eq(
      ['Favor modifier `unless` usage when having a single-line' \
       ' body. Another good alternative is the usage of control flow' \
       ' `&&`/`||`.'])
  end

  it 'accepts code with EOL comment since user might want to keep it' do
    inspect_source(cop, ['unless a',
                         '  b # A comment',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts if-else-end' do
    inspect_source(cop,
                   'if args.last.is_a? Hash then args.pop else ' \
                   'Hash.new end')
    expect(cop.messages).to be_empty
  end

  it 'accepts an empty condition' do
    check_empty(cop, 'if')
    check_empty(cop, 'unless')
  end

  it 'accepts if/elsif' do
    inspect_source(cop, ['if test',
                         '  something',
                         'elsif test2',
                         '  something_else',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  context 'with implicit match conditional' do
    let(:source) do
      [
        "  if #{conditional}",
        "    #{body}",
        '  end'
      ]
    end

    let(:body) { 'b' * 36 }

    context 'when a multiline if fits on one line' do
      let(:conditional) { "/#{'a' * 36}/" }

      it 'registers an offense' do
        expect("  #{body} if #{conditional}".length).to eq(80)

        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "when a multiline if doesn't fit on one line" do
      let(:conditional) { "/#{'a' * 37}/" }

      it 'accepts' do
        expect("  #{body} if #{conditional}".length).to eq(81)

        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'when the maximum line length is specified by the cop itself' do
      let(:config) do
        hash = {
          'Metrics/LineLength' => { 'Max' => 100 },
          'Style/IfUnlessModifier' => { 'MaxLineLength' => 80 }
        }
        RuboCop::Config.new(hash)
      end

      it "accepts multiline if that doesn't fit on one line" do
        check_too_long(cop, 'if')
      end

      it "accepts multiline unless that doesn't fit on one line" do
        check_too_long(cop, 'unless')
      end
    end
  end
end
