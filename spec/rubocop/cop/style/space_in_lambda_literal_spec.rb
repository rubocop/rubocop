# frozen_string_literal: true

describe RuboCop::Cop::Style::SpaceInLambdaLiteral, :config do
  subject(:cop) { described_class.new(config) }

  context 'when configured to enforce spaces' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_space' } }

    it 'registers an offense for no space between -> and (' do
      inspect_source(cop, 'a = ->(b, c) { b + c }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not register an offense for a space between -> and (' do
      inspect_source(cop, 'a = -> (b, c) { b + c }')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for multi-line lambdas' do
      inspect_source(cop, ['l = lambda do |a, b|',
                           '  tmp = a * 7',
                           '  tmp * b / 50',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for no space between -> and {' do
      inspect_source(cop, 'a = ->{ b + c }')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for no space in the inner nested lambda' do
      inspect_source(cop, 'a = -> (b = ->(c) {}, d) { b + d }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for no space in the outer nested lambda' do
      inspect_source(cop, 'a = ->(b = -> (c) {}, d) { b + d }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for no space in both lambdas when nested' do
      inspect_source(cop, 'a = ->(b = ->(c) {}, d) { b + d }')
      expect(cop.offenses.size).to eq(2)
    end

    it 'autocorrects an offense for no space between -> and (' do
      code = 'a = ->(b, c) { b + c }'
      expected = 'a = -> (b, c) { b + c }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for no space in the inner nested lambda' do
      code = 'a = -> (b = ->(c) {}, d) { b + d }'
      expected = 'a = -> (b = -> (c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for no space in the outer nested lambda' do
      code = 'a = ->(b = -> (c) {}, d) { b + d }'
      expected = 'a = -> (b = -> (c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for no space in both lambdas when nested' do
      code = 'a = ->(b = ->(c) {}, d) { b + d }'
      expected = 'a = -> (b = -> (c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end
  end

  context 'when configured to enforce no space' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_space' } }

    it 'registers an offense for a space between -> and (' do
      inspect_source(cop, 'a = -> (b, c) { b + c }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not register an offense for no space between -> and (' do
      inspect_source(cop, 'a = ->(b, c) { b + c }')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for multi-line lambdas' do
      inspect_source(cop, ['l = lambda do |a, b|',
                           '  tmp = a * 7',
                           '  tmp * b / 50',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for a space between -> and {' do
      inspect_source(cop, 'a = -> { b + c }')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for spaces between -> and (' do
      inspect_source(cop, 'a = ->   (b, c) { b + c }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for a space in the inner nested lambda' do
      inspect_source(cop, 'a = ->(b = -> (c) {}, d) { b + d }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for a space in the outer nested lambda' do
      inspect_source(cop, 'a = -> (b = ->(c) {}, d) { b + d }')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers two offenses for a space in both lambdas when nested' do
      inspect_source(cop, 'a = -> (b = -> (c) {}, d) { b + d }')
      expect(cop.offenses.size).to eq(2)
    end

    it 'autocorrects an offense for a space between -> and (' do
      code = 'a = -> (b, c) { b + c }'
      expected = 'a = ->(b, c) { b + c }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for spaces between -> and (' do
      code = 'a = ->   (b, c) { b + c }'
      expected = 'a = ->(b, c) { b + c }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for a space in the inner nested lambda' do
      code = 'a = ->(b = -> (c) {}, d) { b + d }'
      expected = 'a = ->(b = ->(c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for a space in the outer nested lambda' do
      code = 'a = -> (b = ->(c) {}, d) { b + d }'
      expected = 'a = ->(b = ->(c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects two offenses for a space in both lambdas when nested' do
      code = 'a = -> (b = -> (c) {}, d) { b + d }'
      expected = 'a = ->(b = ->(c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end
  end
end
