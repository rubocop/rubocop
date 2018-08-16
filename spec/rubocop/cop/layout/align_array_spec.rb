# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::AlignArray do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/AlignArray' => cop_config,
                        'Layout/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'aligned with first value' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'with_first_value' }
    end

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

  context 'aligned with fixed indentation' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_fixed_indentation'
      }
    end

    let(:correct_source) do
      <<-RUBY.strip_indent
        ['a', 'b',
          'c',
          'd']
      RUBY
    end

    it 'does not autocorrect correct source' do
      expect(autocorrect_source(correct_source))
        .to eq(correct_source)
    end

    it 'autocorrects by outdenting when indented too far' do
      original_source = <<-RUBY.strip_indent
        ['a', 'b',
              'c',
              'd']
      RUBY

      expect(autocorrect_source(original_source))
        .to eq(correct_source)
    end

    it 'autocorrects by indenting when not indented' do
      original_source = <<-RUBY.strip_indent
        ['a', 'b',
        'c',
        'd']
      RUBY

      expect(autocorrect_source(original_source))
        .to eq(correct_source)
    end

    it 'autocorrects when first line is indented' do
      original_source = <<-RUBY.strip_margin('|')
        |  ['a', 'b',
        |  'c',
        |  'd']
      RUBY

      correct_source = <<-RUBY.strip_margin('|')
        |  ['a', 'b',
        |    'c',
        |    'd']
      RUBY

      expect(autocorrect_source(original_source))
        .to eq(correct_source)
    end

    it "doesn't get confused by splat" do
      expect_offense(<<-RUBY.strip_indent)
        [a,
         *b,
         ^^ Use one level of indentation for values following the first line of a multi-line array.
          c,
        ]
      RUBY
    end

    context 'multi-line method calls' do
      it 'can handle existing indentation from multi-line method calls' do
        expect_no_offenses(<<-RUBY.strip_indent)
           something
             .method_name(['a',
               'b'])
        RUBY
      end

      it 'registers offenses for double indentation from relevant method' do
        expect_offense(<<-RUBY.strip_indent)
           something
             .method_name(['a',
             'b'])
             ^^^ Use one level of indentation for values following the first line of a multi-line array.
        RUBY
      end
    end

    context 'assigned arrays' do
      context 'with IndentationWidth:Width set to 4' do
        let(:indentation_width) { 4 }

        it 'accepts the first parameter being on a new row' do
          expect_no_offenses(<<-RUBY.strip_indent)
             assigned_value = [
                 a,
                 b,
                 c
             ]
          RUBY
        end

        it 'accepts the first parameter being on bracket row' do
          expect_no_offenses(<<-RUBY.strip_indent)
             assigned_value = [a,
                 b,
                 c
             ]
          RUBY
        end

        it 'autocorrects even when first argument is in wrong position' do
          original_source = <<-RUBY.strip_margin('|')
            | assigned_value = [
            |         a,
            |            b,
            |                    c
            | ]
          RUBY

          correct_source = <<-RUBY.strip_margin('|')
            | assigned_value = [
            |     a,
            |     b,
            |     c
            | ]
          RUBY

          expect(autocorrect_source(original_source))
            .to eq(correct_source)
        end
      end

      context 'with Layout/AlignArray:IndentationWidth set to 4' do
        let(:config) do
          RuboCop::Config.new('Layout/AlignArray' =>
                              cop_config.merge('IndentationWidth' => 4))
        end

        it 'accepts the first parameter being on a new row' do
          expect_no_offenses(<<-RUBY.strip_indent)
             assigned_value = [
                 a,
                 b,
                 c
             ]
          RUBY
        end

        it 'accepts the first parameter being on bracket row' do
          expect_no_offenses(<<-RUBY.strip_indent)
             assigned_value = [a,
                 b,
                 c
             ]
          RUBY
        end

        it 'autocorrects even when first argument is in wrong position' do
          original_source = <<-RUBY.strip_margin('|')
            | assigned_value = [
            |         a,
            |            b,
            |                    c
            | ]
          RUBY

          correct_source = <<-RUBY.strip_margin('|')
            | assigned_value = [
            |     a,
            |     b,
            |     c
            | ]
          RUBY

          expect(autocorrect_source(original_source))
            .to eq(correct_source)
        end
      end
    end
  end
end
