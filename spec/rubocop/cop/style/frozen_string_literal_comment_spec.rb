# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FrozenStringLiteralComment, :config do
  subject(:cop) { described_class.new(config) }

  context 'always' do
    let(:cop_config) do
      { 'Enabled'       => true,
        'EnforcedStyle' => 'always' }
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'accepts a frozen string literal on the top line' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal on the top line' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for arbitrary tokens' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: token
        ^ Missing magic "frozen_string_literal" comment.
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'on the top line' do
      expect_offense(<<~RUBY)
        puts 1
        ^ Missing magic "frozen_string_literal" comment.
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic "frozen_string_literal" comment.
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal below a shebang comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal below a shebang comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under an encoding comment' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        ^ Missing magic "frozen_string_literal" comment.
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal below an encoding comment' do
      expect_no_offenses(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a dsabled frozen string literal below an encoding comment' do
      expect_no_offenses(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang and an encoding comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic "frozen_string_literal" comment.
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal comment below shebang and encoding ' \
       'comments' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal comment below shebang and ' \
       'encoding comments' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal comment below shebang above an ' \
       'encoding comments' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal comment below shebang above ' \
       'an encoding comments' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'accepts an emacs style combined magic comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # -*- encoding: UTF-8; frozen_string_literal: true -*-
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offence for not having a frozen string literal comment ' \
       'when there is only a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic "frozen_string_literal" comment.
      RUBY
    end

    context 'auto-correct' do
      it 'adds a frozen string literal comment to the first line if one is ' \
         'missing' do
        new_source = autocorrect_source(<<~RUBY)
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment to the first line if one is ' \
         'missing and handles extra spacing' do
        new_source = autocorrect_source(<<~RUBY)

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after an encoding comment' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment when there is an empty line before the code' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after an encoding comment ' \
         'when there is an empty line before the code' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang when there is ' \
         'only a shebang' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
        RUBY
      end
    end
  end

  context 'never' do
    let(:cop_config) do
      { 'Enabled'       => true,
        'EnforcedStyle' => 'never' }
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for a frozen string literal comment ' \
      'on the top line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'on the top line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'accepts not having a frozen string literal comment on the top line' do
      expect_no_offenses('puts 1')
    end

    it 'accepts not having not having a frozen string literal comment ' \
      'under a shebang' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        puts 1
      RUBY
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal ' \
      'below a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'allows not having a frozen string literal comment ' \
      'under an encoding comment' do
      expect_no_offenses(<<~RUBY)
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offense for a frozen string literal comment below ' \
      'an encoding comment' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'registers an offense for a dsabled frozen string literal below ' \
      'an encoding comment' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'allows not having a frozen string literal comment ' \
      'under a shebang and an encoding comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below shebang and encoding comments' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'below shebang and encoding comments' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below shebang above an encoding comments' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'below shebang above an encoding comments' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        # encoding: utf-8
        puts 1
      RUBY
    end

    context 'auto-correct' do
      it 'removes the frozen string literal comment from the top line' do
        new_source = autocorrect_source(<<~RUBY)
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal comment on the top line' do
        new_source = autocorrect_source(<<~RUBY)
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment below a shebang comment' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal below a shebang comment' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment below an encoding comment' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal below an encoding comment' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment ' \
        'below shebang and encoding comments' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal comment from ' \
        'below shebang and encoding comments' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end
    end
  end

  context 'always_true' do
    let(:cop_config) do
      { 'Enabled'       => true,
        'EnforcedStyle' => 'always_true' }
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'accepts a frozen string literal on the top line' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal on the top ' \
       'line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY
    end

    it 'registers an offense for arbitrary tokens' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: token
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'on the top line' do
      expect_offense(<<~RUBY)
        puts 1
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal below a shebang comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal below ' \
       'a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under an encoding comment' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal below an encoding comment' do
      expect_no_offenses(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal ' \
       'below an encoding comment' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang and an encoding comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal comment below shebang and encoding ' \
       'comments' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
       'below shebang and encoding comments' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal comment below shebang above an ' \
       'encoding comments' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal ' \
       'comment below shebang above an encoding comments' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'accepts an emacs style combined magic comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # -*- encoding: UTF-8; frozen_string_literal: true -*-
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offence for not having a frozen string literal comment ' \
       'when there is only a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY
    end

    context 'auto-correct' do
      it 'adds a frozen string literal comment to the first line if one is ' \
         'missing' do
        new_source = autocorrect_source(<<~RUBY)
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment on the first line when ' \
         'one is disabled' do
        new_source = autocorrect_source(<<~RUBY)
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment on the first line when ' \
         'one is invalid' do
        new_source = autocorrect_source(<<~RUBY)
          # frozen_string_literal: foobar
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment to the first line if one is ' \
         'missing and handles extra spacing' do
        new_source = autocorrect_source(<<~RUBY)

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment on the first line when ' \
         'one is disabled and handles extra spacing' do
        new_source = autocorrect_source(<<~RUBY)
          # frozen_string_literal: false

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment on the first line when ' \
         'one is invalid and handles extra spacing' do
        new_source = autocorrect_source(<<~RUBY)
          # frozen_string_literal: foobar

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang when' \
         'one is disabled' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang when' \
         'one is invalid' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: foobar
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after an encoding comment' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after an encoding comment' \
         'when one is disabled' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after an encoding comment' \
         'when one is invalid' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: foobar
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang and ' \
         'encoding comment when one is disabled' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang and ' \
         'encoding comment when one is invalid' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: foobar
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment when there is an empty line before the code' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang and ' \
         'encoding comment when there is an empty line before the code and ' \
         'there is a disabled frozen string literal comment' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: false

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang and ' \
         'encoding comment when there is an empty line before the code and ' \
         'there is an invalid frozen string literal comment' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: foobar

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after an encoding comment ' \
         'when there is an empty line before the code' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after an encoding comment ' \
         'when disabled and there is an empty line before the code' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: false

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'enables a frozen string literal comment after an encoding comment ' \
         'when invalid and there is an empty line before the code' do
        new_source = autocorrect_source(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: foobar

          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang when there is ' \
         'only a shebang' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang ' \
         'when disabled and there is only a shebang' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
        RUBY
      end

      it 'enables a frozen string literal comment after a shebang ' \
         'when invalid and there is only a shebang' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: foo
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
        RUBY
      end

      it 'enables a disabled frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'enables an invalid frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: foobar
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<~RUBY)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # encoding: utf-8
          puts 1
        RUBY
      end
    end
  end
end
