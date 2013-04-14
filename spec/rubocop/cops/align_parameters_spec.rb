# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AlignParameters do
      let(:align) { AlignParameters.new }

      it 'registers an offence for parameters with single indent' do
        inspect_source(align, 'file.rb', ['function(a,',
                                          '  if b then c else d end)'])
        expect(align.offences.map(&:message)).to eq(
          ['Align the parameters of a method call if they span more than ' +
           'one line.'])
      end

      it 'registers an offence for parameters with double indent' do
        inspect_source(align, 'file.rb', ['function(a,',
                                          '    if b then c else d end)'])
        expect(align.offences.map(&:message)).to eq(
          ['Align the parameters of a method call if they span more than ' +
           'one line.'])
      end

      it 'accepts correctly aligned parameters' do
        inspect_source(align, 'file.rb', ['function(a,',
                                          '         0, 1,',
                                          '         (x + y),',
                                          '         if b then c else d end)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'accepts calls that only span one line' do
        inspect_source(align, 'file.rb', ['find(path, s, @special[sexp[0]])'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it "doesn't get confused by a symbol argument" do
        inspect_source(align, '',
                       ['add_offence(:convention, index,',
                        '            ERROR_MESSAGE % kind)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it "doesn't get confused by splat operator" do
        inspect_source(align, '',
                       ['func1(*a,',
                        '      *b,',
                        '      c)',
                        'func2(a,',
                        '     *b,',
                        '      c)',
                        'func3(*a)',
                       ])
        expect(align.offences.map(&:to_s)).to eq(
          ['C:  5: Align the parameters of a method call if they span ' +
           'more than one line.'])
      end

      it "doesn't get confused by extra comma at the end" do
        inspect_source(align, '',
                       ['func1(a,',
                        '     b,)'])
        expect(align.offences.map(&:to_s)).to eq(
          ['C:  2: Align the parameters of a method call if they span ' +
           'more than one line.'])
      end

      it 'can handle a correctly aligned string literal as first argument' do
        inspect_source(align, '',
                       ['add_offence(:convention, x,',
                        '            a)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a string literal as other argument' do
        inspect_source(align, '',
                       ['add_offence(:convention,',
                        '            "", a)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it "doesn't get confused by a line break inside a parameter" do
        inspect_source(align, '',
                       ['read(path, { headers:    true,',
                        '             converters: :numeric })'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it "doesn't get confused by symbols with embedded expressions" do
        inspect_source(align, '',
                       ['send(:"#{name}_comments_path")'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it "doesn't get confused by regexen with embedded expressions" do
        inspect_source(align, '',
                       ['a(/#{name}/)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'accepts braceless hashes' do
        inspect_source(align, '',
                       ['run(collection, :entry_name => label,',
                        '                :paginator  => paginator)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'accepts the first parameter being on a new row' do
        inspect_source(align, '',
                       ['  match(',
                        '    a,',
                        '    b',
                        '  )'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle heredoc strings' do
        src = ['class_eval(<<-EOS, __FILE__, __LINE__ + 1)',
               '            def run_#{name}_callbacks(*args)',
               '              a = 1',
               '              return value',
               '            end',
               '            EOS']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a method call within a method call' do
        inspect_source(align, '',
                       ['a(a1,',
                        '  b(b1,',
                        '    b2),',
                        '  a2)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a call embedded in a string' do
        inspect_source(align, '',
                       ['model("#{index(name)}", child)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle do-end' do
        inspect_source(align, '',
                       ['      run(lambda do |e|',
                        "        w = e['warden']",
                        '      end)'])
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a call with a block inside another call' do
        src = ['new(table_name,',
               '    exec_query("info(\'#{row[\'name\']}\')").map { |col|',
               "      col['name']",
               '    })']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a ternary condition with a block reference' do
        src = ['cond ? a : func(&b)']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle parentheses used with no parameters' do
        src = ['func()']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a multiline hash as first parameter' do
        src = ['assert_equal({',
               '  :space_before => "",',
               '}, state)']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle a multiline hash as second parameter' do
        src = ['tag(:input, {',
               '  :value => value',
               '})']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle method calls without parentheses' do
        src = ['a(b c, d)']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it 'can handle other method calls without parentheses' do
        src = ['chars(Unicode.apply_mapping @wrapped_string, :uppercase)']
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end

      it "doesn't check alignment if tabs are used to indent" do
        src = ['a(b,',
               "\tc)"]
        inspect_source(align, '', src)
        expect(align.offences.map(&:message)).to be_empty
      end
    end
  end
end
