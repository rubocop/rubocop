# encoding: utf-8

require 'spec_helper'
require 'fileutils'

module RuboCop
  module Formatter
    describe HTMLFormatter, :isolated_environment do
      fixtures_path =
        File.expand_path('../../../fixtures/html_formatter', __FILE__)

      around do |example|
        assets_path = File.expand_path('../../../../assets', __FILE__)

        FakeFS::FileSystem.clone(assets_path)
        FakeFS::FileSystem.clone(fixtures_path)

        Dir.chdir(File.join(fixtures_path, 'project')) do
          example.run
        end
      end

      let(:actual_html_path) do
        path = File.expand_path('result.html')
        CLI.new.run(['--format', 'html', '--out', path])
        path
      end

      let(:actual_html) do
        File.read(actual_html_path, encoding: 'UTF-8')
      end

      let(:expected_html_path) do
        File.join(fixtures_path, 'expected.html')
      end

      let(:expected_html) do
        html = File.read(expected_html_path, encoding: 'UTF-8')
        # Avoid failure on version bump
        html.sub(/(class="version".{0,20})\d+(?:\.\d+){2}/i) do
          Regexp.last_match(1) + RuboCop::Version::STRING
        end
      end

      it 'outputs the result in HTML' do
        # FileUtils.copy(actual_html_path, expected_html_path)
        expect(actual_html).to eq(expected_html)
      end
    end
  end
end
