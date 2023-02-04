# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ArrayAlignment, :config do
  let(:config) do
    RuboCop::Config.new('Layout/ArrayAlignment' => cop_config,
                        'Layout/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'when aligned with first parameter' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_first_element' } }

    it 'registers an offense and corrects misaligned array elements' do
      expect_offense(<<~RUBY)
        array = [a,
           b,
           ^ Align the elements of an array literal if they span more than one line.
          c,
          ^ Align the elements of an array literal if they span more than one line.
           d]
           ^ Align the elements of an array literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        array = [a,
                 b,
                 c,
                 d]
      RUBY
    end

    it 'accepts aligned array keys' do
      expect_no_offenses(<<~RUBY)
        array = [a,
                 b,
                 c,
                 d]
      RUBY
    end

    it 'accepts single line array' do
      expect_no_offenses('array = [ a, b ]')
    end

    it 'accepts several elements per line' do
      expect_no_offenses(<<~RUBY)
        array = [ a, b,
                  c, d ]
      RUBY
    end

    it 'accepts aligned array with fullwidth characters' do
      expect_no_offenses(<<~RUBY)
        puts 'Ｒｕｂｙ', [ a,
                           b ]
      RUBY
    end

    it 'autocorrects array within array with too much indentation' do
      expect_offense(<<~RUBY)
        [:l1,
          [:l2,
          ^^^^^ Align the elements of an array literal if they span more than one line.
            [:l3,
            ^^^^^ Align the elements of an array literal if they span more than one line.
             [:l4]]]]
      RUBY

      expect_correction(<<~RUBY, loop: false)
        [:l1,
         [:l2,
           [:l3,
            [:l4]]]]
      RUBY
    end

    it 'autocorrects array within array with too little indentation' do
      expect_offense(<<~RUBY)
        [:l1,
        [:l2,
        ^^^^^ Align the elements of an array literal if they span more than one line.
          [:l3,
          ^^^^^ Align the elements of an array literal if they span more than one line.
           [:l4]]]]
      RUBY

      expect_correction(<<~RUBY, loop: false)
        [:l1,
         [:l2,
           [:l3,
            [:l4]]]]
      RUBY
    end

    it 'does not indent heredoc strings when autocorrecting' do
      expect_offense(<<~RUBY)
        var = [
               { :type => 'something',
                 :sql => <<EOF
        Select something
        from atable
        EOF
               },
              { :type => 'something',
              ^^^^^^^^^^^^^^^^^^^^^^^ Align the elements of an array literal if they span more than one line.
                :sql => <<EOF
        Select something
        from atable
        EOF
              }
        ]
      RUBY

      expect_correction(<<~RUBY)
        var = [
               { :type => 'something',
                 :sql => <<EOF
        Select something
        from atable
        EOF
               },
               { :type => 'something',
                 :sql => <<EOF
        Select something
        from atable
        EOF
               }
        ]
      RUBY
    end

    it 'accepts the first element being on a new row' do
      expect_no_offenses(<<~RUBY)
        array = [
          a,
          b,
          c,
          d
        ]
      RUBY
    end

    it 'autocorrects misaligned array with the first element on a new row' do
      expect_offense(<<~RUBY)
        array = [
          a,
           b,
           ^ Align the elements of an array literal if they span more than one line.
          c,
           d
           ^ Align the elements of an array literal if they span more than one line.
        ]
      RUBY

      expect_correction(<<~RUBY)
        array = [
          a,
          b,
          c,
          d
        ]
      RUBY
    end

    it 'does not register an offense or try to correct parallel assignment' do
      expect_no_offenses(<<~RUBY)
        thing, foo =
          1, 2
      RUBY
    end
  end

  context 'when aligned with fixed indentation' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_fixed_indentation' } }

    it 'registers an offense and corrects misaligned array elements' do
      expect_offense(<<~RUBY)
        array = [a,
           b,
           ^ Use one level of indentation for elements following the first line of a multi-line array.
          c,
           d]
           ^ Use one level of indentation for elements following the first line of a multi-line array.
      RUBY

      expect_correction(<<~RUBY)
        array = [a,
          b,
          c,
          d]
      RUBY
    end

    it 'accepts aligned array keys' do
      expect_no_offenses(<<~RUBY)
        array = [a,
          b,
          c,
          d]
      RUBY
    end

    it 'accepts when assigning aligned bracketed array elements' do
      expect_no_offenses(<<~RUBY)
        var = [
          first,
          second
        ]
      RUBY
    end

    it 'accepts when assigning aligned unbracketed array elements' do
      expect_no_offenses(<<~RUBY)
        var =
          first,
          second
      RUBY
    end

    it 'registers an offense when assigning not aligned unbracketed array elements' do
      expect_offense(<<~RUBY)
        var =
             first,
             ^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
            second
            ^^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
      RUBY

      expect_correction(<<~RUBY)
        var =
          first,
          second
      RUBY
    end

    it 'accepts single line array' do
      expect_no_offenses('array = [ a, b ]')
    end

    it 'accepts several elements per line' do
      expect_no_offenses(<<~RUBY)
        array = [ a, b,
          c, d ]
      RUBY
    end

    it 'accepts aligned array with fullwidth characters' do
      expect_no_offenses(<<~RUBY)
        puts 'Ｒｕｂｙ', [ a,
          b ]
      RUBY
    end

    it 'autocorrects array within array with too much indentation' do
      expect_offense(<<~RUBY)
        [:l1,
           [:l2,
           ^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
              [:l3,
              ^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
                [:l4]]]]
      RUBY

      expect_correction(<<~RUBY, loop: false)
        [:l1,
          [:l2,
             [:l3,
               [:l4]]]]
      RUBY
    end

    it 'autocorrects array within array with too little indentation' do
      expect_offense(<<~RUBY)
        [:l1,
         [:l2,
         ^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
          [:l3,
          ^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
            [:l4]]]]
      RUBY

      expect_correction(<<~RUBY, loop: false)
        [:l1,
          [:l2,
           [:l3,
             [:l4]]]]
      RUBY
    end

    it 'does not indent heredoc strings when autocorrecting' do
      expect_offense(<<~RUBY)
        var = [
          { :type => 'something',
            :sql => <<EOF
        Select something
        from atable
        EOF
          },
         { :type => 'something',
         ^^^^^^^^^^^^^^^^^^^^^^^ Use one level of indentation for elements following the first line of a multi-line array.
           :sql => <<EOF
        Select something
        from atable
        EOF
         }
        ]
      RUBY

      expect_correction(<<~RUBY)
        var = [
          { :type => 'something',
            :sql => <<EOF
        Select something
        from atable
        EOF
          },
          { :type => 'something',
            :sql => <<EOF
        Select something
        from atable
        EOF
          }
        ]
      RUBY
    end

    it 'accepts the first element being on a new row' do
      expect_no_offenses(<<~RUBY)
        array = [
          a,
          b,
          c,
          d
        ]
      RUBY
    end

    it 'autocorrects misaligned array with the first element on a new row' do
      expect_offense(<<~RUBY)
        array = [
          a,
           b,
           ^ Use one level of indentation for elements following the first line of a multi-line array.
          c,
           d
           ^ Use one level of indentation for elements following the first line of a multi-line array.
        ]
      RUBY

      expect_correction(<<~RUBY)
        array = [
          a,
          b,
          c,
          d
        ]
      RUBY
    end

    it 'does not register an offense or try to correct parallel assignment' do
      expect_no_offenses(<<~RUBY)
        thing, foo =
          1, 2
      RUBY
    end
  end
end
