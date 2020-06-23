# frozen_string_literal: true

RSpec.describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  describe '--disable-uncorrectable' do
    let(:exit_code) do
      cli.run(%w[--auto-correct-all --format simple --disable-uncorrectable])
    end

    let(:setup_long_line) do
      create_file('.rubocop.yml', <<~YAML)
        Style/IpAddresses:
          Enabled: true
        Layout/LineLength:
          Max: #{max_length}
      YAML
      create_file('example.rb', <<~RUBY)
        ip('1.2.3.4')
        # last line
      RUBY
    end
    let(:max_length) { 46 }

    it 'does not disable anything for cops that support autocorrect' do
      create_file('example.rb', 'puts 1==2')
      expect(exit_code).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string).to eq(<<~OUTPUT)
        == example.rb ==
        C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
        C:  1:  7: [Corrected] Layout/SpaceAroundOperators: Surrounding space missing for operator ==.
        C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.

        1 file inspected, 3 offenses detected, 3 offenses corrected
      OUTPUT
      expect(IO.read('example.rb')).to eq(<<~RUBY)
        # frozen_string_literal: true

        puts 1 == 2
      RUBY
    end

    context 'if one one-line disable statement fits' do
      it 'adds it' do
        setup_long_line
        expect(exit_code).to eq(0)
        expect($stderr.string).to eq('')
        expect($stdout.string).to eq(<<~OUTPUT)
          == example.rb ==
          C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
          C:  1:  4: [Todo] Style/IpAddresses: Do not hardcode IP addresses.
          C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.

          1 file inspected, 3 offenses detected, 3 offenses corrected
        OUTPUT
        expect(IO.read('example.rb')).to eq(<<~RUBY)
          # frozen_string_literal: true

          ip('1.2.3.4') # rubocop:todo Style/IpAddresses
          # last line
        RUBY
      end

      it 'adds it when the cop supports autocorrect but does not correct the offense' do
        create_file('example.rb', <<~RUBY)
          def ordinary_method(some_arg)
            puts 'Ignoring args'
          end

          def method_with_keyword_arg(some_keyword_arg:)
            puts 'Ignoring args'
          end
        RUBY

        expect(exit_code).to eq(0)
        expect($stderr.string).to eq('')
        expect($stdout.string).to eq(<<~OUTPUT)
          == example.rb ==
          C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
          W:  1: 21: [Corrected] Lint/UnusedMethodArgument: Unused method argument - some_arg. If it's necessary, use _ or _some_arg as an argument name to indicate that it won't be used. You can also write as ordinary_method(*) if you want the method to accept any arguments but don't care about them.
          C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.
          W:  5: 29: [Todo] Lint/UnusedMethodArgument: Unused method argument - some_keyword_arg. You can also write as method_with_keyword_arg(*) if you want the method to accept any arguments but don't care about them.

          1 file inspected, 4 offenses detected, 4 offenses corrected
        OUTPUT

        expect(IO.read('example.rb')).to eq(<<~RUBY)
          # frozen_string_literal: true

          def ordinary_method(_some_arg)
            puts 'Ignoring args'
          end

          def method_with_keyword_arg(some_keyword_arg:) # rubocop:todo Lint/UnusedMethodArgument
            puts 'Ignoring args'
          end
        RUBY
      end

      context 'and there are two offenses of the same kind on one line' do
        it 'adds a single one-line disable statement' do
          create_file('.rubocop.yml', <<~YAML)
            Style/IpAddresses:
              Enabled: true
          YAML
          create_file('example.rb', <<~RUBY)
            ip('1.2.3.4', '5.6.7.8')
          RUBY
          expect(exit_code).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to eq(<<~OUTPUT)
            == example.rb ==
            C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
            C:  1:  4: [Todo] Style/IpAddresses: Do not hardcode IP addresses.
            C:  1: 15: [Todo] Style/IpAddresses: Do not hardcode IP addresses.
            C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.

            1 file inspected, 4 offenses detected, 4 offenses corrected
          OUTPUT
          expect(IO.read('example.rb')).to eq(<<~RUBY)
            # frozen_string_literal: true

            ip('1.2.3.4', '5.6.7.8') # rubocop:todo Style/IpAddresses
          RUBY
        end
      end

      context "but there are more offenses on the line and they don't all " \
              'fit' do
        it 'adds both one-line and before-and-after disable statements' do
          create_file('example.rb', <<~RUBY)
            # Chess engine.
            class Chess
              def choose_move(who_to_move)
                legal_moves = all_legal_moves_that_dont_put_me_in_check(who_to_move)

                return nil if legal_moves.empty?

                mating_move = checkmating_move(legal_moves)
                return mating_move if mating_move

                best_moves = checking_moves(legal_moves)
                best_moves = castling_moves(legal_moves) if best_moves.empty?
                best_moves = taking_moves(legal_moves) if best_moves.empty?
                best_moves = legal_moves if best_moves.empty?
                best_moves = remove_dangerous_moves(best_moves, who_to_move)
                best_moves = legal_moves if best_moves.empty?
                best_moves.sample
              end
            end
          RUBY
          create_file('.rubocop.yml', <<~YAML)
            Metrics/AbcSize:
              Max: 15
            Metrics/CyclomaticComplexity:
              Max: 6
          YAML
          expect(exit_code).to eq(0)
          expect($stderr.string).to eq('')
          expect($stdout.string).to eq(<<~OUTPUT)
            == example.rb ==
            C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
            C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.
            C:  3:  3: [Todo] Metrics/AbcSize: Assignment Branch Condition size for choose_move is too high. [<8, 12, 6> 15.62/15]
            C:  3:  3: [Todo] Metrics/CyclomaticComplexity: Cyclomatic complexity for choose_move is too high. [7/6]
            C:  3:  3: [Todo] Metrics/MethodLength: Method has too many lines. [11/10]
            C:  4:  3: [Todo] Metrics/AbcSize: Assignment Branch Condition size for choose_move is too high. [<8, 12, 6> 15.62/15]
            C:  4:  3: [Todo] Metrics/MethodLength: Method has too many lines. [11/10]
            C:  4: 32: [Corrected] Style/DoubleCopDisableDirective: More than one disable comment on one line.

            1 file inspected, 8 offenses detected, 8 offenses corrected
          OUTPUT
          expect(IO.read('example.rb')).to eq(<<~RUBY)
            # frozen_string_literal: true

            # Chess engine.
            class Chess
              # rubocop:todo Metrics/MethodLength
              # rubocop:todo Metrics/AbcSize
              def choose_move(who_to_move) # rubocop:todo Metrics/CyclomaticComplexity
                legal_moves = all_legal_moves_that_dont_put_me_in_check(who_to_move)

                return nil if legal_moves.empty?

                mating_move = checkmating_move(legal_moves)
                return mating_move if mating_move

                best_moves = checking_moves(legal_moves)
                best_moves = castling_moves(legal_moves) if best_moves.empty?
                best_moves = taking_moves(legal_moves) if best_moves.empty?
                best_moves = legal_moves if best_moves.empty?
                best_moves = remove_dangerous_moves(best_moves, who_to_move)
                best_moves = legal_moves if best_moves.empty?
                best_moves.sample
              end
              # rubocop:enable Metrics/AbcSize
              # rubocop:enable Metrics/MethodLength
            end
          RUBY
        end
      end
    end

    context "if a one-line disable statement doesn't fit" do
      let(:max_length) { super() - 1 }

      it 'adds before-and-after disable statement' do
        setup_long_line
        expect(exit_code).to eq(0)
        expect($stderr.string).to eq('')
        expect($stdout.string).to eq(<<~OUTPUT)
          == example.rb ==
          C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
          C:  1:  4: [Todo] Style/IpAddresses: Do not hardcode IP addresses.
          C:  2:  1: [Corrected] Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.

          1 file inspected, 3 offenses detected, 3 offenses corrected
        OUTPUT
        expect(IO.read('example.rb')).to eq(<<~RUBY)
          # frozen_string_literal: true

          # rubocop:todo Style/IpAddresses
          ip('1.2.3.4')
          # rubocop:enable Style/IpAddresses
          # last line
        RUBY
      end
    end
  end
end
