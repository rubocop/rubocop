# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::RaiseString do
  subject(:cop) { described_class.new }
  let(:error_msg) { "'something failed'" }

  %w(raise fail).each do |method|
    context "for #{method}" do
      context 'with a single line string' do
        let(:source) { "#{method} #{error_msg}" }

        it 'reports an offense' do
          inspect_source(cop, source)
          expect(cop.messages)
            .to eq(["Use an exception class with `#{method}` "\
                    'instead of a String.'])
          expect(cop.highlights).to eq([error_msg])
        end
      end

      context 'with a multiline string' do
        let(:source) do
          ["#{method} 'something '\\", "'failed'"]
        end

        it 'reports an offense' do
          inspect_source(cop, source)
          expect(cop.messages)
            .to eq(["Use an exception class with `#{method}` "\
                    'instead of a String.'])
          expect(cop.highlights).to eq(["'something '\\\n'failed'"])
        end
      end

      context 'with a compact exception' do
        let(:source) { "#{method} CustomError.new(#{error_msg})" }

        it_behaves_like 'accepts'
      end

      context 'with a exploded exception' do
        let(:source) { "#{method} CustomError, #{error_msg}" }

        it_behaves_like 'accepts'
      end

      context 'with no argument' do
        let(:source) { method }

        it_behaves_like 'accepts'
      end
    end
  end
end
