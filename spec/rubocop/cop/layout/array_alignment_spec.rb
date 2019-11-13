# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ArrayAlignment do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects misaligned array elements' do
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

  it 'accepts aligned array keys' do
    expect_no_offenses(<<~RUBY)
      array = [
        a,
        b,
        c,
        d
      ]
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

  it 'does not auto-correct array within array with too much indentation' do
    expect_offense(<<~RUBY)
      [:l1,
        [:l2,
        ^^^^^ Align the elements of an array literal if they span more than one line.

          [:l3,
          ^^^^^ Align the elements of an array literal if they span more than one line.
           [:l4]]]]
    RUBY

    expect_correction(<<~RUBY)
      [:l1,
       [:l2,

         [:l3,
          [:l4]]]]
    RUBY
  end

  it 'does not auto-correct array within array with too little indentation' do
    expect_offense(<<~RUBY)
      [:l1,
      [:l2,
      ^^^^^ Align the elements of an array literal if they span more than one line.

        [:l3,
        ^^^^^ Align the elements of an array literal if they span more than one line.
         [:l4]]]]
    RUBY

    expect_correction(<<~RUBY)
      [:l1,
       [:l2,

         [:l3,
          [:l4]]]]
    RUBY
  end

  it 'does not indent heredoc strings in autocorrect' do
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
end
