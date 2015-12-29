# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::AlignParameters do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/AlignParameters' => cop_config,
                        'Style/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'aligned with first parameter' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_first_parameter'
      }
    end

    it 'registers an offense for parameters with single indent' do
      inspect_source(cop, ['function(a,',
                           '  if b then c else d end)'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['if b then c else d end'])
    end

    it 'registers an offense for parameters with double indent' do
      inspect_source(cop, ['function(a,',
                           '    if b then c else d end)'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts multiline []= method call' do
      inspect_source(cop, ['Test.config["something"] =',
                           ' true'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts correctly aligned parameters' do
      inspect_source(cop, ['function(a,',
                           '         0, 1,',
                           '         (x + y),',
                           '         if b then c else d end)'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts calls that only span one line' do
      inspect_source(cop, 'find(path, s, @special[sexp[0]])')
      expect(cop.offenses).to be_empty
    end

    it "doesn't get confused by a symbol argument" do
      inspect_source(cop, ['add_offense(index,',
                           '            MSG % kind)'])
      expect(cop.offenses).to be_empty
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
      expect(cop.offenses.map(&:to_s))
        .to eq(['C:  5:  6: Align the parameters of a method call if ' \
                'they span more than one line.'])
      expect(cop.highlights).to eq(['*b'])
    end

    it "doesn't get confused by extra comma at the end" do
      inspect_source(cop, ['func1(a,',
                           '     b,)'])
      expect(cop.offenses.map(&:to_s))
        .to eq(['C:  2:  6: Align the parameters of a method call if ' \
                'they span more than one line.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'can handle a correctly aligned string literal as first argument' do
      inspect_source(cop, ['add_offense(x,',
                           '            a)'])
      expect(cop.offenses).to be_empty
    end

    it 'can handle a string literal as other argument' do
      inspect_source(cop, ['add_offense(',
                           '            "", a)'])
      expect(cop.offenses).to be_empty
    end

    it "doesn't get confused by a line break inside a parameter" do
      inspect_source(cop, ['read(path, { headers:    true,',
                           '             converters: :numeric })'])
      expect(cop.offenses).to be_empty
    end

    it "doesn't get confused by symbols with embedded expressions" do
      inspect_source(cop, 'send(:"#{name}_comments_path")')
      expect(cop.offenses).to be_empty
    end

    it "doesn't get confused by regexen with embedded expressions" do
      inspect_source(cop, 'a(/#{name}/)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts braceless hashes' do
      inspect_source(cop, ['run(collection, :entry_name => label,',
                           '                :paginator  => paginator)'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts the first parameter being on a new row' do
      inspect_source(cop, ['  match(',
                           '    a,',
                           '    b',
                           '  )'])
      expect(cop.offenses).to be_empty
    end

    it 'can handle heredoc strings' do
      inspect_source(cop, ['class_eval(<<-EOS, __FILE__, __LINE__ + 1)',
                           '            def run_#{name}_callbacks(*args)',
                           '              a = 1',
                           '              return value',
                           '            end',
                           '            EOS'])
      expect(cop.offenses).to be_empty
    end

    it 'can handle a method call within a method call' do
      inspect_source(cop, ['a(a1,',
                           '  b(b1,',
                           '    b2),',
                           '  a2)'])
      expect(cop.offenses).to be_empty
    end

    it 'can handle a call embedded in a string' do
      inspect_source(cop, 'model("#{index(name)}", child)')
      expect(cop.offenses).to be_empty
    end

    it 'can handle do-end' do
      inspect_source(cop, ['      run(lambda do |e|',
                           "        w = e['warden']",
                           '      end)'])
      expect(cop.offenses).to be_empty
    end

    it 'can handle a call with a block inside another call' do
      src = ['new(table_name,',
             '    exec_query("info(\'#{row[\'name\']}\')").map { |col|',
             "      col['name']",
             '    })']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'can handle a ternary condition with a block reference' do
      inspect_source(cop, 'cond ? a : func(&b)')
      expect(cop.offenses).to be_empty
    end

    it 'can handle parentheses used with no parameters' do
      inspect_source(cop, 'func()')
      expect(cop.offenses).to be_empty
    end

    it 'can handle a multiline hash as second parameter' do
      inspect_source(cop, ['tag(:input, {',
                           '  :value => value',
                           '})'])
      expect(cop.offenses).to be_empty
    end

    it 'can handle method calls without parentheses' do
      inspect_source(cop, 'a(b c, d)')
      expect(cop.offenses).to be_empty
    end

    it 'can handle other method calls without parentheses' do
      src = 'chars(Unicode.apply_mapping @wrapped_string, :uppercase)'
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it "doesn't crash and burn when there are nested issues" do
      # regression test; see GH issue 2441
      src = ['build(:house,',
             '  :rooms => [',
             '    build(:bedroom,',
             '      :bed => build(:bed,',
             '        :occupants => [],',
             '        :size => "king"',
             '      )',
             '    )',
             '  ]',
             ')']
      expect { inspect_source(cop, src) }.not_to raise_error
    end

    context 'method definitions' do
      it 'registers an offense for parameters with single indent' do
        inspect_source(cop, ['def method(a,',
                             '  b)',
                             'end'])
        expect(cop.offenses.size).to eq 1
        expect(cop.offenses.first.to_s).to match(/method definition/)
      end

      it 'registers an offense for parameters with double indent' do
        inspect_source(cop, ['def method(a,',
                             '    b)',
                             'end'])
        expect(cop.offenses.size).to eq 1
      end

      it 'accepts parameter lists on a single line' do
        inspect_source(cop, ['def method(a, b)',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts proper indentation' do
        inspect_source(cop, ['def method(a,',
                             '           b)',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts the first parameter being on a new row' do
        inspect_source(cop, ['def method(',
                             '  a,',
                             '  b)',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a method definition without parameters' do
        inspect_source(cop, ['def method',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it "doesn't get confused by splat" do
        inspect_source(cop, ['def func2(a,',
                             '         *b,',
                             '          c)',
                             'end'])
        expect(cop.offenses.size).to eq 1
        expect(cop.highlights).to eq(['*b'])
      end

      it 'auto-corrects alignment' do
        new_source = autocorrect_source(cop, ['def method(a,',
                                              '    b)',
                                              'end'])
        expect(new_source).to eq(['def method(a,',
                                  '           b)',
                                  'end'].join("\n"))
      end

      context 'defining self.method' do
        it 'registers an offense for parameters with single indent' do
          inspect_source(cop, ['def self.method(a,',
                               '  b)',
                               'end'])
          expect(cop.offenses.size).to eq 1
          expect(cop.offenses.first.to_s).to match(/method definition/)
        end

        it 'accepts proper indentation' do
          inspect_source(cop, ['def self.method(a,',
                               '                b)',
                               'end'])
          expect(cop.offenses).to be_empty
        end

        it 'auto-corrects alignment' do
          new_source = autocorrect_source(cop, ['def self.method(a,',
                                                '    b)',
                                                'end'])
          expect(new_source).to eq(['def self.method(a,',
                                    '                b)',
                                    'end'].join("\n"))
        end
      end
    end

    context 'assigned methods' do
      it 'accepts the first parameter being on a new row' do
        inspect_source(cop, [' assigned_value = match(',
                             '   a,',
                             '   b,',
                             '   c',
                             ' )'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts the first parameter being on method row' do
        inspect_source(cop, [' assigned_value = match(a,',
                             '                        b,',
                             '                        c',
                             '                  )'])
        expect(cop.offenses).to be_empty
      end
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

    it 'does not crash in autocorrect on dynamic string in parameter value' do
      src = ['class MyModel < ActiveRecord::Base',
             '  has_many :other_models,',
             '    class_name: "legacy_name",',
             '    order: "#{legacy_name.table_name}.published DESC"',
             '',
             'end']
      new_source = autocorrect_source(cop, src)
      expect(new_source)
        .to eq ['class MyModel < ActiveRecord::Base',
                '  has_many :other_models,',
                '           class_name: "legacy_name",',
                '           order: "#{legacy_name.table_name}.published DESC"',
                '',
                'end'].join("\n")
    end
  end

  context 'aligned with fixed indentation' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_fixed_indentation'
      }
    end

    let(:correct_source) do
      [
        'create :transaction, :closed,',
        '  account:     account,',
        '  open_price:  1.29,',
        '  close_price: 1.30'
      ]
    end

    it 'does not autocorrect correct source' do
      expect(autocorrect_source(cop, correct_source))
        .to eq(correct_source.join("\n"))
    end

    it 'autocorrects by outdenting when indented too far' do
      original_source = [
        'create :transaction, :closed,',
        '       account:     account,',
        '       open_price:  1.29,',
        '       close_price: 1.30'
      ]

      expect(autocorrect_source(cop, original_source))
        .to eq(correct_source.join("\n"))
    end

    it 'autocorrects by indenting when not indented' do
      original_source = [
        'create :transaction, :closed,',
        'account:     account,',
        'open_price:  1.29,',
        'close_price: 1.30'
      ]

      expect(autocorrect_source(cop, original_source))
        .to eq(correct_source.join("\n"))
    end

    it 'autocorrects when first line is indented' do
      original_source = [
        '  create :transaction, :closed,',
        '  account:     account,',
        '  open_price:  1.29,',
        '  close_price: 1.30'
      ]

      correct_source = [
        '  create :transaction, :closed,',
        '    account:     account,',
        '    open_price:  1.29,',
        '    close_price: 1.30'
      ]

      expect(autocorrect_source(cop, original_source))
        .to eq(correct_source.join("\n"))
    end

    context 'multi-line method calls' do
      it 'can handle existing indentation from multi-line method calls' do
        inspect_source(cop, [' something',
                             '   .method_name(',
                             '     a,',
                             '     b,',
                             '     c',
                             '   )'])
        expect(cop.offenses).to be_empty
      end

      it 'registers offenses for double indentation from relevant method' do
        inspect_source(cop, [' something',
                             '   .method_name(',
                             '       a,',
                             '       b,',
                             '       c',
                             '   )'])
        expect(cop.offenses.size).to eq(3)
      end

      it 'does not err on method call without a method name' do
        inspect_source(cop, [' something',
                             '   .(',
                             '     a,',
                             '     b,',
                             '     c',
                             '   )'])
        expect(cop.offenses).to be_empty
      end

      it 'autocorrects relative to position of relevant method call' do
        original_source = [
          ' something',
          '   .method_name(',
          '       a,',
          '          b,',
          '            c',
          '   )'
        ]
        correct_source = [
          ' something',
          '   .method_name(',
          '     a,',
          '     b,',
          '     c',
          '   )'
        ]
        expect(autocorrect_source(cop, original_source))
          .to eq(correct_source.join("\n"))
      end
    end

    context 'method definitions' do
      it 'registers an offense for parameters aligned to first param' do
        inspect_source(cop, ['def method(a,',
                             '           b)',
                             'end'])
        expect(cop.offenses.size).to eq 1
        expect(cop.offenses.first.to_s).to match(/method definition/)
      end

      it 'registers an offense for parameters with double indent' do
        inspect_source(cop, ['def method(a,',
                             '    b)',
                             'end'])
        expect(cop.offenses.size).to eq 1
      end

      it 'accepts parameter lists on a single line' do
        inspect_source(cop, ['def method(a, b)',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts proper indentation' do
        inspect_source(cop, ['def method(a,',
                             '  b)',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts the first parameter being on a new row' do
        inspect_source(cop, ['def method(',
                             '  a,',
                             '  b)',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a method definition without parameters' do
        inspect_source(cop, ['def method',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it "doesn't get confused by splat" do
        inspect_source(cop, ['def func2(a,',
                             '         *b,',
                             '          c)',
                             'end'])
        expect(cop.offenses).not_to be_empty
        expect(cop.highlights).to include '*b'
      end

      it 'auto-corrects alignment' do
        new_source = autocorrect_source(cop, ['def method(a,',
                                              '    b)',
                                              'end'])
        expect(new_source).to eq(['def method(a,',
                                  '  b)',
                                  'end'].join("\n"))
      end

      context 'defining self.method' do
        it 'registers an offense for parameters aligned to first param' do
          inspect_source(cop, ['def self.method(a,',
                               '                b)',
                               'end'])
          expect(cop.offenses.size).to eq 1
          expect(cop.offenses.first.to_s).to match(/method definition/)
        end

        it 'accepts proper indentation' do
          inspect_source(cop, ['def self.method(a,',
                               '  b)',
                               'end'])
          expect(cop.offenses).to be_empty
        end

        it 'auto-corrects alignment' do
          new_source = autocorrect_source(cop, ['def self.method(a,',
                                                '    b)',
                                                'end'])
          expect(new_source).to eq(['def self.method(a,',
                                    '  b)',
                                    'end'].join("\n"))
        end
      end
    end

    context 'assigned methods' do
      context 'with IndentationWidth:Width set to 4' do
        let(:indentation_width) { 4 }

        it 'accepts the first parameter being on a new row' do
          inspect_source(cop, [' assigned_value = match(',
                               '     a,',
                               '     b,',
                               '     c',
                               ' )'])
          expect(cop.offenses).to be_empty
        end

        it 'accepts the first parameter being on method row' do
          inspect_source(cop, [' assigned_value = match(a,',
                               '     b,',
                               '     c',
                               ' )'])
          expect(cop.offenses).to be_empty
        end

        it 'autocorrects even when first argument is in wrong position' do
          original_source = [' assigned_value = match(',
                             '         a,',
                             '            b,',
                             '                    c',
                             ' )']

          correct_source = [' assigned_value = match(',
                            '     a,',
                            '     b,',
                            '     c',
                            ' )']

          expect(autocorrect_source(cop, original_source))
            .to eq(correct_source.join("\n"))
        end
      end
    end
  end
end
