# frozen_string_literal: true

describe RuboCop::Cop::Layout::AlignArray do
  subject(:cop) { described_class.new }

  it 'registers an offense for misaligned array elements' do
    inspect_source(cop, <<-END.strip_indent)
      array = [
        a,
         b,
        c,
         d
      ]
    END
    expect(cop.messages).to eq(['Align the elements of an array ' \
                                'literal if they span more than ' \
                                'one line.'] * 2)
    expect(cop.highlights).to eq(%w[b d])
  end

  it 'accepts aligned array keys' do
    expect_no_offenses(<<-END.strip_indent)
      array = [
        a,
        b,
        c,
        d
      ]
    END
  end

  it 'accepts single line array' do
    expect_no_offenses('array = [ a, b ]')
  end

  it 'accepts several elements per line' do
    expect_no_offenses(<<-END.strip_indent)
      array = [ a, b,
                c, d ]
    END
  end

  it 'accepts aligned array with fullwidth characters' do
    expect_no_offenses(<<-END.strip_indent)
      puts 'Ｒｕｂｙ', [ a,
                         b ]
    END
  end

  it 'auto-corrects alignment' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      array = [
        a,
         b,
        c,
       d
      ]
    END
    expect(new_source).to eq(<<-END.strip_indent)
      array = [
        a,
        b,
        c,
        d
      ]
    END
  end

  it 'does not auto-correct array within array with too much indentation' do
    original_source = <<-END.strip_indent
      [:l1,
        [:l2,

          [:l3,
           [:l4]]]]
    END
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(<<-END.strip_indent)
      [:l1,
       [:l2,

         [:l3,
          [:l4]]]]
    END
  end

  it 'does not auto-correct array within array with too little indentation' do
    original_source = <<-END.strip_indent
      [:l1,
      [:l2,

        [:l3,
         [:l4]]]]
    END
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(<<-END.strip_indent)
      [:l1,
       [:l2,

         [:l3,
          [:l4]]]]
    END
  end

  it 'auto-corrects only elements that begin a line' do
    original_source = <<-END.strip_indent
      array = [:bar, {
               whiz: 2, bang: 3 }, option: 3]
    END
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(original_source)
  end

  it 'does not indent heredoc strings in autocorrect' do
    original_source = <<-END.strip_indent
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
    END
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(<<-END.strip_indent)
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
    END
  end
end
