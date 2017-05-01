# frozen_string_literal: true

describe RuboCop::Cop::Rails::ReadWriteAttribute do
  subject(:cop) { described_class.new }

  context 'read_attribute' do
    it 'registers an offense' do
      inspect_source(cop, 'res = read_attribute(:test)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['read_attribute'])
    end

    it 'registers no offense with explicit receiver' do
      expect_no_offenses('res = object.read_attribute(:test)')
    end
  end

  context 'write_attribute' do
    it 'registers an offense' do
      inspect_source(cop, 'write_attribute(:test, val)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['write_attribute'])
    end

    it 'registers no offense with explicit receiver' do
      expect_no_offenses('object.write_attribute(:test, val)')
    end
  end

  describe '#autocorrect' do
    context 'write_attribute' do
      it 'autocorrects symbol' do
        source = 'write_attribute(:attr, var)'
        corrected_source = 'self[:attr] = var'

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects string' do
        source = "write_attribute('attr', 'test')"
        corrected_source = "self['attr'] = 'test'"

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects without parentheses' do
        source = "write_attribute 'attr', 'test'"
        corrected_source = "self['attr'] = 'test'"

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects expression' do
        source = "write_attribute(:attr, 'test_' + postfix)"
        corrected_source = "self[:attr] = 'test_' + postfix"

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects multiline' do
        source = [
          'write_attribute(',
          ':attr, ',
          '(',
          "'test_' + postfix",
          ').to_sym',
          ')',
          ''
        ]
        corrected_source = <<-END.strip_indent
          self[:attr] = (
          'test_' + postfix
          ).to_sym
        END

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end

    context 'read_attribute' do
      it 'autocorrects symbol' do
        source = 'res = read_attribute(:test)'
        corrected_source = 'res = self[:test]'

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects string' do
        source = "res = read_attribute('test')"
        corrected_source = "res = self['test']"

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects without parentheses' do
        source = "res = read_attribute 'test'"
        corrected_source = "res = self['test']"

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects expression' do
        source = "res = read_attribute('test_' + postfix)"
        corrected_source = "res = self['test_' + postfix]"

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end

      it 'autocorrects multiline' do
        source = <<-END.strip_indent
          res = read_attribute(
          (
          'test_' + postfix
          ).to_sym
          )
        END
        corrected_source = <<-END.strip_indent
          res = self[(
          'test_' + postfix
          ).to_sym]
        END

        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end
  end
end
