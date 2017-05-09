# frozen_string_literal: true

describe RuboCop::Cop::Style::RegexpLiteral, :config do
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
      new_source = autocorrect_source(cop, '/a/')
      expect(new_source).to eq('%r[a]')
    end
  end

  context 'when EnforcedStyle is set to slashes' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    describe 'a single-line `//` regex without slashes' do
      let(:source) { 'foo = /a/' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
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

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    describe 'a multi-line `//` regex without slashes' do
      let(:source) do
        ['foo = /',
         '  foo',
         '  bar',
         '/x']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line `//` regex with slashes' do
      let(:source) do
        ['foo = /',
         '  https?:\/\/',
         '  example\.com',
         '/x']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source.join("\n"))
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
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
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq('foo = /a/')
      end
    end

    describe 'a single-line %r regex with slashes' do
      let(:source) { 'foo = %r{home/}' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            foo = %r{home/}
                  ^^^^^^^^^ Use `//` around regular expression.
          RUBY
        end

        it 'cannot auto-correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source)
        end
      end
    end

    describe 'a multi-line %r regex without slashes' do
      let(:source) do
        ['foo = %r{',
         '  foo',
         '  bar',
         '}x']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `//` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("foo = /\n  foo\n  bar\n/x")
      end
    end

    describe 'a multi-line %r regex with slashes' do
      let(:source) do
        ['foo = %r{',
         '  https?://',
         '  example\.com',
         '}x']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Use `//` around regular expression.'])
        end

        it 'cannot auto-correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source.join("\n"))
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
        new_source = autocorrect_source(cop, source)
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

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end
    end

    describe 'a multi-line `//` regex without slashes' do
      let(:source) do
        ['foo = /',
         '  foo',
         '  bar',
         '/x']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("foo = %r{\n  foo\n  bar\n}x")
      end
    end

    describe 'a multi-line `//` regex with slashes' do
      let(:source) do
        ['foo = /',
         '  https?:\/\/',
         '  example\.com',
         '/x']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source.join("\n"))
      end
    end

    describe 'a single-line %r regex without slashes' do
      let(:source) { 'foo = %r{a}' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a single-line %r regex with slashes' do
      let(:source) { 'foo = %r{home/}' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line %r regex without slashes' do
      let(:source) do
        ['foo = %r{',
         '  foo',
         '  bar',
         '}x']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line %r regex with slashes' do
      let(:source) do
        ['foo = %r{',
         '  https?://',
         '  example\.com',
         '}x']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when EnforcedStyle is set to mixed' do
    let(:cop_config) { { 'EnforcedStyle' => 'mixed' } }

    describe 'a single-line `//` regex without slashes' do
      let(:source) { 'foo = /a/' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
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

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'is accepted' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    describe 'a multi-line `//` regex without slashes' do
      let(:source) do
        ['foo = /',
         '  foo',
         '  bar',
         '/x']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("foo = %r{\n  foo\n  bar\n}x")
      end
    end

    describe 'a multi-line `//` regex with slashes' do
      let(:source) do
        ['foo = /',
         '  https?:\/\/',
         '  example\.com',
         '/x']
      end

      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Use `%r` around regular expression.'])
      end

      it 'cannot auto-correct' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source.join("\n"))
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
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq('foo = /a/')
      end
    end

    describe 'a single-line %r regex with slashes' do
      let(:source) { 'foo = %r{home/}' }

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      describe 'when configured to allow inner slashes' do
        before { cop_config['AllowInnerSlashes'] = true }

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            foo = %r{home/}
                  ^^^^^^^^^ Use `//` around regular expression.
          RUBY
        end

        it 'cannot auto-correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source)
        end
      end
    end

    describe 'a multi-line %r regex without slashes' do
      let(:source) do
        ['foo = %r{',
         '  foo',
         '  bar',
         '}x']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    describe 'a multi-line %r regex with slashes' do
      let(:source) do
        ['foo = %r{',
         '  https?://',
         '  example\.com',
         '}x']
      end

      it 'is accepted' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end
end
