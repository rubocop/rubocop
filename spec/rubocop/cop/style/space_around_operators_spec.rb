# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAroundOperators do
  subject(:cop) { described_class.new }

  it 'registers an offence for assignment without space on both sides' do
    inspect_source(cop, ['x=0', 'y= 0', 'z =0'])
    expect(cop.messages).to eq(
      ["Surrounding space missing for operator '='."] * 3)
  end

  it 'registers an offence for ternary operator without space' do
    inspect_source(cop, ['x == 0?1:2'])
    expect(cop.messages).to eq(
      ["Surrounding space missing for operator '?'.",
       "Surrounding space missing for operator ':'."])
  end

  it 'registers an offence in presence of modifier if statement' do
    check_modifier('if')
  end

  it 'registers an offence in presence of modifier unless statement' do
    check_modifier('unless')
  end

  it 'registers an offence in presence of modifier while statement' do
    check_modifier('unless')
  end

  it 'registers an offence in presence of modifier until statement' do
    check_modifier('unless')
  end

  def check_modifier(keyword)
    src = ["a=1 #{keyword} condition",
           'c=2']
    inspect_source(cop, src)
    expect(cop.offences.map(&:line)).to eq([1, 2])
    expect(cop.messages).to eq(
      ["Surrounding space missing for operator '='."] * 2)
  end

  it 'registers an offence for binary operators that could be unary' do
    inspect_source(cop, ['a-3', 'x&0xff', 'z+0'])
    expect(cop.messages).to eq(
      ["Surrounding space missing for operator '-'.",
       "Surrounding space missing for operator '&'.",
       "Surrounding space missing for operator '+'."])
  end

  it 'registers an offence for arguments to a method' do
    inspect_source(cop, ['puts 1+2'])
    expect(cop.messages).to eq(
      ["Surrounding space missing for operator '+'."])
  end

  it 'accepts operator symbols' do
    inspect_source(cop, ['func(:-)'])
    expect(cop.messages).to be_empty
  end

  it 'accepts ranges' do
    inspect_source(cop, ['a, b = (1..2), (1...3)'])
    expect(cop.messages).to be_empty
  end

  it 'accepts scope operator' do
    source = ['@io.class == Zlib::GzipWriter']
    inspect_source(cop, source)
    expect(cop.messages).to be_empty
  end

  it 'accepts ::Kernel::raise' do
    source = ['::Kernel::raise IllegalBlockError.new']
    inspect_source(cop, source)
    expect(cop.messages).to be_empty
  end

  it 'accepts exclamation point negation' do
    inspect_source(cop, ['x = !a&&!b'])
    expect(cop.messages).to eq(
      ["Surrounding space missing for operator '&&'."])
  end

  it 'accepts exclamation point definition' do
    inspect_source(cop, ['  def !',
                         '    !__getobj__',
                         '  end'])
    expect(cop.offences).to be_empty
    expect(cop.messages).to be_empty
  end

  it 'accepts a unary' do
    inspect_source(cop,
                   ['  def bm(label_width = 0, *labels, &blk)',
                    '    benchmark(CAPTION, label_width, FORMAT,',
                    '              *labels, &blk)',
                    '  end',
                    '',
                    '  def each &block',
                    '  end',
                    '',
                    '  def each *args',
                    '  end',
                    ''])
    expect(cop.messages).to be_empty
  end

  it 'accepts splat operator' do
    inspect_source(cop, ['return *list if options'])
    expect(cop.messages).to be_empty
  end

  it 'accepts def of operator' do
    inspect_source(cop, ['def +(other); end',
                         'def self.===(other); end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts an operator at the end of a line' do
    inspect_source(cop,
                   ["['Favor unless over if for negative ' +",
                    " 'conditions.'] * 2"])
    expect(cop.messages).to eq([])
  end

  it 'accepts an assignment with spaces' do
    inspect_source(cop, ['x = 0'])
    expect(cop.offences).to be_empty
  end

  it 'accepts an operator called with method syntax' do
    inspect_source(cop, ['Date.today.+(1).to_s'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for operators without spaces' do
    inspect_source(cop,
                   ['x+= a+b-c*d/e%f^g|h&i||j',
                    'y -=k&&l'])
    expect(cop.messages)
      .to eq(["Surrounding space missing for operator '+='.",
              "Surrounding space missing for operator '+'.",
              "Surrounding space missing for operator '-'.",
              "Surrounding space missing for operator '*'.",
              "Surrounding space missing for operator '/'.",
              "Surrounding space missing for operator '%'.",
              "Surrounding space missing for operator '^'.",
              "Surrounding space missing for operator '|'.",
              "Surrounding space missing for operator '&'.",
              "Surrounding space missing for operator '||'.",
              "Surrounding space missing for operator '-='.",
              "Surrounding space missing for operator '&&'."])
  end

  it 'accepts operators with spaces' do
    inspect_source(cop,
                   ['x += a + b - c * d / e % f ^ g | h & i || j',
                    'y -= k && l'])
    expect(cop.messages).to eq([])
  end

  it "accepts some operators that are exceptions & don't need spaces" do
    inspect_source(cop, ['(1..3)',
                         'ActionController::Base',
                         'each { |s, t| }'])
    expect(cop.messages).to eq([])
  end

  it 'accepts an assignment followed by newline' do
    inspect_source(cop, ['x =', '0'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offences for exponent operator with spaces' do
    inspect_source(cop, ['x = a * b ** 2'])
    expect(cop.messages).to eq(
      ['Space around operator ** detected.'])
  end

  it 'accepts exponent operator without spaces' do
    inspect_source(cop, ['x = a * b**2'])
    expect(cop.offences).to be_empty
  end

  it 'accepts unary operators without space' do
    inspect_source(cop, ['[].map(&:size)',
                         '-3',
                         'x = +2'])
    expect(cop.messages).to eq([])
  end

  it 'accepts argument default values without space' do
    # These are handled by SpaceAroundEqualsInParameterDefault,
    # so SpaceAroundOperators leaves them alone.
    inspect_source(cop,
                   ['def init(name=nil)',
                    'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts the construct class <<self with no space after <<' do
    inspect_source(cop, ['class <<self',
                         'end'])
    expect(cop.messages).to be_empty
  end
end
