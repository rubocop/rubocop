# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AlignParameters do
      let (:align) { AlignParameters.new }

      it 'registers an offence for parameters with single indent' do
        align.inspect_source('file.rb', ['function(a,',
                                         '  if b then c else d end)'])
        align.offences.map(&:message).should ==
          ['Align the parameters of a method call if they span more than ' +
           'one line.']
      end

      it 'registers an offence for parameters with double indent' do
        align.inspect_source('file.rb', ['function(a,',
                                         '    if b then c else d end)'])
        align.offences.map(&:message).should ==
          ['Align the parameters of a method call if they span more than ' +
           'one line.']
      end

      it 'accepts correctly aligned parameters' do
        align.inspect_source('file.rb', ['function(a,',
                                         '         0, 1,',
                                         '         (x + y),',
                                         '         if b then c else d end)'])
        align.offences.map(&:message).should == []
      end

      it 'accepts calls that only span one line' do
        align.inspect_source('file.rb', ['find(path, s, @special[sexp[0]])'])
        align.offences.map(&:message).should == []
      end

      it "doesn't get confused by a symbol argument" do
        align.inspect_source('',
                             ['add_offence(:convention, index, source[index],',
                              '            ERROR_MESSAGE % kind)'])
        align.offences.map(&:message).should == []
      end

      it "doesn't get confused by splat operator" do
        align.inspect_source('',
                             ['func1(*a,',
                              '      *b,',
                              '      c)',
                              'func2(a,',
                              '     *b,',
                              '      c)',
                              'func3(*a)',
                             ])
        align.offences.map(&:to_s).should ==
          ['C:  4: Align the parameters of a method call if they span more ' +
           'than one line.']
      end

      it 'can handle a correctly aligned string literal as first argument' do
        align.inspect_source('',
                             ['add_offence("", x,',
                              '            a)'])
        align.offences.map(&:message).should == []
      end

      it 'can handle a string literal as other argument' do
        align.inspect_source('',
                             ['add_offence(x,',
                              '            "", a)'])
        align.offences.map(&:message).should == []
      end

      it "doesn't get confused by a line break inside a parameter" do
        align.inspect_source('',
                             ['read(path, { headers:    true,',
                              '             converters: :numeric })'])
        align.offences.map(&:message).should == []
      end

      it "doesn't get confused by symbols with embedded expressions" do
        align.inspect_source('',
                             ['send(:"#{name}_comments_path")'])
        align.offences.map(&:message).should == []
      end

      it "doesn't get confused by regexen with embedded expressions" do
        align.inspect_source('',
                             ['a(/#{name}/)'])
        align.offences.map(&:message).should == []
      end

      it "accepts braceless hashes" do
        align.inspect_source('',
                             ['run(collection, :entry_name => label,',
                              '                :paginator  => paginator)'])
        align.offences.map(&:message).should == []
      end

      it 'accepts the first parameter being on a new row' do
        align.inspect_source('',
                             ['  match(',
                              '    a,',
                              '    b',
                              '  )'])
        align.offences.map(&:message).should == []
      end

      it 'can handle heredoc strings' do
        src = ['class_eval(<<-EOS, __FILE__, __LINE__ + 1)',
               '  x = 1',
               '  EOS']
        align.inspect_source('', src)
        align.offences.map(&:message).should == []
      end

      it 'can handle a method call within a method call' do
        align.inspect_source('',
                             ['a(a1,',
                              '  b(b1,',
                              '    b2),',
                              '  a2)'])
        align.offences.map(&:message).should == []
      end

      it 'accepts this stuff' do
        align.inspect_source('',
                             ['model("#{index(name)}", child)'])
        align.offences.map(&:message).should == []
      end

      it 'can handle do-end' do
        align.inspect_source('',
                             ['      run(lambda do |e|',
                              "        w = e['warden']",
                              '      end)'])
        align.offences.map(&:message).should == []
      end

      it 'can do this stuff', if: false do
        src = ['new(table_name,',
               "    row['name'],",
               "    row['unique'] != 0,",
               '    exec_query("info(\'#{row[\'name\']}\')").map { |col|',
               "      col['name']",
               '    })']
        puts src
        align.inspect_source('', src)
        align.offences.map(&:message).should == []
      end
    end
  end
end
