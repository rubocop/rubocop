# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MutableConstant do
  subject(:cop) { described_class.new }

  shared_examples :mutable_objects do |o|
    it "registers an offense for #{o} assigned to a constant" do
      inspect_source(cop, "CONST = #{o}")
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects by adding .freeze' do
      new_source = autocorrect_source(cop, "CONST = #{o}")
      expect(new_source).to eq("CONST = #{o}.freeze")
    end
  end

  it_behaves_like :mutable_objects, '[1, 2, 3]'
  it_behaves_like :mutable_objects, '{ a: 1, b: 2 }'
  it_behaves_like :mutable_objects, "'str'"
  it_behaves_like :mutable_objects, '"top#{1 + 2}"'

  shared_examples :immutable_objects do |o|
    it "allows #{o} to be assigned to a constant" do
      inspect_source(cop, "CONST = #{o}")
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like :immutable_objects, '1'
  it_behaves_like :immutable_objects, '1.5'
  it_behaves_like :immutable_objects, ':sym'

  it 'allows method call assignments' do
    inspect_source(cop, 'TOP_TEST = Something.new')
    expect(cop.offenses).to be_empty
  end
end
