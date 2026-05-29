# frozen_string_literal: true

RSpec.describe RuboCop::CopLazyLoader, :restore_registry do
  subject(:test_module) do
    Module.new do
      extend RuboCop::CopLazyLoader

      # fakes a name since anonymous modules don't have one
      def self.name
        'RuboCop::Cop::Test'
      end
    end
  end

  describe '#register_cop' do
    it 'sets up autoload on the module' do
      test_module.register_cop(:FooCop, 'rubocop/cop/test/foo_cop')

      expect(test_module.autoload?(:FooCop)).to eq('rubocop/cop/test/foo_cop')
    end

    it 'registers the cop in the registry' do
      test_module.register_cop(:FooCop, 'rubocop/cop/test/foo_cop')

      expect(RuboCop::Cop::Registry.global.names).to include('Test/FooCop')
    end
  end
end
