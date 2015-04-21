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
  it_behaves_like('register_offenses', '[0, 3]')
  it_behaves_like('register_offenses', '[0..3]')
  it_behaves_like('register_offenses', '[0...3]')

  it 'registers an offense for random' do
    source = ['random = { random: Random.new(1) }',
              '[1, 2, 3, 4].shuffle(random)'].join("\n")
    inspect_source(cop, source)

    expect(cop.messages)
      .to eq(['Use `sample` instead of `shuffle(random)`.'])
  end

  it 'registers an offense when using shuffle with a defined random' do
    inspect_source(cop, '[1, 2, 3, 4].shuffle(random: Random.new(1))')

    expect(cop.messages)
      .to eq(['Use `sample` instead of `shuffle(random: Random.new(1))`.'])
  end

  it 'does not register an offense when using sample' do
    inspect_source(cop, '[1, 2, 3, 4].sample')

    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when calling a method on shuffle' do
    inspect_source(cop, '[1, 2, 3, 4].shuffle.join([5, 6, 7])')

    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when calling map on shuffle' do
    inspect_source(cop, '[1, 2, 3, 4].shuffle.map { |e| e }')

    expect(cop.messages).to be_empty
  end

  context 'autocorrect' do
    shared_examples 'corrects' do |selector|
      it "shuffle#{selector} to sample" do
        new_source = autocorrect_source(cop, "[1, 2, 3, 4].shuffle#{selector}")

        expect(new_source).to eq('[1, 2, 3, 4].sample')
      end
    end

    it_behaves_like('corrects', '.first')
    it_behaves_like('corrects', '.last')
    it_behaves_like('corrects', '[0]')
    it_behaves_like('corrects', '[3]')

    it 'does not correct shuffle with an inclusive range selector' do
      new_source = autocorrect_source(cop, '[1, 2, 3, 4].shuffle[0..3]')

      expect(new_source).to eq('[1, 2, 3, 4].shuffle[0..3]')
    end

    it 'does not correct shuffle with an exclusive range selector' do
      new_source = autocorrect_source(cop, '[1, 2, 3, 4].shuffle[0...3]')

      expect(new_source).to eq('[1, 2, 3, 4].shuffle[0...3]')
    end

    it 'corrects shuffle with an array range selector' do
      new_source = autocorrect_source(cop, '[1, 2, 3, 4].shuffle[0, 3]')

      expect(new_source).to eq('[1, 2, 3, 4].sample(3)')
    end

    it 'corrects shuffle with an assigned random hash' do
      source = '[1, 2, 3, 4].shuffle(random: Random.new(1))'
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq('[1, 2, 3, 4].sample(random: Random.new(1))')
    end

    it 'corrects shuffle with an assigned random variable' do
      source = ['random = { random: Random.new(1) }',
                '[1, 2, 3, 4].shuffle(random)'].join("\n")
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['random = { random: Random.new(1) }',
                                '[1, 2, 3, 4].sample(random)'].join("\n"))
    end
  end
end
