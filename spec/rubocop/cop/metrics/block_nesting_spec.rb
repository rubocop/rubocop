# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::BlockNesting, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 2 } }

  shared_examples 'too deep' do |source, lines, max_to_allow = 3|
    it "registers #{lines.length} offense(s)" do
      inspect_source(source)
      expect(cop.offenses.map(&:line)).to eq(lines)
      expect(cop.messages).to eq(
        ['Avoid more than 2 levels of block nesting.'] * lines.length
      )
    end

    it 'sets `Max` value correctly' do
      inspect_source(source)
      expect(cop.config_to_allow_offenses['Max']).to eq(max_to_allow)
    end
  end

  it 'accepts `Max` levels of nesting' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
        if b
          puts b
        end
      end
    RUBY
  end

  context '`Max + 1` levels of `if` nesting' do
    source = <<-RUBY.strip_indent
      if a
        if b
          if c
            puts c
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context '`Max + 2` levels of `if` nesting' do
    source = <<-RUBY.strip_indent
      if a
        if b
          if c
            if d
              puts d
            end
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3], 4
  end

  context 'Multiple nested `ifs` at same level' do
    source = <<-RUBY.strip_indent
      if a
        if b
          if c
            puts c
          end
        end
        if d
          if e
            puts e
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3, 8]
  end

  context 'nested `case`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          case c
            when C
              puts C
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `while`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          while c
            puts c
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested modifier `while`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          begin
            puts c
          end while c
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `until`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          until c
            puts c
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested modifier `until`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          begin
            puts c
          end until c
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `for`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          for c in [1,2] do
            puts c
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `rescue`' do
    source = <<-RUBY.strip_indent
      if a
        if b
          begin
            puts c
          rescue
            puts x
          end
        end
      end
    RUBY
    it_behaves_like 'too deep', source, [5]
  end

  it 'accepts if/elsif' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if a
      elsif b
      elsif c
      elsif d
      end
    RUBY
  end

  context 'when CountBlocks is false' do
    let(:cop_config) { { 'Max' => 2, 'CountBlocks' => false } }

    it 'accepts nested multiline blocks' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if a
          if b
            [1, 2].each do |c|
              puts c
            end
          end
        end
      RUBY
    end

    it 'accepts nested inline blocks' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if a
          if b
            [1, 2].each { |c| puts c }
          end
        end
      RUBY
    end
  end

  context 'when CountBlocks is true' do
    let(:cop_config) { { 'Max' => 2, 'CountBlocks' => true } }

    context 'nested multiline block' do
      source = <<-RUBY.strip_indent
        if a
          if b
            [1, 2].each do |c|
              puts c
            end
          end
        end
      RUBY
      it_behaves_like 'too deep', source, [3]
    end

    context 'nested inline block' do
      source = <<-RUBY.strip_indent
        if a
          if b
            [1, 2].each { |c| puts c }
          end
        end
      RUBY
      it_behaves_like 'too deep', source, [3]
    end
  end
end
