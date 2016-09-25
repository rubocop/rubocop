# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceBeforeFirstArg, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowForAlignment' => true } }

  context 'for method calls without parentheses' do
    it 'registers an offense for method call with two spaces before the ' \
       'first arg' do
      inspect_source(cop, ['something  x',
                           'a.something  y, z'])
      expect(cop.messages)
        .to eq(['Put one space between the method name and the first ' \
                'argument.'] * 2)
      expect(cop.highlights).to eq(['  ', '  '])
    end

    it 'auto-corrects extra space' do
      new_source = autocorrect_source(cop, ['something  x',
                                            'a.something   y, z'])
      expect(new_source).to eq(['something x',
                                'a.something y, z'].join("\n"))
    end

    it 'accepts a method call with one space before the first arg' do
      inspect_source(cop, ['something x',
                           'a.something y, z'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts + operator' do
      inspect_source(cop, ['something +',
                           '  x'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts setter call' do
      inspect_source(cop, ['something.x =',
                           '  y'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts multiple space containing line break' do
      inspect_source(cop, ['something \\',
                           '  x'])
      expect(cop.offenses).to be_empty
    end

    context 'when AllowForAlignment is true' do
      it 'accepts method calls with aligned first arguments' do
        inspect_source(cop, ['form.inline_input   :full_name,     as: :string',
                             'form.disabled_input :password,      as: :passwd',
                             'form.masked_input   :zip_code,      as: :string',
                             'form.masked_input   :email_address, as: :email',
                             'form.masked_input   :phone_number,  as: :tel'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'when AllowForAlignment is false' do
      let(:cop_config) { { 'AllowForAlignment' => false } }

      it 'does not accept method calls with aligned first arguments' do
        inspect_source(cop, ['form.inline_input   :full_name,     as: :string',
                             'form.disabled_input :password,      as: :passwd',
                             'form.masked_input   :zip_code,      as: :string',
                             'form.masked_input   :email_address, as: :email',
                             'form.masked_input   :phone_number,  as: :tel'])
        expect(cop.offenses.size).to eq(4)
      end
    end
  end

  context 'for method calls with parentheses' do
    it 'accepts a method call without space' do
      inspect_source(cop, ['something(x)',
                           'a.something(y, z)'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a method call with space after the left parenthesis' do
      inspect_source(cop, 'something(  x  )')
      expect(cop.offenses).to be_empty
    end
  end
end
