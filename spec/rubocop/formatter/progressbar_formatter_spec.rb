# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::ProgressbarFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  let(:finish) { formatter.file_finished(files.first, offenses) }

  let(:files) do
    %w[lib/rubocop.rb spec/spec_helper.rb].map do |path|
      File.expand_path(path)
    end
  end

  context 'when output tty is true' do
    let(:offenses) do
      %w[CopB CopA CopC CopC].map { |c| double('offense', cop_name: c) }
    end

    before do
      allow(output).to receive(:tty?).and_return(true)
      formatter.started(files)
      finish
    end

    it 'has a progresbar' do
      formatter.finished(files)
      expect(formatter.instance_variable_get(:@progressbar).progress).to eq 1
    end
  end
end
