# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Blocks do
  subject(:cop) { described_class.new }

  it 'accepts a multiline block with do-end' do
    inspect_source(cop, ['each do |x|',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for a single line block with do-end' do
    inspect_source(cop, 'each do |x| end')
    expect(cop.messages)
      .to eq(['Prefer {...} over do...end for single-line blocks.'])
  end

  it 'accepts a single line block with braces' do
    inspect_source(cop, 'each { |x| }')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects do and end for single line blocks to { and }' do
    new_source = autocorrect_source(cop, 'block do |x| end')
    expect(new_source).to eq('block { |x| }')
  end

  it 'does not auto-correct do-end if {} would change the meaning' do
    src = "s.subspec 'Subspec' do |sp| end"
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(src)
  end

  it 'does not auto-correct {} if do-end would change the meaning' do
    src = ['foo :bar, :baz, qux: lambda { |a|',
           '  bar a',
           '}'].join("\n")
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(src)
  end

  context 'when there are braces around a multi-line block' do
    it 'registers an offense in the simple case' do
      inspect_source(cop, ['each { |x|',
                           '}'])
      expect(cop.messages)
        .to eq(['Avoid using {...} for multi-line blocks.'])
    end

    it 'accepts braces if do-end would change the meaning' do
      src = ['scope :foo, lambda { |f|',
             '  where(condition: "value")',
             '}',
             '',
             'expect { something }.to raise_error(ErrorClass) { |error|',
             '  # ...',
             '}',
             '',
             'expect { x }.to change {',
             '  Counter.count',
             '}.from(0).to(1)']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for braces if do-end would not change ' \
       'the meaning' do
      src = ['scope :foo, (lambda { |f|',
             '  where(condition: "value")',
             '})',
             '',
             'expect { something }.to(raise_error(ErrorClass) { |error|',
             '  # ...',
             '})']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(2)
    end

    it 'can handle special method names such as []= and done?' do
      src = ['h2[k2] = Hash.new { |h3,k3|',
             '  h3[k3] = 0',
             '}',
             '',
             'x = done? list.reject { |e|',
             '  e.nil?',
             '}']
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['Avoid using {...} for multi-line blocks.'])
    end

    it 'auto-corrects { and } to do and end' do
      source = <<-END.strip_indent
        each{ |x|
          some_method
          other_method
        }
      END

      expected_source = <<-END.strip_indent
        each do |x|
          some_method
          other_method
        end
      END

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(expected_source)
    end

    it 'does not auto-correct {} if do-end would introduce a syntax error' do
      src = ['my_method :arg1, arg2: proc {',
             '  something',
             '}, arg3: :another_value'].join("\n")
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end
  end
end
