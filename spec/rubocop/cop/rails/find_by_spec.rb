# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindBy do
  subject(:cop) { described_class.new }

  shared_examples 'registers_offense' do |selector|
    it "when using where.#{selector}" do
      inspect_source("User.where(id: x).#{selector}")

      expect(cop.messages)
        .to eq(["Use `find_by` instead of `where.#{selector}`."])
    end
  end

  it_behaves_like('registers_offense', 'first')
  it_behaves_like('registers_offense', 'take')

  it 'does not register an offense when using find_by' do
    expect_no_offenses('User.find_by(id: x)')
  end

  it 'autocorrects where.take to find_by' do
    new_source = autocorrect_source('User.where(id: x).take')

    expect(new_source).to eq('User.find_by(id: x)')
  end

  it 'does not autocorrect where.first' do
    new_source = autocorrect_source('User.where(id: x).first')

    expect(new_source).to eq('User.where(id: x).first')
  end
end
