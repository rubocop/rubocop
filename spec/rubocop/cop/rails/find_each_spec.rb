# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindEach do
  subject(:cop) { described_class.new }

  shared_examples 'register_offense' do |scope|
    it "registers an offense when using #{scope}.each" do
      inspect_source("User.#{scope}.each { |u| u.something }")

      expect(cop.messages).to eq(['Use `find_each` instead of `each`.'])
    end

    it "does not register an offense when using #{scope}.order(...).each" do
      inspect_source("User.#{scope}.order(:name).each { |u| u.something }")

      expect(cop.offenses.empty?).to be(true)
    end

    it "does not register an offense when using #{scope}.limit(...).each" do
      inspect_source("User.#{scope}.limit(10).each { |u| u.something }")

      expect(cop.offenses.empty?).to be(true)
    end

    it "does not register an offense when using #{scope}.select(...).each" do
      inspect_source("User.#{scope}.select(:name, :age).each " \
                          '{ |u| u.something }')

      expect(cop.offenses.empty?).to be(true)
    end
  end

  it_behaves_like('register_offense', 'where(name: name)')
  it_behaves_like('register_offense', 'all')
  it_behaves_like('register_offense', 'where.not(name: name)')

  it 'does not register an offense when using find_by' do
    expect_no_offenses('User.all.find_each { |u| u.x }')
  end

  it 'auto-corrects each to find_each' do
    new_source = autocorrect_source('User.all.each { |u| u.x }')

    expect(new_source).to eq('User.all.find_each { |u| u.x }')
  end
end
