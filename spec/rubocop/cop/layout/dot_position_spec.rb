# frozen_string_literal: true

describe RuboCop::Cop::Layout::DotPosition, :config do
  subject(:cop) { described_class.new(config) }

  context 'Leading dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'leading' } }

    it 'registers an offense for trailing dot in multi-line call' do
      inspect_source(cop, <<-END.strip_indent)
        something.
          method_name
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'trailing')
    end

    it 'registers an offense for correct + opposite' do
      inspect_source(cop, <<-END.strip_indent)
        something
          .method_name
        something.
          method_name
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts leading do in multi-line method call' do
      expect_no_offenses(<<-END.strip_indent)
        something
          .method_name
      END
    end

    it 'does not err on method call with no dots' do
      expect_no_offenses('puts something')
    end

    it 'does not err on method call without a method name' do
      inspect_source(cop, <<-END.strip_indent)
        l.
        (1)
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not err on method call on same line' do
      expect_no_offenses('something.method_name')
    end

    it 'auto-corrects trailing dot in multi-line call' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        something.
          method_name
      END
      expect(new_source).to eq(<<-END.strip_indent)
        something
          .method_name
      END
    end

    it 'auto-corrects trailing dot in multi-line call without selector' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        something.
          (1)
      END
      expect(new_source).to eq(<<-END.strip_indent)
        something
          .(1)
      END
    end

    it 'auto-corrects correct + opposite style' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        something
          .method_name
        something.
          method_name
      END
      expect(new_source).to eq(<<-END.strip_indent)
        something
          .method_name
        something
          .method_name
      END
    end

    context 'when there is an intervening line comment' do
      it 'does not register offense' do
        expect_no_offenses(<<-END.strip_indent)
          something.
          # a comment here
            method_name
        END
      end
    end

    context 'when there is an intervening blank line' do
      it 'does not register offense' do
        expect_no_offenses(<<-END.strip_indent)
          something.

            method_name
        END
      end
    end
  end

  context 'Trailing dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'trailing' } }

    it 'registers an offense for leading dot in multi-line call' do
      inspect_source(cop, <<-END.strip_indent)
        something
          .method_name
      END
      expect(cop.messages)
        .to eq(['Place the . on the previous line, together with the method ' \
                'call receiver.'])
      expect(cop.highlights).to eq(['.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'leading')
    end

    it 'accepts trailing dot in multi-line method call' do
      expect_no_offenses(<<-END.strip_indent)
        something.
          method_name
      END
    end

    it 'does not err on method call with no dots' do
      expect_no_offenses('puts something')
    end

    it 'does not err on method call without a method name' do
      inspect_source(cop, <<-END.strip_indent)
        l
        .(1)
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not err on method call on same line' do
      expect_no_offenses('something.method_name')
    end

    it 'does not get confused by several lines of chained methods' do
      expect_no_offenses(<<-END.strip_indent)
        File.new(something).
        readlines.map.
        compact.join("\n")
      END
    end

    it 'auto-corrects leading dot in multi-line call' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        something
          .method_name
      END
      expect(new_source).to eq(<<-END.strip_indent)
        something.
          method_name
      END
    end

    it 'auto-corrects leading dot in multi-line call without selector' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        something
          .(1)
      END
      expect(new_source).to eq(<<-END.strip_indent)
        something.
          (1)
      END
    end
  end
end
