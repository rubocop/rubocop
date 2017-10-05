# frozen_string_literal: true

describe RuboCop::Cop::Rails::OutputSafety do
  subject(:cop) { described_class.new }

  context 'when using `#safe_concat`' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        foo.safe_concat('bar')
            ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when wrapped inside `#safe_join`' do
      expect_offense(<<-RUBY.strip_indent)
        safe_join([i18n_text.safe_concat(i18n_text)])
                             ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    context 'when using safe navigation operator', :ruby23 do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          foo&.safe_concat('bar')
               ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
        RUBY
      end
    end
  end

  context 'when using `#html_safe`' do
    it 'registers an offense for literal receiver and no argument' do
      expect_offense(<<-RUBY.strip_indent)
        "foo".html_safe
              ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense for variable receiver and no argument' do
      expect_offense(<<-RUBY.strip_indent)
        foo.html_safe
            ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense for variable receiver and arguments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo.html_safe(one)
      RUBY
    end

    it 'does not register an offense without a receiver' do
      expect_no_offenses('html_safe')
    end

    it 'registers an offense when used inside `#safe_join`' do
      expect_offense(<<-RUBY.strip_indent)
        safe_join([i18n_text.html_safe, "foo"])
                             ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when used inside `#safe_join` in other method' do
      expect_offense(<<-RUBY.strip_indent)
        foo(safe_join([i18n_text.html_safe, "bar"]))
                                 ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    context 'when using safe navigation operator', :ruby23 do
      it 'registers an offense for variable receiver and no argument' do
        expect_offense(<<-RUBY.strip_indent)
          foo&.html_safe
               ^^^^^^^^^ Tagging a string as html safe may be a security risk.
        RUBY
      end
    end
  end

  context 'when using `#raw`' do
    it 'registers an offense with no receiver and a variable argument' do
      expect_offense(<<-RUBY)
        raw(foo)
        ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense with no receiver and a literal argument' do
      expect_offense(<<-RUBY)
        raw("foo")
        ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense with a receiver' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo.raw(foo)
      RUBY
    end

    it 'does not register an offense without arguments' do
      expect_no_offenses('raw')
    end

    it 'does not reguster an offense with more than one argument' do
      expect_no_offenses('raw(one, two)')
    end

    it 'does not ergister an offense for comments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # foo.html_safe
        # raw foo
      RUBY
    end

    it 'registers an offense when used inside `#safe_join`' do
      expect_offense(<<-RUBY.strip_indent)
        safe_join([raw(i18n_text), "foo"])
                   ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when used inside `#safe_join` in other method' do
      expect_offense(<<-RUBY.strip_indent)
        foo(safe_join([raw(i18n_text), "bar"]))
                       ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end
  end
end
