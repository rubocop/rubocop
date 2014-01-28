# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AlignParameters do
  subject(:cop) { described_class.new }

  it 'registers an offence for parameters with single indent' do
    inspect_source(cop, ['function(a,',
                         '  if b then c else d end)'])
    expect(cop.offences.size).to eq(1)
    expect(cop.highlights).to eq(['if b then c else d end'])
  end

  it 'registers an offence for parameters with double indent' do
    inspect_source(cop, ['function(a,',
                         '    if b then c else d end)'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts multiline []= method call' do
    inspect_source(cop, ['Test.config["something"] =',
                         ' true'])
    expect(cop.offences).to be_empty
  end

  it 'accepts correctly aligned parameters' do
    inspect_source(cop, ['function(a,',
                         '         0, 1,',
                         '         (x + y),',
                         '         if b then c else d end)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts calls that only span one line' do
    inspect_source(cop, ['find(path, s, @special[sexp[0]])'])
    expect(cop.offences).to be_empty
  end

  it "doesn't get confused by a symbol argument" do
    inspect_source(cop, ['add_offence(index,',
                         '            MSG % kind)'])
    expect(cop.offences).to be_empty
  end

  it "doesn't get confused by splat operator" do
    inspect_source(cop, ['func1(*a,',
                         '      *b,',
                         '      c)',
                         'func2(a,',
                         '     *b,',
                         '      c)',
                         'func3(*a)'
                        ])
    expect(cop.offences.map(&:to_s))
      .to eq(['C:  5:  6: Align the parameters of a method call if ' \
              'they span more than one line.'])
    expect(cop.highlights).to eq(['*b'])
  end

  it "doesn't get confused by extra comma at the end" do
    inspect_source(cop, ['func1(a,',
                         '     b,)'])
    expect(cop.offences.map(&:to_s))
      .to eq(['C:  2:  6: Align the parameters of a method call if ' \
              'they span more than one line.'])
    expect(cop.highlights).to eq(['b'])
  end

  it 'can handle a correctly aligned string literal as first argument' do
    inspect_source(cop, ['add_offence(x,',
                         '            a)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle a string literal as other argument' do
    inspect_source(cop, ['add_offence(',
                         '            "", a)'])
    expect(cop.offences).to be_empty
  end

  it "doesn't get confused by a line break inside a parameter" do
    inspect_source(cop, ['read(path, { headers:    true,',
                         '             converters: :numeric })'])
    expect(cop.offences).to be_empty
  end

  it "doesn't get confused by symbols with embedded expressions" do
    inspect_source(cop, ['send(:"#{name}_comments_path")'])
    expect(cop.offences).to be_empty
  end

  it "doesn't get confused by regexen with embedded expressions" do
    inspect_source(cop, ['a(/#{name}/)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts braceless hashes' do
    inspect_source(cop, ['run(collection, :entry_name => label,',
                         '                :paginator  => paginator)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts the first parameter being on a new row' do
    inspect_source(cop, ['  match(',
                         '    a,',
                         '    b',
                         '  )'])
    expect(cop.offences).to be_empty
  end

  it 'can handle heredoc strings' do
    inspect_source(cop, ['class_eval(<<-EOS, __FILE__, __LINE__ + 1)',
                         '            def run_#{name}_callbacks(*args)',
                         '              a = 1',
                         '              return value',
                         '            end',
                         '            EOS'])
    expect(cop.offences).to be_empty
  end

  it 'can handle a method call within a method call' do
    inspect_source(cop, ['a(a1,',
                         '  b(b1,',
                         '    b2),',
                         '  a2)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle a call embedded in a string' do
    inspect_source(cop, ['model("#{index(name)}", child)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle do-end' do
    inspect_source(cop, ['      run(lambda do |e|',
                         "        w = e['warden']",
                         '      end)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle a call with a block inside another call' do
    src = ['new(table_name,',
           '    exec_query("info(\'#{row[\'name\']}\')").map { |col|',
           "      col['name']",
           '    })']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'can handle a ternary condition with a block reference' do
    inspect_source(cop, ['cond ? a : func(&b)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle parentheses used with no parameters' do
    inspect_source(cop, ['func()'])
    expect(cop.offences).to be_empty
  end

  it 'can handle a multiline hash as second parameter' do
    inspect_source(cop, ['tag(:input, {',
                         '  :value => value',
                         '})'])
    expect(cop.offences).to be_empty
  end

  it 'can handle method calls without parentheses' do
    inspect_source(cop, ['a(b c, d)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle other method calls without parentheses' do
    src = ['chars(Unicode.apply_mapping @wrapped_string, :uppercase)']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects alignment' do
    new_source = autocorrect_source(cop, ['func(a,',
                                          '       b,',
                                          'c)'])
    expect(new_source).to eq(['func(a,',
                              '     b,',
                              '     c)'].join("\n"))
  end

  it 'auto-corrects each line of a multi-line parameter to the right' do
    new_source =
      autocorrect_source(cop,
                         ['create :transaction, :closed,',
                          '      account:          account,',
                          '      open_price:       1.29,',
                          '      close_price:      1.30'])
    expect(new_source)
      .to eq(['create :transaction, :closed,',
              '       account:          account,',
              '       open_price:       1.29,',
              '       close_price:      1.30'].join("\n"))
  end

  it 'auto-corrects each line of a multi-line parameter to the left' do
    new_source =
      autocorrect_source(cop,
                         ['create :transaction, :closed,',
                          '         account:          account,',
                          '         open_price:       1.29,',
                          '         close_price:      1.30'])
    expect(new_source)
      .to eq(['create :transaction, :closed,',
              '       account:          account,',
              '       open_price:       1.29,',
              '       close_price:      1.30'].join("\n"))
  end

  it 'auto-corrects only parameters that begin a line' do
    original_source = ['foo(:bar, {',
                       '    whiz: 2, bang: 3 }, option: 3)']
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(original_source.join("\n"))
  end
end
