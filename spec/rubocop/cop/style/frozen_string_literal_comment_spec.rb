# frozen_string_literal: true

describe RuboCop::Cop::Style::FrozenStringLiteralComment, :config do
  subject(:cop) { described_class.new(config) }

  context 'always' do
    let(:cop_config) do
      { 'Enabled'           => true,
        'EnforcedStyle'     => 'always' }
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'accepts a frozen string literal on the top line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal on the top line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'on the top line' do
      inspect_source('puts 1')

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        puts 1
      RUBY

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'accepts a frozen string literal below a shebang comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal below a shebang comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under an encoding comment' do
      inspect_source(<<-RUBY.strip_indent)
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'accepts a frozen string literal below an encoding comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a dsabled frozen string literal below an encoding comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang and an encoding comment' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'accepts a frozen string literal comment below shebang and encoding ' \
       'comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'accepts a disabled frozen string literal comment below shebang and ' \
       'encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'accepts a frozen string literal comment below shebang above an ' \
       'encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'accepts a disabled frozen string literal comment below shebang above ' \
       'an encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'accepts an emacs style combined magic comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # -*- encoding: UTF-8; frozen_string_literal: true -*-
          # encoding: utf-8
          puts 1
        RUBY
    end

    context 'auto-correct' do
      it 'adds a frozen string literal comment to the first line if one is ' \
         'missing' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after an encoding comment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment when there is an empty line before the code' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8

          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end

      it 'adds a frozen string literal comment after an encoding comment ' \
         'when there is an empty line before the code' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # encoding: utf-8

          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
        RUBY
      end
    end
  end

  context 'when_needed' do
    let(:cop_config) do
      { 'Enabled'           => true,
        'EnforcedStyle'     => 'when_needed' }
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    if RUBY_VERSION >= '2.3.0'
      context 'ruby >= 2.3' do
        context 'no frozen string literal comment' do
          it 'accepts not modifing a string' do
            expect_no_offenses('puts "x"')
          end

          it 'accepts calling + on a string' do
            expect_no_offenses('"x" + "y"')
          end

          it 'accepts calling freeze on a variable' do
            expect_no_offenses(<<-RUBY.strip_indent)
              foo = "x"
                foo.freeze
            RUBY
          end

          it 'accepts calling shovel on a variable' do
            expect_no_offenses(<<-RUBY.strip_indent)
              foo = "x"
                foo << "y"
            RUBY
          end

          it 'accepts freezing a string' do
            expect_no_offenses('"x".freeze')
          end

          it 'accepts when << is called on a string literal' do
            expect_no_offenses('"x" << "y"')
          end
        end

        it 'accepts freezing a string when there is a frozen string literal ' \
           'comment' do
          inspect_source(<<-RUBY.strip_indent)
            # frozen_string_literal: true
            "x".freeze
          RUBY

          expect(cop.offenses).to be_empty
        end

        it 'accepts shoveling into a string when there is a frozen string ' \
           'literal comment' do
          inspect_source(<<-RUBY.strip_indent)
            # frozen_string_literal: true
            "x" << "y"
          RUBY

          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'ruby < 2.3' do
      context 'target_ruby_version < 2.3', :ruby19 do
        it 'accepts freezing a string' do
          expect_no_offenses('"x".freeze')
        end

        it 'accepts calling << on a string' do
          expect_no_offenses('"x" << "y"')
        end

        it 'accepts freezing a string with interpolation' do
          expect_no_offenses('"#{foo}bar".freeze')
        end

        it 'accepts calling << on a string with interpolation' do
          expect_no_offenses('"#{foo}bar" << "baz"')
        end
      end

      context 'target_ruby_version 2.3+', :ruby23 do
        it 'accepts freezing a string' do
          expect_offense(<<-RUBY.strip_indent)
            "x".freeze
            ^ Missing magic comment `# frozen_string_literal: true`.
          RUBY
        end

        it 'accepts calling << on a string' do
          expect_offense(<<-RUBY.strip_indent)
            "x" << "y"
            ^ Missing magic comment `# frozen_string_literal: true`.
          RUBY
        end

        it 'accepts freezing a string with interpolation' do
          expect_offense(<<-'RUBY'.strip_indent)
            "#{foo}bar".freeze
            ^ Missing magic comment `# frozen_string_literal: true`.
          RUBY
        end

        it 'accepts calling << on a string with interpolation' do
          expect_offense(<<-'RUBY'.strip_indent)
            "#{foo}bar" << "baz"
            ^ Missing magic comment `# frozen_string_literal: true`.
          RUBY
        end
      end
    end
  end

  context 'never' do
    let(:cop_config) do
      { 'Enabled'           => true,
        'EnforcedStyle'     => 'never' }
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for a frozen string literal comment ' \
      'on the top line' do
      inspect_source(<<-RUBY.strip_indent)
        # frozen_string_literal: true
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'on the top line' do
      inspect_source(<<-RUBY.strip_indent)
        # frozen_string_literal: false
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'accepts not having a frozen string literal comment on the top line' do
      expect_no_offenses('puts 1')
    end

    it 'accepts not having not having a frozen string literal comment ' \
      'under a shebang' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below a shebang comment' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal ' \
      'below a shebang comment' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'allows not having a frozen string literal comment ' \
      'under an encoding comment' do
      inspect_source(<<-RUBY.strip_indent)
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment below ' \
      'an encoding comment' do
      inspect_source(<<-RUBY.strip_indent)
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a dsabled frozen string literal below ' \
      'an encoding comment' do
      inspect_source(<<-RUBY.strip_indent)
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'allows not having a frozen string literal comment ' \
      'under a shebang and an encoding comment' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below shebang and encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'below shebang and encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below shebang above an encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'below shebang above an encoding comments' do
      inspect_source(<<-RUBY.strip_indent)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        # encoding: utf-8
        puts 1
      RUBY

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    context 'auto-correct' do
      it 'removes the frozen string literal comment from the top line' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal comment on the top line' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment below a shebang comment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal below a shebang comment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment below an encoding comment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a dsabled frozen string literal below an encoding comment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment ' \
        'below shebang and encoding comments' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal comment from ' \
        'below shebang and encoding comments' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end

      it 'removes a disabled frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # frozen_string_literal: false
          # encoding: utf-8
          puts 1
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
        RUBY
      end
    end
  end
end
