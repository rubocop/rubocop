# frozen_string_literal: true

RSpec.describe RuboCop::Lockfile, :isolated_environment do
  include FileHelper

  subject { described_class.new }

  let(:lockfile) do
    create_file('Gemfile.lock', <<~LOCKFILE)
      GEM
        gems:
          rake (13.0.1)
          rspec (3.9.0)
          dep (1.0.0)
            dep2 (~> 1.0)
          dep2 (1.0.0)
            dep3 (~> 1.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        dep (~> 1.0.0)
        rake (~> 13.0)
        rspec (~> 3.7)
    LOCKFILE
  end

  before do
    allow(Bundler).to receive(:default_lockfile)
      .and_return(lockfile ? Pathname.new(lockfile) : nil)
  end

  shared_examples 'error states' do
    context 'when bundler is not loaded' do
      before { hide_const('Bundler') }

      it { is_expected.to eq([]) }
    end

    context 'when there is an no lockfile' do
      let(:lockfile) { nil }

      it { is_expected.to eq([]) }
    end

    context 'when there is a garbage lockfile' do
      let(:lockfile) do
        create_file('Gemfile.lock', <<~LOCKFILE)
          <<<<<<<
        LOCKFILE
      end

      it { is_expected.to eq([]) }
    end
  end

  describe '#dependencies' do
    subject { super().dependencies }

    let(:names) { subject.map(&:name) }

    it_behaves_like 'error states'

    # FIXME: Remove `broken_on: windows` when `undefined method `add_dependency_names'
    #        for nil:NilClass` error of Bundler 2.2.5 on Windows will be resolved.
    it 'returns all the dependencies', broken_on: :windows do
      expect(names).to contain_exactly('dep', 'rake', 'rspec')
    end

    context 'when there is an empty lockfile' do
      let(:lockfile) { create_empty_file('Gemfile.lock') }

      it { is_expected.to eq([]) }
    end
  end

  describe '#gems' do
    subject { super().gems }

    let(:names) { subject.map(&:name) }

    it_behaves_like 'error states'

    # FIXME: Remove `broken_on: windows` when `undefined method `add_dependency_names'
    #        for nil:NilClass` error of Bundler 2.2.5 on Windows will be resolved.
    it 'returns all the dependencies', broken_on: :windows do
      expect(names).to contain_exactly('dep', 'dep2', 'dep3', 'rake', 'rspec')
    end

    context 'when there is an empty lockfile' do
      let(:lockfile) { create_empty_file('Gemfile.lock') }

      it { is_expected.to eq([]) }
    end
  end

  describe '#includes_gem?' do
    subject { super().includes_gem?(name) }

    # FIXME: Remove `broken_on: windows` when `undefined method `add_dependency_names'
    #        for nil:NilClass` error of Bundler 2.2.5 on Windows will be resolved.
    context 'for an included dependency', broken_on: :windows do
      let(:name) { 'rake' }

      it { is_expected.to eq(true) }
    end

    # FIXME: Remove `broken_on: windows` when `undefined method `add_dependency_names'
    #        for nil:NilClass` error of Bundler 2.2.5 on Windows will be resolved.
    context 'for an included gem', broken_on: :windows do
      let(:name) { 'dep2' }

      it { is_expected.to eq(true) }
    end

    # FIXME: Remove `broken_on: windows` when `undefined method `add_dependency_names'
    #        for nil:NilClass` error of Bundler 2.2.5 on Windows will be resolved.
    context 'for an excluded gem', broken_on: :windows do
      let(:name) { 'other' }

      it { is_expected.to eq(false) }
    end
  end
end
