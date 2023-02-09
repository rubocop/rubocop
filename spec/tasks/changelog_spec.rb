# frozen_string_literal: true

require_relative '../../tasks/changelog'

RSpec.describe Changelog do
  subject(:changelog) do
    list = entries.to_h { |e| [e.path, e.content] }
    described_class.new(content: <<~CHANGELOG, entries: list)
      # Change log

      <!---
        Do NOT edit this CHANGELOG.md file by hand directly, as it is automatically updated.

        Please add an entry file to the https://github.com/rubocop/rubocop/blob/master/changelog/
        named `{change_type}_{change_description}.md` if the new code introduces user-observable changes.

        See https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format for details.
      -->

      ## master (unreleased)

      ### New features

      * [#bogus] Bogus feature
      * [#bogus] Other bogus feature

      ## 0.7.1 (2020-09-28)

      ### Bug fixes

      * [#127](https://github.com/rubocop/rubocop/pull/127): Fix dependency issue for JRuby. ([@marcandre][])

      ## 0.7.0 (2020-09-27)

      ### New features

      * [#105](https://github.com/rubocop/rubocop/pull/105): `NodePattern` stuff...
      * [#109](https://github.com/rubocop/rubocop/pull/109): Add `NodePattern` debugging rake tasks: `test_pattern`, `compile`, `parse`. See also [this app](https://nodepattern.herokuapp.com) ([@marcandre][])
      * [#110](https://github.com/rubocop/rubocop/pull/110): Add `NodePattern` support for multiple terms unions. ([@marcandre][])
      * [#111](https://github.com/rubocop/rubocop/pull/111): Optimize some `NodePattern`s by using `Set`s. ([@marcandre][])
      * [#112](https://github.com/rubocop/rubocop/pull/112): Add `NodePattern` support for Regexp literals. ([@marcandre][])

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
    subject(:entry) { described_class.new(type: type, body: body, user: github_user) }

    let(:type) { :fix }
    let(:github_user) { 'johndoe' }

    describe '#content' do
      context 'when there is an issue referenced' do
        let(:body) { '[Fix #567] Do something cool.' }

        it 'generates correct content' do
          expect(entry.content).to eq <<~MD
            * [#567](https://github.com/rubocop/rubocop/issues/567): Do something cool. ([@johndoe][])
          MD
        end
      end

      context 'when there is no issue referenced' do
        let(:body) { 'Do something cool.' }

        it 'generates correct content' do
          expect(entry.content).to eq <<~MD
            * [#x](https://github.com/rubocop/rubocop/pull/x): Do something cool. ([@johndoe][])
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

    describe '#path' do
      it 'generates correct file name' do
        body = 'Add new `Lint/UselessRescue` cop'
        entry = described_class.new(type: :new, body: body, user: github_user)
        expect(entry.path).to eq('changelog/new_add_new_lint_useless_rescue_cop.md')
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
      * [#x](https://github.com/rubocop/rubocop/pull/x): Do something coolx. ([@johndoex][])

      ### Bug fixes

      * [#x](https://github.com/rubocop/rubocop/pull/x): Do something cool. ([@johndoe][])
      * [#x](https://github.com/rubocop/rubocop/pull/x): Do something coolxx. ([@johndoexx][])
    CHANGELOG

    expect(changelog.new_contributor_lines).to eq(
      [
        '[@johndoe]: https://github.com/johndoe',
        '[@johndoex]: https://github.com/johndoex'
      ]
    )
  end
end
