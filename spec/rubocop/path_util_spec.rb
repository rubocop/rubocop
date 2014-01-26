# encoding: utf-8

require 'spec_helper'

describe Rubocop::PathUtil do
  describe '#relative_path' do
    pending 'builds paths relative to the current project by default'
    it 'builds paths relative to PWD by default as a stop-gap' do
      relative = File.join(Dir.pwd, 'relative')
      expect(subject.relative_path(relative)).to eq('relative')
    end

    it 'supports custom base paths' do
      expect(subject.relative_path('/foo/bar', '/foo')).to eq('bar')
    end
  end

  describe '#match_path?' do
    it 'matches strings to the basename' do
      expect(subject.match_path?('file', '/dir/file')).to be_true
      expect(subject.match_path?('file', '/dir/files')).to be_false
      expect(subject.match_path?('dir', '/dir/file')).to be_false
    end

    it 'matches strings to the full path' do
      expect(subject.match_path?('/dir/file', '/dir/file')).to be_true
      expect(subject.match_path?('/dir/file', '/dir/dir/file')).to be_false
    end

    it 'matches glob expressions' do
      expect(subject.match_path?('dir/*', 'dir/file')).to be_true
      expect(subject.match_path?('dir/*', 'dir/sub/file')).to be_true
      expect(subject.match_path?('dir/**/*', 'dir/sub/file')).to be_true
      expect(subject.match_path?('sub/*', 'dir/sub/file')).to be_false
    end

    it 'matches regexps' do
      expect(subject.match_path?(/^d.*e$/, 'dir/file')).to be_true
      expect(subject.match_path?(/^d.*e$/, 'dir/filez')).to be_false
    end
  end
end
