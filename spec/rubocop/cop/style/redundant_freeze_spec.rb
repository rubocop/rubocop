# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RedundantFreeze do
  subject(:cop) { described_class.new }

  shared_examples :immutable_objects do |o|
    it "registers an offense for frozen #{o}" do
      inspect_source(cop, "CONST = #{o}.freeze")
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects by removing .freeze' do
      new_source = autocorrect_source(cop, "CONST = #{o}.freeze")
      expect(new_source).to eq("CONST = #{o}")
    end
  end

  it_behaves_like :immutable_objects, '1'
  it_behaves_like :immutable_objects, '1.5'
  it_behaves_like :immutable_objects, ':sym'
  it_behaves_like :immutable_objects, ':""'

  shared_examples :mutable_objects do |o|
    it "allows #{o} with freeze" do
      inspect_source(cop, "CONST = #{o}.freeze")
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like :mutable_objects, '[1, 2, 3]'
  it_behaves_like :mutable_objects, '{ a: 1, b: 2 }'
  it_behaves_like :mutable_objects, "'str'"
  it_behaves_like :mutable_objects, '"top#{1 + 2}"'

  it 'allows .freeze on  method call' do
    inspect_source(cop, 'TOP_TEST = Something.new.freeze')
    expect(cop.offenses).to be_empty
  end
end
