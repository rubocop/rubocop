# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Next, :config do
  let(:cop_config) { { 'MinBodyLength' => 1 } }

  shared_examples 'iterators' do |condition|
    let(:opposite) { condition == 'if' ? 'unless' : 'if' }

    it "registers an offense for #{condition} inside of downto" do
      expect_offense(<<~RUBY, condition: condition)
        3.downto(1) do
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            puts o
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        3.downto(1) do
          next #{opposite} o == 1
          puts o
        end
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it "registers an offense for #{condition} inside of downto numblock" do
        expect_offense(<<~RUBY, condition: condition)
          3.downto(1) do
            %{condition} _1 == 1
            ^{condition}^^^^^^^^ Use `next` to skip iteration.
              puts _1
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          3.downto(1) do
            next #{opposite} _1 == 1
            puts _1
          end
        RUBY
      end
    end

    it "registers an offense for #{condition} inside of each" do
      expect_offense(<<~RUBY, condition: condition)
        [].each do |o|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            puts o
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].each do |o|
          next #{opposite} o == 1
          puts o
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of each_with_object" do
      expect_offense(<<~RUBY, condition: condition)
        [].each_with_object({}) do |o, a|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            a[o] = {}
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].each_with_object({}) do |o, a|
          next #{opposite} o == 1
          a[o] = {}
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of for" do
      expect_offense(<<~RUBY, condition: condition)
        for o in 1..3 do
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            puts o
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        for o in 1..3 do
          next #{opposite} o == 1
          puts o
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of loop" do
      expect_offense(<<~RUBY, condition: condition)
        loop do
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            puts o
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          next #{opposite} o == 1
          puts o
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of map" do
      expect_offense(<<~RUBY, condition: condition)
        loop do
          {}.map do |k, v|
            %{condition} v == 1
            ^{condition}^^^^^^^ Use `next` to skip iteration.
              puts k
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          {}.map do |k, v|
            next #{opposite} v == 1
            puts k
          end
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of times" do
      expect_offense(<<~RUBY, condition: condition)
        loop do
          3.times do |o|
            %{condition} o == 1
            ^{condition}^^^^^^^ Use `next` to skip iteration.
              puts o
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          3.times do |o|
            next #{opposite} o == 1
            puts o
          end
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of collect" do
      expect_offense(<<~RUBY, condition: condition)
        [].collect do |o|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            true
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].collect do |o|
          next #{opposite} o == 1
          true
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of select" do
      expect_offense(<<~RUBY, condition: condition)
        [].select do |o|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            true
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].select do |o|
          next #{opposite} o == 1
          true
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of select!" do
      expect_offense(<<~RUBY, condition: condition)
        [].select! do |o|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            true
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].select! do |o|
          next #{opposite} o == 1
          true
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of reject" do
      expect_offense(<<~RUBY, condition: condition)
        [].reject do |o|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            true
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].reject do |o|
          next #{opposite} o == 1
          true
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of reject!" do
      expect_offense(<<~RUBY, condition: condition)
        [].reject! do |o|
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            true
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].reject! do |o|
          next #{opposite} o == 1
          true
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of nested iterators" do
      expect_offense(<<~RUBY, condition: condition)
        loop do
          until false
            %{condition} o == 1
            ^{condition}^^^^^^^ Use `next` to skip iteration.
              puts o
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          until false
            next #{opposite} o == 1
            puts o
          end
        end
      RUBY
    end

    it "registers an offense for #{condition} inside of nested iterators" do
      expect_offense(<<~RUBY, condition: condition)
        loop do
          while true
            %{condition} o == 1
            ^{condition}^^^^^^^ Use `next` to skip iteration.
              puts o
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          while true
            next #{opposite} o == 1
            puts o
          end
        end
      RUBY
    end

    it 'registers an offense for a condition at the end of an iterator ' \
       'when there is more in the iterator than the condition' do
      expect_offense(<<~RUBY, condition: condition)
        [].each do |o|
          puts o
          %{condition} o == 1
          ^{condition}^^^^^^^ Use `next` to skip iteration.
            puts o
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        [].each do |o|
          puts o
          next #{opposite} o == 1
          puts o
        end
      RUBY
    end

    it 'registers an offense when line break before condition' do
      expect_offense(<<~RUBY)
        array.each do |item|
          if
          ^^ Use `next` to skip iteration.
             condition
            next if item.zero?
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        array.each do |item|
          next unless condition
            next if item.zero?
            do_something
        end
      RUBY
    end

    it 'allows loops with conditional break' do
      expect_no_offenses(<<~RUBY)
        loop do
          puts ''
          break #{condition} o == 1
        end
      RUBY
    end

    it 'allows loops with conditional return' do
      expect_no_offenses(<<~RUBY)
        loop do
          puts ''
          return #{condition} o == 1
        end
      RUBY
    end

    it "allows loops with #{condition} being the entire body with else" do
      expect_no_offenses(<<~RUBY)
        [].each do |o|
          #{condition} o == 1
            puts o
          else
            puts 'no'
          end
        end
      RUBY
    end

    it "allows loops with #{condition} with else, nested in another condition" do
      expect_no_offenses(<<~RUBY)
        [].each do |o|
          if foo
            #{condition} o == 1
              puts o
            else
              puts 'no'
            end
          end
        end
      RUBY
    end

    it "allows loops with #{condition} with else at the end" do
      expect_no_offenses(<<~RUBY)
        [].each do |o|
          puts o
          #{condition} o == 1
            puts o
          else
            puts 'no'
          end
        end
      RUBY
    end

    it "reports an offense for #{condition} whose body has 3 lines" do
      expect_offense(<<~RUBY, condition: condition)
        arr.each do |e|
          %{condition} something
          ^{condition}^^^^^^^^^^ Use `next` to skip iteration.
            work
            work
            work
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        arr.each do |e|
          next #{opposite} something
          work
          work
          work
        end
      RUBY
    end

    context 'EnforcedStyle: skip_modifier_ifs' do
      let(:cop_config) { { 'EnforcedStyle' => 'skip_modifier_ifs' } }

      it "allows modifier #{condition}" do
        expect_no_offenses(<<~RUBY)
          [].each do |o|
            puts o #{condition} o == 1
          end
        RUBY
      end
    end

    context 'EnforcedStyle: always' do
      let(:cop_config) { { 'EnforcedStyle' => 'always' } }
      let(:opposite) { condition == 'if' ? 'unless' : 'if' }

      it "registers an offense for modifier #{condition}" do
        expect_offense(<<~RUBY, condition: condition)
          [].each do |o|
            puts o #{condition} o == 1 # comment
            ^^^^^^^^{condition}^^^^^^^ Use `next` to skip iteration.
          end
        RUBY

        expect_correction(<<~RUBY)
          [].each do |o|
            next #{opposite} o == 1
            puts o # comment
          end
        RUBY
      end
    end

    it 'autocorrects a misaligned end' do
      expect_offense(<<~RUBY)
        [1, 2, 3, 4].each do |num|
          if !opts.nil?
          ^^^^^^^^^^^^^ Use `next` to skip iteration.
            puts num
            if num != 2
              puts 'hello'
              puts 'world'
            end
         end
        end
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3, 4].each do |num|
          next unless !opts.nil?
          puts num
          next unless num != 2
          puts 'hello'
          puts 'world'
        end
      RUBY
    end
  end

  it 'keeps comments when autocorrecting' do
    expect_offense(<<~RUBY)
      loop do
        if test # keep me
        ^^^^^^^ Use `next` to skip iteration.
          # keep me
          something # keep me
          # keep me

        end # keep me
      end
    RUBY

    expect_correction(<<~RUBY)
      loop do
        next unless test # keep me
        # keep me
        something # keep me
        # keep me

       # keep me
      end
    RUBY
  end

  it 'handles `then` when autocorrecting' do
    expect_offense(<<~RUBY)
      loop do
        if test then
        ^^^^^^^ Use `next` to skip iteration.
          something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      loop do
        next unless test
        something
      end
    RUBY
  end

  it "doesn't reindent heredoc bodies when autocorrecting" do
    expect_offense(<<~RUBY)
      loop do
        if test
        ^^^^^^^ Use `next` to skip iteration.
          str = <<-BLAH
        this is a heredoc
         nice eh?
          BLAH
          something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      loop do
        next unless test
        str = <<-BLAH
        this is a heredoc
         nice eh?
        BLAH
        something
      end
    RUBY
  end

  it 'handles nested autocorrections' do
    expect_offense(<<~RUBY)
      loop do
        if test
        ^^^^^^^ Use `next` to skip iteration.
          loop do
            if test
            ^^^^^^^ Use `next` to skip iteration.
              something
            end
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      loop do
        next unless test
        loop do
          next unless test
          something
        end
      end
    RUBY
  end

  it_behaves_like 'iterators', 'if'
  it_behaves_like 'iterators', 'unless'

  it 'allows empty blocks' do
    expect_no_offenses(<<~RUBY)
      [].each do
      end
      [].each { }
    RUBY
  end

  it 'allows loops with conditions at the end with ternary op' do
    expect_no_offenses(<<~RUBY)
      [].each do |o|
        o == x ? y : z
      end
    RUBY
  end

  it 'allows super nodes' do
    # https://github.com/rubocop/rubocop/issues/1115
    expect_no_offenses(<<~RUBY)
      def foo
        super(a, a) { a }
      end
    RUBY
  end

  it 'does not blow up on empty body until block' do
    expect_no_offenses('until sup; end')
  end

  it 'does not blow up on empty body while block' do
    expect_no_offenses('while sup; end')
  end

  it 'does not blow up on empty body for block' do
    expect_no_offenses('for x in y; end')
  end

  it 'does not crash with an empty body branch' do
    expect_no_offenses(<<~RUBY)
      loop do
        if true
        end
      end
    RUBY
  end

  it 'does not crash with empty brackets' do
    expect_no_offenses(<<~RUBY)
      loop do
        ()
      end
    RUBY
  end

  context 'MinBodyLength: 3' do
    let(:cop_config) { { 'MinBodyLength' => 3 } }

    it 'accepts if whose body has 1 line' do
      expect_no_offenses(<<~RUBY)
        arr.each do |e|
          if something
            work
          end
        end
      RUBY
    end
  end

  context 'Invalid MinBodyLength' do
    let(:cop_config) { { 'MinBodyLength' => -2 } }

    it 'fails with an error' do
      source = <<~RUBY
        loop do
          if o == 1
            puts o
          end
        end
      RUBY

      expect { expect_no_offenses(source) }
        .to raise_error('MinBodyLength needs to be a positive integer!')
    end
  end
end
