# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationWithEmpty do
  subject(:cop) { described_class.new }

  context 'target_ruby_version >= 2.3', :ruby23 do
    context 'in a conditional' do
      it 'registers an offense on `&.empty?`' do
        expect_offense(<<-RUBY.strip_indent)
          return unless foo&.empty?
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid calling `empty?` with the safe navigation operator in conditionals.
        RUBY
      end

      it 'does not register an offense on `.empty?`' do
        expect_no_offenses(<<-RUBY.strip_indent)
          return if foo.empty?
        RUBY
      end
    end

    context 'outside a conditional' do
      it 'registers no offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          bar = foo&.empty?
        RUBY
      end
    end
  end
end
