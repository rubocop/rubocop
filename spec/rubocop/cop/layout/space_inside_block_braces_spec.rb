# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideBlockBraces, :config do
  let(:supported_styles) { %w[space no_space] }
  let(:cop_config) do
    {
      'EnforcedStyle' => 'space',
      'SupportedStyles' => supported_styles,
      'SpaceBeforeBlockParameters' => true
    }
  end

  context 'with space inside empty braces not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'no_space' } }

    it 'accepts empty braces with no space inside' do
      expect_no_offenses('each {}')
    end

    it 'accepts braces with something inside' do
      expect_no_offenses('each { "f" }')
    end

    it 'accepts multiline braces with content' do
      expect_no_offenses(<<~RUBY)
        each { %(
        ) }
      RUBY
    end

    it 'accepts empty braces with comment and line break inside' do
      expect_no_offenses(<<~RUBY)
        each { # Comment
        }
      RUBY
    end

    it 'accepts empty braces with line break inside' do
      expect_no_offenses(<<-RUBY.strip_margin('|'))
        |  each {
        |  }
      RUBY
    end

    it 'registers an offense and corrects empty braces with space inside' do
      expect_offense(<<~RUBY)
        each { }
              ^ Space inside empty braces detected.
      RUBY

      expect_correction(<<~RUBY)
        each {}
      RUBY
    end

    it 'accepts braces that are not empty' do
      expect_no_offenses(<<~RUBY)
        a {
          b
        }
      RUBY
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'space' } }

    it 'accepts empty braces with space inside' do
      expect_no_offenses('each { }')
    end

    it 'registers an offense and corrects empty braces with no space inside' do
      expect_offense(<<~RUBY)
        each {}
             ^^ Space missing inside empty braces.
      RUBY

      expect_correction(<<~RUBY)
        each { }
      RUBY
    end
  end

  context 'with invalid value for EnforcedStyleForEmptyBraces' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'unknown' } }

    it 'fails with an error' do
      expect { expect_no_offenses('each { }') }
        .to raise_error('Unknown EnforcedStyleForEmptyBraces selected!')
    end
  end

  context 'Ruby >= 2.7', :ruby27 do
    it 'registers an offense for numblocks without inner space' do
      expect_offense(<<~RUBY)
        [1, 2, 3].each {_1 * 2}
                        ^ Space missing inside {.
                              ^ Space missing inside }.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].each { _1 * 2 }
      RUBY
    end
  end

  it 'accepts braces surrounded by spaces' do
    expect_no_offenses('each { puts }')
  end

  it 'accepts left brace without outer space' do
    expect_no_offenses('each{ puts }')
  end

  it 'registers an offense and corrects left brace without inner space' do
    expect_offense(<<~RUBY)
      each {puts }
            ^ Space missing inside {.
    RUBY

    expect_correction(<<~RUBY)
      each { puts }
    RUBY
  end

  it 'registers an offense and corrects right brace without inner space' do
    expect_offense(<<~RUBY)
      each { puts}
                 ^ Space missing inside }.
    RUBY

    expect_correction(<<~RUBY)
      each { puts }
    RUBY
  end

  it 'registers an offense and corrects both left and right brace without inner space after success' do
    expect_offense(<<~RUBY)
      each { puts }
      each {puts}
            ^ Space missing inside {.
                ^ Space missing inside }.
    RUBY

    expect_correction(<<~RUBY)
      each { puts }
      each { puts }
    RUBY
  end

  it 'register offenses and correct both braces without inner space' do
    expect_offense(<<~RUBY)
      a {}
      b { }
         ^ Space inside empty braces detected.
      each {puts}
            ^ Space missing inside {.
                ^ Space missing inside }.
    RUBY

    expect_correction(<<~RUBY)
      a {}
      b {}
      each { puts }
    RUBY
  end

  context 'with passed in parameters' do
    context 'for single-line blocks' do
      it 'accepts left brace with inner space' do
        expect_no_offenses('each { |x| puts }')
      end

      it 'registers an offense and corrects left brace without inner space' do
        expect_offense(<<~RUBY)
          each {|x| puts }
               ^^ Space between { and | missing.
        RUBY

        expect_correction(<<~RUBY)
          each { |x| puts }
        RUBY
      end
    end

    context 'for multi-line blocks' do
      it 'accepts left brace with inner space' do
        expect_no_offenses(<<~RUBY)
          each { |x|
            puts
          }
        RUBY
      end

      it 'registers an offense and corrects left brace without inner space' do
        expect_offense(<<~RUBY)
          each {|x|
               ^^ Space between { and | missing.
            puts
          }
        RUBY

        expect_correction(<<~RUBY)
          each { |x|
            puts
          }
        RUBY
      end
    end

    it 'accepts new lambda syntax' do
      expect_no_offenses('->(x) { x }')
    end

    context 'and BlockDelimiters cop enabled' do
      let(:config) do
        RuboCop::Config.new('Style/BlockDelimiters' => { 'Enabled' => true },
                            'Layout/SpaceInsideBlockBraces' => cop_config)
      end

      it 'registers an offense and corrects for single-line blocks' do
        expect_offense(<<~RUBY)
          each {|x| puts}
                        ^ Space missing inside }.
               ^^ Space between { and | missing.
        RUBY

        expect_correction(<<~RUBY)
          each { |x| puts }
        RUBY
      end

      it 'registers an offense and corrects multi-line blocks' do
        expect_offense(<<~RUBY)
          each {|x|
               ^^ Space between { and | missing.
            puts
          }
        RUBY

        expect_correction(<<~RUBY)
          each { |x|
            puts
          }
        RUBY
      end
    end

    context 'and space before block parameters not allowed' do
      let(:cop_config) do
        {
          'EnforcedStyle'              => 'space',
          'SupportedStyles'            => supported_styles,
          'SpaceBeforeBlockParameters' => false
        }
      end

      it 'registers an offense and corrects left brace with inner space' do
        expect_offense(<<~RUBY)
          each { |x| puts }
                ^ Space between { and | detected.
        RUBY

        expect_correction(<<~RUBY)
          each {|x| puts }
        RUBY
      end

      it 'accepts new lambda syntax' do
        expect_no_offenses('->(x) { x }')
      end

      it 'accepts left brace without inner space' do
        expect_no_offenses('each {|x| puts }')
      end
    end
  end

  context 'configured with no_space' do
    let(:cop_config) do
      {
        'EnforcedStyle'              => 'no_space',
        'SupportedStyles'            => supported_styles,
        'SpaceBeforeBlockParameters' => true
      }
    end

    it 'accepts braces without spaces inside' do
      expect_no_offenses('each {puts}')
    end

    it 'registers an offense and corrects left brace with inner space' do
      expect_offense(<<~RUBY)
        each { puts}
              ^ Space inside { detected.
      RUBY

      expect_correction(<<~RUBY)
        each {puts}
      RUBY
    end

    it 'registers an offense and corrects right brace with inner space' do
      expect_offense(<<~RUBY)
        each {puts }
                  ^ Space inside } detected.
      RUBY

      expect_correction(<<~RUBY)
        each {puts}
      RUBY
    end

    it 'registers an offense and corrects both left and right brace with inner space after success' do
      expect_offense(<<~RUBY)
        each {puts}
        each { puts }
              ^ Space inside { detected.
                   ^ Space inside } detected.
      RUBY

      expect_correction(<<~RUBY)
        each {puts}
        each {puts}
      RUBY
    end

    it 'accepts left brace without outer space' do
      expect_no_offenses('each{puts}')
    end

    it 'accepts when a method call with a multiline block is used as an argument' do
      expect_no_offenses(<<~RUBY)
        foo bar { |arg|
          baz(arg)
        }
      RUBY
    end

    context 'with passed in parameters' do
      context 'and space before block parameters allowed' do
        it 'accepts left brace with inner space' do
          expect_no_offenses('each { |x| puts}')
        end

        it 'registers an offense and corrects left brace without inner space' do
          expect_offense(<<~RUBY)
            each {|x| puts}
                 ^^ Space between { and | missing.
          RUBY

          expect_correction(<<~RUBY)
            each { |x| puts}
          RUBY
        end

        it 'accepts new lambda syntax' do
          expect_no_offenses('->(x) {x}')
        end
      end

      context 'and space before block parameters not allowed' do
        let(:cop_config) do
          {
            'EnforcedStyle'              => 'no_space',
            'SupportedStyles'            => supported_styles,
            'SpaceBeforeBlockParameters' => false
          }
        end

        it 'registers an offense and corrects left brace with inner space' do
          expect_offense(<<~RUBY)
            each { |x| puts}
                  ^ Space between { and | detected.
          RUBY

          expect_correction(<<~RUBY)
            each {|x| puts}
          RUBY
        end

        it 'accepts new lambda syntax' do
          expect_no_offenses('->(x) {x}')
        end

        it 'accepts when braces are aligned in multiline block' do
          expect_no_offenses(<<~RUBY)
            items.map {|item|
              item.do_something
            }
          RUBY
        end

        it 'registers an offense when braces are not aligned in multiline block' do
          expect_offense(<<~RUBY)
            items.map {|item|
              item.do_something
              }
            ^^ Space inside } detected.
          RUBY

          expect_correction(<<~RUBY)
            items.map {|item|
              item.do_something
            }
          RUBY
        end

        it 'accepts when braces are aligned in multiline block with bracket' do
          expect_no_offenses(<<~RUBY)
            foo {[
              bar
            ]}
          RUBY
        end

        it 'registers an offense when braces are not aligned in multiline block with bracket' do
          expect_offense(<<~RUBY)
            foo {[
              bar
              ]}
            ^^ Space inside } detected.
          RUBY

          expect_correction(<<~RUBY)
            foo {[
              bar
            ]}
          RUBY
        end
      end
    end
  end
end
