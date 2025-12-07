# frozen_string_literal: true

RSpec.describe RuboCop::MagicComment do
  shared_examples 'magic comment' do |comment, expectations = {}|
    encoding = expectations[:encoding]
    frozen_string = expectations[:frozen_string_literal]
    shareable_constant_value = expectations[:shareable_constant_value]
    typed = expectations[:typed]

    it "returns #{encoding.inspect} for encoding when comment is #{comment}" do
      expect(described_class.parse(comment).encoding).to eql(encoding)
    end

    it "returns #{frozen_string.inspect} for frozen_string_literal when comment is #{comment}" do
      expect(described_class.parse(comment).frozen_string_literal).to eql(frozen_string)
    end

    it "returns #{shareable_constant_value.inspect} for shareable_constant_value " \
       "when comment is #{comment}" do
      expect(described_class.parse(comment)
                            .shareable_constant_value).to eql(shareable_constant_value)
    end

    it "returns #{typed.inspect} for typed when comment is #{comment}" do
      expect(described_class.parse(comment).typed).to eql(typed)
    end
  end

  it_behaves_like 'magic comment', '#'

  it_behaves_like 'magic comment', '# encoding: utf-8', encoding: 'utf-8'

  it_behaves_like 'magic comment', '# ENCODING: utf-8', encoding: 'utf-8'

  it_behaves_like 'magic comment', '# eNcOdInG: utf-8', encoding: 'utf-8'

  it_behaves_like 'magic comment', '# coding: utf-8', encoding: 'utf-8'

  it_behaves_like 'magic comment', '    # coding: utf-8', encoding: 'utf-8'

  it_behaves_like 'magic comment', '# incoding: utf-8'

  it_behaves_like 'magic comment',
                  '# encoding: stateless-iso-2022-jp-kddi',
                  encoding: 'stateless-iso-2022-jp-kddi'

  it_behaves_like 'magic comment', '# frozen_string_literal: true', frozen_string_literal: true

  it_behaves_like 'magic comment', '    # frozen_string_literal: true', frozen_string_literal: true

  it_behaves_like 'magic comment', '# frozen_string_literal:true', frozen_string_literal: true

  it_behaves_like 'magic comment', '# frozen_string_literal: false', frozen_string_literal: false

  it_behaves_like 'magic comment', '# frozen-string-literal: true', frozen_string_literal: true

  it_behaves_like 'magic comment', '# FROZEN-STRING-LITERAL: true', frozen_string_literal: true

  it_behaves_like 'magic comment', '# fRoZeN-sTrInG_lItErAl: true', frozen_string_literal: true

  it_behaves_like 'magic comment', '# shareable_constant_value: literal', shareable_constant_value: 'literal'

  it_behaves_like 'magic comment', '# shareable_constant_value:literal', shareable_constant_value: 'literal'

  it_behaves_like 'magic comment', '# shareable-constant-value: literal', shareable_constant_value: 'literal'

  it_behaves_like 'magic comment', '# SHAREABLE-CONSTANT-VALUE: literal', shareable_constant_value: 'literal'

  it_behaves_like 'magic comment', '# sHaReaBLE-CoNstANT-ValUE: literal', shareable_constant_value: 'literal'

  it_behaves_like 'magic comment', '# shareable_constant_value: none', shareable_constant_value: 'none'

  it_behaves_like 'magic comment', '# xyz shareable_constant_value: literal'

  it_behaves_like 'magic comment', '# xyz shareable_constant_value: literal xyz'

  it_behaves_like 'magic comment', '# typed: ignore', typed: 'ignore'

  it_behaves_like 'magic comment', '# typed: false', typed: 'false'

  it_behaves_like 'magic comment', '# typed: true', typed: 'true'

  it_behaves_like 'magic comment', '# typed: strict', typed: 'strict'

  it_behaves_like 'magic comment', '# typed: strong', typed: 'strong'

  it_behaves_like 'magic comment', '#typed:strict', typed: 'strict'

  it_behaves_like 'magic comment', '#    typed:strict', typed: 'strict'

  it_behaves_like 'magic comment', '# @typed'

  it_behaves_like(
    'magic comment',
    '# shareable_constant_value: experimental_everything',
    shareable_constant_value: 'experimental_everything'
  )

  it_behaves_like(
    'magic comment',
    '# shareable_constant_value: experimental_copy',
    shareable_constant_value: 'experimental_copy'
  )

  it_behaves_like 'magic comment',
                  '# -*- frozen-string-literal: true -*-',
                  frozen_string_literal: true

  it_behaves_like 'magic comment',
                  '# frozen_string_literal: invalid',
                  frozen_string_literal: 'invalid'

  it_behaves_like 'magic comment',
                  '# -*- encoding : ascii-8bit -*-',
                  encoding: 'ascii-8bit',
                  frozen_string_literal: nil

  it_behaves_like 'magic comment',
                  '# encoding: ascii-8bit frozen_string_literal: true',
                  encoding: 'ascii-8bit',
                  frozen_string_literal: nil

  it_behaves_like 'magic comment',
                  '# frozen_string_literal: true encoding: ascii-8bit',
                  encoding: 'ascii-8bit',
                  frozen_string_literal: nil

  it_behaves_like 'magic comment',
                  ' CSV.generate(encoding: Encoding::UTF_8) do |csv|',
                  encoding: nil,
                  frozen_string_literal: nil

  it_behaves_like(
    'magic comment',
    '# -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-',
    encoding: 'ascii-8bit',
    frozen_string_literal: true
  )

  it_behaves_like(
    'magic comment',
    '# coding: utf-8 -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-',
    encoding: 'ascii-8bit',
    frozen_string_literal: true
  )

  it_behaves_like(
    'magic comment',
    '# -*- coding: ASCII-8BIT; typed: strict -*-',
    encoding: 'ascii-8bit'
  )

  it_behaves_like 'magic comment',
                  '# vim: filetype=ruby, fileencoding=ascii-8bit',
                  encoding: 'ascii-8bit'

  it_behaves_like 'magic comment', '# vim: filetype=ruby,fileencoding=ascii-8bit', encoding: nil

  it_behaves_like 'magic comment',
                  '# vim: filetype=ruby,  fileencoding=ascii-8bit',
                  encoding: 'ascii-8bit'

  it_behaves_like 'magic comment',
                  '#vim: filetype=ruby, fileencoding=ascii-8bit',
                  encoding: 'ascii-8bit'

  it_behaves_like 'magic comment',
                  '#vim: filetype=ruby, fileencoding=ascii-8bit, typed=strict',
                  encoding: 'ascii-8bit'

  it_behaves_like(
    'magic comment',
    '# coding: utf-8 vim: filetype=ruby, fileencoding=ascii-8bit',
    encoding: 'utf-8'
  )

  it_behaves_like 'magic comment',
                  '# vim: filetype=python, fileencoding=ascii-8bit',
                  encoding: 'ascii-8bit'

  it_behaves_like 'magic comment', '# vim:fileencoding=utf-8', encoding: nil

  describe '#valid?' do
    subject { described_class.parse(comment).valid? }

    context 'with an empty string' do
      let(:comment) { '' }

      it { is_expected.to be(false) }
    end

    context 'with a non magic comment' do
      let(:comment) { '# do something' }

      it { is_expected.to be(false) }
    end

    context 'with an encoding comment' do
      let(:comment) { '# encoding: utf-8' }

      it { is_expected.to be(true) }
    end

    context 'with a frozen string literal comment' do
      let(:comment) { '# frozen-string-literal: true' }

      it { is_expected.to be(true) }
    end

    context 'with a shareable constant value comment' do
      let(:comment) { '# shareable-constant-value: literal' }

      it { is_expected.to be(true) }
    end
  end

  describe '#valid_rbs_inline_value?' do
    subject { described_class.parse(comment).valid_rbs_inline_value? }

    context 'when given comment specified as `enabled`' do
      let(:comment) { '# rbs_inline: enabled' }

      it { is_expected.to be(true) }
    end

    context 'when given comment specified as `disabled`' do
      let(:comment) { '# rbs_inline: disabled' }

      it { is_expected.to be(true) }
    end

    context 'when given comment specified as an invalid value`' do
      let(:comment) { '# rbs_inline: invalid' }

      it { is_expected.to be(false) }
    end
  end

  describe '#valid_shareable_constant_value?' do
    subject { described_class.parse(comment).valid_shareable_constant_value? }

    context 'when given comment specified as `none`' do
      let(:comment) { '# shareable_constant_value: none' }

      it { is_expected.to be(true) }
    end

    context 'when given comment specified as `literal`' do
      let(:comment) { '# shareable_constant_value: literal' }

      it { is_expected.to be(true) }
    end

    context 'when given comment specified as `experimental_everything`' do
      let(:comment) { '# shareable_constant_value: experimental_everything' }

      it { is_expected.to be(true) }
    end

    context 'when given comment specified as `experimental_copy`' do
      let(:comment) { '# shareable_constant_value: experimental_copy' }

      it { is_expected.to be(true) }
    end

    context 'when given comment specified as unknown value' do
      let(:comment) { '# shareable_constant_value: unknown' }

      it { is_expected.to be(false) }
    end

    context 'when given comment is not specified' do
      let(:comment) { '' }

      it { is_expected.to be(false) }
    end
  end

  describe '#without' do
    subject { described_class.parse(comment).without(:encoding) }

    context 'simple format' do
      context 'when the entire comment is a single value' do
        let(:comment) { '# encoding: utf-8' }

        it { is_expected.to eq('') }
      end

      context 'when the comment contains a different magic value' do
        let(:comment) { '# frozen-string-literal: true' }

        it { is_expected.to eq(comment) }
      end
    end

    context 'emacs format' do
      context 'with one token' do
        let(:comment) { '# -*- coding: ASCII-8BIT -*-' }

        it { is_expected.to eq('') }
      end

      context 'with multiple tokens' do
        let(:comment) { '# -*- coding: ASCII-8BIT; frozen_string_literal: true -*-' }

        it { is_expected.to eq('# -*- frozen_string_literal: true -*-') }
      end
    end

    context 'vim format' do
      context 'when the comment has multiple tokens' do
        let(:comment) { '# vim: filetype=ruby, fileencoding=ascii-8bit' }

        it { is_expected.to eq('# vim: filetype=ruby') }
      end
    end
  end
end
