# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::BlockNesting, :config do
  let(:cop_config) { { 'Max' => 2 } }

  it 'accepts `Max` levels of nesting' do
    expect_no_offenses(<<~RUBY)
      if a
        if b
          puts b
        end
      end
    RUBY
  end

  context '`Max + 1` levels of `if` nesting' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            if c
            ^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
      RUBY
      expect(cop.config_to_allow_offenses[:exclude_limit]).to eq('Max' => 3)
    end
  end

  context '`Max + 2` levels of `if` nesting' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            if c
            ^^^^ Avoid more than 2 levels of block nesting.
              if d
                puts d
              end
            end
          end
        end
      RUBY
      expect(cop.config_to_allow_offenses[:exclude_limit]).to eq('Max' => 4)
    end
  end

  context 'Multiple nested `ifs` at same level' do
    it 'registers 2 offenses' do
      expect_offense(<<~RUBY)
        if a
          if b
            if c
            ^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
          if d
            if e
            ^^^^ Avoid more than 2 levels of block nesting.
              puts e
            end
          end
        end
      RUBY
      expect(cop.config_to_allow_offenses[:exclude_limit]).to eq('Max' => 3)
    end
  end

  context 'nested `case`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            case c
            ^^^^^^ Avoid more than 2 levels of block nesting.
              when C
                puts C
            end
          end
        end
      RUBY
    end
  end

  context 'nested `case` as a pattern matching', :ruby27 do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            case c
            ^^^^^^ Avoid more than 2 levels of block nesting.
              in C
                puts C
            end
          end
        end
      RUBY
    end
  end

  context 'nested `while`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            while c
            ^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
      RUBY
    end
  end

  context 'nested modifier `while`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            begin
            ^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end while c
          end
        end
      RUBY
    end
  end

  context 'nested `until`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            until c
            ^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
      RUBY
    end
  end

  context 'nested modifier `until`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            begin
            ^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end until c
          end
        end
      RUBY
    end
  end

  context 'nested `for`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            for c in [1,2] do
            ^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
      RUBY
    end
  end

  context 'nested `rescue`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a
          if b
            begin
              puts c
            rescue
            ^^^^^^ Avoid more than 2 levels of block nesting.
              puts x
            end
          end
        end
      RUBY
    end
  end

  it 'accepts if/elsif' do
    expect_no_offenses(<<~RUBY)
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
      expect_no_offenses(<<~RUBY)
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
      expect_no_offenses(<<~RUBY)
        if a
          if b
            [1, 2].each { |c| puts c }
          end
        end
      RUBY
    end

    context 'when numbered parameter', :ruby27 do
      it 'accepts nested multiline blocks' do
        expect_no_offenses(<<~RUBY)
          if a
            if b
              [1, 2].each do
                puts _1
              end
            end
          end
        RUBY
      end

      it 'accepts nested inline blocks' do
        expect_no_offenses(<<~RUBY)
          if a
            if b
              [1, 2].each { puts _1 }
            end
          end
        RUBY
      end
    end
  end

  context 'when CountBlocks is true' do
    let(:cop_config) { { 'Max' => 2, 'CountBlocks' => true } }

    context 'nested multiline block' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          if a
            if b
              [1, 2].each do |c|
              ^^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
                puts c
              end
            end
          end
        RUBY
      end
    end

    context 'nested inline block' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          if a
            if b
              [1, 2].each { |c| puts c }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
            end
          end
        RUBY
      end
    end

    context 'when numbered parameter', :ruby27 do
      context 'nested multiline block' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            if a
              if b
                [1, 2].each do
                ^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
                  puts _1
                end
              end
            end
          RUBY
        end
      end

      context 'nested inline block' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            if a
              if b
                [1, 2].each { puts _1 }
                ^^^^^^^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
              end
            end
          RUBY
        end
      end
    end
  end
end
