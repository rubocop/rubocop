# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideStringInterpolation, :config do
  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    context 'for ill-formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<~'RUBY')
          "#{ var}"
             ^ Do not use space inside string interpolation.
          "#{var }"
                ^ Do not use space inside string interpolation.
          "#{   var   }"
             ^^^ Do not use space inside string interpolation.
                   ^^^ Do not use space inside string interpolation.
          "#{var	}"
                ^ Do not use space inside string interpolation.
          "#{	var	}"
             ^ Do not use space inside string interpolation.
                 ^ Do not use space inside string interpolation.
          "#{	var}"
             ^ Do not use space inside string interpolation.
          "#{ 	 var 	 	}"
             ^^^ Do not use space inside string interpolation.
                   ^^^^ Do not use space inside string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
        RUBY
      end

      it 'finds interpolations in string-like contexts' do
        expect_offense(<<~'RUBY')
          /regexp #{ var}/
                    ^ Do not use space inside string interpolation.
          `backticks #{ var}`
                       ^ Do not use space inside string interpolation.
          :"symbol #{ var}"
                     ^ Do not use space inside string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          /regexp #{var}/
          `backticks #{var}`
          :"symbol #{var}"
        RUBY
      end
    end

    context 'for "space" style formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<~'RUBY')
          "#{ var }"
             ^ Do not use space inside string interpolation.
                 ^ Do not use space inside string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{var}"
        RUBY
      end
    end

    it 'does not touch spaces inside the interpolated expression' do
      expect_offense(<<~'RUBY')
        "#{ a; b }"
           ^ Do not use space inside string interpolation.
                ^ Do not use space inside string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{a; b}"
      RUBY
    end

    context 'for well-formatted string interpolations' do
      it 'accepts excess literal spacing' do
        expect_no_offenses(<<~'RUBY')
          "Variable is    #{var}      "
          "  Variable is  #{var}"
        RUBY
      end
    end

    it 'accepts empty interpolation' do
      expect_no_offenses("\"\#{}\"")
    end

    context 'when interpolation starts or ends with a line break' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{
            code
          }"
        RUBY
      end

      it 'ignores comments and whitespace when looking for line breaks' do
        expect_no_offenses(<<~'RUBY')
          def foo
            "#{ # comment
              code
            }"
          end
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    context 'for ill-formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<~'RUBY')
          "#{ var}"
                 ^ Use space inside string interpolation.
          "#{var }"
           ^^ Use space inside string interpolation.
          "#{   var   }"
          "#{var	}"
           ^^ Use space inside string interpolation.
          "#{	var	}"
          "#{	var}"
                 ^ Use space inside string interpolation.
          "#{ 	 var 	 	}"
        RUBY

        # Extra space is handled by ExtraSpace cop.
        expect_correction(<<~'RUBY')
          "#{ var }"
          "#{ var }"
          "#{   var   }"
          "#{ var	}"
          "#{	var	}"
          "#{	var }"
          "#{ 	 var 	 	}"
        RUBY
      end
    end

    context 'for "no_space" style formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<~'RUBY')
          "#{var}"
           ^^ Use space inside string interpolation.
                ^ Use space inside string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{ var }"
        RUBY
      end
    end

    context 'for well-formatted string interpolations' do
      it 'does not register an offense for excess literal spacing' do
        expect_no_offenses(<<~'RUBY')
          "Variable is    #{ var }      "
          "  Variable is  #{ var }"
        RUBY
      end
    end

    it 'accepts empty interpolation' do
      expect_no_offenses("\"\#{}\"")
    end
  end
end
