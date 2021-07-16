# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FormatStringToken, :config do
  let(:enforced_style) { :annotated }
  let(:ignored_methods) { [] }

  let(:cop_config) do
    {
      'EnforcedStyle' => enforced_style,
      'SupportedStyles' => %i[annotated template unannotated],
      'MaxUnannotatedPlaceholdersAllowed' => 0,
      'IgnoredMethods' => ignored_methods
    }
  end

  shared_examples 'maximum allowed unannotated' do |token|
    context 'when MaxUnannotatedPlaceholdersAllowed is 1' do
      before { cop_config['MaxUnannotatedPlaceholdersAllowed'] = 1 }

      it 'does not register offenses for single unannotated' do
        expect_no_offenses("format('%#{token}', foo)")
      end

      it 'registers offense for dual unannotated' do
        expect_offense(<<~RUBY)
          format('%#{token} %s', foo, bar)
                  ^^ Prefer [...]
                     ^^ Prefer [...]
        RUBY
      end
    end

    context 'when MaxUnannotatedPlaceholdersAllowed is 2' do
      before { cop_config['MaxUnannotatedPlaceholdersAllowed'] = 2 }

      it 'does not register offenses for single unannotated' do
        expect_no_offenses("format('%#{token}', foo)")
      end

      it 'does not register offenses for dual unannotated' do
        expect_no_offenses("format('%#{token} %s', foo, bar)")
      end
    end
  end

  shared_examples 'enforced styles for format string tokens' do |token|
    template  = '%{template}'
    annotated = "%<named>#{token}"

    context 'when enforced style is annotated' do
      let(:enforced_style) { :annotated }

      it 'registers offenses for template style' do
        expect_offense(<<~RUBY, annotated: annotated, template: template)
          <<-HEREDOC
          foo %{annotated} + bar %{template}
              _{annotated}       ^{template} Prefer annotated tokens [...]
          HEREDOC
        RUBY

        expect_no_corrections
      end

      it 'supports dynamic string with interpolation' do
        expect_offense(<<~'RUBY', annotated: annotated, template: template)
          "a#{b}%{annotated} c#{d}%{template} e#{f}"
                _{annotated}      ^{template} Prefer annotated tokens [...]
        RUBY

        expect_no_corrections
      end

      it 'sets the enforced style to annotated after inspecting "%<a>s"' do
        expect_no_offenses('"%<a>s"')

        expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'annotated')
      end

      it 'configures the enforced style to template after inspecting "%{a}"' do
        expect_offense(<<~RUBY)
          "%{a}"
           ^^^^ Prefer annotated tokens [...]
        RUBY

        expect_no_corrections

        expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'template')
      end

      it_behaves_like 'maximum allowed unannotated', token
    end

    context 'when enforced style is template' do
      let(:enforced_style) { :template }

      it 'registers offenses for annotated style' do
        expect_offense(<<~RUBY, annotated: annotated, template: template)
          <<-HEREDOC
          foo %{template} + bar %{annotated}
              _{template}       ^{annotated} Prefer template tokens [...]
          HEREDOC
        RUBY

        expect_no_corrections
      end

      it 'supports dynamic string with interpolation' do
        expect_offense(<<~'RUBY', annotated: annotated, template: template)
          "a#{b}%{template} c#{d}%{annotated} e#{f}"
                _{template}      ^{annotated} Prefer template tokens [...]
        RUBY

        expect_no_corrections
      end

      it 'sets the enforced style to annotated after inspecting "%<a>s"' do
        expect_offense(<<~RUBY)
          "%<a>s"
           ^^^^^ Prefer template tokens [...]
        RUBY

        expect_no_corrections

        expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'annotated')
      end

      it 'configures the enforced style to template after inspecting "%{a}"' do
        expect_no_offenses('"%{a}"')

        expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'template')
      end

      it_behaves_like 'maximum allowed unannotated', token
    end
  end

  it 'ignores percent escapes' do
    expect_no_offenses("format('%<hit_rate>6.2f%%', hit_rate: 12.34)")
  end

  it 'ignores xstr' do
    expect_no_offenses('`echo "%s %<annotated>s %{template}"`')
  end

  it 'ignores regexp' do
    expect_no_offenses('/foo bar %u/')
  end

  it 'ignores `%r` regexp' do
    expect_no_offenses('%r{foo bar %u}')
  end

  %i[strptime strftime].each do |method_name|
    it "ignores time format (when used as argument to #{method_name})" do
      expect_no_offenses(<<~RUBY)
        Time.#{method_name}('2017-12-13', '%Y-%m-%d')
      RUBY
    end
  end

  it 'ignores time format when it is stored in a variable' do
    expect_no_offenses(<<~RUBY)
      time_format = '%Y-%m-%d'
      Time.strftime('2017-12-13', time_format)
    RUBY
  end

  it 'ignores time format and unrelated `format` method using' do
    expect_no_offenses(<<~RUBY)
      Time.now.strftime('%Y-%m-%d-%H-%M-%S')
      format
    RUBY
  end

  it 'handles dstrs' do
    expect_offense(<<~'RUBY')
      "c#{b}%{template}"
            ^^^^^^^^^^^ Prefer annotated tokens (like `%<foo>s`) over template tokens (like `%{foo}`).
    RUBY

    expect_no_corrections
  end

  it 'ignores http links' do
    expect_no_offenses(<<~RUBY)
      'https://ru.wikipedia.org/wiki/%D0%90_'\
        '(%D0%BA%D0%B8%D1%80%D0%B8%D0%BB%D0%BB%D0%B8%D1%86%D0%B0)'
    RUBY
  end

  it 'ignores placeholder arguments' do
    expect_no_offenses(<<~RUBY)
      format(
        '%<day>s %<start>s-%<end>s',
        day: open_house.starts_at.strftime('%a'),
        start: open_house.starts_at.strftime('%l'),
        end: open_house.ends_at.strftime('%l %p').strip
      )
    RUBY
  end

  it 'works inside hashes' do
    expect_offense(<<~RUBY)
      { bar: format('%{foo}', foo: 'foo') }
                     ^^^^^^ Prefer annotated tokens (like `%<foo>s`) over template tokens (like `%{foo}`).
    RUBY

    expect_no_corrections
  end

  it 'supports flags and modifiers' do
    expect_offense(<<~RUBY)
      format('%-20s %-30s', 'foo', 'bar')
              ^^^^^ Prefer annotated tokens (like `%<foo>s`) over unannotated tokens (like `%s`).
                    ^^^^^ Prefer annotated tokens (like `%<foo>s`) over unannotated tokens (like `%s`).
    RUBY

    expect_no_corrections
  end

  it 'ignores __FILE__' do
    expect_no_offenses('__FILE__')
  end

  it_behaves_like 'enforced styles for format string tokens', 'A'
  it_behaves_like 'enforced styles for format string tokens', 'B'
  it_behaves_like 'enforced styles for format string tokens', 'E'
  it_behaves_like 'enforced styles for format string tokens', 'G'
  it_behaves_like 'enforced styles for format string tokens', 'X'
  it_behaves_like 'enforced styles for format string tokens', 'a'
  it_behaves_like 'enforced styles for format string tokens', 'b'
  it_behaves_like 'enforced styles for format string tokens', 'c'
  it_behaves_like 'enforced styles for format string tokens', 'd'
  it_behaves_like 'enforced styles for format string tokens', 'e'
  it_behaves_like 'enforced styles for format string tokens', 'f'
  it_behaves_like 'enforced styles for format string tokens', 'g'
  it_behaves_like 'enforced styles for format string tokens', 'i'
  it_behaves_like 'enforced styles for format string tokens', 'o'
  it_behaves_like 'enforced styles for format string tokens', 'p'
  it_behaves_like 'enforced styles for format string tokens', 's'
  it_behaves_like 'enforced styles for format string tokens', 'u'
  it_behaves_like 'enforced styles for format string tokens', 'x'

  context 'when enforced style is annotated' do
    let(:enforced_style) { :annotated }

    it 'gives a helpful error message' do
      expect_offense(<<~RUBY)
        "%{foo}"
         ^^^^^^ Prefer annotated tokens (like `%<foo>s`) over template tokens (like `%{foo}`).
      RUBY

      expect_no_corrections
    end

    context 'when `IgnoredMethods: redirect`' do
      let(:ignored_methods) { ['redirect'] }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          redirect("%{foo}")
        RUBY
      end
    end

    context 'when `IgnoredMethods: []`' do
      let(:ignored_methods) { [] }

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          redirect("%{foo}")
                    ^^^^^^ Prefer annotated tokens (like `%<foo>s`) over template tokens (like `%{foo}`).
        RUBY
      end
    end
  end

  context 'when enforced style is template' do
    let(:enforced_style) { :template }

    it 'gives a helpful error message' do
      expect_offense(<<~RUBY)
        "%<foo>d"
         ^^^^^^^ Prefer template tokens (like `%{foo}`) over annotated tokens (like `%<foo>s`).
      RUBY

      expect_no_corrections
    end
  end

  context 'when enforced style is unannotated' do
    let(:enforced_style) { :unannotated }

    it 'gives a helpful error message' do
      expect_offense(<<~RUBY)
        "%{foo}"
         ^^^^^^ Prefer unannotated tokens (like `%s`) over template tokens (like `%{foo}`).
      RUBY

      expect_no_corrections
    end
  end
end
