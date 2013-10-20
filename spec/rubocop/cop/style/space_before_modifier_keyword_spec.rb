# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceBeforeModifierKeyword do
  subject(:cop) { described_class.new }

  it 'registers an offence for missing space before if/unless' do
    inspect_source(cop, ['(a = 3)if a == 2',
                         'a = "test"if a == 2',
                         'a = 42unless a == 2',
                         'a = [1,2,3]unless a == 2',
                         'a = {:a => "b"}if a == 2'])
    expect(cop.highlights).to eq([')', '"', '2', ']', '}'])
  end

  it 'registers an offence for missing space before while/until' do
    inspect_source(cop, ['(a = 3)while b',
                         'a = "test"until b',
                         'a = 42while b',
                         'a = [1,2,3]until b',
                         'a = {:a => "b"}while b'])
    expect(cop.highlights).to eq([')', '"', '2', ']', '}'])
  end

  it 'accepts modifiers with preceding space' do
    inspect_source(cop, ['(a = 3) if b',
                         'a = "test" unless b',
                         'a = 42 while b',
                         'a = [1,2,3] until b'])
    expect(cop.offences).to be_empty
  end

  it 'accepts elsif at beginning of line' do
    inspect_source(cop, ["if RUBY_VERSION.between?('1.9.2', '2.0.0')",
                         "  require 'testing/performance/ruby/yarv'",
                         'elsif RUBY_VERSION.between?("1.8.6", "1.9")',
                         "  require 'testing/performance/ruby/mri'",
                         'end'])
    expect(cop.highlights).to eq([])
  end

  it 'does not crash on ternary conditionals' do
    inspect_source(cop, 'a ? b : c')
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, ['(a = 3)if a == 2',
                                          'a = "test"if a == 2',
                                          'a = 42unless a == 2',
                                          'a = [1,2,3]unless a == 2',
                                          'a = {:a => "b"}if a == 2',
                                          '(a = 3)while b',
                                          'a = "test"until b',
                                          'a = 42while b',
                                          'a = [1,2,3]until b',
                                          'a = {:a => "b"}while b'])
    expect(new_source).to eq(['(a = 3) if a == 2',
                              'a = "test" if a == 2',
                              'a = 42 unless a == 2',
                              'a = [1,2,3] unless a == 2',
                              'a = {:a => "b"} if a == 2',
                              '(a = 3) while b',
                              'a = "test" until b',
                              'a = 42 while b',
                              'a = [1,2,3] until b',
                              'a = {:a => "b"} while b'].join("\n"))
  end
end
