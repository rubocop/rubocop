# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::BlockLength, :config do
  let(:cop_config) { { 'Max' => 2, 'CountComments' => false } }

  shared_examples 'allow an offense on an allowed method' do |allowed, config_key|
    before { cop_config[config_key] = [allowed] }

    it 'still rejects other methods with long blocks' do
      expect_offense(<<~RUBY)
        something do
        ^^^^^^^^^^^^ Block has too many lines. [3/2]
          a = 1
          a = 2
          a = 3
        end
      RUBY
    end

    it 'accepts the foo method with a long block' do
      expect_no_offenses(<<~RUBY)
        #{allowed} do
          a = 1
          a = 2
          a = 3
        end
      RUBY
    end
  end

  it 'rejects a block with more than 5 lines' do
    expect_offense(<<~RUBY)
      something do
      ^^^^^^^^^^^^ Block has too many lines. [3/2]
        a = 1
        a = 2
        a = 3
      end
    RUBY
  end

  it 'reports the correct beginning and end lines' do
    offenses = expect_offense(<<~RUBY)
      something do
      ^^^^^^^^^^^^ Block has too many lines. [3/2]
        a = 1
        a = 2
        a = 3
      end
    RUBY
    offense = offenses.first
    expect(offense.location.last_line).to eq(5)
  end

  it 'accepts a block with less than 3 lines' do
    expect_no_offenses(<<~RUBY)
      something do
        a = 1
        a = 2
      end
    RUBY
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<~RUBY)
      something do
        a = 1


        a = 4
      end
    RUBY
  end

  context 'when using numbered parameter', :ruby27 do
    it 'rejects a block with more than 5 lines' do
      expect_offense(<<~RUBY)
        something do
        ^^^^^^^^^^^^ Block has too many lines. [3/2]
          a = _1
          a = _2
          a = _3
        end
      RUBY
    end

    it 'reports the correct beginning and end lines' do
      offenses = expect_offense(<<~RUBY)
        something do
        ^^^^^^^^^^^^ Block has too many lines. [3/2]
          a = _1
          a = _2
          a = _3
        end
      RUBY
      offense = offenses.first
      expect(offense.location.last_line).to eq(5)
    end

    it 'accepts a block with less than 3 lines' do
      expect_no_offenses(<<~RUBY)
        something do
          a = _1
          a = _2
        end
      RUBY
    end

    it 'does not count blank lines' do
      expect_no_offenses(<<~RUBY)
        something do
          a = _1


          a = _2
        end
      RUBY
    end
  end

  it 'accepts a block with multiline receiver and less than 3 lines of body' do
    expect_no_offenses(<<~RUBY)
      [
        :a,
        :b,
        :c,
      ].each do
        a = 1
        a = 2
      end
    RUBY
  end

  it 'accepts empty blocks' do
    expect_no_offenses(<<~RUBY)
      something do
      end
    RUBY
  end

  it 'rejects brace blocks too' do
    expect_offense(<<~RUBY)
      something {
      ^^^^^^^^^^^ Block has too many lines. [3/2]
        a = 1
        a = 2
        a = 3
      }
    RUBY
  end

  it 'properly counts nested blocks' do
    expect_offense(<<~RUBY)
      something do
      ^^^^^^^^^^^^ Block has too many lines. [6/2]
        something do
        ^^^^^^^^^^^^ Block has too many lines. [4/2]
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
    RUBY
  end

  it 'does not count commented lines by default' do
    expect_no_offenses(<<~RUBY)
      something do
        a = 1
        #a = 2
        #a = 3
        a = 4
      end
    RUBY
  end

  context 'when defining a class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when defining a module' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Module.new do
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when defining a Struct' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        Person = Struct.new(:first_name, :last_name) do
          def full_name
            "#{first_name} #{last_name}"
          end

          def foo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
            a = 6
          end
        end
      RUBY
    end
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      expect_offense(<<~RUBY)
        something do
        ^^^^^^^^^^^^ Block has too many lines. [3/2]
          a = 1
          #a = 2
          a = 3
        end
      RUBY
    end
  end

  context 'when `CountAsOne` is not empty' do
    before { cop_config['CountAsOne'] = ['array'] }

    it 'folds array into one line' do
      expect_no_offenses(<<~RUBY)
        something do
          a = 1
          a = [
            2,
            3
          ]
        end
      RUBY
    end
  end

  context 'when methods to allow are defined' do
    context 'when AllowedMethods is enabled' do
      it_behaves_like('allow an offense on an allowed method', 'foo', 'AllowedMethods')

      it_behaves_like('allow an offense on an allowed method', 'Gem::Specification.new',
                      'AllowedMethods')

      context 'when receiver contains whitespaces' do
        before { cop_config['AllowedMethods'] = ['Foo::Bar.baz'] }

        it 'allows whitespaces' do
          expect_no_offenses(<<~RUBY)
            Foo::
              Bar.baz do
              a = 1
              a = 2
              a = 3
            end
          RUBY
        end
      end

      context 'when a method is allowed, but receiver is a module' do
        before { cop_config['AllowedMethods'] = ['baz'] }

        it 'does not report an offense' do
          expect_no_offenses(<<~RUBY)
            Foo::Bar.baz do
              a = 1
              a = 2
              a = 3
            end
          RUBY
        end
      end
    end

    context 'when AllowedPatterns is enabled' do
      before { cop_config['AllowedPatterns'] = [/baz/] }

      it 'does not report an offense' do
        expect_no_offenses(<<~RUBY)
          Foo::Bar.baz do
            a = 1
            a = 2
            a = 3
          end
        RUBY
      end

      context 'that does not match' do
        it 'reports an offense' do
          expect_offense(<<~RUBY)
            Foo::Bar.bar do
            ^^^^^^^^^^^^^^^ Block has too many lines. [3/2]
              a = 1
              a = 2
              a = 3
            end
          RUBY
        end
      end
    end

    context 'when IgnoredMethods is enabled' do
      context 'when string' do
        before { cop_config['IgnoredMethods'] = ['Foo::Bar.baz'] }

        it 'does not report an offense' do
          expect_no_offenses(<<~RUBY)
            Foo::Bar.baz do
              a = 1
              a = 2
              a = 3
            end
          RUBY
        end

        context 'that does not match' do
          it 'reports an offense' do
            expect_offense(<<~RUBY)
              Foo::Bar.bar do
              ^^^^^^^^^^^^^^^ Block has too many lines. [3/2]
                a = 1
                a = 2
                a = 3
              end
            RUBY
          end
        end
      end

      context 'when regex' do
        before { cop_config['IgnoredMethods'] = [/baz/] }

        it 'does not report an offense' do
          expect_no_offenses(<<~RUBY)
            Foo::Bar.baz do
              a = 1
              a = 2
              a = 3
            end
          RUBY
        end

        context 'that does not match' do
          it 'reports an offense' do
            expect_offense(<<~RUBY)
              Foo::Bar.bar do
              ^^^^^^^^^^^^^^^ Block has too many lines. [3/2]
                a = 1
                a = 2
                a = 3
              end
            RUBY
          end
        end
      end
    end

    context 'when ExcludedMethods is enabled' do
      before { cop_config['ExcludedMethods'] = ['Foo::Bar.baz'] }

      it 'does not report an offense' do
        expect_no_offenses(<<~RUBY)
          Foo::Bar.baz do
            a = 1
            a = 2
            a = 3
          end
        RUBY
      end

      context 'that does not match' do
        it 'reports an offense' do
          expect_offense(<<~RUBY)
            Foo::Bar.bar do
            ^^^^^^^^^^^^^^^ Block has too many lines. [3/2]
              a = 1
              a = 2
              a = 3
            end
          RUBY
        end
      end
    end
  end
end
