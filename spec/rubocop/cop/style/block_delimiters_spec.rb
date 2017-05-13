# frozen_string_literal: true

describe RuboCop::Cop::Style::BlockDelimiters, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'syntactic styles' do
    it 'registers an offense for a single line block with do-end' do
      inspect_source(cop, 'each do |x| end')
      expect(cop.messages)
        .to eq(['Prefer `{...}` over `do...end` for single-line blocks.'])
    end

    it 'accepts a single line block with braces' do
      expect_no_offenses('each { |x| }')
    end

    it 'accepts a multi-line block with do-end' do
      expect_no_offenses(<<-END.strip_indent)
        each do |x|
        end
      END
    end

    it 'accepts a multi-line block that needs braces to be valid ruby' do
      inspect_source(cop, <<-END.strip_indent)
        puts [1, 2, 3].map { |n|
          n * n
        }, 1
      END
      expect(cop.messages).to be_empty
    end
  end

  context 'Semantic style' do
    cop_config = {
      'EnforcedStyle' => 'semantic',
      'ProceduralMethods' => %w[tap],
      'FunctionalMethods' => %w[let],
      'IgnoredMethods' => %w[lambda]
    }

    let(:cop_config) { cop_config }

    it 'accepts a multi-line block with braces if the return value is ' \
       'assigned' do
      inspect_source(cop, <<-END.strip_indent)
        foo = map { |x|
          x
        }
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts a multi-line block with braces if it is the return value ' \
       'of its scope' do
      inspect_source(cop, <<-END.strip_indent)
        block do
          map { |x|
            x
          }
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts a multi-line block with braces when passed to a method' do
      expect_no_offenses(<<-END.strip_indent)
        puts map { |x|
          x
        }
      END
    end

    it 'accepts a multi-line block with braces when chained' do
      expect_no_offenses(<<-END.strip_indent)
        map { |x|
          x
        }.inspect
      END
    end

    it 'accepts a multi-line block with braces when passed to a known ' \
       'functional method' do
      inspect_source(cop, <<-END.strip_indent)
        let(:foo) {
          x
        }
      END
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a multi-line block with braces if the ' \
       'return value is not used' do
      inspect_source(cop, <<-END.strip_indent)
        each { |x|
          x
        }
      END
      expect(cop.messages)
        .to eq(['Prefer `do...end` over `{...}` for procedural blocks.'])
    end

    it 'registers an offense for a multi-line block with do-end if the ' \
       'return value is assigned' do
      inspect_source(cop, <<-END.strip_indent)
        foo = map do |x|
          x
        end
      END
      expect(cop.messages)
        .to eq(['Prefer `{...}` over `do...end` for functional blocks.'])
    end

    it 'registers an offense for a multi-line block with do-end if the ' \
       'return value is passed to a method' do
      inspect_source(cop, <<-END.strip_indent)
        puts (map do |x|
          x
        end)
      END
      expect(cop.messages)
        .to eq(['Prefer `{...}` over `do...end` for functional blocks.'])
    end

    it 'accepts a multi-line block with do-end if it is the return value ' \
       'of its scope' do
      inspect_source(cop, <<-END.strip_indent)
        block do
          map do |x|
            x
          end
        end
      END
      expect(cop.messages).to be_empty
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

    it 'accepts a multi-line functional block with do-end if it is ' \
       'a known procedural method' do
      inspect_source(cop, <<-END.strip_indent)
        foo = bar.tap do |x|
          x.age = 3
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts a multi-line functional block with do-end if it is ' \
       'an ignored method' do
      inspect_source(cop, <<-END.strip_indent)
        foo = lambda do
          puts 42
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for a single line procedural block' do
      expect_offense(<<-RUBY.strip_indent)
        each { |x| puts x }
             ^ Prefer `do...end` over `{...}` for procedural blocks.
      RUBY
    end

    it 'accepts a single line block with do-end if it is procedural' do
      expect_no_offenses('each do |x| puts x; end')
    end

    context 'with a procedural block' do
      let(:corrected_source) do
        <<-END.strip_indent
        each do |x|
          x
        end
        END
      end

      it 'auto-corrects { and } to do and end' do
        source = <<-END.strip_indent
        each { |x|
          x
        }
        END

        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(corrected_source)
      end

      it 'auto-corrects { and } to do and end with appropriate spacing' do
        source = <<-END.strip_indent
        each {|x|
          x
        }
        END

        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(corrected_source)
      end
    end

    it 'does not auto-correct {} to do-end if it is a known functional ' \
       'method' do
      source = <<-END.strip_indent
        let(:foo) { |x|
          x
        }
      END

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(source)
    end

    it 'does not autocorrect do-end to {} if it is a known procedural ' \
       'method' do
      source = <<-END.strip_indent
        foo = bar.tap do |x|
          x.age = 1
        end
      END

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(source)
    end

    it 'auto-corrects do-end to {} if it is a functional block' do
      source = <<-END.strip_indent
        foo = map do |x|
          x
        end
      END

      expected_source = <<-END.strip_indent
        foo = map { |x|
          x
        }
      END

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(expected_source)
    end

    it 'auto-corrects do-end to {} with appropriate spacing' do
      source = <<-END.strip_indent
        foo = map do|x|
          x
        end
      END

      expected_source = <<-END.strip_indent
        foo = map { |x|
          x
        }
      END

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(expected_source)
    end

    it 'auto-corrects do-end to {} if it is a functional block and does ' \
       'not change the meaning' do
      source = <<-END.strip_indent
        puts (map do |x|
          x
        end)
      END

      expected_source = <<-END.strip_indent
        puts (map { |x|
          x
        })
      END

      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(expected_source)
    end
  end

  context 'line count-based style' do
    cop_config = {
      'EnforcedStyle' => 'line_count_based',
      'IgnoredMethods' => %w[proc]
    }

    let(:cop_config) { cop_config }

    include_examples 'syntactic styles'

    it 'auto-corrects do and end for single line blocks to { and }' do
      new_source = autocorrect_source(cop, 'block do |x| end')
      expect(new_source).to eq('block { |x| }')
    end

    it 'does not auto-correct do-end if {} would change the meaning' do
      src = "s.subspec 'Subspec' do |sp| end"
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end

    it 'does not auto-correct {} if do-end would change the meaning' do
      src = <<-END.strip_indent
        foo :bar, :baz, qux: lambda { |a|
          bar a
        }
      END
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end

    context 'when there are braces around a multi-line block' do
      it 'registers an offense in the simple case' do
        expect_offense(<<-END.strip_indent)
          each { |x|
               ^ Avoid using `{...}` for multi-line blocks.
          }
        END
      end

      it 'accepts braces if do-end would change the meaning' do
        src = <<-END.strip_indent
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
        END
        inspect_source(cop, src)
        expect(cop.offenses).to be_empty
      end

      it 'accepts a multi-line functional block with {} if it is ' \
         'an ignored method' do
        inspect_source(cop, <<-END.strip_indent)
          foo = proc {
            puts 42
          }
        END
        expect(cop.messages).to be_empty
      end

      it 'registers an offense for braces if do-end would not change ' \
         'the meaning' do
        src = <<-END.strip_indent
          scope :foo, (lambda { |f|
            where(condition: "value")
          })

          expect { something }.to(raise_error(ErrorClass) { |error|
            # ...
          })
        END
        inspect_source(cop, src)
        expect(cop.offenses.size).to eq(2)
      end

      it 'can handle special method names such as []= and done?' do
        src = <<-END.strip_indent
          h2[k2] = Hash.new { |h3,k3|
            h3[k3] = 0
          }

          x = done? list.reject { |e|
            e.nil?
          }
        END
        inspect_source(cop, src)
        expect(cop.messages)
          .to eq(['Avoid using `{...}` for multi-line blocks.'])
      end

      it 'auto-corrects { and } to do and end' do
        source = <<-END.strip_indent
          each{ |x|
            some_method
            other_method
          }
        END

        expected_source = <<-END.strip_indent
          each do |x|
            some_method
            other_method
          end
        END

        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(expected_source)
      end

      it 'auto-corrects adjacent curly braces correctly' do
        source = <<-END.strip_indent
          (0..3).each { |a| a.times {
            puts a
          }}
        END

        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(<<-END.strip_indent)
          (0..3).each do |a| a.times do
            puts a
          end end
        END
      end

      it 'does not auto-correct {} if do-end would introduce a syntax error' do
        src = <<-END.strip_indent
          my_method :arg1, arg2: proc {
            something
          }, arg3: :another_value
        END
        new_source = autocorrect_source(cop, src)
        expect(new_source).to eq(src)
      end
    end
  end

  context 'braces for chaining style' do
    cop_config = {
      'EnforcedStyle' => 'braces_for_chaining',
      'IgnoredMethods' => %w[proc]
    }

    let(:cop_config) { cop_config }

    include_examples 'syntactic styles'

    it 'registers an offense for multi-line chained do-end blocks' do
      expect_offense(<<-END.strip_indent)
        each do |x|
             ^^ Prefer `{...}` over `do...end` for multi-line chained blocks.
        end.map(&:to_s)
      END
    end

    it 'auto-corrects do-end for chained blocks' do
      src = <<-END.strip_indent
        each do |x|
        end.map(&:to_s)
      END
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(<<-END.strip_indent)
        each { |x|
        }.map(&:to_s)
      END
    end

    it 'accepts a multi-line functional block with {} if it is ' \
       'an ignored method' do
      inspect_source(cop, <<-END.strip_indent)
        foo = proc {
          puts 42
        }
      END
      expect(cop.messages).to be_empty
    end

    context 'when there are braces around a multi-line block' do
      it 'registers an offense in the simple case' do
        expect_offense(<<-END.strip_indent)
          each { |x|
               ^ Prefer `do...end` for multi-line blocks without chaining.
          }
        END
      end

      it 'allows when the block is being chained' do
        expect_no_offenses(<<-END.strip_indent)
          each { |x|
          }.map(&:to_sym)
        END
      end
    end
  end
end
