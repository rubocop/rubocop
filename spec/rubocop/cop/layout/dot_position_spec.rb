# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::DotPosition, :config do
  subject(:cop) { described_class.new(config) }

  context 'Leading dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'leading' } }

    it 'registers an offense for trailing dot in multi-line call' do
      inspect_source(<<-RUBY.strip_indent)
        something.
          method_name
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'trailing')
    end

    it 'registers an offense for correct + opposite' do
      inspect_source(<<-RUBY.strip_indent)
        something
          .method_name
        something.
          method_name
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts leading do in multi-line method call' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something
          .method_name
      RUBY
    end

    it 'does not err on method call with no dots' do
      expect_no_offenses('puts something')
    end

    it 'does not err on method call without a method name' do
      expect_offense(<<-RUBY.strip_indent)
        l.
         ^ Place the . on the next line, together with the method name.
        (1)
      RUBY
    end

    it 'does not err on method call on same line' do
      expect_no_offenses('something.method_name')
    end

    it 'auto-corrects trailing dot in multi-line call' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something.
          method_name
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something
          .method_name
      RUBY
    end

    it 'auto-corrects trailing dot in multi-line call without selector' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something.
          (1)
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something
          .(1)
      RUBY
    end

    it 'auto-corrects correct + opposite style' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something
          .method_name
        something.
          method_name
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something
          .method_name
        something
          .method_name
      RUBY
    end

    context 'when there is an intervening line comment' do
      it 'does not register offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          something.
          # a comment here
            method_name
        RUBY
      end
    end

    context 'when there is an intervening blank line' do
      it 'does not register offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          something.

            method_name
        RUBY
      end
    end
  end

  context 'Trailing dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'trailing' } }

    it 'registers an offense for leading dot in multi-line call' do
      inspect_source(<<-RUBY.strip_indent)
        something
          .method_name
      RUBY
      expect(cop.messages)
        .to eq(['Place the . on the previous line, together with the method ' \
                'call receiver.'])
      expect(cop.highlights).to eq(['.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'leading')
    end

    it 'accepts trailing dot in multi-line method call' do
      expect_no_offenses(<<-RUBY.strip_indent)
        something.
          method_name
      RUBY
    end

    it 'does not err on method call with no dots' do
      expect_no_offenses('puts something')
    end

    it 'does not err on method call without a method name' do
      expect_offense(<<-RUBY.strip_indent)
        l
        .(1)
        ^ Place the . on the previous line, together with the method call receiver.
      RUBY
    end

    it 'does not err on method call on same line' do
      expect_no_offenses('something.method_name')
    end

    it 'does not get confused by several lines of chained methods' do
      expect_no_offenses(<<-RUBY.strip_indent)
        File.new(something).
        readlines.map.
        compact.join("\n")
      RUBY
    end

    it 'auto-corrects leading dot in multi-line call' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something
          .method_name
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something.
          method_name
      RUBY
    end

    it 'auto-corrects leading dot in multi-line call without selector' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something
          .(1)
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        something.
          (1)
      RUBY
    end
  end
end
