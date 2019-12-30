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
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'on the top line' do
      expect_offense(<<~RUBY)
        puts 1
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'when there is only a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
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
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under an encoding comment separated by a newline' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        ^ Missing magic comment `# frozen_string_literal: true`.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: true

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

    it 'accepts a disabled frozen string literal below an encoding comment' do
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
        ^ Missing magic comment `# frozen_string_literal: true`.
        # encoding: utf-8
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense with an empty line between magic comments ' \
       'and the code' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        # encoding: utf-8

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true

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

    it 'accepts a frozen string literal comment below newline-separated ' \
       'magic comments' do
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
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY
    end

    it 'registers an offence for an extra first empty line' do
      pending 'There is a flaw that skips adding caret symbol in this case' \
              'making it impossible to use `expect_offense` matcher'

      expect_offense(<<~RUBY)

        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY

      expect(new_source).to eq(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
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

      expect_correction(<<~RUBY)
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

      expect_correction(<<~RUBY)
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

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
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

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
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

      expect_correction(<<~RUBY)
        # encoding: utf-8
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal below ' \
      'an encoding comment' do
      expect_offense(<<~RUBY)
        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # encoding: utf-8
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

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
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

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
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

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
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

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # encoding: utf-8
        puts 1
      RUBY
    end
  end
end
