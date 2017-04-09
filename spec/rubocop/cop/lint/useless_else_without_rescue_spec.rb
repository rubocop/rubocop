# frozen_string_literal: true

describe RuboCop::Cop::Lint::UselessElseWithoutRescue do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'with `else` without `rescue`' do
    let(:source) do
      <<-END.strip_indent
        begin
          do_something
        else
          handle_unknown_errors
        end
      END
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('`else` without `rescue` is useless.')
      expect(cop.highlights).to eq(['else'])
    end
  end

  context 'with `else` with `rescue`' do
    let(:source) do
      <<-END.strip_indent
        begin
          do_something
        rescue ArgumentError
          handle_argument_error
        else
          handle_unknown_errors
        end
      END
    end

    it 'accepts' do
      expect(cop.offenses).to be_empty
    end
  end
end
