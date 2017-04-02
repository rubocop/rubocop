# frozen_string_literal: true

describe RuboCop::Cop::Lint::UselessAssignment do
  subject(:cop) { described_class.new }

  context 'when a variable is assigned and unreferenced in a method' do
    let(:source) do
      [
        'class SomeClass',
        '  foo = 1',
        '  puts foo',
        '  def some_method',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced ' \
          'in a singleton method defined with self keyword' do
    let(:source) do
      [
        'class SomeClass',
        '  foo = 1',
        '  puts foo',
        '  def self.some_method',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced ' \
          'in a singleton method defined with variable name' do
    let(:source) do
      [
        '1.times do',
        '  foo = 1',
        '  puts foo',
        '  instance = Object.new',
        '  def instance.some_method',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced in a class' do
    let(:source) do
      [
        '1.times do',
        '  foo = 1',
        '  puts foo',
        '  class SomeClass',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced in a class ' \
          'subclassing another class stored in local variable' do
    let(:source) do
      [
        '1.times do',
        '  foo = 1',
        '  puts foo',
        '  array_class = Array',
        '  class SomeClass < array_class',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced ' \
          'in a singleton class' do
    let(:source) do
      [
        '1.times do',
        '  foo = 1',
        '  puts foo',
        '  instance = Object.new',
        '  class << instance',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced in a module' do
    let(:source) do
      [
        '1.times do',
        '  foo = 1',
        '  puts foo',
        '  module SomeModule',
        '    foo = 2',
        '    bar = 3',
        '    puts bar',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned and unreferenced in top level' do
    let(:source) do
      [
        'foo = 1',
        'bar = 2',
        'puts bar'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned with operator assignment ' \
          'in top level' do
    let(:source) do
      'foo ||= 1'
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to eq(
        'Useless assignment to variable - `foo`. Use `||` instead of `||=`.'
      )
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned multiple times ' \
          'but unreferenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  bar = 2',
        '  foo = 3',
        '  puts bar',
        'end'
      ]
    end

    it 'registers offenses for each assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(2)

      expect(cop.offenses[0].message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses[0].line).to eq(2)

      expect(cop.offenses[1].message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses[1].line).to eq(4)

      expect(cop.highlights).to eq(%w[foo foo])
    end
  end

  context 'when a referenced variable is reassigned ' \
          'but not re-referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  puts foo',
        '  foo = 3',
        'end'
      ]
    end

    it 'registers an offense for the non-re-referenced assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(4)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when an unreferenced variable is reassigned ' \
          'and re-referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  foo = 3',
        '  puts foo',
        'end'
      ]
    end

    it 'registers an offense for the unreferenced assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when an unreferenced variable is reassigned in a block' do
    let(:source) do
      [
        'def const_name(node)',
        '  const_names = []',
        '  const_node = node',
        '',
        '  loop do',
        '    namespace_node, name = *const_node',
        '    const_names << name',
        '    break unless namespace_node',
        '    break if namespace_node.type == :cbase',
        '    const_node = namespace_node',
        '  end',
        '',
        "  const_names.reverse.join('::')",
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a referenced variable is reassigned in a block' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  puts foo',
        '  1.times do',
        '    foo = 2',
        '  end',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a block local variable is declared but not assigned' do
    let(:source) do
      [
        '1.times do |i; foo|',
        'end'
      ]
    end

    include_examples 'accepts'
  end

  context 'when a block local variable is assigned and unreferenced' do
    let(:source) do
      [
        '1.times do |i; foo|',
        '  foo = 2',
        'end'
      ]
    end

    it 'registers offenses for the assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned in loop body and unreferenced' do
    let(:source) do
      [
        'def some_method',
        '  while true',
        '    foo = 1',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned at the end of loop body ' \
          'and would be referenced in next iteration' do
    let(:source) do
      [
        'def some_method',
        '  total = 0',
        '  foo = 0',
        '',
        '  while total < 100',
        '    total += foo',
        '    foo += 1',
        '  end',
        '',
        '  total',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned at the end of loop body ' \
          'and would be referenced in loop condition' do
    let(:source) do
      [
        'def some_method',
        '  total = 0',
        '  foo = 0',
        '',
        '  while foo < 100',
        '    total += 1',
        '    foo += 1',
        '  end',
        '',
        '  total',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a setter is invoked with operator assignment in loop body' do
    let(:source) do
      [
        'def some_method',
        '  obj = {}',
        '',
        '  while obj[:count] < 100',
        '    obj[:count] += 1',
        '  end',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context "when a variable is reassigned in loop body but won't " \
          'be referenced either next iteration or loop condition' do
    let(:source) do
      [
        'def some_method',
        '  total = 0',
        '  foo = 0',
        '',
        '  while total < 100',
        '    total += 1',
        '    foo += 1',
        '  end',
        '',
        '  total',
        'end'
      ]
    end

    it 'registers an offense' do
      pending 'Requires an advanced logic that checks whether the return ' \
              'value of an operator assignment is used or not.'
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(7)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a referenced variable is reassigned ' \
          'but not re-referenced in a method defined in loop' do
    let(:source) do
      [
        'while true',
        '  def some_method',
        '    foo = 1',
        '    puts foo',
        '    foo = 3',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable that has same name as outer scope variable ' \
          'is not referenced in a method defined in loop' do
    let(:source) do
      [
        'foo = 1',
        '',
        'while foo < 100',
        '  foo += 1',
        '  def some_method',
        '    foo = 1',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned in single branch if ' \
          'and unreferenced' do
    let(:source) do
      [
        'def some_method(flag)',
        '  if flag',
        '    foo = 1',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a unreferenced variable is reassigned in same branch ' \
          'and referenced after the branching' do
    let(:source) do
      [
        'def some_method(flag)',
        '  if flag',
        '    foo = 1',
        '    foo = 2',
        '  end',
        '',
        '  foo',
        'end'
      ]
    end

    it 'registers an offense for the unreferenced assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is reassigned in single branch if ' \
          'and referenced after the branching' do
    let(:source) do
      [
        'def some_method(flag)',
        '  foo = 1',
        '',
        '  if flag',
        '    foo = 2',
        '  end',
        '',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned in a loop' do
    context 'while loop' do
      let(:source) do
        [
          'def while(param)',
          '  ret = 1',
          '',
          '  while param != 10',
          '    param += 2',
          '    ret = param + 1',
          '  end',
          '',
          '  ret',
          'end'
        ]
      end

      include_examples 'accepts'
    end

    context 'post while loop' do
      let(:source) do
        [
          'def post_while(param)',
          '  ret = 1',
          '',
          '  begin',
          '    param += 2',
          '    ret = param + 1',
          '  end while param < 40',
          '',
          '  ret',
          'end'
        ]
      end

      include_examples 'accepts'
    end

    context 'until loop' do
      let(:source) do
        [
          'def until(param)',
          '  ret = 1',
          '',
          '  until param == 10',
          '    param += 2',
          '    ret = param + 1',
          '  end',
          '',
          '  ret',
          'end'
        ]
      end

      include_examples 'accepts'
    end

    context 'post until loop' do
      let(:source) do
        [
          'def post_until(param)',
          '  ret = 1',
          '',
          '  begin',
          '    param += 2',
          '    ret = param + 1',
          '  end until param == 10',
          '',
          '  ret',
          'end'
        ]
      end

      include_examples 'accepts'
    end

    context 'for loop' do
      let(:source) do
        [
          'def for(param)',
          '  ret = 1',
          '',
          '  for x in param...10',
          '    param += x',
          '    ret = param + 1',
          '  end',
          '',
          '  ret',
          'end'
        ]
      end

      include_examples 'accepts'
    end
  end

  context 'when a variable is assigned in each branch of if ' \
          'and referenced after the branching' do
    let(:source) do
      [
        'def some_method(flag)',
        '  if flag',
        '    foo = 2',
        '  else',
        '    foo = 3',
        '  end',
        '',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned in single branch if ' \
          'and referenced in the branch' do
    let(:source) do
      [
        'def some_method(flag)',
        '  foo = 1',
        '',
        '  if flag',
        '    foo = 2',
        '    puts foo',
        '  end',
        'end'
      ]
    end

    it 'registers an offense for the unreferenced assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned in each branch of if ' \
          'and referenced in the else branch' do
    let(:source) do
      [
        'def some_method(flag)',
        '  if flag',
        '    foo = 2',
        '  else',
        '    foo = 3',
        '    puts foo',
        '  end',
        'end'
      ]
    end

    it 'registers an offense for the assignment in the if branch' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is reassigned and unreferenced in a if branch ' \
          'while the variable is referenced in the paired else branch ' do
    let(:source) do
      [
        'def some_method(flag)',
        '  foo = 1',
        '',
        '  if flag',
        '    puts foo',
        '    foo = 2',
        '  else',
        '    puts foo',
        '  end',
        'end'
      ]
    end

    it 'registers an offense for the reassignment in the if branch' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context "when there's an unreferenced assignment in top level if branch " \
          'while the variable is referenced in the paired else branch' do
    let(:source) do
      [
        'if flag',
        '  foo = 1',
        'else',
        '  puts foo',
        'end'
      ]
    end

    it 'registers an offense for the assignment in the if branch' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context "when there's an unreferenced reassignment in a if branch " \
          'while the variable is referenced in the paired elsif branch' do
    let(:source) do
      [
        'def some_method(flag_a, flag_b)',
        '  foo = 1',
        '',
        '  if flag_a',
        '    puts foo',
        '    foo = 2',
        '  elsif flag_b',
        '    puts foo',
        '  end',
        'end'
      ]
    end

    it 'registers an offense for the reassignment in the if branch' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context "when there's an unreferenced reassignment in a if branch " \
          'while the variable is referenced in a case branch ' \
          'in the paired else branch' do
    let(:source) do
      [
        'def some_method(flag_a, flag_b)',
        '  foo = 1',
        '',
        '  if flag_a',
        '    puts foo',
        '    foo = 2',
        '  else',
        '    case',
        '    when flag_b',
        '      puts foo',
        '    end',
        '  end',
        'end'
      ]
    end

    it 'registers an offense for the reassignment in the if branch' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when an assignment in a if branch is referenced ' \
          'in another if branch' do
    let(:source) do
      [
        'def some_method(flag_a, flag_b)',
        '  if flag_a',
        '    foo = 1',
        '  end',
        '',
        '  if flag_b',
        '    puts foo',
        '  end',
        'end'
      ]
    end

    include_examples 'accepts'
  end

  context 'when a variable is assigned in branch of modifier if ' \
          'that references the variable in its conditional clause' \
          'and referenced after the branching' do
    let(:source) do
      [
        'def some_method(flag)',
        '  foo = 1 unless foo',
        '  puts foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned in branch of modifier if ' \
          'that references the variable in its conditional clause' \
          'and unreferenced' do
    let(:source) do
      [
        'def some_method(flag)',
        '  foo = 1 unless foo',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned on each side of && ' \
          'and referenced after the &&' do
    let(:source) do
      [
        'def some_method',
        '  (foo = do_something_returns_object_or_nil) && (foo = 1)',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a unreferenced variable is reassigned ' \
          'on the left side of && and referenced after the &&' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  (foo = do_something_returns_object_or_nil) && do_something',
        '  foo',
        'end'
      ]
    end

    it 'registers an offense for the unreferenced assignment' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a unreferenced variable is reassigned ' \
          'on the right side of && and referenced after the &&' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  do_something_returns_object_or_nil && foo = 2',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned ' \
          'while referencing itself in rhs and referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = [1, 2]',
        '  foo = foo.map { |i| i + 1 }',
        '  puts foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned ' \
          'with binary operator assignment and referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  foo += 1',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned ' \
          'with logical operator assignment and referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = do_something_returns_object_or_nil',
        '  foo ||= 1',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned with binary operator ' \
           'assignment while assigning to itself in rhs ' \
           'then referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  foo += foo = 2',
        '  foo',
        'end'
      ]
    end

    it 'registers an offense for the assignment in rhs' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned first with ||= and referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo ||= 1',
        '  foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned with ||= ' \
          'at the last expression of the scope' do
    let(:source) do
      [
        'def some_method',
        '  foo = do_something_returns_object_or_nil',
        '  foo ||= 1',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to eq(
        'Useless assignment to variable - `foo`. Use `||` instead of `||=`.'
      )
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned with ||= ' \
          'before the last expression of the scope' do
    let(:source) do
      [
        'def some_method',
        '  foo = do_something_returns_object_or_nil',
        '  foo ||= 1',
        '  some_return_value',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned with multiple assignment ' \
          'and unreferenced' do
    let(:source) do
      [
        'def some_method',
        '  foo, bar = do_something',
        '  puts foo',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to eq(
        'Useless assignment to variable - `bar`. ' \
        'Use `_` or `_bar` as a variable name ' \
        "to indicate that it won't be used."
      )
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['bar'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned with multiple assignment ' \
          'while referencing itself in rhs and referenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  foo, bar = do_something(foo)',
        '  puts foo, bar',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned in loop body ' \
          'and referenced in post while condition' do
    let(:source) do
      [
        'begin',
        '  a = (a || 0) + 1',
        '  puts a',
        'end while a <= 2'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned in loop body ' \
          'and referenced in post until condition' do
    let(:source) do
      [
        'begin',
        '  a = (a || 0) + 1',
        '  puts a',
        'end until a > 2'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned ' \
          'in main body of begin with rescue but unreferenced' do
    let(:source) do
      [
        'begin',
        '  do_something',
        '  foo = true',
        'rescue',
        '  do_anything',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned in main body of begin, rescue ' \
          'and else then referenced after the begin' do
    let(:source) do
      [
        'begin',
        '  do_something',
        '  foo = :in_begin',
        'rescue FirstError',
        '  foo = :in_first_rescue',
        'rescue SecondError',
        '  foo = :in_second_rescue',
        'else',
        '  foo = :in_else',
        'end',
        '',
        'puts foo'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned multiple times ' \
          'in main body of begin then referenced after the begin' do
    let(:source) do
      [
        'begin',
        '  status = :initial',
        '  connect_sometimes_fails!',
        '  status = :connected',
        '  fetch_sometimes_fails!',
        '  status = :fetched',
        'rescue',
        '  do_something',
        'end',
        '',
        'puts status'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned multiple times ' \
          'in main body of begin then referenced in rescue' do
    let(:source) do
      [
        'begin',
        '  status = :initial',
        '  connect_sometimes_fails!',
        '  status = :connected',
        '  fetch_sometimes_fails!',
        '  status = :fetched',
        'rescue',
        '  puts status',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned multiple times ' \
          'in main body of begin then referenced in ensure' do
    let(:source) do
      [
        'begin',
        '  status = :initial',
        '  connect_sometimes_fails!',
        '  status = :connected',
        '  fetch_sometimes_fails!',
        '  status = :fetched',
        'ensure',
        '  puts status',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is reassigned multiple times in rescue ' \
          'and referenced after the begin' do
    let(:source) do
      [
        'foo = false',
        '',
        'begin',
        '  do_something',
        'rescue',
        '  foo = true',
        '  foo = true',
        'end',
        '',
        'puts foo'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in rescue with ensure then referenced after the begin' do
    let(:source) do
      [
        'foo = false',
        '',
        'begin',
        '  do_something',
        'rescue',
        '  foo = true',
        '  foo = true',
        'ensure',
        '  do_anything',
        'end',
        '',
        'puts foo'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in ensure with rescue then referenced after the begin' do
    let(:source) do
      [
        'begin',
        '  do_something',
        'rescue',
        '  do_anything',
        'ensure',
        '  foo = true',
        '  foo = true',
        'end',
        '',
        'puts foo'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(6)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a variable is assigned at the end of rescue ' \
          'and would be referenced with retry' do
    let(:source) do
      [
        'retried = false',
        '',
        'begin',
        '  do_something',
        'rescue',
        '  fail if retried',
        '  retried = true',
        '  retry',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned with operator assignment ' \
          'in rescue and would be referenced with retry' do
    let(:source) do
      [
        'retry_count = 0',
        '',
        'begin',
        '  do_something',
        'rescue',
        '  fail if (retry_count += 1) > 3',
        '  retry',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned ' \
          'in main body of begin, rescue and else ' \
          'and reassigned in ensure then referenced after the begin' do
    let(:source) do
      [
        'begin',
        '  do_something',
        '  foo = :in_begin',
        'rescue FirstError',
        '  foo = :in_first_rescue',
        'rescue SecondError',
        '  foo = :in_second_rescue',
        'else',
        '  foo = :in_else',
        'ensure',
        '  foo = :in_ensure',
        'end',
        '',
        'puts foo'
      ]
    end

    it 'registers offenses for each assignment before ensure' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(4)

      expect(cop.offenses[0].line).to eq(3)
      expect(cop.offenses[1].line).to eq(5)
      expect(cop.offenses[2].line).to eq(7)
      expect(cop.offenses[3].line).to eq(9)
    end
  end

  context 'when a rescued error variable is wrongly tried to be referenced ' \
          'in another rescue body' do
    let(:source) do
      [
        'begin',
        '  do_something',
        'rescue FirstError => error',
        'rescue SecondError',
        '  p error # => nil',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `error`.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['error'])
    end
  end

  context 'when a method argument is reassigned ' \
          'and zero arity super is called' do
    let(:source) do
      [
        'def some_method(foo)',
        '  foo = 1',
        '  super',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a local variable is unreferenced ' \
          'and zero arity super is called' do
    let(:source) do
      [
        'def some_method(bar)',
        '  foo = 1',
        '  super',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a method argument is reassigned ' \
          'but not passed to super' do
    let(:source) do
      [
        'def some_method(foo, bar)',
        '  foo = 1',
        '  super(bar)',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end
  end

  context 'when a named capture is unreferenced in top level' do
    let(:source) do
      "/(?<foo>\w+)/ =~ 'FOO'"
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(1)
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a named capture is unreferenced ' \
          'in other than top level' do
    let(:source) do
      [
        'def some_method',
        "  /(?<foo>\\w+)/ =~ 'FOO'",
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['/(?<foo>\w+)/'])
    end

    # MRI 2.0 accepts this case, but I have no idea why it does so
    # and there's no convincing reason to conform to this behavior,
    # so RuboCop does not mimic MRI in this case.
  end

  context 'when a named capture is referenced' do
    let(:source) do
      [
        'def some_method',
        "  /(?<foo>\w+)(?<bar>\s+)/ =~ 'FOO'",
        '  puts foo',
        '  puts bar',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is referenced ' \
          'in rhs of named capture expression' do
    let(:source) do
      [
        'def some_method',
        "  foo = 'some string'",
        '  /(?<foo>\w+)/ =~ foo',
        '  puts foo',
        'end'
      ]
    end

    include_examples 'accepts'
  end

  context 'when a variable is assigned in begin ' \
          'and referenced outside' do
    let(:source) do
      [
        'def some_method',
        '  begin',
        '    foo = 1',
        '  end',
        '  puts foo',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is shadowed by a block argument ' \
          'and unreferenced' do
    let(:source) do
      [
        'def some_method',
        '  foo = 1',
        '  1.times do |foo|',
        '    puts foo',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1', 'unused variable'
  end

  context 'when a variable is not used and the name starts with _' do
    let(:source) do
      [
        'def some_method',
        '  _foo = 1',
        '  bar = 2',
        '  puts bar',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a method argument is not used' do
    let(:source) do
      [
        'def some_method(arg)',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when an optional method argument is not used' do
    let(:source) do
      [
        'def some_method(arg = nil)',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a block method argument is not used' do
    let(:source) do
      [
        'def some_method(&block)',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a splat method argument is not used' do
    let(:source) do
      [
        'def some_method(*args)',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a optional keyword method argument is not used' do
    let(:source) do
      [
        'def some_method(name: value)',
        'end'
      ]
    end

    include_examples 'accepts' unless RUBY_VERSION < '2.0'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a keyword splat method argument is used' do
    let(:source) do
      [
        'def some_method(name: value, **rest_keywords)',
        '  p rest_keywords',
        'end'
      ]
    end

    include_examples 'accepts' unless RUBY_VERSION < '2.0'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a keyword splat method argument is not used' do
    let(:source) do
      [
        'def some_method(name: value, **rest_keywords)',
        'end'
      ]
    end

    include_examples 'accepts' unless RUBY_VERSION < '2.0'
    include_examples 'mimics MRI 2.1'
  end

  context 'when an anonymous keyword splat method argument is defined' do
    let(:source) do
      [
        'def some_method(name: value, **)',
        'end'
      ]
    end

    include_examples 'accepts' unless RUBY_VERSION < '2.0'
    include_examples 'mimics MRI 2.1'
  end

  context 'when a block argument is not used' do
    let(:source) do
      [
        '1.times do |i|',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  context 'when there is only one AST node and it is unused variable' do
    let(:source) do
      'foo = 1'
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless assignment to variable - `foo`.')
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['foo'])
    end

    include_examples 'mimics MRI 2.1'
  end

  context 'when a variable is assigned ' \
          'while being passed to a method taking block' do
    context 'and the variable is used' do
      let(:source) do
        [
          'some_method(foo = 1) do',
          'end',
          'puts foo'
        ]
      end

      include_examples 'accepts'
      include_examples 'mimics MRI 2.1'
    end

    context 'and the variable is not used' do
      let(:source) do
        [
          'some_method(foo = 1) do',
          'end'
        ]
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Useless assignment to variable - `foo`.')
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq(['foo'])
      end

      include_examples 'mimics MRI 2.1'
    end
  end

  context 'when a variable is assigned ' \
          'and passed to a method followed by method taking block' do
    let(:source) do
      [
        "pattern = '*.rb'",
        'Dir.glob(pattern).map do |path|',
        'end'
      ]
    end

    include_examples 'accepts'
    include_examples 'mimics MRI 2.1'
  end

  # regression test, from problem in Locatable
  context 'when a variable is assigned in 2 identical if branches' do
    let(:source) do
      ['def foo',
       '  if bar',
       '    foo = 1',
       '  else',
       '    foo = 1',
       '  end',
       '  foo.bar.baz',
       'end']
    end

    it "doesn't think 1 of the 2 assignments is useless" do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  describe 'similar name suggestion' do
    context "when there's a similar variable-like method invocation" do
      let(:source) do
        [
          'def some_method',
          '  enviromnent = {}',
          '  another_symbol',
          '  puts environment',
          'end'
        ]
      end

      it 'suggests the method name' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(
          'Useless assignment to variable - `enviromnent`. ' \
          'Did you mean `environment`?'
        )
      end
    end

    context "when there's a similar variable" do
      let(:source) do
        [
          'def some_method',
          '  environment = nil',
          '  another_symbol',
          '  enviromnent = {}',
          '  puts environment',
          'end'
        ]
      end

      it 'suggests the variable name' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(
          'Useless assignment to variable - `enviromnent`. ' \
          'Did you mean `environment`?'
        )
      end
    end

    context 'when there are only less similar names' do
      let(:source) do
        [
          'def some_method',
          '  enviromnent = {}',
          '  another_symbol',
          '  puts envelope',
          'end'
        ]
      end

      it 'does not suggest any name' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Useless assignment to variable - `enviromnent`.')
      end
    end

    context "when there's a similar method invocation with explicit receiver" do
      let(:source) do
        [
          'def some_method',
          '  enviromnent = {}',
          '  another_symbol',
          '  puts self.environment',
          'end'
        ]
      end

      it 'does not suggest any name' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Useless assignment to variable - `enviromnent`.')
      end
    end

    context "when there's a similar method invocation with arguments" do
      let(:source) do
        [
          'def some_method',
          '  enviromnent = {}',
          '  another_symbol',
          '  puts environment(1)',
          'end'
        ]
      end

      it 'does not suggest any name' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Useless assignment to variable - `enviromnent`.')
      end
    end

    context "when there's a similar name but it's in inner scope" do
      let(:source) do
        [
          'class SomeClass',
          '  enviromnent = {}',
          '',
          '  def some_method(environment)',
          '    puts environment',
          '  end',
          'end'
        ]
      end

      it 'does not suggest any name' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Useless assignment to variable - `enviromnent`.')
      end
    end
  end
end
