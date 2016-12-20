# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::SafeNavigationChain, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :accepts do |name, code|
    it "accepts usages of #{name}" do
      inspect_source(cop, code)

      expect(cop.offenses).to be_empty
    end
  end

  shared_examples :offense do |name, code|
    it "registers an offense for #{name}" do
      inspect_source(cop, code)

      expect(cop.messages)
        .to eq(
          ['Do not chain ordinary method call after safe navigation operator.']
        )
    end
  end

  shared_examples :autocorrect do |name, source, correction|
    it "corrects #{name}" do
      new_source = autocorrect_source_with_loop(cop, source)

      expect(new_source).to eq(correction)
    end
  end

  context 'TargetRubyVersion >= 2.3', :ruby23 do
    [
      ['ordinary method chain', 'x.foo.bar.baz'],
      ['ordinary method chain with argument', 'x.foo(x).bar(y).baz(z)'],
      ['method chain with safe navigation only', 'x&.foo&.bar&.baz'],
      ['method chain with safe navigation only with argument',
       'x&.foo(x)&.bar(y)&.baz(z)'],
      ['safe navigation at last only', 'x.foo.bar&.baz'],
      ['safe navigation at last only with argument', 'x.foo(x).bar(y)&.baz(z)'],
      ['safe navigation with == operator', 'x&.foo == bar'],
      ['safe navigation with === operator', 'x&.foo === bar'],
      ['safe navigation with || operator', 'x&.foo || bar'],
      ['safe navigation with && operator', 'x&.foo && bar'],
      ['safe navigation with | operator', 'x&.foo | bar'],
      ['safe navigation with & operator', 'x&.foo & bar'],
      ['safe navigation with `nil?` method', 'x&.foo.nil?'],
      ['safe navigation with `present?` method', 'x&.foo.present?'],
      ['safe navigation with `blank?` method', 'x&.foo.blank?'],
      ['safe navigation with assignment method', 'x&.foo = bar'],
      ['safe navigation with self assignment method', 'x&.foo += bar']
    ].each do |name, code|
      include_examples :accepts, name, code
    end

    [
      ['ordinary method call exists after safe navigation method call',
       'x&.foo.bar'],
      ['ordinary method call exists after safe navigation method call' \
       'with argument',
       'x&.foo(x).bar(y)'],
      ['ordinary method chain exists after safe navigation method call',
       'x&.foo.bar.baz'],
      ['ordinary method chain exists after safe navigation method call' \
      'with argument',
       'x&.foo(x).bar(y).baz(z)'],
      ['safe navigation with < operator', 'x&.foo < bar'],
      ['safe navigation with > operator', 'x&.foo > bar'],
      ['safe navigation with <= operator', 'x&.foo <= bar'],
      ['safe navigation with >= operator', 'x&.foo >= bar'],
      ['safe navigation with + operator', 'x&.foo + bar'],
      ['safe navigation with []', 'x&.foo[bar]'],
      ['safe navigation with []=', 'x&.foo[bar] = baz']
    ].each do |name, code|
      include_examples :offense, name, code
    end

    [
      ['ordinary method call exists after safe navigation method call',
       'x&.foo.bar', 'x&.foo&.bar'],
      ['ordinary method call exists after safe navigation method call' \
       'with argument',
       'x&.foo(x).bar(y)', 'x&.foo(x)&.bar(y)'],
      ['ordinary method chain exists after safe navigation method call',
       'x&.foo.bar.baz', 'x&.foo&.bar&.baz'],
      ['ordinary method chain exists after safe navigation method call' \
      'with argument',
       'x&.foo(x).bar(y).baz(z)', 'x&.foo(x)&.bar(y)&.baz(z)'],
      # Do not autocorrect the followings
      ['safe navigation with < operator', 'x&.foo < bar', 'x&.foo < bar'],
      ['safe navigation with > operator', 'x&.foo > bar', 'x&.foo > bar'],
      ['safe navigation with <= operator', 'x&.foo <= bar', 'x&.foo <= bar'],
      ['safe navigation with >= operator', 'x&.foo >= bar', 'x&.foo >= bar'],
      ['safe navigation with + operator', 'x&.foo + bar', 'x&.foo + bar'],
      ['safe navigation with []', 'x&.foo[bar]', 'x&.foo[bar]'],
      ['safe navigation with []=', 'x&.foo[bar] = baz', 'x&.foo[bar] = baz']
    ].each do |name, code, correction|
      include_examples :autocorrect, name, code, correction
    end
  end
end
