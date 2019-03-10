# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindEach do
  subject(:cop) { described_class.new }

  shared_examples 'register_offense' do |scope|
    it "registers an offense when using #{scope}.each" do
      inspect_source("User.#{scope}.each { |u| u.something }")

      expect(cop.messages).to eq(['Use `find_each` instead of `each`.'])
    end

    it "does not register an offense when using #{scope}.order(...).each" do
      expect_no_offenses("User.#{scope}.order(:name).each { |u| u.something }")
    end

    it "does not register an offense when using #{scope}.limit(...).each" do
      expect_no_offenses("User.#{scope}.limit(10).each { |u| u.something }")
    end

    it "does not register an offense when using #{scope}.select(...).each" do
      expect_no_offenses("User.#{scope}.select(:name, :age).each " \
                          '{ |u| u.something }')
    end
  end

  it_behaves_like('register_offense', 'all')
  it_behaves_like('register_offense', 'eager_load(:association_name)')
  it_behaves_like('register_offense', 'includes(:association_name)')
  it_behaves_like('register_offense', 'joins(:association_name)')
  it_behaves_like('register_offense', 'left_joins(:association_name)')
  it_behaves_like('register_offense', 'left_outer_joins(:association_name)')
  it_behaves_like('register_offense', 'preload(:association_name)')
  it_behaves_like('register_offense', 'references(:association_name)')
  it_behaves_like('register_offense', 'unscoped')
  it_behaves_like('register_offense', 'where(name: name)')
  it_behaves_like('register_offense', 'where.not(name: name)')

  it 'does not register an offense when called on a constant' do
    expect_no_offenses('FOO.each { |u| u.x }')
  end

  it 'does not register an offense when using find_by' do
    expect_no_offenses('User.all.find_each { |u| u.x }')
  end

  it 'auto-corrects each to find_each' do
    expect_offense(<<-RUBY.strip_indent)
      User.all.each { |u| u.x }
               ^^^^ Use `find_each` instead of `each`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      User.all.find_each { |u| u.x }
    RUBY
  end

  it 'registers an offense with non-send ancestors' do
    expect_offense(<<-RUBY.strip_indent)
      class C; User.all.each { |u| u.x }; end
                        ^^^^ Use `find_each` instead of `each`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      class C; User.all.find_each { |u| u.x }; end
    RUBY
  end

  it 'does not register an offense when using order(...) earlier' do
    expect_no_offenses('User.order(:name).all.each { |u| u.something }')
  end
end
