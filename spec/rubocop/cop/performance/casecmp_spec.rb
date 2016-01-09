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

    it "formats the error message correctly for str.#{selector} ==" do
      inspect_source(cop, "str.#{selector} == 'string'")
      expect(cop.messages).to eq(["Use `casecmp` instead of `#{selector} ==`."])
    end
  end

  it_behaves_like('selectors', 'upcase')
  it_behaves_like('selectors', 'downcase')
end
