# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Attr do
  subject(:cop) { described_class.new }

  it 'registers an offense attr' do
    expect_offense(<<-RUBY.strip_indent)
      class SomeClass
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'accepts attr when it does not take arguments' do
    expect_no_offenses('func(attr)')
  end

  it 'accepts attr when it has a receiver' do
    expect_no_offenses('x.attr arg')
  end

  context 'auto-corrects' do
    it 'attr to attr_reader' do
      new_source = autocorrect_source('attr :name')
      expect(new_source).to eq('attr_reader :name')
    end

    it 'attr, false to attr_reader' do
      new_source = autocorrect_source('attr :name, false')
      expect(new_source).to eq('attr_reader :name')
    end

    it 'attr :name, true to attr_accessor :name' do
      new_source = autocorrect_source('attr :name, true')
      expect(new_source).to eq('attr_accessor :name')
    end

    it 'attr with multiple names to attr_reader' do
      new_source = autocorrect_source('attr :foo, :bar')
      expect(new_source).to eq('attr_reader :foo, :bar')
    end
  end

  context 'offense message' do
    it 'for attr :name suggests to use attr_reader' do
      expect_offense(<<-RUBY.strip_indent)
        attr :foo
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY
    end

    it 'for attr :name, false suggests to use attr_reader' do
      expect_offense(<<-RUBY.strip_indent)
        attr :foo, false
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY
    end

    it 'for attr :name, true suggests to use attr_accessor' do
      expect_offense(<<-RUBY.strip_indent)
        attr :foo, true
        ^^^^ Do not use `attr`. Use `attr_accessor` instead.
      RUBY
    end

    it 'for attr with multiple names suggests to use attr_reader' do
      expect_offense(<<-RUBY.strip_indent)
        attr :foo, :bar
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY
    end
  end
end
