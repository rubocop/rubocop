# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Encoding, :config do
  it 'does not register an offense when no encoding present' do
    expect_no_offenses(<<~RUBY)
      def foo() end
    RUBY
  end

  it 'does not register an offense when encoding present but not UTF-8' do
    expect_no_offenses(<<~RUBY)
      # encoding: us-ascii
      def foo() end
    RUBY
  end

  it 'does not register an offense on a different magic comment type' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      def foo() end
    RUBY
  end

  it 'registers an offense when encoding present and UTF-8' do
    expect_offense(<<~RUBY)
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY

    expect_correction(<<~RUBY)
      def foo() end
    RUBY
  end

  it 'registers an offense when encoding present on 2nd line after shebang' do
    expect_offense(<<~RUBY)
      #!/usr/bin/env ruby
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY

    expect_correction(<<~RUBY)
      #!/usr/bin/env ruby
      def foo() end
    RUBY
  end

  it 'registers an offense and corrects if there are multiple encoding magic comments' do
    expect_offense(<<~RUBY)
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      # coding: utf-8
      ^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY

    expect_correction(<<~RUBY)
      def foo() end
    RUBY
  end

  it 'registers an offense and corrects the magic comment follows another magic comment' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
      def foo() end
    RUBY
  end

  it 'does not register an offense when encoding is not at the top of the file' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true

      # encoding: utf-8
      def foo() end
    RUBY
  end

  it 'does not register an offense when encoding is in the wrong place' do
    expect_no_offenses(<<~RUBY)
      def foo() end
      # encoding: utf-8
    RUBY
  end

  context 'vim comments' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        # vim:filetype=ruby, fileencoding=utf-8
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
        def foo() end
      RUBY

      expect_correction(<<~RUBY)
        # vim: filetype=ruby
        def foo() end
      RUBY
    end
  end

  context 'emacs comment' do
    it 'registers an offense for encoding' do
      expect_offense(<<~RUBY)
        # -*- encoding : utf-8 -*-
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
        def foo() 'ä' end
      RUBY

      expect_correction(<<~RUBY)
        def foo() 'ä' end
      RUBY
    end

    it 'only removes encoding if there are other editor comments' do
      expect_offense(<<~RUBY)
        # -*- encoding : utf-8; mode: enh-ruby -*-
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
        def foo() 'ä' end
      RUBY

      expect_correction(<<~RUBY)
        # -*- mode: enh-ruby -*-
        def foo() 'ä' end
      RUBY
    end
  end
end
