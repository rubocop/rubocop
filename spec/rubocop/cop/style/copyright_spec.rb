# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Copyright, :config do
  let(:cop_config) { { 'Notice' => 'Copyright (\(c\) )?2015 Acme Inc' } }

  it 'does not register an offense when the notice is present' do
    expect_no_offenses(<<~RUBY)
      # Copyright 2015 Acme Inc.
      # test2
      names = Array.new
      names << 'James'
    RUBY
  end

  it 'does not register an offense when the notice is not the first comment' do
    expect_no_offenses(<<~RUBY)
      # test2
      # Copyright 2015 Acme Inc.
      names = Array.new
      names << 'James'
    RUBY
  end

  it 'does not register an offense when the notice is in a block comment' do
    expect_no_offenses(<<~RUBY)
      =begin
      blah, blah, blah
      Copyright 2015 Acme Inc.
      =end
      names = Array.new
      names << 'James'
    RUBY
  end

  context 'when the copyright notice is missing' do
    let(:source) { <<~RUBY }
      # test
      ^ Include a copyright notice matching [...]
      # test2
      names = Array.new
      names << 'James'
    RUBY

    it 'adds an offense' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect_offense(source)

      expect_correction(<<~RUBY)
        # Copyright (c) 2015 Acme Inc.
        # test
        # test2
        names = Array.new
        names << 'James'
      RUBY
    end

    it 'fails to autocorrect when the AutocorrectNotice does not match the Notice pattern' do
      cop_config['AutocorrectNotice'] = '# Copyleft (c) 2015 Acme Inc.'
      expect { expect_offense(source) }.to raise_error(RuboCop::Warning)
    end

    it 'fails to autocorrect if no AutocorrectNotice is given' do
      # cop_config['AutocorrectNotice'] = '# Copyleft (c) 2015 Acme Inc.'
      expect { expect_offense(source) }.to raise_error(RuboCop::Warning)
    end
  end

  context 'when the copyright notice comes after any code' do
    it 'adds an offense' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect_offense(<<~RUBY)
        # test2
        ^ Include a copyright notice matching [...]
        names = Array.new
        # Copyright (c) 2015 Acme Inc.
        names << 'James'
      RUBY

      expect_correction(<<~RUBY)
        # Copyright (c) 2015 Acme Inc.
        # test2
        names = Array.new
        # Copyright (c) 2015 Acme Inc.
        names << 'James'
      RUBY
    end
  end

  context 'when the source code file is empty' do
    it 'adds an offense' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect_offense(<<~RUBY)
        ^ Include a copyright notice matching [...]
      RUBY

      expect_correction(<<~RUBY)
        # Copyright (c) 2015 Acme Inc.
      RUBY
    end
  end

  context 'when the copyright notice is missing and the source code file starts with a shebang' do
    it 'adds an offense' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Include a copyright notice matching [...]
        names = Array.new
        names << 'James'
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
      RUBY
    end
  end

  context 'when the copyright notice is missing and ' \
          'the source code file starts with an encoding comment' do
    it 'adds an offense' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect_offense(<<~RUBY)
        # encoding: utf-8
        ^ Include a copyright notice matching [...]
        names = Array.new
        names << 'James'
      RUBY

      expect_correction(<<~RUBY)
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
    it 'adds an offense' do
      cop_config['AutocorrectNotice'] = '# Copyright (c) 2015 Acme Inc.'

      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Include a copyright notice matching [...]
        # encoding: utf-8
        names = Array.new
        names << 'James'
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
      RUBY
    end
  end
end
