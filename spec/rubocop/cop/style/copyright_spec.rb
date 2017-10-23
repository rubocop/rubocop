# frozen_string_literal: true

def expect_copyright_offense(cop, source)
  inspect_source(source)
  expect(cop.offenses.size).to eq(1)
end

describe RuboCop::Cop::Style::Copyright, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Notice' => 'Copyright (\(c\) )?2015 Acme Inc' } }

  it 'does not register an offense when the notice is present' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # Copyright 2015 Acme Inc.
      # test2
      names = Array.new
      names << 'James'
    RUBY
  end

  it 'does not register an offense when the notice is not the first comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # test2
      # Copyright 2015 Acme Inc.
      names = Array.new
      names << 'James'
    RUBY
  end

  it 'does not register an offense when the notice is in a block comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      =begin
      blah, blah, blah
      Copyright 2015 Acme Inc.
      =end
      names = Array.new
      names << 'James'
    RUBY
  end

  context 'when the copyright notice is missing' do
    let(:source) { <<-RUBY.strip_indent }
      # test
      # test2
      names = Array.new
      names << 'James'
    RUBY

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect(autocorrect_source(source)).to eq(<<-RUBY.strip_indent)
        # Copyright (c) 2015 Acme Inc.
        # test
        # test2
        names = Array.new
        names << 'James'
      RUBY
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
    let(:source) { <<-RUBY.strip_indent }
      # test2
      names = Array.new
      # Copyright (c) 2015 Acme Inc.
      names << 'James'
    RUBY

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect(autocorrect_source(source)).to eq(<<-RUBY.strip_indent)
        # Copyright (c) 2015 Acme Inc.
        # test2
        names = Array.new
        # Copyright (c) 2015 Acme Inc.
        names << 'James'
      RUBY
    end
  end

  context 'when the source code file is empty' do
    let(:source) { '' }

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect(autocorrect_source(source))
        .to eq("# Copyright (c) 2015 Acme Inc.\n")
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with a shebang' do
    let(:source) { <<-RUBY.strip_indent }
      #!/usr/bin/env ruby
      names = Array.new
      names << 'James'
    RUBY

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect(autocorrect_source(source)).to eq(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
      RUBY
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with an encoding comment' do
    let(:source) { <<-RUBY.strip_indent }
      # encoding: utf-8
      names = Array.new
      names << 'James'
    RUBY

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect(autocorrect_source(source)).to eq(<<-RUBY.strip_indent)
        # encoding: utf-8
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
      RUBY
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with shebang and ' \
          'an encoding comment' do
    let(:source) { <<-RUBY.strip_indent }
      #!/usr/bin/env ruby
      # encoding: utf-8
      names = Array.new
      names << 'James'
    RUBY

    it 'adds an offense' do
      expect_copyright_offense(cop, source)
    end

    it 'correctly autocorrects the source code' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect(autocorrect_source(source)).to eq(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
      RUBY
    end
  end
end
