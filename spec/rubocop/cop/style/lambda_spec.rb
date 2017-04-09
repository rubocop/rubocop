# frozen_string_literal: true

describe RuboCop::Cop::Style::Lambda, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'registers an offense' do |message|
    it 'registers an offense' do
      inspect_source(cop, source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([message])
    end
  end

  shared_examples 'auto-correct' do |expected|
    it 'auto-corrects' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(expected)
    end
  end

  shared_examples 'does not auto-correct' do
    it 'does not autocorrect' do
      expect(autocorrect_source(cop, source)).to eq(source)
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end
  end

  context 'with enforced `lambda` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'lambda' } }

    context 'with a single line lambda literal' do
      context 'with arguments' do
        let(:source) { 'f = ->(x) { x }' }

        it_behaves_like 'registers an offense',
                        'Use the `lambda` method for all lambdas.'
        it_behaves_like 'auto-correct', 'f = lambda { |x| x }'
      end

      context 'without arguments' do
        let(:source) { 'f = -> { x }' }

        it_behaves_like 'registers an offense',
                        'Use the `lambda` method for all lambdas.'
        it_behaves_like 'auto-correct', 'f = lambda { x }'
      end
    end

    context 'with a multiline lambda literal' do
      context 'with arguments' do
        let(:source) do
          <<-END.strip_indent
            f = ->(x) do
              x
            end
          END
        end

        it_behaves_like 'registers an offense',
                        'Use the `lambda` method for all lambdas.'
        it_behaves_like 'auto-correct', <<-END.strip_indent
          f = lambda do |x|
            x
          end
        END
      end

      context 'without arguments' do
        let(:source) do
          <<-END.strip_indent
            f = -> do
              x
            end
          END
        end

        it_behaves_like 'registers an offense',
                        'Use the `lambda` method for all lambdas.'
        it_behaves_like 'auto-correct', <<-END.strip_indent
          f = lambda do
            x
          end
        END
      end
    end
  end

  context 'with enforced `literal` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'literal' } }

    context 'with a single line lambda method call' do
      context 'with arguments' do
        let(:source) { 'f = lambda { |x| x }' }

        it_behaves_like 'registers an offense',
                        'Use the `-> { ... }` lambda literal syntax for ' \
                        'all lambdas.'
        it_behaves_like 'auto-correct', 'f = ->(x) { x }'
      end

      context 'without arguments' do
        let(:source) { 'f = lambda { x }' }

        it_behaves_like 'registers an offense',
                        'Use the `-> { ... }` lambda literal syntax for ' \
                        'all lambdas.'
        it_behaves_like 'auto-correct', 'f = -> { x }'
      end
    end

    context 'with a multiline lambda method call' do
      context 'with arguments' do
        let(:source) do
          <<-END.strip_indent
            f = lambda do |x|
              x
            end
          END
        end

        it_behaves_like 'registers an offense',
                        'Use the `-> { ... }` lambda literal syntax for ' \
                        'all lambdas.'
        it_behaves_like 'auto-correct', <<-END.strip_indent
          f = ->(x) do
            x
          end
        END
      end

      context 'without arguments' do
        let(:source) do
          <<-END.strip_indent
            f = lambda do
              x
            end
          END
        end

        it_behaves_like 'registers an offense',
                        'Use the `-> { ... }` lambda literal syntax for ' \
                        'all lambdas.'
        it_behaves_like 'auto-correct', <<-END.strip_indent
          f = -> do
            x
          end
        END
      end
    end
  end

  context 'with default `line_count_dependent` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'line_count_dependent' } }

    context 'with a single line lambda method call' do
      context 'with arguments' do
        let(:source) { 'f = lambda { |x| x }' }

        it_behaves_like 'registers an offense',
                        'Use the `-> { ... }` lambda literal syntax for ' \
                        'single line lambdas.'
        it_behaves_like 'auto-correct', 'f = ->(x) { x }'
      end

      context 'without arguments' do
        let(:source) { 'f = lambda { x }' }

        it_behaves_like 'registers an offense',
                        'Use the `-> { ... }` lambda literal syntax for ' \
                        'single line lambdas.'
        it_behaves_like 'auto-correct', 'f = -> { x }'
      end
    end

    context 'with a multiline lambda method call' do
      it 'does not register an offense' do
        inspect_source(cop, <<-END.strip_indent)
          l = lambda do |x|
            x
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with a single line lambda literal' do
      it 'does not register an offense' do
        inspect_source(cop, <<-END.strip_indent)
          lambda = ->(x) { x }
          lambda.(1)
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with a multiline lambda literal' do
      context 'with arguments' do
        let(:source) do
          <<-END.strip_indent
            f = ->(x) do
              x
            end
          END
        end

        it_behaves_like 'registers an offense',
                        'Use the `lambda` method for multiline lambdas.'
        it_behaves_like 'auto-correct', <<-END.strip_indent
          f = lambda do |x|
            x
          end
        END
      end

      context 'without arguments' do
        let(:source) do
          <<-END.strip_indent
            f = -> do
              x
            end
          END
        end

        it_behaves_like 'registers an offense',
                        'Use the `lambda` method for multiline lambdas.'
        it_behaves_like 'auto-correct', <<-END.strip_indent
          f = lambda do
            x
          end
        END
      end
    end

    context 'unusual lack of spacing' do
      # The lack of spacing shown here is valid ruby syntax,
      # and can be the result of previous autocorrects re-writing
      # a multi-line `->(x){ ... }` to `->(x)do ... end`.
      # See rubocop/cop/style/block_delimiters.rb.
      # Tests correction of an issue resulting in `lambdado` syntax errors.
      context 'without any spacing' do
        let(:source) do
          <<-END.strip_indent
            ->(x)do
              x
            end
          END
        end

        it_behaves_like 'auto-correct', <<-END.strip_indent
          lambda do |x|
            x
          end
        END
      end

      context 'without spacing after arguments' do
        let(:source) do
          <<-END.strip_indent
            -> (x)do
              x
            end
          END
        end

        it_behaves_like 'auto-correct', <<-END.strip_indent
          lambda do |x|
            x
          end
        END
      end

      context 'without spacing before arguments' do
        let(:source) do
          <<-END.strip_indent
            ->(x) do
              x
            end
          END
        end

        it_behaves_like 'auto-correct', <<-END.strip_indent
          lambda do |x|
            x
          end
        END
      end

      context 'with a multiline lambda literal' do
        context 'with empty arguments' do
          let(:source) do
            <<-END.strip_indent
              ->()do
                x
              end
            END
          end

          it_behaves_like 'auto-correct', <<-END.strip_indent
            lambda do
              x
            end
          END
        end

        context 'with no arguments and bad spacing' do
          let(:source) do
            <<-END.strip_indent
              -> ()do
                x
              end
            END
          end

          it_behaves_like 'auto-correct', <<-END.strip_indent
            lambda do
              x
            end
          END
        end

        context 'with no arguments and no spacing' do
          let(:source) do
            <<-END.strip_indent
              ->do
                x
              end
            END
          end

          it_behaves_like 'auto-correct', <<-END.strip_indent
            lambda do
              x
            end
          END
        end

        context 'without parentheses' do
          let(:source) do
            <<-END.strip_indent
              -> hello do
                puts hello
              end
            END
          end

          it_behaves_like 'registers an offense',
                          'Use the `lambda` method for multiline lambdas.'
          it_behaves_like 'auto-correct', <<-END.strip_indent
            lambda do |hello|
              puts hello
            end
          END
        end

        context 'with no parentheses and bad spacing' do
          let(:source) do
            <<-END.strip_indent
              ->   hello  do
                puts hello
              end
            END
          end

          it_behaves_like 'registers an offense',
                          'Use the `lambda` method for multiline lambdas.'
          it_behaves_like 'auto-correct', <<-END.strip_indent
            lambda do |hello|
              puts hello
            end
          END
        end

        context 'with no parentheses and many args' do
          let(:source) do
            <<-END.strip_indent
              ->   hello, user  do
                puts hello
              end
            END
          end

          it_behaves_like 'registers an offense',
                          'Use the `lambda` method for multiline lambdas.'
          it_behaves_like 'auto-correct', <<-END.strip_indent
            lambda do |hello, user|
              puts hello
            end
          END
        end
      end
    end

    context 'when calling a lambda method without a block' do
      it 'does not register an offense' do
        inspect_source(cop, 'l = lambda.test')
        expect(cop.offenses).to be_empty
      end
    end

    context 'with a multiline lambda literal as an argument' do
      let(:source) do
        <<-END.strip_indent
          has_many :kittens, -> do
            where(cats: Cat.young.where_values_hash)
          end, source: cats
        END
      end

      it_behaves_like 'registers an offense',
                      'Use the `lambda` method for multiline lambdas.'
      it_behaves_like 'does not auto-correct'
    end

    context 'with a multiline lambda literal as a keyword argument' do
      let(:source) do
        <<-END.strip_indent
          has_many opt: -> do
            where(cats: Cat.young.where_values_hash)
          end
        END
      end

      it_behaves_like 'registers an offense',
                      'Use the `lambda` method for multiline lambdas.'
      it_behaves_like 'does not auto-correct'
    end
  end
end
