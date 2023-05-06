# frozen_string_literal: true

RSpec.describe RuboCop::Server::ClientCommand::Exec do
  if RuboCop::Server.support_server?
    it 'does not read from $stdin when -s/--stdin not specified' do
      exec_command = described_class.new

      expect(ARGV).to receive(:include?).with('-s').and_return(false)
      expect(ARGV).to receive(:include?).with('--stdin').and_return(false)

      expect(exec_command).to receive(:ensure_server!).and_return(nil)
      expect(exec_command).to receive(:send_request).and_return(nil)
      expect(exec_command).to receive(:stderr).and_return('')
      expect(exec_command).to receive(:status).and_return(0)

      allow($stdin).to receive(:tty?).and_return(false)
      expect($stdin).not_to receive(:read)

      exec_command.run
    end

    it 'reads from $stdin when -s/--stdin specified' do
      exec_command = described_class.new

      expect(ARGV).to receive(:include?).with('-s').and_return(true)

      expect(exec_command).to receive(:ensure_server!).and_return(nil)
      expect(exec_command).to receive(:send_request).and_return(nil)
      expect(exec_command).to receive(:stderr).and_return('')
      expect(exec_command).to receive(:status).and_return(0)

      allow($stdin).to receive(:tty?).and_return(false)
      expect($stdin).to receive(:read)

      exec_command.run
    end
  end
end
