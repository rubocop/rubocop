# frozen_string_literal: true

def unindent(s)
  s.gsub(/^#{s.scan(/^[ \t]+(?=\S)/).min}/, '')
end

def expect_no_copyright_offense(cop, source)
  inspect_source(source)
  expect(cop.offenses.empty?).to be(true)
end

def expect_copyright_offense(cop, source)
  inspect_source(source)
  expect(cop.offenses.size).to eq(1)
end

describe RuboCop::Cop::Style::Copyright, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Notice' => 'Copyright (\(c\) )?2015 Acme Inc' } }

  context 'when the copyright notice is present' do
    let(:source) { unindent(<<-SOURCE) }
      # Copyright 2015 Acme Inc.
      # test2
      names = Array.new
      names << 'James'
    SOURCE

    it 'does not add an offense' do
      expect_no_copyright_offense(cop, source)
    end
  end

  context 'when the copyright notice is not the first comment' do
    let(:source) { unindent(<<-SOURCE) }
      # test2
      # Copyright 2015 Acme Inc.
      names = Array.new
      names << 'James'
    SOURCE

    it 'does not add an offense' do
      expect_no_copyright_offense(cop, source)
    end
  end

  context 'when the copyright notice is in a block comment' do
    let(:source) { unindent(<<-SOURCE) }
      =begin
      blah, blah, blah
      Copyright 2015 Acme Inc.
      =end
      names = Array.new
      names << 'James'
    SOURCE

    it 'does not add an offense' do
      expect_no_copyright_offense(cop, source)
    end
  end

  context 'when the copyright notice is missing' do
    let(:source) { unindent(<<-SOURCE) }
      # test
      # test2
      names = Array.new
      names << 'James'
    SOURCE

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    let(:expected_autocorrected_source) { unindent(<<-SOURCE) }
      # Copyright (c) 2015 Acme Inc.
      # test
      # test2
      names = Array.new
      names << 'James'
    SOURCE

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'
      autocorrected_source = autocorrect_source(source)
      expect(autocorrected_source).to eq(expected_autocorrected_source)
    end

    it 'fails to autocorrect when the AutocorrectNotice does ' \
       'not match the Notice pattern' do
      cop_config['AutocorrectNotice'] = '# Copyleft (c) 2015 Acme Inc.'
      expect do
        autocorrect_source(source)
      end.to raise_error(RuboCop::Warning)
    end

    it 'fails to autocorrect if no AutocorrectNotice is given' do
      # cop_config['AutocorrectNotice'] = '# Copyleft (c) 2015 Acme Inc.'
      expect do
        autocorrect_source(source)
      end.to raise_error(RuboCop::Warning)
    end
  end

  context 'when the copyright notice comes after any code' do
    let(:source) { unindent(<<-SOURCE) }
      # test2
      names = Array.new
      # Copyright (c) 2015 Acme Inc.
      names << 'James'
    SOURCE

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    let(:expected_autocorrected_source) { unindent(<<-SOURCE) }
      # Copyright (c) 2015 Acme Inc.
      # test2
      names = Array.new
      # Copyright (c) 2015 Acme Inc.
      names << 'James'
    SOURCE

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'
      autocorrected_source = autocorrect_source(source)
      expect(autocorrected_source).to eq(expected_autocorrected_source)
    end
  end

  context 'when the source code file is empty' do
    let(:source) { '' }

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    let(:expected_autocorrected_source) { "# Copyright (c) 2015 Acme Inc.\n" }

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'
      autocorrected_source = autocorrect_source(source)
      expect(autocorrected_source).to eq(expected_autocorrected_source)
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with a shebang' do
    let(:source) { unindent(<<-SOURCE) }
      #!/usr/bin/env ruby
      names = Array.new
      names << 'James'
    SOURCE

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    let(:expected_autocorrected_source) { unindent(<<-SOURCE) }
      #!/usr/bin/env ruby
      # Copyright (c) 2015 Acme Inc.
      names = Array.new
      names << 'James'
    SOURCE

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'
      autocorrected_source = autocorrect_source(source)
      expect(autocorrected_source).to eq(expected_autocorrected_source)
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with an encoding comment' do
    let(:source) { unindent(<<-SOURCE) }
      # encoding: utf-8
      names = Array.new
      names << 'James'
    SOURCE

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    let(:expected_autocorrected_source) { unindent(<<-SOURCE) }
      # encoding: utf-8
      # Copyright (c) 2015 Acme Inc.
      names = Array.new
      names << 'James'
    SOURCE

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'
      autocorrected_source = autocorrect_source(source)
      expect(autocorrected_source).to eq(expected_autocorrected_source)
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with shebang and ' \
          'an encoding comment' do
    let(:source) { unindent(<<-SOURCE) }
      #!/usr/bin/env ruby
      # encoding: utf-8
      names = Array.new
      names << 'James'
    SOURCE

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    let(:expected_autocorrected_source) { unindent(<<-SOURCE) }
      #!/usr/bin/env ruby
      # encoding: utf-8
      # Copyright (c) 2015 Acme Inc.
      names = Array.new
      names << 'James'
    SOURCE

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'
      autocorrected_source = autocorrect_source(source)
      expect(autocorrected_source).to eq(expected_autocorrected_source)
    end
  end
end
