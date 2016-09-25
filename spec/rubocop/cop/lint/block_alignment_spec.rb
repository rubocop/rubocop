# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::BlockAlignment, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'AlignWith' => 'either' }
  end

  context 'when the block has no arguments' do
    it 'registers an offense for mismatched block end' do
      inspect_source(cop,
                     ['test do',
                      '  end'])
      expect(cop.messages)
        .to eq(['`end` at 2, 2 is not aligned with `test do` at 1, 0.'])
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, ['test do',
                                            '  end'])

      expect(new_source).to eq(['test do',
                                'end'].join("\n"))
    end
  end

  context 'when the block has arguments' do
    it 'registers an offense for mismatched block end' do
      inspect_source(cop,
                     ['test do |ala|',
                      '  end'])
      expect(cop.messages)
        .to eq(['`end` at 2, 2 is not aligned with `test do |ala|` at 1, 0.'])
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, ['test do |ala|',
                                            '  end'])

      expect(new_source).to eq(['test do |ala|',
                                'end'].join("\n"))
    end
  end

  it 'accepts a block end that does not begin its line' do
    inspect_source(cop,
                   ['  scope :bar, lambda { joins(:baz)',
                    '                       .distinct }'])
    expect(cop.offenses).to be_empty
  end

  context 'when the block is a logical operand' do
    it 'accepts a correctly aligned block end' do
      inspect_source(cop,
                     ['(value.is_a? Array) && value.all? do |subvalue|',
                      '  type_check_value(subvalue, array_type)',
                      'end',
                      'a || b do',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'accepts end aligned with a variable' do
    inspect_source(cop,
                   ['variable = test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  context 'when there is an assignment chain' do
    it 'registers an offense for an end aligned with the 2nd variable' do
      inspect_source(cop,
                     ['a = b = c = test do |ala|',
                      '    end'])
      expect(cop.messages)
        .to eq(['`end` at 2, 4 is not aligned with' \
                ' `a = b = c = test do |ala|` at 1, 0.'])
    end

    it 'accepts end aligned with the first variable' do
      inspect_source(cop,
                     ['a = b = c = test do |ala|',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects alignment to the first variable' do
      new_source = autocorrect_source(cop,
                                      ['a = b = c = test do |ala|',
                                       '    end'])

      expect(new_source).to eq(['a = b = c = test do |ala|',
                                'end'].join("\n"))
    end
  end

  context 'and the block is an operand' do
    it 'accepts end aligned with a variable' do
      inspect_source(cop,
                     ['b = 1 + preceding_line.reduce(0) do |a, e|',
                      '  a + e.length + newline_length',
                      'end + 1'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'registers an offense for mismatched block end with a variable' do
    inspect_source(cop,
                   ['variable = test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with `variable = test do |ala|`' \
              ' at 1, 0.'])
  end

  context 'when the block is defined on the next line' do
    it 'accepts end aligned with the block expression' do
      inspect_source(cop,
                     ['variable =',
                      '  a_long_method_that_dont_fit_on_the_line do |v|',
                      '    v.foo',
                      '  end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offenses for mismatched end alignment' do
      inspect_source(cop,
                     ['variable =',
                      '  a_long_method_that_dont_fit_on_the_line do |v|',
                      '    v.foo',
                      'end'])
      expect(cop.messages)
        .to eq(['`end` at 4, 0 is not aligned with' \
                ' `a_long_method_that_dont_fit_on_the_line do |v|` at 2, 2.'])
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(
        cop,
        ['variable =',
         '  a_long_method_that_dont_fit_on_the_line do |v|',
         '    v.foo',
         'end']
      )

      expect(new_source)
        .to eq(['variable =',
                '  a_long_method_that_dont_fit_on_the_line do |v|',
                '    v.foo',
                '  end'].join("\n"))
    end
  end

  context 'when the method part is a call chain that spans several lines' do
    # Example from issue 346 of bbatsov/rubocop on github:
    it 'accepts pretty alignment style' do
      src = [
        'def foo(bar)',
        '  bar.get_stuffs',
        '      .reject do |stuff| ',
        '        stuff.with_a_very_long_expression_that_doesnt_fit_the_line',
        '      end.select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '      end',
        '      .select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '      end',
        'end'
      ]
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'registers offenses for misaligned ends' do
      src = [
        'def foo(bar)',
        '  bar.get_stuffs',
        '      .reject do |stuff|',
        '        stuff.with_a_very_long_expression_that_doesnt_fit_the_line',
        '        end.select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '    end',
        '      .select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '        end',
        'end'
      ]
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['`end` at 5, 8 is not aligned with `bar.get_stuffs` at 2, 2' \
                ' or `.reject do |stuff|` at 3, 6.',
                '`end` at 7, 4 is not aligned with `bar.get_stuffs` at 2, 2' \
                ' or `end.select do |stuff|` at 5, 8.',
                '`end` at 10, 8 is not aligned with `bar.get_stuffs` at 2, 2' \
                ' or `.select do |stuff|` at 8, 6.'])
    end

    # Example from issue 393 of bbatsov/rubocop on github:
    it 'accepts end indented as the start of the block' do
      src = ['my_object.chaining_this_very_long_method(with_a_parameter)',
             '    .and_one_with_a_block do',
             '  do_something',
             'end',
             '', # Other variant:
             'my_object.chaining_this_very_long_method(',
             '    with_a_parameter).and_one_with_a_block do',
             '  do_something',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    # Example from issue 447 of bbatsov/rubocop on github:
    it 'accepts two kinds of end alignment' do
      src = [
        # Aligned with start of line where do is:
        'params = default_options.merge(options)',
        '          .delete_if { |k, v| v.nil? }',
        '          .each_with_object({}) do |(k, v), new_hash|',
        '            new_hash[k.to_s] = v.to_s',
        '          end',
        # Aligned with start of the whole expression:
        'params = default_options.merge(options)',
        '          .delete_if { |k, v| v.nil? }',
        '          .each_with_object({}) do |(k, v), new_hash|',
        '            new_hash[k.to_s] = v.to_s',
        'end'
      ]
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects misaligned ends with the start of the expression' do
      src = [
        'def foo(bar)',
        '  bar.get_stuffs',
        '      .reject do |stuff|',
        '        stuff.with_a_very_long_expression_that_doesnt_fit_the_line',
        '        end.select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '    end',
        '      .select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '        end',
        'end'
      ]

      aligned_src = [
        'def foo(bar)',
        '  bar.get_stuffs',
        '      .reject do |stuff|',
        '        stuff.with_a_very_long_expression_that_doesnt_fit_the_line',
        '  end.select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '  end',
        '      .select do |stuff|',
        '        stuff.another_very_long_expression_that_doesnt_fit_the_line',
        '  end',
        'end'
      ].join("\n")

      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(aligned_src)
    end
  end

  context 'when variables of a mass assignment spans several lines' do
    it 'accepts end aligned with the variables' do
      src = ['e,',
             'f = [5, 6].map do |i|',
             '  i - 5',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for end aligned with the block' do
      src = ['e,',
             'f = [5, 6].map do |i|',
             '  i - 5',
             '    end']
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['`end` at 4, 4 is not aligned with `e,` at 1, 0 or' \
                ' `f = [5, 6].map do |i|` at 2, 0.'])
    end

    it 'auto-corrects' do
      src = ['e,',
             'f = [5, 6].map do |i|',
             '  i - 5',
             '    end']
      corrected = ['e,',
                   'f = [5, 6].map do |i|',
                   '  i - 5',
                   'end']
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end

  it 'accepts end aligned with an instance variable' do
    inspect_source(cop,
                   ['@variable = test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with' \
     ' an instance variable' do
    inspect_source(cop,
                   ['@variable = test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with `@variable = test do |ala|`' \
              ' at 1, 0.'])
  end

  it 'accepts end aligned with a class variable' do
    inspect_source(cop,
                   ['@@variable = test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with a class variable' do
    inspect_source(cop,
                   ['@@variable = test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with `@@variable = test do |ala|`' \
              ' at 1, 0.'])
  end

  it 'accepts end aligned with a global variable' do
    inspect_source(cop,
                   ['$variable = test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with a global variable' do
    inspect_source(cop,
                   ['$variable = test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with `$variable = test do |ala|`' \
              ' at 1, 0.'])
  end

  it 'accepts end aligned with a constant' do
    inspect_source(cop,
                   ['CONSTANT = test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with a constant' do
    inspect_source(cop,
                   ['Module::CONSTANT = test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with' \
              ' `Module::CONSTANT = test do |ala|` at 1, 0.'])
  end

  it 'accepts end aligned with a method call' do
    inspect_source(cop,
                   ['parser.children << lambda do |token|',
                    '  token << 1',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with a method call' do
    inspect_source(cop,
                   ['parser.children << lambda do |token|',
                    '  token << 1',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 3, 2 is not aligned with' \
              ' `parser.children << lambda do |token|` at 1, 0.'])
  end

  it 'accepts end aligned with a method call with arguments' do
    inspect_source(cop,
                   ['@h[:f] = f.each_pair.map do |f, v|',
                    '  v = 1',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched end with a method call' \
     ' with arguments' do
    inspect_source(cop,
                   ['@h[:f] = f.each_pair.map do |f, v|',
                    '  v = 1',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 3, 2 is not aligned with' \
              ' `@h[:f] = f.each_pair.map do |f, v|` at 1, 0.'])
  end

  it 'does not raise an error for nested block in a method call' do
    inspect_source(cop,
                   'expect(arr.all? { |o| o.valid? })')
    expect(cop.offenses).to be_empty
  end

  it 'accepts end aligned with the block when the block is a method argument' do
    inspect_source(cop,
                   ['expect(arr.all? do |o|',
                    '         o.valid?',
                    '       end)'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched end not aligned with the block' \
     ' that is an argument' do
    inspect_source(cop,
                   ['expect(arr.all? do |o|',
                    '  o.valid?',
                    '  end)'])
    expect(cop.messages)
      .to eq(['`end` at 3, 2 is not aligned with `arr.all? do |o|` at 1, 7 or' \
              ' `expect(arr.all? do |o|` at 1, 0.'])
  end

  it 'accepts end aligned with an op-asgn (+=, -=)' do
    inspect_source(cop,
                   ['rb += files.select do |file|',
                    '  file << something',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with an op-asgn (+=, -=)' do
    inspect_source(cop,
                   ['rb += files.select do |file|',
                    '  file << something',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 3, 2 is not aligned with `rb` at 1, 0.'])
  end

  it 'accepts end aligned with an and-asgn (&&=)' do
    inspect_source(cop,
                   ['variable &&= test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with an and-asgn (&&=)' do
    inspect_source(cop,
                   ['variable &&= test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with `variable &&= test do |ala|`' \
              ' at 1, 0.'])
  end

  it 'accepts end aligned with an or-asgn (||=)' do
    inspect_source(cop,
                   ['variable ||= test do |ala|',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with an or-asgn (||=)' do
    inspect_source(cop,
                   ['variable ||= test do |ala|',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 2, 2 is not aligned with `variable ||= test do |ala|`' \
              ' at 1, 0.'])
  end

  it 'accepts end aligned with a mass assignment' do
    inspect_source(cop,
                   ['var1, var2 = lambda do |test|',
                    '  [1, 2]',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts end aligned with a call chain left hand side' do
    inspect_source(cop,
                   ['parser.diagnostics.consumer = lambda do |diagnostic|',
                    '  diagnostics << diagnostic',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for mismatched block end with a mass assignment' do
    inspect_source(cop,
                   ['var1, var2 = lambda do |test|',
                    '  [1, 2]',
                    '  end'])
    expect(cop.messages)
      .to eq(['`end` at 3, 2 is not aligned with `var1, var2` at 1, 0.'])
  end

  context 'when multiple similar-looking blocks have misaligned ends' do
    it 'registers an offense for each of them' do
      inspect_source(cop,
                     ['a = test do',
                      ' end',
                      'b = test do',
                      ' end'])
      expect(cop.offenses.size).to eq 2
    end
  end

  context 'on a splatted method call' do
    it 'aligns end with the splat operator' do
      inspect_source(cop,
                     ['def get_gems_by_name',
                      '  @gems ||= Hash[*get_latest_gems.map { |gem|',
                      '                   [gem.name, gem, gem.full_name, gem]',
                      '                 }.flatten]',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects' do
      source = ['def get_gems_by_name',
                '  @gems ||= Hash[*get_latest_gems.map { |gem|',
                '                   [gem.name, gem, gem.full_name, gem]',
                '              }.flatten]',
                'end']
      corrected = ['def get_gems_by_name',
                   '  @gems ||= Hash[*get_latest_gems.map { |gem|',
                   '                   [gem.name, gem, gem.full_name, gem]',
                   '                 }.flatten]',
                   'end']

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end

  context 'on a bit-flipped method call' do
    it 'aligns end with the ~ operator' do
      inspect_source(cop,
                     ['def abc',
                      '  @abc ||= A[~xyz { |x|',
                      '               x',
                      '             }.flatten]',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects' do
      source = ['def abc',
                '  @abc ||= A[~xyz { |x|',
                '               x',
                '                        }.flatten]',
                'end']
      corrected = ['def abc',
                   '  @abc ||= A[~xyz { |x|',
                   '               x',
                   '             }.flatten]',
                   'end']

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end

  context 'on a logically negated method call' do
    it 'aligns end with the ! operator' do
      inspect_source(cop,
                     ['def abc',
                      '  @abc ||= A[!xyz { |x|',
                      '               x',
                      '             }.flatten]',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects' do
      source = ['def abc',
                '  @abc ||= A[!xyz { |x|',
                '               x',
                '}.flatten]',
                'end']
      corrected = ['def abc',
                   '  @abc ||= A[!xyz { |x|',
                   '               x',
                   '             }.flatten]',
                   'end']

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end

  context 'on an arithmetically negated method call' do
    it 'aligns end with the - operator' do
      inspect_source(cop,
                     ['def abc',
                      '  @abc ||= A[-xyz { |x|',
                      '               x',
                      '             }.flatten]',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects' do
      source = ['def abc',
                '  @abc ||= A[-xyz { |x|',
                '               x',
                '                  }.flatten]',
                'end']
      corrected = ['def abc',
                   '  @abc ||= A[-xyz { |x|',
                   '               x',
                   '             }.flatten]',
                   'end']

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end

  context 'when the block is terminated by }' do
    it 'mentions } (not end) in the message' do
      inspect_source(cop,
                     ['test {',
                      '  }'])
      expect(cop.messages)
        .to eq(['`}` at 2, 2 is not aligned with `test {` at 1, 0.'])
    end
  end

  context 'when configured to align with start_of_line' do
    let(:cop_config) do
      { 'AlignWith' => 'start_of_line' }
    end

    it 'allows when start_of_line aligned' do
      src = [
        'foo.bar',
        '  .each do',
        '    baz',
        'end'
      ]
      inspect_source(cop, src)
      expect(cop.messages).to be_empty
    end

    it 'errors when do aligned' do
      src = [
        'foo.bar',
        '  .each do',
        '    baz',
        '  end'
      ]
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['`end` at 4, 2 is not aligned with ' \
                '`foo.bar` at 1, 0.'])
    end

    it 'autocorrects' do
      src = [
        'foo.bar',
        '  .each do',
        '    baz',
        '  end'
      ]
      corrected = [
        'foo.bar',
        '  .each do',
        '    baz',
        'end'
      ]

      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end

  context 'when configured to align with do' do
    let(:cop_config) do
      { 'AlignWith' => 'start_of_block' }
    end

    it 'allows when do aligned' do
      src = [
        'foo.bar',
        '  .each do',
        '    baz',
        '  end'
      ]
      inspect_source(cop, src)
      expect(cop.messages).to be_empty
    end

    it 'errors when start_of_line aligned' do
      src = [
        'foo.bar',
        '  .each do',
        '    baz',
        'end'
      ]
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['`end` at 4, 0 is not aligned with ' \
                '`.each do` at 2, 2.'])
    end

    it 'autocorrects' do
      src = [
        'foo.bar',
        '  .each do',
        '    baz',
        'end'
      ]
      corrected = [
        'foo.bar',
        '  .each do',
        '    baz',
        '  end'
      ]

      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(corrected.join("\n"))
    end
  end
end
