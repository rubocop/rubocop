# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInLambdaLiteral, :config do
  subject(:cop) { described_class.new(config) }

  context 'when configured to enforce spaces' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_space' } }

    it 'registers an offense for no space between -> and (' do
      expect_offense(<<-RUBY.strip_indent)
        a = ->(b, c) { b + c }
            ^^^^^^^^^^^^^^^^^^ Use a space between `->` and opening brace in lambda literals
      RUBY
    end

    it 'does not register an offense for a space between -> and (' do
      expect_no_offenses('a = -> (b, c) { b + c }')
    end

    it 'does not register an offense for multi-line lambdas' do
      expect_no_offenses(<<-END.strip_indent)
        l = lambda do |a, b|
          tmp = a * 7
          tmp * b / 50
        end
      END
    end

    it 'does not register an offense for no space between -> and {' do
      expect_no_offenses('a = ->{ b + c }')
    end

    it 'registers an offense for no space in the inner nested lambda' do
      expect_offense(<<-RUBY.strip_indent)
        a = -> (b = ->(c) {}, d) { b + d }
                    ^^^^^^^^ Use a space between `->` and opening brace in lambda literals
      RUBY
    end

    it 'registers an offense for no space in the outer nested lambda' do
      expect_offense(<<-RUBY.strip_indent)
        a = ->(b = -> (c) {}, d) { b + d }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a space between `->` and opening brace in lambda literals
      RUBY
    end

    it 'registers an offense for no space in both lambdas when nested' do
      expect_offense(<<-RUBY.strip_indent)
        a = ->(b = ->(c) {}, d) { b + d }
                   ^^^^^^^^ Use a space between `->` and opening brace in lambda literals
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a space between `->` and opening brace in lambda literals
      RUBY
    end

    it 'autocorrects an offense for no space between -> and (' do
      code = 'a = ->(b, c) { b + c }'
      expected = 'a = -> (b, c) { b + c }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for no space in the inner nested lambda' do
      code = 'a = -> (b = ->(c) {}, d) { b + d }'
      expected = 'a = -> (b = -> (c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for no space in the outer nested lambda' do
      code = 'a = ->(b = -> (c) {}, d) { b + d }'
      expected = 'a = -> (b = -> (c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for no space in both lambdas when nested' do
      code = 'a = ->(b = ->(c) {}, d) { b + d }'
      expected = 'a = -> (b = -> (c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end
  end

  context 'when configured to enforce no space' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_space' } }

    it 'registers an offense for a space between -> and (' do
      expect_offense(<<-RUBY.strip_indent)
        a = -> (b, c) { b + c }
            ^^^^^^^^^^^^^^^^^^^ Do not use spaces between `->` and opening brace in lambda literals
      RUBY
    end

    it 'does not register an offense for no space between -> and (' do
      expect_no_offenses('a = ->(b, c) { b + c }')
    end

    it 'does not register an offense for multi-line lambdas' do
      expect_no_offenses(<<-END.strip_indent)
        l = lambda do |a, b|
          tmp = a * 7
          tmp * b / 50
        end
      END
    end

    it 'does not register an offense for a space between -> and {' do
      expect_no_offenses('a = -> { b + c }')
    end

    it 'registers an offense for spaces between -> and (' do
      expect_offense(<<-RUBY.strip_indent)
        a = ->   (b, c) { b + c }
            ^^^^^^^^^^^^^^^^^^^^^ Do not use spaces between `->` and opening brace in lambda literals
      RUBY
    end

    it 'registers an offense for a space in the inner nested lambda' do
      expect_offense(<<-RUBY.strip_indent)
        a = ->(b = -> (c) {}, d) { b + d }
                   ^^^^^^^^^ Do not use spaces between `->` and opening brace in lambda literals
      RUBY
    end

    it 'registers an offense for a space in the outer nested lambda' do
      expect_offense(<<-RUBY.strip_indent)
        a = -> (b = ->(c) {}, d) { b + d }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use spaces between `->` and opening brace in lambda literals
      RUBY
    end

    it 'registers two offenses for a space in both lambdas when nested' do
      expect_offense(<<-RUBY.strip_indent)
        a = -> (b = -> (c) {}, d) { b + d }
                    ^^^^^^^^^ Do not use spaces between `->` and opening brace in lambda literals
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use spaces between `->` and opening brace in lambda literals
      RUBY
    end

    it 'autocorrects an offense for a space between -> and (' do
      code = 'a = -> (b, c) { b + c }'
      expected = 'a = ->(b, c) { b + c }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for spaces between -> and (' do
      code = 'a = ->   (b, c) { b + c }'
      expected = 'a = ->(b, c) { b + c }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for a space in the inner nested lambda' do
      code = 'a = ->(b = -> (c) {}, d) { b + d }'
      expected = 'a = ->(b = ->(c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects an offense for a space in the outer nested lambda' do
      code = 'a = -> (b = ->(c) {}, d) { b + d }'
      expected = 'a = ->(b = ->(c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end

    it 'autocorrects two offenses for a space in both lambdas when nested' do
      code = 'a = -> (b = -> (c) {}, d) { b + d }'
      expected = 'a = ->(b = ->(c) {}, d) { b + d }'
      expect(autocorrect_source(cop, code)).to eq(expected)
    end
  end
end
