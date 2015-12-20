# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::ConditionalAssignment do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/ConditionalAssignment' => {
                          'Enabled' => true
                        },
                        'Metrics/LineLength' => {
                          'Max' => 80,
                          'Enabled' => true
                        })
  end

  it 'allows if else without variable assignment' do
    source = ['if foo',
              '  1',
              'else',
              '  2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows assignment to the result of a ternary operation' do
    source = 'bar = foo? ? "a" : "b"'
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows modifier if' do
    inspect_source(cop, 'return if a == 1')

    expect(cop.messages).to be_empty
  end

  it 'allows modifier if inside of if else' do
    source = ['if foo',
              '  a unless b',
              'else',
              '  c unless d',
              'end']

    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  context 'empty branch' do
    it 'allows an empty if statement' do
      source = ['if foo',
                '  # comment',
                'else',
                '  do_something',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows an empty elsif statement' do
      source = ['if foo',
                '  bar = 1',
                'elsif baz',
                '  # empty',
                'else',
                '  bar = 2',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows if elsif without else' do
      source = ['if foo',
                "  bar = 'some string'",
                'elsif bar',
                "  bar = 'another string'",
                'end']

      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows assignment in if without an else' do
      source = ['if foo',
                '  bar = 1',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows assignment in unless without an else' do
      source = ['unless foo',
                '  bar = 1',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows assignment in case when without an else' do
      source = ['case foo',
                'when "a"',
                '  bar = 1',
                'when "b"',
                '  bar = 2',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows an empty when branch with an else' do
      source = ['case foo',
                'when "a"',
                '  # empty',
                'when "b"',
                '  bar = 2',
                'else',
                '  bar = 3',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows case with an empty else' do
      source = ['case foo',
                'when "b"',
                '  bar = 2',
                'else',
                '  # empty',
                'end']
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end
  end

  it 'allows assignment of different variables in if else' do
    source = ['if foo',
              '  bar = 1',
              'else',
              '  baz = 1',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows method calls in if else' do
    source = ['if foo',
              '  bar',
              'else',
              '  baz',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows if elsif else with the same assignment only in if else' do
    source = ['if foo',
              '  bar = 1',
              'elsif foobar',
              '  baz = 2',
              'else',
              '  bar = 1',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows if elsif else with the same assignment only in if elsif' do
    source = ['if foo',
              '  bar = 1',
              'elsif foobar',
              '  bar = 2',
              'else',
              '  baz = 1',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows if elsif else with the same assignment only in elsif else' do
    source = ['if foo',
              '  bar = 1',
              'elsif foobar',
              '  baz = 2',
              'else',
              '  baz = 1',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows assignment using different operators in if else' do
    source = ['if foo',
              '  bar = 1',
              'else',
              '  bar << 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows assignment using different (method) operators in if..else' do
    source = ['if foo',
              '  bar[index] = 1',
              'else',
              '  bar << 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows aref assignment with different indices in if..else' do
    source = ['if foo',
              '  bar[1] = 1',
              'else',
              '  bar[2] = 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows assignment using different operators in if elsif else' do
    source = ['if foo',
              '  bar = 1',
              'elsif foobar',
              '  bar += 2',
              'else',
              '  bar << 3',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  it 'allows assignment of different variables in case when else' do
    source = ['case foo',
              'when "a"',
              '  bar = 1',
              'else',
              '  baz = 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  context 'correction would exceed max line length' do
    it 'allows assignment to the same variable in if else if the ' \
       'correction would create a line longer than the configured LineLength' do
      source = ['if foo',
                "  #{'a' * 78}",
                '  bar = 1',
                'else',
                '  bar = 2',
                'end']

      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end

    it 'allows assignment to the same variable in case when else if the ' \
       'correction would create a line longer than the configured LineLength' do
      source = ['case foo',
                'when foobar',
                "  #{'a' * 78}",
                '  bar = 1',
                'else',
                '  bar = 2',
                'end']

      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end
  end

  shared_examples 'all variable types' do |variable|
    it 'registers an offense assigning any variable type in if else' do
      source = ['if foo',
                "  #{variable} = 1",
                'else',
                "  #{variable} = 2",
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end

    it 'registers an offense assigning any variable type in case when' do
      source = ['case foo',
                'when "a"',
                "  #{variable} = 1",
                'else',
                "  #{variable} = 2",
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end
  end

  it_behaves_like('all variable types', 'bar')
  it_behaves_like('all variable types', 'BAR')
  it_behaves_like('all variable types', '@bar')
  it_behaves_like('all variable types', '@@bar')
  it_behaves_like('all variable types', '$BAR')

  shared_examples 'all assignment types' do |assignment|
    it "registers and offense for assignment using #{assignment} in if else" do
      source = ['if foo',
                "  bar #{assignment} 1",
                'else',
                "  bar #{assignment} 2",
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end

    it "registers an offense for assignment using #{assignment} in case when" do
      source = ['case foo',
                'when "a"',
                "  bar #{assignment} 1",
                'else',
                "  bar #{assignment} 2",
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end
  end

  it_behaves_like('all assignment types', '=')
  it_behaves_like('all assignment types', '||=')
  it_behaves_like('all assignment types', '&&=')
  it_behaves_like('all assignment types', '+=')
  it_behaves_like('all assignment types', '<<')
  it_behaves_like('all assignment types', '-=')

  it 'registers an offense for assignment in if elsif else' do
    source = ['if foo',
              '  bar = 1',
              'elsif baz',
              '  bar = 2',
              'else',
              '  bar = 3',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  it 'registers an offense for assignment in if elsif else' do
    source = ['if foo',
              '  bar = 1',
              'elsif baz',
              '  bar = 2',
              'elsif foobar',
              '  bar = 3',
              'else',
              '  bar = 4',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  context 'assignment as the last statement' do
    it 'registers an offense in if else with more than variable assignment' do
      source = ['if foo',
                '  method_call',
                '  bar = 1',
                'else',
                '  method_call',
                '  bar = 2',
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end

    it 'registers an offense in if elsif else with more than ' \
       'variable assignment' do
      source = ['if foo',
                '  method_call',
                '  bar = 1',
                'elsif foobar',
                '  method_call',
                '  bar = 2',
                'else',
                '  method_call',
                '  bar = 3',
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end

    it 'registers an offense in if elsif else with some branches only ' \
        'containing variable assignment and others containing more than ' \
        'variable assignment' do
      source = ['if foo',
                '  bar = 1',
                'elsif foobar',
                '  method_call',
                '  bar = 2',
                'elsif baz',
                '  bar = 3',
                'else',
                '  method_call',
                '  bar = 4',
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end

    it 'registers an offense in unless else with more than ' \
       'variable assignment' do
      source = ['unless foo',
                '  method_call',
                '  bar = 1',
                'else',
                '  method_call',
                '  bar = 2',
                'end']
      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end

    it 'registers an offense in case when else with more than ' \
       'variable assignment' do
      source = ['case foo',
                'when foobar',
                '  method_call',
                '  bar = 1',
                'else',
                '  method_call',
                '  bar = 2',
                'end']

      inspect_source(cop, source)

      expect(cop.messages)
        .to eq(['Use the return of the conditional for variable assignment.'])
    end
  end

  it 'registers an offense for assignment in if then else' do
    source = ['if foo then bar = 1',
              'else bar = 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  it 'registers an offense for assignment in if elsif else' do
    source = ['if foo',
              '  bar = 1',
              'elsif foobar',
              '  bar = 2',
              'elsif baz',
              '  bar = 3',
              'else',
              '  bar = 4',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  it 'registers an offense for assignment in unless else' do
    source = ['unless foo',
              '  bar = 1',
              'else',
              '  bar = 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  it 'registers an offense for assignment in case when then else' do
    source = ['case foo',
              'when bar then baz = 1',
              'else baz = 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  it 'registers an offense for assignment in case with when when else' do
    source = ['case foo',
              'when foobar',
              '  bar = 1',
              'when baz',
              '  bar = 2',
              'else',
              '  bar = 3',
              'end']
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use the return of the conditional for variable assignment.'])
  end

  it 'allows different assignment types in case with when when else' do
    source = ['case foo',
              'when foobar',
              '  bar = 1',
              'else',
              '  bar << 2',
              'end']
    inspect_source(cop, source)

    expect(cop.messages).to be_empty
  end

  context 'auto-correct' do
    it 'corrects assignment in if else' do
      source = ['if foo',
                '  bar = 1',
                'else',
                '  bar = 2',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['bar = if foo',
                                '  1',
                                'else',
                                '  2',
                                'end'].join("\n"))
    end

    it 'corrects assignment in if elsif else' do
      source = ['if foo',
                '  bar = 1',
                'elsif baz',
                '  bar = 2',
                'else',
                '  bar = 3',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['bar = if foo',
                                '  1',
                                'elsif baz',
                                '  2',
                                'else',
                                '  3',
                                'end'].join("\n"))
    end

    shared_examples '2 character assignment types' do |asgn|
      it "corrects assignment using #{asgn} in if elsif else" do
        source = ['if foo',
                  "  bar #{asgn} 1",
                  'elsif baz',
                  "  bar #{asgn} 2",
                  'else',
                  "  bar #{asgn} 3",
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(["bar #{asgn} if foo",
                                  '  1',
                                  'elsif baz',
                                  '  2',
                                  'else',
                                  '  3',
                                  'end'].join("\n"))
      end

      it "corrects assignment using #{asgn} in case when else" do
        source = ['case foo',
                  'when bar',
                  "  baz #{asgn} 1",
                  'else',
                  "  baz #{asgn} 2",
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(["baz #{asgn} case foo",
                                  'when bar',
                                  '  1',
                                  'else',
                                  '  2',
                                  'end'].join("\n"))
      end

      it "corrects assignment using #{asgn} in unless else" do
        source = ['unless foo',
                  "  bar #{asgn} 1",
                  'else',
                  "  bar #{asgn} 2",
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(["bar #{asgn} unless foo",
                                  '  1',
                                  'else',
                                  '  2',
                                  'end'].join("\n"))
      end
    end

    it_behaves_like('2 character assignment types', '+=')
    it_behaves_like('2 character assignment types', '-=')
    it_behaves_like('2 character assignment types', '<<')

    shared_examples '3 character assignment types' do |asgn|
      it "corrects assignment using #{asgn} in if elsif else" do
        source = ['if foo',
                  "  bar #{asgn} 1",
                  'elsif baz',
                  "  bar #{asgn} 2",
                  'else',
                  "  bar #{asgn} 3",
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(["bar #{asgn} if foo",
                                  '  1',
                                  'elsif baz',
                                  '  2',
                                  'else',
                                  '  3',
                                  'end'].join("\n"))
      end

      it "corrects assignment using #{asgn} in case when else" do
        source = ['case foo',
                  'when bar',
                  "  baz #{asgn} 1",
                  'else',
                  "  baz #{asgn} 2",
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(["baz #{asgn} case foo",
                                  'when bar',
                                  '  1',
                                  'else',
                                  '  2',
                                  'end'].join("\n"))
      end

      it "corrects assignment using #{asgn} in unless else" do
        source = ['unless foo',
                  "  bar #{asgn} 1",
                  'else',
                  "  bar #{asgn} 2",
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(["bar #{asgn} unless foo",
                                  '  1',
                                  'else',
                                  '  2',
                                  'end'].join("\n"))
      end
    end

    it_behaves_like('3 character assignment types', '&&=')
    it_behaves_like('3 character assignment types', '||=')

    it 'corrects assignment in if elsif else with multiple elsifs' do
      source = ['if foo',
                '  bar = 1',
                'elsif baz',
                '  bar = 2',
                'elsif foobar',
                '  bar = 3',
                'else',
                '  bar = 4',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['bar = if foo',
                                '  1',
                                'elsif baz',
                                '  2',
                                'elsif foobar',
                                '  3',
                                'else',
                                '  4',
                                'end'].join("\n"))
    end

    it 'corrects assignment in unless else' do
      source = ['unless foo',
                '  bar = 1',
                'else',
                '  bar = 2',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['bar = unless foo',
                                '  1',
                                'else',
                                '  2',
                                'end'].join("\n"))
    end

    it 'corrects assignment in case when else' do
      source = ['case foo',
                'when bar',
                '  baz = 1',
                'else',
                '  baz = 2',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['baz = case foo',
                                'when bar',
                                '  1',
                                'else',
                                '  2',
                                'end'].join("\n"))
    end

    it 'corrects assignment in case when else with multiple whens' do
      source = ['case foo',
                'when bar',
                '  baz = 1',
                'when foobar',
                '  baz = 2',
                'else',
                '  baz = 3',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['baz = case foo',
                                'when bar',
                                '  1',
                                'when foobar',
                                '  2',
                                'else',
                                '  3',
                                'end'].join("\n"))
    end

    context 'assignment from a method' do
      it 'corrects if else' do
        source = ['if foo?(scope.node)',
                  '  bar << foobar(var, all)',
                  'else',
                  '  bar << baz(var, all)',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar << if foo?(scope.node)',
                                  '  foobar(var, all)',
                                  'else',
                                  '  baz(var, all)',
                                  'end'].join("\n"))
      end

      it 'corrects unless else' do
        source = ['unless foo?(scope.node)',
                  '  bar << foobar(var, all)',
                  'else',
                  '  bar << baz(var, all)',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar << unless foo?(scope.node)',
                                  '  foobar(var, all)',
                                  'else',
                                  '  baz(var, all)',
                                  'end'].join("\n"))
      end

      it 'corrects case when' do
        source = ['case foo',
                  'when foobar',
                  '  bar << foobar(var, all)',
                  'else',
                  '  bar << baz(var, all)',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar << case foo',
                                  'when foobar',
                                  '  foobar(var, all)',
                                  'else',
                                  '  baz(var, all)',
                                  'end'].join("\n"))
      end
    end

    context 'then' do
      it 'corrects if then elsif then else' do
        source = ['if cond then bar = 1',
                  'elsif cond then bar = 2',
                  'else bar = 3',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar = if cond then 1',
                                  'elsif cond then 2',
                                  'else 3',
                                  'end'].join("\n"))
      end

      it 'corrects case when then else' do
        source = ['case foo',
                  'when baz then bar = 1',
                  'else bar = 2',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar = case foo',
                                  'when baz then 1',
                                  'else 2',
                                  'end'].join("\n"))
      end
    end

    it 'preserves comments during correction in if else' do
      source = ['if foo',
                '  # comment in if',
                '  bar = 1',
                'else',
                '  # comment in else',
                '  bar = 2',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['bar = if foo',
                                '  # comment in if',
                                '  1',
                                'else',
                                '  # comment in else',
                                '  2',
                                'end'].join("\n"))
    end

    it 'preserves comments during correction in case when else' do
      source = ['case foo',
                'when foobar',
                '  # comment in when',
                '  bar = 1',
                'else',
                '  # comment in else',
                '  bar = 2',
                'end']

      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['bar = case foo',
                                'when foobar',
                                '  # comment in when',
                                '  1',
                                'else',
                                '  # comment in else',
                                '  2',
                                'end'].join("\n"))
    end

    context 'assignment as the last statement' do
      it 'preserves all code before the variable assignment in a branch' do
        source = ['if foo',
                  '  # comment in if',
                  '  method_call',
                  '  bar = 1',
                  'elsif foobar',
                  '  method_call',
                  '  bar = 2',
                  'elsif baz',
                  '  bar = 3',
                  'else',
                  '  bar = 4',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar = if foo',
                                  '  # comment in if',
                                  '  method_call',
                                  '  1',
                                  'elsif foobar',
                                  '  method_call',
                                  '  2',
                                  'elsif baz',
                                  '  3',
                                  'else',
                                  '  4',
                                  'end'].join("\n"))
      end

      it 'preserves all code before variable assignment in unless else' do
        source = ['unless foo',
                  '  method_call',
                  '  bar = 1',
                  'else',
                  '  method_call',
                  '  bar = 2',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar = unless foo',
                                  '  method_call',
                                  '  1',
                                  'else',
                                  '  method_call',
                                  '  2',
                                  'end'].join("\n"))
      end

      it 'preserves all code before varialbe assignment in case when else' do
        source = ['case foo',
                  'when foobar',
                  '  method_call',
                  '  bar = 1',
                  'when baz',
                  '  # comment in when',
                  '  bar = 2',
                  'else',
                  '  method_call',
                  '  bar = 3',
                  'end']

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(['bar = case foo',
                                  'when foobar',
                                  '  method_call',
                                  '  1',
                                  'when baz',
                                  '  # comment in when',
                                  '  2',
                                  'else',
                                  '  method_call',
                                  '  3',
                                  'end'].join("\n"))
      end

      context 'aref assignment' do
        it 'corrects if..else' do
          new_source = autocorrect_source(cop, ['if something',
                                                '  array[1] = 1',
                                                'else',
                                                '  array[1] = 2',
                                                'end'])
          expect(new_source).to eq(['array[1] = if something',
                                    '  1',
                                    'else',
                                    '  2',
                                    'end'].join("\n"))
        end

        context 'with different indices' do
          it "doesn't register an offense" do
            inspect_source(cop, ['if something',
                                 '  array[1, 2] = 1',
                                 'else',
                                 '  array[1, 3] = 2',
                                 'end'])
            expect(cop.offenses).to be_empty
          end
        end
      end

      context 'self.attribute= assignment' do
        it 'corrects if..else' do
          new_source = autocorrect_source(cop, ['if something',
                                                '  self.attribute = 1',
                                                'else',
                                                '  self.attribute = 2',
                                                'end'])
          expect(new_source).to eq(['self.attribute = if something',
                                    '  1',
                                    'else',
                                    '  2',
                                    'end'].join("\n"))
        end

        context 'with different receivers' do
          it "doesn't register an offense" do
            inspect_source(cop, ['if something',
                                 '  obj1.attribute = 1',
                                 'else',
                                 '  obj2.attribute = 2',
                                 'end'])
            expect(cop.offenses).to be_empty
          end
        end
      end

      context 'multiple assignment' do
        it "doesn't register an offense" do
          inspect_source(cop, ['if something',
                               '  a, b = 1, 2',
                               'else',
                               '  a, b = 2, 1',
                               'end'])
          expect(cop.offenses).to be_empty
        end
      end
    end
  end
end
