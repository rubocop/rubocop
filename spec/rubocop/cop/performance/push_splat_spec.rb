# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::PushSplat do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  shared_examples_for 'push splat' do |pushed|
    shared_examples_for 'offenses' do |source, corrected|
      let(:source) { source }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(
          'Use `concat` instead of `push(*)`.'
        )
        expect(cop.highlights).to eq([source])
      end

      it 'auto-corrects' do
        corrected = autocorrect_source(cop, source)
        expect(corrected).to eq(corrected)
      end
    end

    it_behaves_like 'offenses', "[].push(*#{pushed})", "[].concat(#{pushed})"
    it_behaves_like 'offenses', "push(*#{pushed})",    "concat(#{pushed})"
    it_behaves_like 'offenses', "[].push *#{pushed}",  "[].concat #{pushed}"
    it_behaves_like 'offenses', "push *#{pushed}",     "concat #{pushed}"
  end

  shared_examples_for 'push without splat' do |pushed|
    context 'with a receiver' do
      let(:source) { "[].push(#{pushed})" }

      it 'registers no offense' do
        expect(cop.messages).to be_empty
      end
    end

    context 'without a receiver' do
      let(:source) { "push(#{pushed})" }

      it 'registers no offense' do
        expect(cop.messages).to be_empty
      end
    end
  end

  it_behaves_like 'push splat', 'a'
  it_behaves_like 'push splat', '[1, 2, 3]'

  it_behaves_like 'push without splat', 'a'
  it_behaves_like 'push without splat', '[1, 2, 3]'
end
