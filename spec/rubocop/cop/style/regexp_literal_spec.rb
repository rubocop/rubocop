# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RegexpLiteral, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w[slashes percent_r mixed]
    }
    RuboCop::Config.new('Style/PercentLiteralDelimiters' =>
                          percent_literal_delimiters_config,
                        'Style/RegexpLiteral' =>
                          cop_config.merge(supported_styles))
  end
  let(:percent_literal_delimiters_config) do
    { 'PreferredDelimiters' => { '%r' => '{}' } }
  end

  describe 'when regex contains slashes in interpolation' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    it 'ignores the slashes that do not belong // regex' do
      expect_no_offenses('x =~ /\s{#{x[/\s+/].length}}/')
    end
  end

  describe '%r regex with other delimiters than curly braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        %r_ls_
        ^^^^^^ Use `//` around regular expression.
      RUBY
    end
  end

  describe 'when PercentLiteralDelimiters is configured with brackets' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_r' } }
    let(:percent_literal_delimiters_config) do
      { 'PreferredDelimiters' => { '%r' => '[]' } }
    end

    it 'respects the configuration when auto-correcting' do
      new_source = autocorrect_source('/a/')
      expect(new_source).to eq('%r[a]')
    end
  end

  describe 'when PercentLiteralDelimiters is configured with slashes' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_r' } }
    let(:percent_literal_delimiters_config) do
      { 'PreferredDelimiters' => { '%r' => '//' } }
    end

    it 'respects the configuration when auto-correcting' do
      new_source = autocorrect_source('/\//')
      expect(new_source).to eq('%r/\//')
    end
  end

  context 'when EnforcedStyle is set to slashes' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    describe 'a single-line `//` regex without slashes' do
      it 'is accepted' do
        expect_no_offenses('foo = /a/')
      end
    end

    describe 'a single-line `//` regex with slashes' do
      let(:source) { 'foo = /home\//' }

      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          foo = /home\//
                ^^^^^^^^ Use `%r` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = %r{home/}')
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          expect_no_offenses('foo = /home\\//')
        end
      end
    end

    describe 'a single-line `//` regex with slashes and interpolation' do
      let(:source) { 'foo = /users\/#{user.id}\/forms/' }

      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          foo = /users\/#{user.id}\/forms/
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%r` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = %r{users/#{user.id}/forms}')
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          expect_no_offenses('foo = /users\/#{user.id}\/forms/')
        end
      end
    end

    describe 'a single-line `%r//` regex with slashes' do
      let(:source) { 'foo = %r/\//' }

      it 'is accepted' do
        expect_no_offenses(source)
      end

      context 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'remains slashes after auto-correction' do
          new_source = autocorrect_source(source)
          expect(new_source).to eq('foo = /\//')
        end
      end
    end

    describe 'a multi-line `//` regex without slashes' do
      it 'is accepted' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = /
            foo
            bar
          /x
        RUBY
      end
    end

    describe 'a multi-line `//` regex with slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent
          foo = /
            https?:\/\/
            example\.com
          /x
        RUBY
      end

      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<-'RUBY'.strip_indent)
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          expect_no_offenses(<<-'RUBY'.strip_indent)
            foo = /
              https?:\/\/
              example\.com
            /x
          RUBY
        end
      end
    end

    describe 'a single-line %r regex without slashes' do
      let(:source) { 'foo = %r{a}' }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          foo = %r{a}
                ^^^^^ Use `//` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = /a/')
      end
    end

    describe 'a single-line %r regex with slashes' do
      let(:source) { 'foo = %r{home/}' }

      it 'is accepted' do
        expect_no_offenses('foo = %r{home/}')
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            foo = %r{home/}
                  ^^^^^^^^^ Use `//` around regular expression.
          RUBY
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(source)
          expect(new_source).to eq('foo = /home\//')
        end
      end
    end

    describe 'a multi-line %r regex without slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent.chomp
          foo = %r{
            foo
            bar
          }x
        RUBY
      end

      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(['Use `//` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq("foo = /\n  foo\n  bar\n/x")
      end
    end

    describe 'a multi-line %r regex with slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end

      it 'is accepted' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'registers an offense' do
          inspect_source(source)
          expect(cop.messages).to eq(['Use `//` around regular expression.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(source)
          expect(new_source).to eq(<<-'RUBY'.strip_indent)
            foo = /
              https?:\/\/
              example\.com
            /x
          RUBY
        end
      end
    end
  end

  context 'when EnforcedStyle is set to percent_r' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_r' } }

    describe 'a single-line `//` regex without slashes' do
      let(:source) { 'foo = /a/' }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          foo = /a/
                ^^^ Use `%r` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = %r{a}')
      end
    end

    describe 'a single-line `//` regex with slashes' do
      let(:source) { 'foo = /home\//' }

      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          foo = /home\//
                ^^^^^^^^ Use `%r` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = %r{home/}')
      end
    end

    describe 'a multi-line `//` regex without slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent.chomp
          foo = /
            foo
            bar
          /x
        RUBY
      end

      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq("foo = %r{\n  foo\n  bar\n}x")
      end
    end

    describe 'a multi-line `//` regex with slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent
          foo = /
            https?:\/\/
            example\.com
          /x
        RUBY
      end

      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<-'RUBY'.strip_indent)
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end
    end

    describe 'a single-line %r regex without slashes' do
      it 'is accepted' do
        expect_no_offenses('foo = %r{a}')
      end
    end

    describe 'a single-line %r regex with slashes' do
      it 'is accepted' do
        expect_no_offenses('foo = %r{home/}')
      end
    end

    describe 'a multi-line %r regex without slashes' do
      it 'is accepted' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = %r{
            foo
            bar
          }x
        RUBY
      end
    end

    describe 'a multi-line %r regex with slashes' do
      it 'is accepted' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is set to mixed' do
    let(:cop_config) { { 'EnforcedStyle' => 'mixed' } }

    describe 'a single-line `//` regex without slashes' do
      it 'is accepted' do
        expect_no_offenses('foo = /a/')
      end
    end

    describe 'a single-line `//` regex with slashes' do
      let(:source) { 'foo = /home\//' }

      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          foo = /home\//
                ^^^^^^^^ Use `%r` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = %r{home/}')
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          expect_no_offenses('foo = /home\\//')
        end
      end
    end

    describe 'a multi-line `//` regex without slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent.chomp
          foo = /
            foo
            bar
          /x
        RUBY
      end

      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq("foo = %r{\n  foo\n  bar\n}x")
      end
    end

    describe 'a multi-line `//` regex with slashes' do
      let(:source) do
        <<-'RUBY'.strip_indent
          foo = /
            https?:\/\/
            example\.com
          /x
        RUBY
      end

      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<-'RUBY'.strip_indent)
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end
    end

    describe 'a single-line %r regex without slashes' do
      let(:source) { 'foo = %r{a}' }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          foo = %r{a}
                ^^^^^ Use `//` around regular expression.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('foo = /a/')
      end
    end

    describe 'a single-line %r regex with slashes' do
      let(:source) { 'foo = %r{home/}' }

      it 'is accepted' do
        expect_no_offenses('foo = %r{home/}')
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            foo = %r{home/}
                  ^^^^^^^^^ Use `//` around regular expression.
          RUBY
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(source)
          expect(new_source).to eq('foo = /home\//')
        end
      end
    end

    describe 'a multi-line %r regex without slashes' do
      it 'is accepted' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = %r{
            foo
            bar
          }x
        RUBY
      end
    end

    describe 'a multi-line %r regex with slashes' do
      it 'is accepted' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = %r{
            https?://
            example\.com
          }x
        RUBY
      end
    end
  end
end
