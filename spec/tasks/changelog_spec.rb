# frozen_string_literal: true

return unless RUBY_VERSION >= '2.6'

require_relative '../../tasks/changelog'

RSpec.describe Changelog do
  subject(:changelog) do
    list = entries.to_h { |e| [e.path, e.content] }
    described_class.new(content: <<~CHANGELOG, entries: list)
      # Change log

      ## master (unreleased)

      ### New features

      * [#bogus] Bogus feature
      * [#bogus] Other bogus feature

      ## 0.7.1 (2020-09-28)

      ### Bug fixes

      * [#127](https://github.com/rubocop-hq/rubocop/pull/127): Fix dependency issue for JRuby. ([@marcandre][])

      ## 0.7.0 (2020-09-27)

      ### New features

      * [#105](https://github.com/rubocop-hq/rubocop/pull/105): `NodePattern` stuff...
      * [#109](https://github.com/rubocop-hq/rubocop/pull/109): Add `NodePattern` debugging rake tasks: `test_pattern`, `compile`, `parse`. See also [this app](https://nodepattern.herokuapp.com) ([@marcandre][])
      * [#110](https://github.com/rubocop-hq/rubocop/pull/110): Add `NodePattern` support for multiple terms unions. ([@marcandre][])
      * [#111](https://github.com/rubocop-hq/rubocop/pull/111): Optimize some `NodePattern`s by using `Set`s. ([@marcandre][])
      * [#112](https://github.com/rubocop-hq/rubocop/pull/112): Add `NodePattern` support for Regexp literals. ([@marcandre][])

      more stuf....

      [@marcandre]: https://github.com/marcandre
      [@johndoexx]: https://github.com/johndoexx
    CHANGELOG
  end

  let(:entries) do
    %i[fix new fix].map.with_index do |type, i|
      Changelog::Entry.new(type: type,
                           body: "Do something cool#{'x' * i}", user: "johndoe#{'x' * i}")
    end
  end

  describe Changelog::Entry do
    subject(:entry) do
      described_class.new(
        type: type,
        body: body,
        user: github_user
      )
    end

    let(:type) { :fix }
    let(:github_user) { 'johndoe' }

    describe '#content' do
      context 'when there is an issue referenced' do
        let(:body) { '[Fix #567] Do something cool.' }

        it 'generates correct content' do
          expect(entry.content).to eq <<~MD
            * [#567](https://github.com/rubocop-hq/rubocop/issues/567): Do something cool. ([@johndoe][])
          MD
        end
      end

      context 'when there is no issue referenced' do
        let(:body) { 'Do something cool.' }

        it 'generates correct content' do
          expect(entry.content).to eq <<~MD
            * [#x](https://github.com/rubocop-hq/rubocop/pull/x): Do something cool. ([@johndoe][])
          MD
        end
      end
    end

    describe '#ref_id' do
      subject { entry.ref_id }

      context 'when there is no body' do
        let(:body) { '' }

        it { is_expected.to eq('x') }
      end

      context 'when there is no issue referenced in the body' do
        let(:body) { 'Fix something' }

        it { is_expected.to eq('x') }
      end

      context 'when there is an issue referenced with [Fix #x] the body' do
        let(:body) { '[Fix #123] Fix something' }

        it { is_expected.to eq('123') }
      end

      context 'when there is an issue referenced with [Fixes #x] the body' do
        let(:body) { '[Fixes #123] Fix something' }

        it { is_expected.to eq('123') }
      end
    end

    describe '#body' do
      subject { entry.body }

      context 'when there is no body' do
        let(:body) { '' }

        it { is_expected.to eq('') }
      end

      context 'when there is no issue referenced in the body' do
        let(:body) { 'Fix something' }

        it { is_expected.to eq('Fix something') }
      end

      context 'when there is an issue referenced with [Fix #x] the body' do
        let(:body) { '[Fix #123] Fix something' }

        it { is_expected.to eq('Fix something') }
      end

      context 'when there is an issue referenced with [Fixes #x] the body' do
        let(:body) { '[Fixes #123] Fix something' }

        it { is_expected.to eq('Fix something') }
      end
    end
  end

  it 'parses correctly' do
    expect(changelog.rest).to start_with('## 0.7.1 (2020-09-28)')
  end

  it 'merges correctly' do
    expect(changelog.unreleased_content).to eq(<<~CHANGELOG)
      ### New features

      * [#bogus] Bogus feature
      * [#bogus] Other bogus feature
      * [#x](https://github.com/rubocop-hq/rubocop/pull/x): Do something coolx. ([@johndoex][])

      ### Bug fixes

      * [#x](https://github.com/rubocop-hq/rubocop/pull/x): Do something cool. ([@johndoe][])
      * [#x](https://github.com/rubocop-hq/rubocop/pull/x): Do something coolxx. ([@johndoexx][])
    CHANGELOG

    expect(changelog.new_contributor_lines).to eq(
      [
        '[@johndoe]: https://github.com/johndoe',
        '[@johndoex]: https://github.com/johndoex'
      ]
    )
  end
end
