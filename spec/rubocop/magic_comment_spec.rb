# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::MagicComment do
  shared_examples 'magic comment' do |comment, expectations = {}|
    encoding = expectations[:encoding]
    frozen_string = expectations[:frozen_string_literal]

    it "returns #{encoding.inspect} for encoding when comment is #{comment}" do
      expect(described_class.parse(comment).encoding).to eql(encoding)
    end

    it "returns #{frozen_string.inspect} for frozen_string_literal " \
         "when comment is #{comment}" do
      expect(described_class.parse(comment).frozen_string_literal)
        .to eql(frozen_string)
    end
  end

  include_examples 'magic comment', '#'

  include_examples 'magic comment',
                   '# encoding: utf-8',
                   encoding: 'utf-8'

  include_examples 'magic comment',
                   '# ENCODING: utf-8',
                   encoding: 'utf-8'

  include_examples 'magic comment',
                   '# eNcOdInG: utf-8',
                   encoding: 'utf-8'

  include_examples 'magic comment',
                   '# coding: utf-8',
                   encoding: 'utf-8'

  include_examples 'magic comment',
                   '# incoding: utf-8'

  include_examples 'magic comment',
                   '# encoding: stateless-iso-2022-jp-kddi',
                   encoding: 'stateless-iso-2022-jp-kddi'

  include_examples 'magic comment',
                   '# frozen_string_literal: true',
                   frozen_string_literal: true

  include_examples 'magic comment',
                   '# frozen_string_literal:true',
                   frozen_string_literal: true

  include_examples 'magic comment',
                   '# frozen_string_literal: false',
                   frozen_string_literal: false

  include_examples 'magic comment',
                   '# frozen-string-literal: true',
                   frozen_string_literal: true

  include_examples 'magic comment',
                   '# FROZEN-STRING-LITERAL: true',
                   frozen_string_literal: true

  include_examples 'magic comment',
                   '# fRoZeN-sTrInG_lItErAl: true',
                   frozen_string_literal: true

  include_examples 'magic comment',
                   '# frozen_string_literal: invalid',
                   frozen_string_literal: 'invalid'

  include_examples 'magic comment',
                   '# -*- encoding : ascii-8bit -*-',
                   encoding: 'ascii-8bit',
                   frozen_string_literal: nil

  include_examples 'magic comment',
                   '# encoding: ascii-8bit frozen_string_literal: true',
                   encoding: 'ascii-8bit',
                   frozen_string_literal: nil

  include_examples 'magic comment',
                   '# frozen_string_literal: true encoding: ascii-8bit',
                   encoding: 'ascii-8bit',
                   frozen_string_literal: nil

  include_examples(
    'magic comment',
    '# -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-',
    encoding: 'ascii-8bit',
    frozen_string_literal: true
  )

  include_examples(
    'magic comment',
    '# coding: utf-8 -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-',
    encoding: 'ascii-8bit',
    frozen_string_literal: true
  )

  include_examples 'magic comment',
                   '# vim: filetype=ruby, fileencoding=ascii-8bit',
                   encoding: 'ascii-8bit'

  include_examples 'magic comment',
                   '# vim: filetype=ruby,fileencoding=ascii-8bit',
                   encoding: nil

  include_examples 'magic comment',
                   '# vim: filetype=ruby,  fileencoding=ascii-8bit',
                   encoding: 'ascii-8bit'

  include_examples 'magic comment',
                   '#vim: filetype=ruby, fileencoding=ascii-8bit',
                   encoding: 'ascii-8bit'

  include_examples(
    'magic comment',
    '# coding: utf-8 vim: filetype=ruby, fileencoding=ascii-8bit',
    encoding: 'utf-8'
  )

  include_examples 'magic comment',
                   '# vim: filetype=python, fileencoding=ascii-8bit',
                   encoding: 'ascii-8bit'

  include_examples 'magic comment',
                   '# vim:fileencoding=utf-8',
                   encoding: nil
end
