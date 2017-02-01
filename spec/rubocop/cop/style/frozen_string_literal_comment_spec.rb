# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::FrozenStringLiteralComment, :config do
  subject(:cop) { described_class.new(config) }

  context 'always' do
    let(:cop_config) do
      { 'Enabled'           => true,
        'EnforcedStyle'     => 'always' }
    end

    it 'accepts an empty source' do
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    it 'accepts a source with no tokens' do
      inspect_source(cop, ' ')

      expect(cop.offenses).to be_empty
    end

    it 'accepts a frozen string literal on the top line' do
      inspect_source(cop, ['# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts a disabled frozen string literal on the top line' do
      inspect_source(cop, ['# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'on the top line' do
      inspect_source(cop, 'puts 1')

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           'puts 1'])

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'accepts a frozen string literal below a shebang comment' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts a disabled frozen string literal below a shebang comment' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under an encoding comment' do
      inspect_source(cop, ['# encoding: utf-8',
                           'puts 1'])

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'accepts a frozen string literal below an encoding comment' do
      inspect_source(cop, ['# encoding: utf-8',
                           '# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts a dsabled frozen string literal below an encoding comment' do
      inspect_source(cop, ['# encoding: utf-8',
                           '# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under a shebang and an encoding comment' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           'puts 1'])

      expect(cop.messages)
        .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
    end

    it 'accepts a frozen string literal comment below shebang and encoding ' \
       'comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           '# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts a disabled frozen string literal comment below shebang and ' \
       'encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           '# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts a frozen string literal comment below shebang above an ' \
       'encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: true',
                           '# encoding: utf-8',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts a disabled frozen string literal comment below shebang above ' \
       'an encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: false',
                           '# encoding: utf-8',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts an emacs style combined magic comment' do
      inspect_source(
        cop,
        [
          '#!/usr/bin/env ruby',
          '# -*- encoding: UTF-8; frozen_string_literal: true -*-',
          '# encoding: utf-8',
          'puts 1'
        ]
      )

      expect(cop.offenses).to be_empty
    end

    context 'auto-correct' do
      it 'adds a frozen string literal comment to the first line if one is ' \
         'missing' do
        new_source = autocorrect_source(cop, 'puts 1')

        expect(new_source).to eq(['# frozen_string_literal: true',
                                  'puts 1'].join("\n"))
      end

      it 'adds a frozen string literal comment after a shebang' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# frozen_string_literal: true',
                                  'puts 1'].join("\n"))
      end

      it 'adds a frozen string literal comment after an encoding comment' do
        new_source = autocorrect_source(cop, ['# encoding: utf-8',
                                              'puts 1'])

        expect(new_source).to eq(['# encoding: utf-8',
                                  '# frozen_string_literal: true',
                                  'puts 1'].join("\n"))
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# encoding: utf-8',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# encoding: utf-8',
                                  '# frozen_string_literal: true',
                                  'puts 1'].join("\n"))
      end

      it 'adds a frozen string literal comment after a shebang and encoding ' \
         'comment when there is an empty line before the code' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# encoding: utf-8',
                                              '',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# encoding: utf-8',
                                  '# frozen_string_literal: true',
                                  '',
                                  'puts 1'].join("\n"))
      end

      it 'adds a frozen string literal comment after an encoding comment ' \
         'when there is an empty line before the code' do
        new_source = autocorrect_source(cop, ['# encoding: utf-8',
                                              '',
                                              'puts 1'])

        expect(new_source).to eq(['# encoding: utf-8',
                                  '# frozen_string_literal: true',
                                  '',
                                  'puts 1'].join("\n"))
      end
    end
  end

  context 'when_needed' do
    let(:cop_config) do
      { 'Enabled'           => true,
        'EnforcedStyle'     => 'when_needed' }
    end

    it 'accepts an empty source' do
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    if RUBY_VERSION >= '2.3.0'
      context 'ruby >= 2.3' do
        context 'no frozen string literal comment' do
          it 'accepts not modifing a string' do
            inspect_source(cop, 'puts "x"')

            expect(cop.offenses).to be_empty
          end

          it 'accepts calling + on a string' do
            inspect_source(cop, '"x" + "y"')

            expect(cop.offenses).to be_empty
          end

          it 'accepts calling freeze on a variable' do
            inspect_source(cop, ['foo = "x"',
                                 '  foo.freeze'])

            expect(cop.offenses).to be_empty
          end

          it 'accepts calling shovel on a variable' do
            inspect_source(cop, ['foo = "x"',
                                 '  foo << "y"'])

            expect(cop.offenses).to be_empty
          end

          it 'accepts freezing a string' do
            inspect_source(cop, '"x".freeze')

            expect(cop.offenses).to be_empty
          end

          it 'accepts when << is called on a string literal' do
            inspect_source(cop, '"x" << "y"')

            expect(cop.offenses).to be_empty
          end
        end

        it 'accepts freezing a string when there is a frozen string literal ' \
           'comment' do
          inspect_source(cop, ['# frozen_string_literal: true',
                               '"x".freeze'])

          expect(cop.offenses).to be_empty
        end

        it 'accepts shoveling into a string when there is a frozen string ' \
           'literal comment' do
          inspect_source(cop, ['# frozen_string_literal: true',
                               '"x" << "y"'])

          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'ruby < 2.3' do
      context 'target_ruby_version < 2.3', :ruby19 do
        it 'accepts freezing a string' do
          inspect_source(cop, '"x".freeze')

          expect(cop.offenses).to be_empty
        end

        it 'accepts calling << on a string' do
          inspect_source(cop, '"x" << "y"')

          expect(cop.offenses).to be_empty
        end

        it 'accepts freezing a string with interpolation' do
          inspect_source(cop, '"#{foo}bar".freeze')

          expect(cop.offenses).to be_empty
        end

        it 'accepts calling << on a string with interpolation' do
          inspect_source(cop, '"#{foo}bar" << "baz"')

          expect(cop.offenses).to be_empty
        end
      end

      context 'target_ruby_version 2.3+', :ruby23 do
        it 'accepts freezing a string' do
          inspect_source(cop, '"x".freeze')

          expect(cop.messages)
            .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
        end

        it 'accepts calling << on a string' do
          inspect_source(cop, '"x" << "y"')

          expect(cop.messages)
            .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
        end

        it 'accepts freezing a string with interpolation' do
          inspect_source(cop, '"#{foo}bar".freeze')

          expect(cop.messages)
            .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
        end

        it 'accepts calling << on a string with interpolation' do
          inspect_source(cop, '"#{foo}bar" << "baz"')

          expect(cop.messages)
            .to eq(['Missing magic comment `# frozen_string_literal: true`.'])
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
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    it 'accepts a source with no tokens' do
      inspect_source(cop, ' ')

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment ' \
      'on the top line' do
      inspect_source(cop, ['# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'on the top line' do
      inspect_source(cop, ['# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'accepts not having a frozen string literal comment on the top line' do
      inspect_source(cop, 'puts 1')

      expect(cop.offenses).to be_empty
    end

    it 'accepts not having not having a frozen string literal comment ' \
      'under a shebang' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below a shebang comment' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal ' \
      'below a shebang comment' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'allows not having a frozen string literal comment ' \
      'under an encoding comment' do
      inspect_source(cop, ['# encoding: utf-8',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment below ' \
      'an encoding comment' do
      inspect_source(cop, ['# encoding: utf-8',
                           '# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a dsabled frozen string literal below ' \
      'an encoding comment' do
      inspect_source(cop, ['# encoding: utf-8',
                           '# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'allows not having a frozen string literal comment ' \
      'under a shebang and an encoding comment' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           'puts 1'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below shebang and encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           '# frozen_string_literal: true',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'below shebang and encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           '# frozen_string_literal: false',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    it 'registers an offense for a frozen string literal comment ' \
      'below shebang above an encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: true',
                           '# encoding: utf-8',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: true'])
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
      'below shebang above an encoding comments' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# frozen_string_literal: false',
                           '# encoding: utf-8',
                           'puts 1'])

      expect(cop.messages).to eq(['Unnecessary frozen string literal comment.'])
      expect(cop.highlights).to eq(['# frozen_string_literal: false'])
    end

    context 'auto-correct' do
      it 'removes the frozen string literal comment from the top line' do
        new_source = autocorrect_source(cop, ['# frozen_string_literal: true',
                                              'puts 1'])

        expect(new_source).to eq('puts 1')
      end

      it 'removes a disabled frozen string literal comment on the top line' do
        new_source = autocorrect_source(cop, ['# frozen_string_literal: false',
                                              'puts 1'])

        expect(new_source).to eq('puts 1')
      end

      it 'removes a frozen string literal comment below a shebang comment' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# frozen_string_literal: true',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  'puts 1'].join("\n"))
      end

      it 'removes a disabled frozen string literal below a shebang comment' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# frozen_string_literal: false',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  'puts 1'].join("\n"))
      end

      it 'removes a frozen string literal comment below an encoding comment' do
        new_source = autocorrect_source(cop, ['# encoding: utf-8',
                                              '# frozen_string_literal: true',
                                              'puts 1'])

        expect(new_source).to eq(['# encoding: utf-8',
                                  'puts 1'].join("\n"))
      end

      it 'removes a dsabled frozen string literal below an encoding comment' do
        new_source = autocorrect_source(cop, ['# encoding: utf-8',
                                              '# frozen_string_literal: false',
                                              'puts 1'])

        expect(new_source).to eq(['# encoding: utf-8',
                                  'puts 1'].join("\n"))
      end

      it 'removes a frozen string literal comment ' \
        'below shebang and encoding comments' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# encoding: utf-8',
                                              '# frozen_string_literal: true',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# encoding: utf-8',
                                  'puts 1'].join("\n"))
      end

      it 'removes a disabled frozen string literal comment from ' \
        'below shebang and encoding comments' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# encoding: utf-8',
                                              '# frozen_string_literal: false',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# encoding: utf-8',
                                  'puts 1'].join("\n"))
      end

      it 'removes a frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# frozen_string_literal: true',
                                              '# encoding: utf-8',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# encoding: utf-8',
                                  'puts 1'].join("\n"))
      end

      it 'removes a disabled frozen string literal comment ' \
        'below shebang above an encoding comments' do
        new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                              '# frozen_string_literal: false',
                                              '# encoding: utf-8',
                                              'puts 1'])

        expect(new_source).to eq(['#!/usr/bin/env ruby',
                                  '# encoding: utf-8',
                                  'puts 1'].join("\n"))
      end
    end
  end
end
