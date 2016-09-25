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

    it "autocorrects string.eql? str.#{selector} without parens " do
      new_source = autocorrect_source(cop, "'string'.eql? str.#{selector}")
      expect(new_source).to eq "str.casecmp('string').zero?"
    end

    it "autocorrects string.eql? str.#{selector} with parens " do
      new_source = autocorrect_source(cop, "'string'.eql?(str.#{selector})")
      expect(new_source).to eq "str.casecmp('string').zero?"
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

    it "doesn't report an offense for variable == str.#{selector}" do
      inspect_source(cop, ['var = "a"',
                           "var == str.#{selector}"])
      expect(cop.offenses).to be_empty
    end

    it "doesn't report an offense for str.#{selector} == variable" do
      inspect_source(cop, ['var = "a"',
                           "str.#{selector} == var"])
      expect(cop.offenses).to be_empty
    end

    it "doesn't report an offense for obj.method == str.#{selector}" do
      inspect_source(cop, "obj.method == str.#{selector}")
      expect(cop.offenses).to be_empty
    end

    it "doesn't report an offense for str.#{selector} == obj.method" do
      inspect_source(cop, "str.#{selector} == obj.method")
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like('selectors', 'upcase')
  it_behaves_like('selectors', 'downcase')
end
