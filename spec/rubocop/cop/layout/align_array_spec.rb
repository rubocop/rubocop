# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::AlignArray do
  subject(:cop) { described_class.new }

  it 'registers an offense for misaligned array elements' do
    expect_offense(<<-RUBY.strip_indent)
      array = [
        a,
         b,
         ^ Align the elements of an array literal if they span more than one line.
        c,
         d
         ^ Align the elements of an array literal if they span more than one line.
      ]
    RUBY
  end

  it 'accepts aligned array keys' do
    expect_no_offenses(<<-RUBY.strip_indent)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      array = [ a, b,
                c, d ]
    RUBY
  end

  it 'accepts aligned array with fullwidth characters' do
    expect_no_offenses(<<-RUBY.strip_indent)
      puts 'Ｒｕｂｙ', [ a,
                         b ]
    RUBY
  end

  it 'auto-corrects alignment' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      array = [
        a,
         b,
        c,
       d
      ]
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      array = [
        a,
        b,
        c,
        d
      ]
    RUBY
  end

  it 'does not auto-correct array within array with too much indentation' do
    original_source = <<-RUBY.strip_indent
      [:l1,
        [:l2,

          [:l3,
           [:l4]]]]
    RUBY
    new_source = autocorrect_source(original_source)
    expect(new_source).to eq(<<-RUBY.strip_indent)
      [:l1,
       [:l2,

         [:l3,
          [:l4]]]]
    RUBY
  end

  it 'does not auto-correct array within array with too little indentation' do
    original_source = <<-RUBY.strip_indent
      [:l1,
      [:l2,

        [:l3,
         [:l4]]]]
    RUBY
    new_source = autocorrect_source(original_source)
    expect(new_source).to eq(<<-RUBY.strip_indent)
      [:l1,
       [:l2,

         [:l3,
          [:l4]]]]
    RUBY
  end

  it 'auto-corrects only elements that begin a line' do
    original_source = <<-RUBY.strip_indent
      array = [:bar, {
               whiz: 2, bang: 3 }, option: 3]
    RUBY
    new_source = autocorrect_source(original_source)
    expect(new_source).to eq(original_source)
  end

  it 'does not indent heredoc strings in autocorrect' do
    original_source = <<-RUBY.strip_indent
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
    new_source = autocorrect_source(original_source)
    expect(new_source).to eq(<<-RUBY.strip_indent)
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
