# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::Colorizable do
  let(:formatter_class) do
    Class.new(RuboCop::Formatter::BaseFormatter) do
      include RuboCop::Formatter::Colorizable
    end
  end

  let(:options) { {} }

  let(:formatter) { formatter_class.new(output, options) }

  let(:output) { instance_double(IO) }

  around do |example|
    original_state = Rainbow.enabled

    begin
      example.run
    ensure
      Rainbow.enabled = original_state
    end
  end

  describe '#colorize' do
    subject(:colorized_output) { formatter.colorize('foo', :red) }

    shared_examples 'does nothing' do
      it 'does nothing' do
        expect(colorized_output).to eq('foo')
      end
    end

    context 'when the global Rainbow.enabled is true' do
      before { Rainbow.enabled = true }

      context "and the formatter's output is a tty" do
        before { allow(output).to receive(:tty?).and_return(true) }

        it 'colorizes the passed string' do
          expect(colorized_output).to eq("\e[31mfoo\e[0m")
        end
      end

      context "and the formatter's output is not a tty" do
        before { allow(output).to receive(:tty?).and_return(false) }

        include_examples 'does nothing'
      end

      context 'and output is not a tty, but --color option was provided' do
        let(:options) { { color: true } }

        before { allow(output).to receive(:tty?).and_return(false) }

        it 'colorizes the passed string' do
          expect(colorized_output).to eq("\e[31mfoo\e[0m")
        end
      end
    end

    context 'when the global Rainbow.enabled is false' do
      before { Rainbow.enabled = false }

      context "and the formatter's output is a tty" do
        before { allow(output).to receive(:tty?).and_return(true) }

        include_examples 'does nothing'
      end

      context "and the formatter's output is not a tty" do
        before { allow(output).to receive(:tty?).and_return(false) }

        include_examples 'does nothing'
      end
    end
  end

  %i[
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
  ].each do |color|
    describe "##{color}" do
      it "invokes #colorize(string, #{color}" do
        expect(formatter).to receive(:colorize).with('foo', color)

        formatter.public_send(color, 'foo')
      end
    end
  end
end
