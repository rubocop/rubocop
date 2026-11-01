# frozen_string_literal: true

RSpec.describe RuboCop::Server::ClientCommand::Stop do
  if RuboCop::Server.support_server?
    subject(:stop_command) { described_class.new }

    before do
      allow(stop_command).to receive(:check_running_server).and_return(true)
      allow(stop_command).to receive(:fork).and_yield.and_return(1)
      allow(Process).to receive(:waitpid).with(1)
      allow(stop_command).to receive(:send_request).with(command: 'stop')
    end

    it 'reads the server pid before stopping and waits until the server process exits' do
      expect(RuboCop::Server::Cache).to receive(:pid).ordered.and_return(4242)
      expect(stop_command).to receive(:send_request).with(command: 'stop').ordered
      expect(RuboCop::Server).to receive(:wait_for_process_exit!).with(4242).ordered
      expect(RuboCop::Server).not_to receive(:wait_for_running_status!)

      stop_command.run
    end

    it 'waits until the server is not running when the pid is unknown' do
      allow(RuboCop::Server::Cache).to receive(:pid).and_return(nil)

      expect(RuboCop::Server).to receive(:wait_for_running_status!).with(false)
      expect(RuboCop::Server).not_to receive(:wait_for_process_exit!)

      stop_command.run
    end
  end
end
