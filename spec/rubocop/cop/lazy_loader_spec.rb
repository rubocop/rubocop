# frozen_string_literal: true

RSpec.describe RuboCop::Cop::LazyLoader, :restore_registry do
  let(:tmp_dir) { Dir.mktmpdir('rubocop-lazy_loader_spec-') }
  let(:cop_path) { File.join(tmp_dir, 'foo_cop.rb') }

  after { FileUtils.remove_entry(tmp_dir) }

  before do
    File.write(cop_path, <<~RUBY)
      module RuboCop
        module Cop
          module Test
            class FooCop < RuboCop::Cop::Base
            end
          end
        end
      end
    RUBY

    stub_const('RuboCop::Cop::Test', Module.new { extend RuboCop::Cop::LazyLoader })
  end

  describe '#register_cop' do
    it 'sets up an autoload and registers the cop without loading the file' do
      RuboCop::Cop::Test.register_cop(:FooCop, cop_path)

      expect(RuboCop::Cop::Test.autoload?(:FooCop)).to eq(cop_path)
      expect(RuboCop::Cop::Registry.global.names).to include('Test/FooCop')
    end

    it 'loads the cop class when the registry needs it' do
      RuboCop::Cop::Test.register_cop(:FooCop, cop_path)

      cop_class = RuboCop::Cop::Registry.global.find_by_cop_name('Test/FooCop')

      expect(cop_class).to eq(RuboCop::Cop::Test::FooCop)
    end

    it 'does not register the cop twice when the file is loaded directly' do
      RuboCop::Cop::Test.register_cop(:FooCop, cop_path)

      expect { require cop_path }.not_to change(RuboCop::Cop::Registry.global, :length)
    end

    it 'raises an error for a relative path' do
      expect do
        RuboCop::Cop::Test.register_cop(:FooCop, 'rubocop/cop/test/foo_cop')
      end.to raise_error(ArgumentError, 'cop path must be absolute: rubocop/cop/test/foo_cop')
    end
  end
end
