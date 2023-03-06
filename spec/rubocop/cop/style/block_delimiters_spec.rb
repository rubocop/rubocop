# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BlockDelimiters, :config do
  shared_examples 'syntactic styles' do
    it 'registers an offense for a single line block with do-end' do
      expect_offense(<<~RUBY)
        each do |x| end
             ^^ Prefer `{...}` over `do...end` for single-line blocks.
      RUBY
    end

    it 'accepts a single line block with braces' do
      expect_no_offenses('each { |x| }')
    end

    it 'accepts a multi-line block with do-end' do
      expect_no_offenses(<<~RUBY)
        each do |x|
        end
      RUBY
    end

    it 'accepts a multi-line block that needs braces to be valid ruby' do
      expect_no_offenses(<<~RUBY)
        puts [1, 2, 3].map { |n|
          n * n
        }, 1
      RUBY
    end

    context 'Ruby >= 2.7', :ruby27 do
      it 'registers an offense for a single line numblock with do-end' do
        expect_offense(<<~RUBY)
          each do _1 end
               ^^ Prefer `{...}` over `do...end` for single-line blocks.
        RUBY
      end

      it 'accepts a single line numblock with braces' do
        expect_no_offenses('each { _1 }')
      end

      it 'accepts a multi-line numblock with do-end' do
        expect_no_offenses(<<~RUBY)
          each do
            _1
          end
        RUBY
      end

      it 'accepts a multi-line numblock that needs braces to be valid ruby' do
        expect_no_offenses(<<~RUBY)
          puts [1, 2, 3].map {
            _1 * _1
          }, 1
        RUBY
      end
    end
  end

  context 'EnforcedStyle: semantic' do
    cop_config = {
      'EnforcedStyle' => 'semantic',
      'ProceduralMethods' => %w[tap],
      'FunctionalMethods' => %w[let],
      'AllowedMethods' => ['lambda'],
      'AllowedPatterns' => ['test']
    }

    let(:cop_config) { cop_config }

    it 'accepts a multi-line block with braces if the return value is assigned' do
      expect_no_offenses(<<~RUBY)
        foo = map { |x|
          x
        }
      RUBY
    end

    it 'accepts a multi-line block with braces if it is the return value of its scope' do
      expect_no_offenses(<<~RUBY)
        block do
          map { |x|
            x
          }
        end
      RUBY
    end

    it 'accepts a multi-line block with braces when passed to a method' do
      expect_no_offenses(<<~RUBY)
        puts map { |x|
          x
        }
      RUBY
    end

    it 'accepts a multi-line block with braces when chained' do
      expect_no_offenses(<<~RUBY)
        map { |x|
          x
        }.inspect
      RUBY
    end

    it 'accepts a multi-line block with braces when passed to a known functional method' do
      expect_no_offenses(<<~RUBY)
        let(:foo) {
          x
        }
      RUBY
    end

    it 'registers an offense for a multi-line block with braces if the return value is not used' do
      expect_offense(<<~RUBY)
        each { |x|
             ^ Prefer `do...end` over `{...}` for procedural blocks.
          x
        }
      RUBY
    end

    it 'registers an offense for a multi-line block with do-end if the return value is assigned' do
      expect_offense(<<~RUBY)
        foo = map do |x|
                  ^^ Prefer `{...}` over `do...end` for functional blocks.
          x
        end
      RUBY
    end

    it 'registers an offense for a multi-line block with do-end if the ' \
       'return value is passed to a method' do
      expect_offense(<<~RUBY)
        puts (map do |x|
                  ^^ Prefer `{...}` over `do...end` for functional blocks.
          x
        end)
      RUBY
    end

    it 'registers an offense for a multi-line block with do-end if the ' \
       'return value is attribute-assigned' do
      expect_offense(<<~RUBY)
        foo.bar = map do |x|
                      ^^ Prefer `{...}` over `do...end` for functional blocks.
          x
        end
      RUBY
    end

    it 'accepts a multi-line block with do-end if it is the return value of its scope' do
      expect_no_offenses(<<~RUBY)
        block do
          map do |x|
            x
          end
        end
      RUBY
    end

    it 'accepts a single line block with {} if used in an if statement' do
      expect_no_offenses('return if any? { |x| x }')
    end

    it 'accepts a single line block with {} if used in a logical or' do
      expect_no_offenses('any? { |c| c } || foo')
    end

    it 'accepts a single line block with {} if used in a logical and' do
      expect_no_offenses('any? { |c| c } && foo')
    end

    it 'accepts a single line block with {} if used in an array' do
      expect_no_offenses('[detect { true }, other]')
    end

    it 'accepts a single line block with {} if used in an irange' do
      expect_no_offenses('detect { true }..other')
    end

    it 'accepts a single line block with {} if used in an erange' do
      expect_no_offenses('detect { true }...other')
    end

    it 'accepts a single line block with {} followed by a safe navigation method call' do
      expect_no_offenses('ary.map { |e| foo(e) }&.bar')
    end

    it 'accepts a multi-line functional block with do-end if it is a known procedural method' do
      expect_no_offenses(<<~RUBY)
        foo = bar.tap do |x|
          x.age = 3
        end
      RUBY
    end

    it 'accepts a multi-line functional block with do-end if it is an ignored method' do
      expect_no_offenses(<<~RUBY)
        foo = lambda do
          puts 42
        end
      RUBY
    end

    it 'accepts a multi-line functional block with do-end if it is an ignored method by regex' do
      expect_no_offenses(<<~RUBY)
        foo = test_method do
          puts 42
        end
      RUBY
    end

    context 'with a procedural one-line block' do
      context 'with AllowBracesOnProceduralOneLiners false or unset' do
        it 'registers an offense for a single line procedural block' do
          expect_offense(<<~RUBY)
            each { |x| puts x }
                 ^ Prefer `do...end` over `{...}` for procedural blocks.
          RUBY

          expect_correction(<<~RUBY)
            each do |x| puts x end
          RUBY
        end

        it 'accepts a single line block with do-end if it is procedural' do
          expect_no_offenses('each do |x| puts x; end')
        end
      end

      context 'with AllowBracesOnProceduralOneLiners true' do
        let(:cop_config) { cop_config.merge('AllowBracesOnProceduralOneLiners' => true) }

        it 'accepts a single line procedural block with braces' do
          expect_no_offenses('each { |x| puts x }')
        end

        it 'accepts a single line procedural do-end block' do
          expect_no_offenses('each do |x| puts x; end')
        end
      end
    end

    context 'with a procedural multi-line block' do
      it 'autocorrects { and } to do and end' do
        expect_offense(<<~RUBY)
          each { |x|
               ^ Prefer `do...end` over `{...}` for procedural blocks.
            x
          }
        RUBY

        expect_correction(<<~RUBY)
          each do |x|
            x
          end
        RUBY
      end

      it 'autocorrects { and } to do and end with appropriate spacing' do
        expect_offense(<<~RUBY)
          each {|x|
               ^ Prefer `do...end` over `{...}` for procedural blocks.
            x
          }
        RUBY

        expect_correction(<<~RUBY)
          each do |x|
            x
          end
        RUBY
      end
    end

    it 'allows {} if it is a known functional method' do
      expect_no_offenses(<<~RUBY)
        let(:foo) { |x|
          x
        }
      RUBY
    end

    it 'allows {} if it is a known procedural method' do
      expect_no_offenses(<<~RUBY)
        foo = bar.tap do |x|
          x.age = 1
        end
      RUBY
    end

    it 'autocorrects do-end to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        foo = map do |x|
                  ^^ Prefer `{...}` over `do...end` for functional blocks.
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        foo = map { |x|
          x
        }
      RUBY
    end

    it 'autocorrects do-end to {} with appropriate spacing' do
      expect_offense(<<~RUBY)
        foo = map do|x|
                  ^^ Prefer `{...}` over `do...end` for functional blocks.
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        foo = map { |x|
          x
        }
      RUBY
    end

    it 'autocorrects do-end to {} if it is a functional block and does not change the meaning' do
      expect_offense(<<~RUBY)
        puts (map do |x|
                  ^^ Prefer `{...}` over `do...end` for functional blocks.
          x
        end)
      RUBY

      expect_correction(<<~RUBY)
        puts (map { |x|
          x
        })
      RUBY
    end

    it 'autocorrects do-end with `rescue` to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        x = map do |a|
                ^^ Prefer `{...}` over `do...end` for functional blocks.
          do_something
        rescue StandardError => e
          puts 'oh no'
        end
      RUBY

      expect_correction(<<~RUBY)
        x = map { |a|
          begin
        do_something
        rescue StandardError => e
          puts 'oh no'
        end
        }
      RUBY
    end

    it 'autocorrects do-end with `ensure` to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        x = map do |a|
                ^^ Prefer `{...}` over `do...end` for functional blocks.
          do_something
        ensure
          puts 'oh no'
        end
      RUBY

      expect_correction(<<~RUBY)
        x = map { |a|
          begin
        do_something
        ensure
          puts 'oh no'
        end
        }
      RUBY
    end
  end

  context 'EnforcedStyle: line_count_based' do
    cop_config = {
      'EnforcedStyle' => 'line_count_based',
      'AllowedMethods' => ['proc'],
      'AllowedPatterns' => ['test']
    }

    let(:cop_config) { cop_config }

    include_examples 'syntactic styles'

    it 'autocorrects do-end for single line blocks to { and }' do
      expect_offense(<<~RUBY)
        block do |x| end
              ^^ Prefer `{...}` over `do...end` for single-line blocks.
      RUBY

      expect_correction(<<~RUBY)
        block { |x| }
      RUBY
    end

    it 'does not autocorrect do-end if {} would change the meaning' do
      expect_offense(<<~RUBY)
        s.subspec 'Subspec' do |sp| end
                            ^^ Prefer `{...}` over `do...end` for single-line blocks.
      RUBY

      expect_no_corrections
    end

    it 'does not autocorrect {} if do-end would change the meaning' do
      expect_no_offenses(<<~RUBY)
        foo :bar, :baz, qux: lambda { |a|
          bar a
        }
      RUBY
    end

    context 'when there are braces around a multi-line block' do
      it 'registers an offense in the simple case' do
        expect_offense(<<~RUBY)
          each { |x|
               ^ Avoid using `{...}` for multi-line blocks.
          }
        RUBY
      end

      it 'registers an offense when combined with attribute assignment' do
        expect_offense(<<~RUBY)
          foo.bar = baz.map { |x|
                            ^ Avoid using `{...}` for multi-line blocks.
          }
        RUBY
      end

      it 'registers an offense when there is a comment after the closing brace and block body is not empty' do
        expect_offense(<<~RUBY)
          baz.map { |x|
                  ^ Avoid using `{...}` for multi-line blocks.
          foo(x) } # comment
        RUBY

        expect_correction(<<~RUBY)
          # comment
          baz.map do |x|
          foo(x) end
        RUBY
      end

      it 'registers an offense when there is a comment after the closing brace and bracket' do
        expect_offense(<<~RUBY)
          [foo {
               ^ Avoid using `{...}` for multi-line blocks.
          }] # comment
        RUBY

        expect_correction(<<~RUBY.chop)
          [# comment
          foo do
          end
          ]#{trailing_whitespace}
        RUBY
      end

      it 'registers an offense and keep chained block when there is a comment after the closing brace and block body is not empty' do
        expect_offense(<<~RUBY)
          baz.map { |x|
                  ^ Avoid using `{...}` for multi-line blocks.
          foo(x) }.map { |x| x.quux } # comment
        RUBY

        expect_correction(<<~RUBY)
          # comment
          baz.map do |x|
          foo(x) end.map { |x| x.quux }
        RUBY
      end

      it 'registers an offense when there is a comment after the closing brace and using method chain' do
        expect_offense(<<~RUBY)
          baz.map { |x|
                  ^ Avoid using `{...}` for multi-line blocks.
          foo(x) }.qux.quux # comment
        RUBY

        expect_correction(<<~RUBY)
          # comment
          baz.map do |x|
          foo(x) end.qux.quux
        RUBY
      end

      it 'registers an offense when there is a comment after the closing brace and block body is empty' do
        expect_offense(<<~RUBY)
          baz.map { |x|
                  ^ Avoid using `{...}` for multi-line blocks.
          } # comment

        RUBY

        expect_correction(<<~RUBY)
          # comment
          baz.map do |x|
          end
        RUBY
      end

      it 'accepts braces if do-end would change the meaning' do
        expect_no_offenses(<<~RUBY)
          scope :foo, lambda { |f|
            where(condition: "value")
          }

          expect { something }.to raise_error(ErrorClass) { |error|
            # ...
          }

          expect { x }.to change {
            Counter.count
          }.from(0).to(1)

          cr.stubs client: mock {
            expects(:email_disabled=).with(true)
            expects :save
          }
        RUBY
      end

      it 'accepts a multi-line functional block with {} if it is an ignored method' do
        expect_no_offenses(<<~RUBY)
          foo = proc {
            puts 42
          }
        RUBY
      end

      it 'accepts a multi-line functional block with {} if it is an ignored method by regex' do
        expect_no_offenses(<<~RUBY)
          foo = test_method {
            puts 42
          }
        RUBY
      end

      it 'registers an offense for braces if do-end would not change the meaning' do
        expect_offense(<<~RUBY)
          scope :foo, (lambda { |f|
                              ^ Avoid using `{...}` for multi-line blocks.
            where(condition: "value")
          })

          expect { something }.to(raise_error(ErrorClass) { |error|
                                                          ^ Avoid using `{...}` for multi-line blocks.
            # ...
          })
        RUBY
      end

      it 'can handle special method names such as []= and done?' do
        expect_offense(<<~RUBY)
          h2[k2] = Hash.new { |h3,k3|
                            ^ Avoid using `{...}` for multi-line blocks.
            h3[k3] = 0
          }

          x = done? list.reject { |e|
            e.nil?
          }
        RUBY
      end

      it 'autocorrects { and } to do and end' do
        expect_offense(<<~RUBY)
          each{ |x|
              ^ Avoid using `{...}` for multi-line blocks.
            some_method
            other_method
          }
        RUBY

        expect_correction(<<~RUBY)
          each do |x|
            some_method
            other_method
          end
        RUBY
      end

      it 'autocorrects adjacent curly braces correctly' do
        expect_offense(<<~RUBY)
          (0..3).each { |a| a.times {
                                    ^ Avoid using `{...}` for multi-line blocks.
                      ^ Avoid using `{...}` for multi-line blocks.
            puts a
          }}
        RUBY

        expect_correction(<<~RUBY)
          (0..3).each do |a| a.times do
            puts a
          end end
        RUBY
      end

      it 'registers an offense and autocorrects when multi-line blocks to `{` and `}` with method chain' do
        expect_offense(<<~RUBY)
          foo bar + baz {
                        ^ Avoid using `{...}` for multi-line blocks.
          }.qux.quux
        RUBY

        expect_correction(<<~RUBY)
          foo bar + baz do
          end.qux.quux
        RUBY
      end

      it 'does not register an offense when multi-line blocks to `{` and `}` with arithmetic operation method chain' do
        expect_no_offenses(<<~RUBY)
          foo bar + baz {
          }.qux + quux
        RUBY
      end

      it 'does not autocorrect {} if do-end would introduce a syntax error' do
        expect_no_offenses(<<~RUBY)
          my_method :arg1, arg2: proc {
            something
          }, arg3: :another_value
        RUBY
      end
    end

    context 'with a single line do-end block with an inline `rescue`' do
      it 'autocorrects properly' do
        expect_offense(<<~RUBY)
          map do |x| x.y? rescue z end
              ^^ Prefer `{...}` over `do...end` for single-line blocks.
        RUBY

        expect_correction(<<~RUBY)
          map { |x| x.y? rescue z }
        RUBY
      end
    end
  end

  context 'EnforcedStyle: braces_for_chaining' do
    cop_config = {
      'EnforcedStyle' => 'braces_for_chaining',
      'AllowedMethods' => ['proc'],
      'AllowedPatterns' => ['test']
    }

    let(:cop_config) { cop_config }

    include_examples 'syntactic styles'

    it 'registers an offense for multi-line chained do-end blocks' do
      expect_offense(<<~RUBY)
        each do |x|
             ^^ Prefer `{...}` over `do...end` for multi-line chained blocks.
        end.map(&:to_s)
      RUBY

      expect_correction(<<~RUBY)
        each { |x|
        }.map(&:to_s)
      RUBY
    end

    it 'accepts a multi-line functional block with {} if it is an ignored method' do
      expect_no_offenses(<<~RUBY)
        foo = proc {
          puts 42
        }
      RUBY
    end

    it 'accepts a multi-line functional block with {} if it is an ignored method by regex' do
      expect_no_offenses(<<~RUBY)
        foo = test_method {
          puts 42
        }
      RUBY
    end

    it 'allows when :[] is chained' do
      expect_no_offenses(<<~RUBY)
        foo = [{foo: :bar}].find { |h|
          h.key?(:foo)
        }[:foo]
      RUBY
    end

    it 'allows do/end inside Hash[]' do
      expect_no_offenses(<<~RUBY)
        Hash[
          {foo: :bar}.map do |k, v|
            [k, v]
          end
        ]
      RUBY
    end

    it 'allows chaining to } inside of Hash[]' do
      expect_no_offenses(<<~RUBY)
        Hash[
          {foo: :bar}.map { |k, v|
            [k, v]
          }.uniq
        ]
      RUBY
    end

    it 'disallows {} with no chain inside of Hash[]' do
      expect_offense(<<~RUBY)
        Hash[
          {foo: :bar}.map { |k, v|
                          ^ Prefer `do...end` for multi-line blocks without chaining.
            [k, v]
          }
        ]
      RUBY
    end

    context 'when there are braces around a multi-line block' do
      it 'registers an offense in the simple case' do
        expect_offense(<<~RUBY)
          each { |x|
               ^ Prefer `do...end` for multi-line blocks without chaining.
          }
        RUBY
      end

      it 'registers an offense when combined with attribute assignment' do
        expect_offense(<<~RUBY)
          foo.bar = baz.map { |x|
                            ^ Prefer `do...end` for multi-line blocks without chaining.
          }
        RUBY
      end

      it 'allows when the block is being chained' do
        expect_no_offenses(<<~RUBY)
          each { |x|
          }.map(&:to_sym)
        RUBY
      end

      it 'allows when the block is being chained with attribute assignment' do
        expect_no_offenses(<<~RUBY)
          foo.bar = baz.map { |x|
          }.map(&:to_sym)
        RUBY
      end
    end

    context 'with safe navigation' do
      it 'registers an offense for multi-line chained do-end blocks' do
        expect_offense(<<~RUBY)
          arr&.each do |x|
                    ^^ Prefer `{...}` over `do...end` for multi-line chained blocks.
          end&.map(&:to_s)
        RUBY

        expect_correction(<<~RUBY)
          arr&.each { |x|
          }&.map(&:to_s)
        RUBY
      end
    end

    it 'autocorrects do-end with `rescue` to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        map do |a|
            ^^ Prefer `{...}` over `do...end` for multi-line chained blocks.
          do_something
        rescue StandardError => e
          puts 'oh no'
        end.join('-')
      RUBY

      expect_correction(<<~RUBY)
        map { |a|
          begin
        do_something
        rescue StandardError => e
          puts 'oh no'
        end
        }.join('-')
      RUBY
    end

    it 'autocorrects do-end with `ensure` to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        map do |a|
            ^^ Prefer `{...}` over `do...end` for multi-line chained blocks.
          do_something
        ensure
          puts 'oh no'
        end.join('-')
      RUBY

      expect_correction(<<~RUBY)
        map { |a|
          begin
        do_something
        ensure
          puts 'oh no'
        end
        }.join('-')
      RUBY
    end
  end

  context 'EnforcedStyle: always_braces' do
    cop_config = {
      'EnforcedStyle' => 'always_braces',
      'AllowedMethods' => ['proc'],
      'AllowedPatterns' => ['test']
    }

    let(:cop_config) { cop_config }

    it 'registers an offense for a single line block with do-end' do
      expect_offense(<<~RUBY)
        each do |x| end
             ^^ Prefer `{...}` over `do...end` for blocks.
      RUBY

      expect_correction(<<~RUBY)
        each { |x| }
      RUBY
    end

    it 'accepts a single line block with braces' do
      expect_no_offenses('each { |x| }')
    end

    it 'registers an offense for a multi-line block with do-end' do
      expect_offense(<<~RUBY)
        each do |x|
             ^^ Prefer `{...}` over `do...end` for blocks.
        end
      RUBY
    end

    it 'does not autocorrect do-end if {} would change the meaning' do
      expect_offense(<<~RUBY)
        s.subspec 'Subspec' do |sp| end
                            ^^ Prefer `{...}` over `do...end` for blocks.
      RUBY

      expect_no_corrections
    end

    it 'accepts a multi-line block that needs braces to be valid ruby' do
      expect_no_offenses(<<~RUBY)
        puts [1, 2, 3].map { |n|
          n * n
        }, 1
      RUBY
    end

    it 'registers an offense for multi-line chained do-end blocks' do
      expect_offense(<<~RUBY)
        each do |x|
             ^^ Prefer `{...}` over `do...end` for blocks.
        end.map(&:to_s)
      RUBY

      expect_correction(<<~RUBY)
        each { |x|
        }.map(&:to_s)
      RUBY
    end

    it 'registers an offense for multi-lined do-end blocks when combined ' \
       'with attribute assignment' do
      expect_offense(<<~RUBY)
        foo.bar = baz.map do |x|
                          ^^ Prefer `{...}` over `do...end` for blocks.
        end
      RUBY
    end

    it 'accepts a multi-line functional block with do-end if it is an ignored method' do
      expect_no_offenses(<<~RUBY)
        foo = proc do
          puts 42
        end
      RUBY
    end

    it 'accepts a multi-line functional block with do-end if it is an ignored method by regex' do
      expect_no_offenses(<<~RUBY)
        foo = test_method do
          puts 42
        end
      RUBY
    end

    context 'when there are braces around a multi-line block' do
      it 'allows in the simple case' do
        expect_no_offenses(<<~RUBY)
          each { |x|
          }
        RUBY
      end

      it 'allows when combined with attribute assignment' do
        expect_no_offenses(<<~RUBY)
          foo.bar = baz.map { |x|
          }
        RUBY
      end

      it 'allows when the block is being chained' do
        expect_no_offenses(<<~RUBY)
          each { |x|
          }.map(&:to_sym)
        RUBY
      end
    end

    it 'autocorrects do-end with `rescue` to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        map do |a|
            ^^ Prefer `{...}` over `do...end` for blocks.
          do_something
        rescue StandardError => e
          puts 'oh no'
        end
      RUBY

      expect_correction(<<~RUBY)
        map { |a|
          begin
        do_something
        rescue StandardError => e
          puts 'oh no'
        end
        }
      RUBY
    end

    it 'autocorrects do-end with `ensure` to {} if it is a functional block' do
      expect_offense(<<~RUBY)
        map do |a|
            ^^ Prefer `{...}` over `do...end` for blocks.
          do_something
        ensure
          puts 'oh no'
        end
      RUBY

      expect_correction(<<~RUBY)
        map { |a|
          begin
        do_something
        ensure
          puts 'oh no'
        end
        }
      RUBY
    end
  end

  context 'BracesRequiredMethods' do
    cop_config = { 'EnforcedStyle' => 'line_count_based', 'BracesRequiredMethods' => %w[sig] }

    let(:cop_config) { cop_config }

    describe 'BracesRequiredMethods methods' do
      it 'allows braces' do
        expect_no_offenses(<<~RUBY)
          sig {
            params(
              foo: string,
            ).void
          }
          def consume(foo)
            foo
          end
        RUBY
      end

      it 'registers an offense with do' do
        expect_offense(<<~RUBY)
          sig do
              ^^ Brace delimiters `{...}` required for 'sig' method.
            params(
              foo: string,
            ).void
          end
          def consume(foo)
            foo
          end
        RUBY

        expect_correction(<<~RUBY)
          sig {
            params(
              foo: string,
            ).void
          }
          def consume(foo)
            foo
          end
        RUBY
      end
    end

    describe 'other methods' do
      it 'allows braces' do
        expect_no_offenses(<<~RUBY)
          other_method do
            params(
              foo: string,
            ).void
          end
          def consume(foo)
            foo
          end
        RUBY
      end

      it 'autocorrects { and } to do and end' do
        expect_offense(<<~RUBY)
          each{ |x|
              ^ Avoid using `{...}` for multi-line blocks.
            some_method
            other_method
          }
        RUBY

        expect_correction(<<~RUBY)
          each do |x|
            some_method
            other_method
          end
        RUBY
      end
    end
  end
end
