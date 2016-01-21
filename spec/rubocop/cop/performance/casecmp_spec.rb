# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::Casecmp do
  subject(:cop) { described_class.new }

  shared_examples 'selectors' do |selector|
    it "autocorrects str.#{selector} ==" do
      new_source = autocorrect_source(cop, "str.#{selector} == 'string'")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects str.#{selector} == with parens around arg" do
      new_source = autocorrect_source(cop, "str.#{selector} == ('string')")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects str.#{selector} !=" do
      new_source = autocorrect_source(cop, "str.#{selector} != 'string'")
      expect(new_source).to eq "!str.casecmp('string').zero?"
    end

    it "autocorrects str.#{selector} != with parens around arg" do
      new_source = autocorrect_source(cop, "str.#{selector} != ('string')")
      expect(new_source).to eq "!str.casecmp('string').zero?"
    end

    it "autocorrects str.#{selector}.eql? without parens" do
      new_source = autocorrect_source(cop, "str.#{selector}.eql? 'string'")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects str.#{selector}.eql? with parens" do
      new_source = autocorrect_source(cop, "str.#{selector}.eql?('string')")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects str.#{selector}.eql? with parens and funny spacing" do
      new_source = autocorrect_source(cop, "str.#{selector}.eql? ( 'string' )")
      expect(new_source).to eq "str.casecmp( 'string' ).zero?"
    end

    it "autocorrects str.#{selector} == a variable" do
      new_source = autocorrect_source(cop, ['other = "a"',
                                            "str.#{selector} == other"])
      expect(new_source).to eq(['other = "a"',
                                'str.casecmp(other).zero?'].join("\n"))
    end

    it "autocorrects str.#{selector} == a method" do
      new_source = autocorrect_source(cop, "str.#{selector} == method(foo)")
      expect(new_source).to eq('str.casecmp(method(foo)).zero?')
    end

    it "autocorrects str.#{selector} == a method call on a variable" do
      new_source = autocorrect_source(cop, "str.#{selector} == other.join")
      expect(new_source).to eq('str.casecmp(other.join).zero?')
    end

    it "autocorrects str.#{selector} == a method call on a variable " \
       'with params' do
      new_source = autocorrect_source(cop,
                                      "str.#{selector} == other.join(', ')")
      expect(new_source).to eq("str.casecmp(other.join(', ')).zero?")
    end

    it "autocorrects str.#{selector} == a method call on a variable " \
       'with a block' do
      source = "str.#{selector} == other.method { |o| o.to_s }"
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq('str.casecmp(other.method { |o| o.to_s }).zero?')
    end

    it "autocorrects == str.#{selector}" do
      new_source = autocorrect_source(cop, "'string' == str.#{selector}")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects string with parens == str.#{selector}" do
      new_source = autocorrect_source(cop, "('string') == str.#{selector}")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects string != str.#{selector}" do
      new_source = autocorrect_source(cop, "'string' != str.#{selector}")
      expect(new_source).to eq "!str.casecmp('string').zero?"
    end

    it 'autocorrects string with parens and funny spacing ' \
       "eql? str.#{selector}" do
      new_source = autocorrect_source(cop, "( 'string' ).eql? str.#{selector}")
      expect(new_source).to eq "str.casecmp( 'string' ).zero?"
    end

    it "autocorrects a method call == str.#{selector}" do
      new_source = autocorrect_source(cop, "other.join == str.#{selector}")
      expect(new_source).to eq('str.casecmp(other.join).zero?')
    end

    it "autocorrects a method call with params == str.#{selector}" do
      new_source = autocorrect_source(cop,
                                      "other.join(', ') == str.#{selector}")
      expect(new_source).to eq("str.casecmp(other.join(', ')).zero?")
    end

    it "autocorrects a method call with a block == str.#{selector}" do
      source = "other.method { |o| o.to_s } == str.#{selector}"
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq('str.casecmp(other.method { |o| o.to_s }).zero?')
    end

    it "autocorrects string.eql? str.#{selector} without parens " do
      new_source = autocorrect_source(cop, "'string'.eql? str.#{selector}")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects string.eql? str.#{selector} with parens " do
      new_source = autocorrect_source(cop, "'string'.eql?(str.#{selector})")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects variable == str.#{selector}" do
      new_source = autocorrect_source(cop, ['other = "a"',
                                            "other == str.#{selector}"])
      expect(new_source).to eq(['other = "a"',
                                'str.casecmp(other).zero?'].join("\n"))
    end

    it "autocorrects obj.#{selector} == str.#{selector}" do
      new_source = autocorrect_source(cop, "obj.#{selector} == str.#{selector}")
      expect(new_source).to eq "obj.casecmp(str.#{selector}).zero?"
    end

    it "autocorrects obj.#{selector} eql? str.#{selector}" do
      new_source = autocorrect_source(cop,
                                      "obj.#{selector}.eql? str.#{selector}")
      expect(new_source).to eq "obj.casecmp(str.#{selector}).zero?"
    end

    it "formats the error message correctly for str.#{selector} ==" do
      inspect_source(cop, "str.#{selector} == 'string'")
      expect(cop.highlights).to eq(["#{selector} =="])
      expect(cop.messages).to eq(["Use `casecmp` instead of `#{selector} ==`."])
    end

    it "formats the error message correctly for == str.#{selector}" do
      inspect_source(cop, "'string' == str.#{selector}")
      expect(cop.highlights).to eq(["== str.#{selector}"])
      expect(cop.messages).to eq(["Use `casecmp` instead of `== #{selector}`."])
    end

    it 'formats the error message correctly for ' \
       "obj.#{selector} == str.#{selector}" do
      inspect_source(cop, "obj.#{selector} == str.#{selector}")
      expect(cop.highlights).to eq(["obj.#{selector} == str.#{selector}"])
      expect(cop.messages).to eq(["Use `casecmp` instead of `#{selector} ==`."])
    end
  end

  it_behaves_like('selectors', 'upcase')
  it_behaves_like('selectors', 'downcase')
end
