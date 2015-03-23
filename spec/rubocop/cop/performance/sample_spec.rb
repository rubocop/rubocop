# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::Sample do
  subject(:cop) { described_class.new }

  shared_examples 'register_offenses' do |selector|
    it "when using shuffle#{selector} on an explicit array" do
      inspect_source(cop, "[1, 2, 3, 4].shuffle#{selector}")

      expect(cop.messages)
        .to eq(["Use `sample` instead of `shuffle#{selector}`."])
    end

    it "when using shuffle#{selector} on an array that is assigned " \
       'to a variable' do
      inspect_source(cop, ['foo = [1, 2, 3, 4]',
                           "foo.shuffle#{selector}"].join("\n"))

      expect(cop.messages)
        .to eq(["Use `sample` instead of `shuffle#{selector}`."])
    end
  end

  it_behaves_like('register_offenses', '.first')
  it_behaves_like('register_offenses', '.last')
  it_behaves_like('register_offenses', '[0]')
  it_behaves_like('register_offenses', '[2]')

  it 'does not registers an offense when using sample' do
    inspect_source(cop, '[1, 2, 3, 4].sample')

    expect(cop.messages).to be_empty
  end

  shared_examples 'corrects' do |selector|
    it "shuffle#{selector} to sample" do
      new_source = autocorrect_source(cop, "[1, 2, 3, 4].shuffle#{selector}")

      expect(new_source).to eq('[1, 2, 3, 4].sample')
    end
  end

  it_behaves_like('corrects', '.first')
  it_behaves_like('corrects', '.last')
  it_behaves_like('corrects', '[0]')
  it_behaves_like('corrects', '[2]')
end
