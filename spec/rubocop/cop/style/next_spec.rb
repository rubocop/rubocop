# frozen_string_literal: true

describe RuboCop::Cop::Style::Next, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'MinBodyLength' => 1 } }

  shared_examples 'iterators' do |condition|
    let(:opposite) { condition == 'if' ? 'unless' : 'if' }

    it "registers an offense for #{condition} inside of downto" do
      inspect_source(cop, <<-END.strip_indent)
        3.downto(1) do
          #{condition} o == 1
            puts o
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "autocorrects #{condition} inside of downto" do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        3.downto(1) do
          #{condition} o == 1
            puts o
          end
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        3.downto(1) do
          next #{opposite} o == 1
          puts o
        end
      END
    end

    it "registers an offense for #{condition} inside of each" do
      inspect_source(cop, <<-END.strip_indent)
        [].each do |o|
          #{condition} o == 1
            puts o
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "autocorrects #{condition} inside of each" do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        [].each do |o|
          #{condition} o == 1
            puts o
          end
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        [].each do |o|
          next #{opposite} o == 1
          puts o
        end
      END
    end

    it "registers an offense for #{condition} inside of each_with_object" do
      inspect_source(cop, <<-END.strip_indent)
        [].each_with_object({}) do |o, a|
          #{condition} o == 1
            a[o] = {}
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of for" do
      inspect_source(cop, <<-END.strip_indent)
        for o in 1..3 do
          #{condition} o == 1
            puts o
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "autocorrects #{condition} inside of for" do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        for o in 1..3 do
          #{condition} o == 1
            puts o
          end
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        for o in 1..3 do
          next #{opposite} o == 1
          puts o
        end
      END
    end

    it "registers an offense for #{condition} inside of loop" do
      inspect_source(cop, <<-END.strip_indent)
        loop do
          #{condition} o == 1
            puts o
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of map" do
      inspect_source(cop, <<-END.strip_indent)
        loop do
          {}.map do |k, v|
            #{condition} v == 1
              puts k
            end
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} v == 1"])
    end

    it "registers an offense for #{condition} inside of times" do
      inspect_source(cop, <<-END.strip_indent)
        loop do
          3.times do |o|
            #{condition} o == 1
              puts o
            end
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of collect" do
      inspect_source(cop, <<-END.strip_indent)
        [].collect do |o|
          #{condition} o == 1
            true
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of select" do
      inspect_source(cop, <<-END.strip_indent)
        [].select do |o|
          #{condition} o == 1
            true
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of select!" do
      inspect_source(cop, <<-END.strip_indent)
        [].select! do |o|
          #{condition} o == 1
            true
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of reject" do
      inspect_source(cop, <<-END.strip_indent)
        [].reject do |o|
          #{condition} o == 1
            true
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of reject!" do
      inspect_source(cop, <<-END.strip_indent)
        [].reject! do |o|
          #{condition} o == 1
            true
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of nested iterators" do
      inspect_source(cop, <<-END.strip_indent)
        loop do
          until false
            #{condition} o == 1
              puts o
            end
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it "registers an offense for #{condition} inside of nested iterators" do
      inspect_source(cop, <<-END.strip_indent)
        loop do
          while true
            #{condition} o == 1
              puts o
            end
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it 'registers an offense for a condition at the end of an iterator ' \
       'when there is more in the iterator than the condition' do
      inspect_source(cop, <<-END.strip_indent)
        [].each do |o|
          puts o
          #{condition} o == 1
            puts o
          end
        end
      END

      expect(cop.messages).to eq(['Use `next` to skip iteration.'])
      expect(cop.highlights).to eq(["#{condition} o == 1"])
    end

    it 'allows loops with conditional break' do
      expect_no_offenses(<<-END.strip_indent)
        loop do
          puts ''
          break #{condition} o == 1
        end
      END
    end

    it 'allows loops with conditional return' do
      expect_no_offenses(<<-END.strip_indent)
        loop do
          puts ''
          return #{condition} o == 1
        end
      END
    end

    it "allows loops with #{condition} being the entire body with else" do
      inspect_source(cop, <<-END.strip_indent)
        [].each do |o|
          #{condition} o == 1
            puts o
          else
            puts 'no'
          end
        end
      END

      expect(cop.offenses).to be_empty
    end

    it "allows loops with #{condition} with else, nested in another " \
       'condition' do
      inspect_source(cop, <<-END.strip_indent)
        [].each do |o|
          if foo
            #{condition} o == 1
              puts o
            else
              puts 'no'
            end
          end
        end
      END

      expect(cop.offenses).to be_empty
    end

    it "allows loops with #{condition} with else at the end" do
      inspect_source(cop, <<-END.strip_indent)
        [].each do |o|
          puts o
          #{condition} o == 1
            puts o
          else
            puts 'no'
          end
        end
      END

      expect(cop.offenses).to be_empty
    end

    it "reports an offense for #{condition} whose body has 3 lines" do
      inspect_source(cop, <<-END.strip_indent)
        arr.each do |e|
          #{condition} something
            work
            work
            work
          end
        end
      END

      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(["#{condition} something"])
    end

    context 'EnforcedStyle: skip_modifier_ifs' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'skip_modifier_ifs' }
      end

      it "allows modifier #{condition}" do
        inspect_source(cop, <<-END.strip_indent)
          [].each do |o|
            puts o #{condition} o == 1
          end
        END

        expect(cop.offenses).to be_empty
      end
    end

    context 'EnforcedStyle: always' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'always' }
      end
      let(:opposite) { condition == 'if' ? 'unless' : 'if' }
      let(:source) do
        <<-END.strip_indent
          [].each do |o|
            puts o #{condition} o == 1 # comment
          end
        END
      end

      it "registers an offense for modifier #{condition}" do
        inspect_source(cop, source)

        expect(cop.messages).to eq(['Use `next` to skip iteration.'])
        expect(cop.highlights).to eq(["puts o #{condition} o == 1"])
      end

      it "auto-corrects modifier #{condition}" do
        corrected = autocorrect_source(cop, source)
        expect(corrected).to eq(<<-END.strip_indent)
          [].each do |o|
            next #{opposite} o == 1
            puts o # comment
          end
        END
      end
    end

    it 'auto-corrects a misaligned end' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        [1, 2, 3, 4].each do |num|
          if !opts.nil?
            puts num
            if num != 2
              puts 'hello'
              puts 'world'
            end
         end
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        [1, 2, 3, 4].each do |num|
          next unless !opts.nil?
          puts num
          if num != 2
            puts 'hello'
            puts 'world'
          end
        end
      END
    end
  end

  it 'keeps comments when autocorrecting' do
    new_source = autocorrect_source(cop, ['loop do',
                                          '  if test # keep me',
                                          '    # keep me',
                                          '    something # keep me',
                                          '    # keep me',
                                          '    ',
                                          '  end # keep me',
                                          'end'])
    expect(new_source).to eq(['loop do',
                              '  next unless test # keep me',
                              '  # keep me',
                              '  something # keep me',
                              '  # keep me',
                              '    ',
                              ' # keep me',
                              'end'].join("\n"))
  end

  it 'handles `then` when autocorrecting' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      loop do
        if test then
          something
        end
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      loop do
        next unless test
        something
      end
    END
  end

  it "doesn't reindent heredoc bodies when autocorrecting" do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      loop do
        if test
          str = <<-BLAH
        this is a heredoc
         nice eh?
          BLAH
          something
        end
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      loop do
        next unless test
        str = <<-BLAH
        this is a heredoc
         nice eh?
        BLAH
        something
      end
    END
  end

  it 'handles nested autocorrections' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      loop do
        if test
          loop do
            if test
              something
            end
          end
        end
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      loop do
        next unless test
        loop do
          next unless test
          something
        end
      end
    END
  end

  it_behaves_like 'iterators', 'if'
  it_behaves_like 'iterators', 'unless'

  it 'allows empty blocks' do
    expect_no_offenses(<<-END.strip_indent)
      [].each do
      end
      [].each { }
    END
  end

  it 'allows loops with conditions at the end with ternary op' do
    expect_no_offenses(<<-END.strip_indent)
      [].each do |o|
        o == x ? y : z
      end
    END
  end

  it 'allows super nodes' do
    # https://github.com/bbatsov/rubocop/issues/1115
    expect_no_offenses(<<-END.strip_indent)
      def foo
        super(a, a) { a }
      end
    END
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
    expect_no_offenses(<<-END.strip_indent)
      loop do
        if true
        end
      end
    END
  end

  it 'does not crash with empty brackets' do
    expect_no_offenses(<<-END.strip_indent)
      loop do
        ()
      end
    END
  end

  context 'MinBodyLength: 3' do
    let(:cop_config) do
      { 'MinBodyLength' => 3 }
    end

    it 'accepts if whose body has 1 line' do
      expect_no_offenses(<<-END.strip_indent)
        arr.each do |e|
          if something
            work
          end
        end
      END
    end
  end

  context 'Invalid MinBodyLength' do
    let(:cop_config) do
      { 'MinBodyLength' => -2 }
    end

    it 'fails with an error' do
      source = <<-END.strip_indent
        loop do
          if o == 1
            puts o
          end
        end
      END

      expect { inspect_source(cop, source) }
        .to raise_error('MinBodyLength needs to be a positive integer!')
    end
  end
end
