# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IfUnlessModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }
  let(:config) do
    hash = { 'Metrics/LineLength' => { 'Max' => 80 } }
    RuboCop::Config.new(hash)
  end

  context 'multiline if that fits on one line' do
    let(:source) do
      ["if #{condition}",
       "  #{body}",
       '', # Empty lines should make no difference.
       'end']
    end

    let(:condition) { 'a' * 38 }
    let(:body) { 'b' * 38 }

    it 'registers an offense' do
      # This if statement fits exactly on one line if written as a
      # modifier.
      expect("#{body} if #{condition}".length).to eq(80)

      inspect_source(cop, source)
      expect(cop.messages).to eq(
        ['Favor modifier `if` usage when having a single-line' \
         ' body. Another good alternative is the usage of control flow' \
         ' `&&`/`||`.']
      )
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq "#{body} if #{condition}"
    end

    context 'and has two statements separated by semicolon' do
      let(:source) do
        ['if condition',
         '  do_this; do_that',
         'end']
      end

      it 'accepts' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'multiline if that fits on one line with comment on first line' do
    let(:source) do
      ['if a # comment',
       '  b',
       'end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages).to eq(
        ['Favor modifier `if` usage when having a single-line' \
         ' body. Another good alternative is the usage of control flow' \
         ' `&&`/`||`.']
      )
    end

    it 'does auto-correction and preserves comment' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'b if a # comment'
    end
  end

  context 'multiline if that fits on one line with comment near end' do
    let(:source) do
      ['if a',
       '  b',
       'end # comment',
       'if a',
       '  b',
       '  # comment',
       'end']
    end

    it 'accepts' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'short multiline if near an else etc' do
    let(:source) do
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
       'end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(['if x',
                               '  y',
                               'elsif x1',
                               '  y1',
                               'else',
                               '  z',
                               'end',
                               'n = a ? 0 : 1',
                               'm = 3 if m0',
                               '',
                               'b if a'].join("\n"))
    end
  end

  it "accepts multiline if that doesn't fit on one line" do
    check_too_long(cop, 'if')
  end

  it 'accepts multiline if whose body is more than one line' do
    check_short_multiline(cop, 'if')
  end

  context 'multiline unless that fits on one line' do
    let(:source) do
      ['unless a',
       '  b',
       'end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages).to eq(
        ['Favor modifier `unless` usage when having a single-line' \
         ' body. Another good alternative is the usage of control flow' \
         ' `&&`/`||`.']
      )
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'b unless a'
    end
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

      it 'does auto-correction' do
        corrected = autocorrect_source(cop, source)
        expect(corrected).to eq "  #{body} if #{conditional}"
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

  it 'accepts if-end followed by a chained call' do
    inspect_source(cop, ['if test',
                         '  something',
                         'end.inspect'])
    expect(cop.messages).to be_empty
  end

  it "doesn't break if-end when used as RHS of local var assignment" do
    corrected = autocorrect_source(cop, ['a = if b',
                                         '  1',
                                         'end'])
    expect(corrected).to eq 'a = (1 if b)'
  end

  it "doesn't break if-end when used as RHS of instance var assignment" do
    corrected = autocorrect_source(cop, ['@a = if b',
                                         '  1',
                                         'end'])
    expect(corrected).to eq '@a = (1 if b)'
  end

  it "doesn't break if-end when used as RHS of class var assignment" do
    corrected = autocorrect_source(cop, ['@@a = if b',
                                         '  1',
                                         'end'])
    expect(corrected).to eq '@@a = (1 if b)'
  end

  it "doesn't break if-end when used as RHS of constant assignment" do
    corrected = autocorrect_source(cop, ['A = if b',
                                         '  1',
                                         'end'])
    expect(corrected).to eq 'A = (1 if b)'
  end

  it "doesn't break if-end when used as RHS of binary arithmetic" do
    corrected = autocorrect_source(cop, ['a + if b',
                                         '  1',
                                         'end'])
    expect(corrected).to eq 'a + (1 if b)'
  end

  it 'accepts if-end when used as LHS of binary arithmetic' do
    inspect_source(cop, ['if test',
                         '  1',
                         'end + 2'])
    expect(cop.messages).to be_empty
  end

  context 'if-end is argument to a parenthesized method call' do
    it "doesn't add redundant parentheses" do
      corrected = autocorrect_source(cop, ['puts("string", if a',
                                           '  1',
                                           'end)'])
      expect(corrected).to eq 'puts("string", 1 if a)'
    end
  end

  context 'if-end is argument to a non-parenthesized method call' do
    it 'adds parentheses so as not to change meaning' do
      corrected = autocorrect_source(cop, ['puts "string", if a',
                                           '  1',
                                           'end'])
      expect(corrected).to eq 'puts "string", (1 if a)'
    end
  end

  context 'if-end with conditional as body' do
    let(:source) do
      ['if condition',
       '  foo ? "bar" : "baz"',
       'end']
    end

    it 'accepts' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'unless-end with conditional as body' do
    let(:source) do
      ['unless condition',
       '  foo ? "bar" : "baz"',
       'end']
    end

    it 'accepts' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end
end
