# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::HashAlignment, :config do
  let(:config) do
    RuboCop::Config.new(
      'Layout/HashAlignment' => default_cop_config.merge(cop_config),
      'Layout/ArgumentAlignment' => argument_alignment_config
    )
  end

  let(:default_cop_config) { { 'EnforcedHashRocketStyle' => 'key', 'EnforcedColonStyle' => 'key' } }
  let(:argument_alignment_config) { { 'EnforcedStyle' => 'with_first_argument' } }

  shared_examples 'not on separate lines' do
    it 'accepts single line hash' do
      expect_no_offenses('func(a: 0, bb: 1)')
    end

    it 'accepts several pairs per line' do
      expect_no_offenses(<<~RUBY)
        func(a: 1, bb: 2,
             ccc: 3, dddd: 4)
      RUBY
    end

    it "accepts pairs that don't start a line" do
      expect_no_offenses(<<~RUBY)
        render :json => {:a => messages,
                         :b => :json}, :status => 404
        def example
          a(
            b: :c,
            d: e(
              f: g
            ), h: :i)
        end
      RUBY
    end

    context 'when using hash value omission', :ruby31 do
      it 'accepts single line hash' do
        expect_no_offenses('func(a:, bb:)')
      end

      it 'accepts several pairs per line' do
        expect_no_offenses(<<~RUBY)
          func(a:, bb:,
               ccc:, dddd:)
        RUBY
      end

      it "accepts pairs that don't start a line" do
        expect_no_offenses(<<~RUBY)
          render :json => {a:,
                           b:}, :status => 404
          def example
            a(
              b:,
              c: d(
                e:
              ), f:)
          end
        RUBY
      end
    end
  end

  context 'always inspect last argument hash' do
    let(:cop_config) { { 'EnforcedLastArgumentHashStyle' => 'always_inspect' } }

    it 'registers offense and corrects misaligned keys in implicit hash' do
      expect_offense(<<~RUBY)
        func(a: 0,
          b: 1)
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        func(a: 0,
             b: 1)
      RUBY
    end

    it 'registers offense and corrects misaligned keys in explicit hash' do
      expect_offense(<<~RUBY)
        func({a: 0,
          b: 1})
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        func({a: 0,
              b: 1})
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in implicit hash for super' do
      expect_offense(<<~RUBY)
        super(a: 0,
          b: 1)
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        super(a: 0,
              b: 1)
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in explicit hash for super' do
      expect_offense(<<~RUBY)
        super({a: 0,
          b: 1})
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        super({a: 0,
               b: 1})
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in implicit hash for yield' do
      expect_offense(<<~RUBY)
        yield(a: 0,
          b: 1)
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        yield(a: 0,
              b: 1)
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in explicit hash for yield' do
      expect_offense(<<~RUBY)
        yield({a: 0,
          b: 1})
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        yield({a: 0,
               b: 1})
      RUBY
    end

    context 'when using hash value omission', :ruby31 do
      it 'registers offense and corrects misaligned keys in implicit hash' do
        expect_offense(<<~RUBY)
          func(a:,
            b:)
            ^^ Align the keys of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          func(a:,
               b:)
        RUBY
      end

      it 'registers offense and corrects misaligned keys in explicit hash' do
        expect_offense(<<~RUBY)
          func({a:,
            b:})
            ^^ Align the keys of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          func({a:,
                b:})
        RUBY
      end
    end
  end

  context 'when `EnforcedStyle: with_fixed_indentation` of `ArgumentAlignment`' do
    let(:argument_alignment_config) { { 'EnforcedStyle' => 'with_fixed_indentation' } }

    it 'register and corrects an offense' do
      expect_offense(<<~RUBY)
        THINGS = {
          oh: :io,
            hi: 'neat'
            ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
            }
      RUBY

      expect_correction(<<~RUBY)
        THINGS = {
          oh: :io,
          hi: 'neat'
            }
      RUBY
    end

    it 'registers and corrects an offense when using misaligned keyword arguments' do
      expect_offense(<<~RUBY)
        config.fog_credentials_as_kwargs(
          provider:              'AWS',
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          aws_access_key_id:     ENV['S3_ACCESS_KEY'],
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          aws_secret_access_key: ENV['S3_SECRET'],
          region:                ENV['S3_REGION'],
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        )
      RUBY

      expect_correction(<<~RUBY)
        config.fog_credentials_as_kwargs(
          provider: 'AWS',
          aws_access_key_id: ENV['S3_ACCESS_KEY'],
          aws_secret_access_key: ENV['S3_SECRET'],
          region: ENV['S3_REGION'],
        )
      RUBY
    end

    context 'when using hash value omission', :ruby31 do
      it 'register and corrects an offense' do
        expect_offense(<<~RUBY)
          THINGS = {
            oh:,
              hi:
              ^^^ Align the keys of a hash literal if they span more than one line.
              }
        RUBY

        expect_correction(<<~RUBY)
          THINGS = {
            oh:,
            hi:
              }
        RUBY
      end

      it 'does not register and corrects an offense when using aligned keyword arguments' do
        expect_no_offenses(<<~RUBY)
          config.fog_credentials_as_kwargs(
            provider:,
            aws_access_key_id:,
            aws_secret_access_key:,
            region:
          )
        RUBY
      end
    end

    it 'does not register an offense using aligned hash literal' do
      expect_no_offenses(<<~RUBY)
        {
          oh: :io,
          hi: 'neat'
        }
      RUBY
    end

    it 'does not register an offense for an empty hash literal' do
      expect_no_offenses(<<~RUBY)
        foo({})
      RUBY
    end

    it 'does not register an offense using aligned hash argument for `proc.()`' do
      expect_no_offenses(<<~RUBY)
        proc.(key: value)
      RUBY
    end
  end

  context 'always ignore last argument hash' do
    let(:cop_config) { { 'EnforcedLastArgumentHashStyle' => 'always_ignore' } }

    it 'accepts misaligned keys in implicit hash' do
      expect_no_offenses(<<~RUBY)
        func(a: 0,
          b: 1)
      RUBY
    end

    it 'accepts misaligned keys in explicit hash' do
      expect_no_offenses(<<~RUBY)
        func({a: 0,
          b: 1})
      RUBY
    end

    it 'accepts misaligned keys in implicit hash for super' do
      expect_no_offenses(<<~RUBY)
        super(a: 0,
          b: 1)
      RUBY
    end

    it 'accepts misaligned keys in explicit hash for super' do
      expect_no_offenses(<<~RUBY)
        super({a: 0,
          b: 1})
      RUBY
    end

    it 'accepts misaligned keys in implicit hash for yield' do
      expect_no_offenses(<<~RUBY)
        yield(a: 0,
          b: 1)
      RUBY
    end

    it 'accepts misaligned keys in explicit hash for yield' do
      expect_no_offenses(<<~RUBY)
        yield({a: 0,
          b: 1})
      RUBY
    end
  end

  context 'ignore implicit last argument hash' do
    let(:cop_config) { { 'EnforcedLastArgumentHashStyle' => 'ignore_implicit' } }

    it 'accepts misaligned keys in implicit hash' do
      expect_no_offenses(<<~RUBY)
        func(a: 0,
          b: 1)
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in explicit hash' do
      expect_offense(<<~RUBY)
        func({a: 0,
          b: 1})
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        func({a: 0,
              b: 1})
      RUBY
    end

    it 'accepts misaligned keys in implicit hash for super' do
      expect_no_offenses(<<~RUBY)
        super(a: 0,
          b: 1)
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in explicit hash for super' do
      expect_offense(<<~RUBY)
        super({a: 0,
          b: 1})
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        super({a: 0,
               b: 1})
      RUBY
    end

    it 'accepts misaligned keys in implicit hash for yield' do
      expect_no_offenses(<<~RUBY)
        yield(a: 0,
          b: 1)
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in explicit hash for yield' do
      expect_offense(<<~RUBY)
        yield({a: 0,
          b: 1})
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        yield({a: 0,
               b: 1})
      RUBY
    end
  end

  context 'ignore explicit last argument hash' do
    let(:cop_config) { { 'EnforcedLastArgumentHashStyle' => 'ignore_explicit' } }

    it 'registers an offense and corrects misaligned keys in implicit hash' do
      expect_offense(<<~RUBY)
        func(a: 0,
          b: 1)
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        func(a: 0,
             b: 1)
      RUBY
    end

    it 'accepts misaligned keys in explicit hash' do
      expect_no_offenses(<<~RUBY)
        func({a: 0,
          b: 1})
      RUBY
    end

    context 'when using hash value omission', :ruby31 do
      it 'registers an offense and corrects misaligned keys in implicit hash' do
        expect_offense(<<~RUBY)
          func(a:,
            b:)
            ^^ Align the keys of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          func(a:,
               b:)
        RUBY
      end

      it 'accepts misaligned keys in explicit hash' do
        expect_no_offenses(<<~RUBY)
          func({a:,
            b:})
        RUBY
      end
    end

    it 'registers an offense and corrects misaligned keys in implicit hash for super' do
      expect_offense(<<~RUBY)
        super(a: 0,
          b: 1)
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        super(a: 0,
              b: 1)
      RUBY
    end

    it 'accepts misaligned keys in explicit hash for super' do
      expect_no_offenses(<<~RUBY)
        super({a: 0,
          b: 1})
      RUBY
    end

    it 'registers an offense and corrects misaligned keys in implicit hash for yield' do
      expect_offense(<<~RUBY)
        yield(a: 0,
          b: 1)
          ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        yield(a: 0,
              b: 1)
      RUBY
    end

    it 'accepts misaligned keys in explicit hash for yield' do
      expect_no_offenses(<<~RUBY)
        yield({a: 0,
          b: 1})
      RUBY
    end
  end

  context 'with default configuration' do
    it 'registers an offense and corrects misaligned hash keys' do
      expect_offense(<<~RUBY)
        hash1 = {
          a: 0,
           bb: 1
           ^^^^^ Align the keys of a hash literal if they span more than one line.
        }
        hash2 = {
          'ccc' => 2,
         'dddd'  =>  2
         ^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash1 = {
          a: 0,
          bb: 1
        }
        hash2 = {
          'ccc' => 2,
          'dddd' => 2
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned mixed multiline hash keys' do
      expect_offense(<<~RUBY)
        hash = { a: 1, b: 2,
                c: 3 }
                ^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        hash = { a: 1, b: 2,
                 c: 3 }
      RUBY
    end

    it 'accepts left-aligned hash keys with single spaces' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
          aa: 0,
          b: 1,
        }
        hash2 = {
          :a => 0,
          :bb => 1
        }
        hash3 = {
          'a' => 0,
          'bb' => 1
        }
      RUBY
    end

    it 'registers an offense and corrects zero or multiple spaces' do
      expect_offense(<<~RUBY)
        hash1 = {
          a:   0,
          ^^^^^^ Align the keys of a hash literal if they span more than one line.
          bb:1,
          ^^^^ Align the keys of a hash literal if they span more than one line.
        }
        hash2 = {
          'ccc'=> 2,
          ^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          'dddd' =>  3
          ^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash1 = {
          a: 0,
          bb: 1,
        }
        hash2 = {
          'ccc' => 2,
          'dddd' => 3
        }
      RUBY
    end

    it 'registers an offense and corrects separator alignment' do
      expect_offense(<<~RUBY)
        hash = {
            'a' => 0,
          'bbb' => 1
          ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
            'a' => 0,
            'bbb' => 1
        }
      RUBY
    end

    it 'registers an offense and corrects table alignment' do
      expect_offense(<<~RUBY)
        hash = {
          'a'   => 0,
          ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          'bbb' => 1
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
          'a' => 0,
          'bbb' => 1
        }
      RUBY
    end

    it 'registers an offense and corrects multiline value starts in wrong place' do
      expect_offense(<<~RUBY)
        hash = {
          'a' =>  (
          ^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
            ),
          'bbb' => 1
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
          'a' => (
            ),
          'bbb' => 1
        }
      RUBY
    end

    it 'does not register an offense when value starts on next line' do
      expect_no_offenses(<<~RUBY)
        hash = {
          'a' =>
            0,
          'bbb' => 1
        }
      RUBY
    end

    context 'with implicit hash as last argument' do
      it 'registers an offense and corrects misaligned hash keys' do
        expect_offense(<<~RUBY)
          func(a: 0,
            b: 1)
            ^^^^ Align the keys of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          func(a: 0,
               b: 1)
        RUBY
      end

      it 'registers an offense and corrects right alignment of keys' do
        expect_offense(<<~RUBY)
          func(a: 0,
             bbb: 1)
             ^^^^^^ Align the keys of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          func(a: 0,
               bbb: 1)
        RUBY
      end

      it 'accepts aligned hash keys' do
        expect_no_offenses(<<~RUBY)
          func(a: 0,
               b: 1)
        RUBY
      end

      it 'accepts an empty hash' do
        expect_no_offenses('h = {}')
      end
    end

    it 'registers an offense and corrects mixed hash styles' do
      expect_offense(<<~RUBY)
        hash1 = { a: 0,
             bb: 1,
             ^^^^^ Align the keys of a hash literal if they span more than one line.
                   ccc: 2 }
                   ^^^^^^ Align the keys of a hash literal if they span more than one line.
        hash2 = { :a   => 0,
                  ^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          :bb  => 1,
          ^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
                    :ccc  =>2 }
                    ^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        hash3 = { 'a'   =>   0,
                  ^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
                       'bb'  => 1,
                       ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
            'ccc'  =>2 }
            ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        hash1 = { a: 0,
                  bb: 1,
                  ccc: 2 }
        hash2 = { :a => 0,
                  :bb => 1,
                  :ccc => 2 }
        hash3 = { 'a' => 0,
                  'bb' => 1,
                  'ccc' => 2 }
      RUBY
    end

    it 'registers an offense and corrects alignment when using double splat in an explicit hash' do
      expect_offense(<<~RUBY)
        Hash(foo: 'bar',
               **extra_params
               ^^^^^^^^^^^^^^ Align keyword splats with the rest of the hash if it spans more than one line.
        )
      RUBY

      expect_correction(<<~RUBY)
        Hash(foo: 'bar',
             **extra_params
        )
      RUBY
    end

    it 'registers an offense and corrects alignment when using double splat in braces' do
      expect_offense(<<~RUBY)
        {foo: 'bar',
               **extra_params
               ^^^^^^^^^^^^^^ Align keyword splats with the rest of the hash if it spans more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        {foo: 'bar',
         **extra_params
        }
      RUBY
    end
  end

  include_examples 'not on separate lines'

  context 'with table alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'table',
        'EnforcedColonStyle' => 'table'
      }
    end

    include_examples 'not on separate lines'

    it 'accepts aligned hash keys and values' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
          'a'   => 0,
          'bbb' => 1
        }
        hash2 = {
          a:   0,
          bbb: 1
        }
      RUBY
    end

    it 'accepts an empty hash' do
      expect_no_offenses('h = {}')
    end

    context 'when using hash value omission', :ruby31 do
      it 'accepts aligned hash keys and values' do
        expect_no_offenses(<<~RUBY)
          hash1 = {
            'a'   => 0,
            'bbb' => 1
          }
          hash2 = {
            a:   0,
            bbb: 1,
            ccc:
          }
        RUBY
      end
    end

    it 'accepts a multiline array of single line hashes' do
      expect_no_offenses(<<~RUBY)
        def self.scenarios_order
            [
              { before:   %w( l k ) },
              { ending:   %w( m l ) },
              { starting: %w( m n ) },
              { after:    %w( n o ) }
            ]
          end
      RUBY
    end

    it 'accepts hashes that use different separators' do
      expect_no_offenses(<<~RUBY)
        hash = {
          a: 1,
          'bbb' => 2
        }
      RUBY
    end

    it 'accepts hashes that use different separators and double splats' do
      expect_no_offenses(<<~RUBY)
        hash = {
          a: 1,
          'bbb' => 2,
          **foo
        }
      RUBY
    end

    it 'accepts a symbol only hash followed by a keyword splat' do
      expect_no_offenses(<<~RUBY)
        hash = {
          a: 1,
          **kw
        }
      RUBY
    end

    it 'accepts a keyword splat only hash' do
      expect_no_offenses(<<~RUBY)
        hash = {
          **kw
        }
      RUBY
    end

    it 'registers an offense for misaligned hash values' do
      expect_offense(<<~RUBY)
        hash1 = {
          'a'   =>  0,
          ^^^^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
          'bbb' => 1
        }
        hash2 = {
          a:   0,
          bbb:1
          ^^^^^ Align the keys and values of a hash literal if they span more than one line.
        }
      RUBY
    end

    it 'registers an offense and corrects for misaligned hash keys' do
      expect_offense(<<~RUBY)
        hash1 = {
          'a'   =>  0,
          ^^^^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
         'bbb'  =>  1
         ^^^^^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
        }
        hash2 = {
           a:  0,
           ^^^^^ Align the keys and values of a hash literal if they span more than one line.
          bbb: 1
          ^^^^^^ Align the keys and values of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash1 = {
          'a'   => 0,
          'bbb' => 1
        }
        hash2 = {
           a:   0,
           bbb: 1
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned hash rockets' do
      expect_offense(<<~RUBY)
        hash = {
          'a'   => 0,
          'bbb'  => 1
          ^^^^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
          'a'   => 0,
          'bbb' => 1
        }
      RUBY
    end
  end

  context 'with table+separator alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'table',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'accepts a single method argument entry with colon' do
      expect_no_offenses('merge(parent: nil)')
    end
  end

  context 'with invalid configuration' do
    let(:cop_config) { { 'EnforcedHashRocketStyle' => 'junk', 'EnforcedColonStyle' => 'junk' } }

    it 'fails' do
      expect do
        expect_offense(<<~RUBY)
          hash = {
            a: 0,
            bb: 1
          }
        RUBY
      end.to raise_error(RuntimeError)
    end
  end

  context 'with separator alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'separator',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'accepts aligned hash keys' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
            a: 0,
          bbb: 1
        }
        hash2 = {
            'a' => 0,
          'bbb' => 1
        }
      RUBY
    end

    context 'when using hash value omission', :ruby31 do
      it 'accepts aligned hash keys' do
        expect_no_offenses(<<~RUBY)
          hash1 = {
              a: 0,
            bbb: 1,
            ccc:
          }
          hash2 = {
              'a' => 0,
            'bbb' => 1
          }
        RUBY
      end

      it 'registers an offense and corrects mixed indentation and spacing' do
        expect_offense(<<~RUBY)
          hash1 = { a: 0,
               bb:,
               ^^^ Align the separators of a hash literal if they span more than one line.
                     ccc: 2 }
                     ^^^^^^ Align the separators of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          hash1 = { a: 0,
                   bb:,
                  ccc: 2 }
        RUBY
      end
    end

    it 'accepts an empty hash' do
      expect_no_offenses('h = {}')
    end

    it 'registers an offense and corrects misaligned hash values' do
      expect_offense(<<~RUBY)
        hash = {
            'a' =>  0,
          'bbb' => 1
          ^^^^^^^^^^ Align the separators of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
            'a' =>  0,
          'bbb' =>  1
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned hash rockets' do
      expect_offense(<<~RUBY)
        hash = {
            'a'  => 0,
          'bbb' =>  1
          ^^^^^^^^^^^ Align the separators of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
            'a'  => 0,
          'bbb'  => 1
        }
      RUBY
    end

    it 'accepts hashes with different separators' do
      expect_no_offenses(<<~RUBY)
        {a: 1,
          'b' => 2,
           **params}
      RUBY
    end

    include_examples 'not on separate lines'

    it 'registers an offense and corrects mixed indentation and spacing' do
      expect_offense(<<~RUBY)
        hash1 = { a: 0,
             bb:    1,
             ^^^^^^^^ Align the separators of a hash literal if they span more than one line.
                   ccc: 2 }
                   ^^^^^^ Align the separators of a hash literal if they span more than one line.
        hash2 = { a => 0,
             bb =>    1,
             ^^^^^^^^^^ Align the separators of a hash literal if they span more than one line.
                   ccc  =>2 }
                   ^^^^^^^^ Align the separators of a hash literal if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        hash1 = { a: 0,
                 bb: 1,
                ccc: 2 }
        hash2 = { a => 0,
                 bb => 1,
                ccc => 2 }
      RUBY
    end

    it "doesn't break code by moving long keys too far left" do
      # regression test; see GH issue 2582
      expect_offense(<<~RUBY)
        {
          sjtjo: sjtjo,
          too_ono_ilitjion_tofotono_o: too_ono_ilitjion_tofotono_o,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the separators of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          sjtjo: sjtjo,
        too_ono_ilitjion_tofotono_o: too_ono_ilitjion_tofotono_o,
        }
      RUBY
    end
  end

  context 'with multiple preferred(key and table) alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => %w[key table],
        'EnforcedColonStyle' => %w[key table]
      }
    end

    it 'accepts aligned hash keys, by keys' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
          a: 0,
          bbb: 1
        }
        hash2 = {
          'a' => 0,
          'bbb' => 1
        }
      RUBY
    end

    it 'accepts aligned hash keys, by table' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
          a:   0,
          bbb: 1
        }
        hash2 = {
          'a'   => 0,
          'bbb' => 1
        }
      RUBY
    end

    it 'accepts aligned hash keys, by both' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
          a:   0,
          bbb: 1
        }
        hash2 = {
          a: 0,
          bbb: 1
        }

        hash3 = {
          'a'   => 0,
          'bbb' => 1
        }
        hash4 = {
          'a' => 0,
          'bbb' => 1
        }
      RUBY
    end

    it 'accepts aligned hash keys with mixed hash style' do
      expect_no_offenses(<<~RUBY)
        headers = {
          "Content-Type" => 0,
          Authorization: 1
        }
      RUBY
    end

    it 'accepts an empty hash' do
      expect_no_offenses('h = {}')
    end

    it 'registers an offense and corrects misaligned hash values' do
      expect_offense(<<~RUBY)
        hash = {
            'a' =>  0,
            ^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          'bbb' => 1
          ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
            'a' => 0,
            'bbb' => 1
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned hash values, ' \
       'prefer table when least offenses' do
      expect_offense(<<~RUBY)
        hash = {
          'abcdefg' => 0,
          'abcdef'  => 0,
          'gijk'    => 0,
          'a'       => 0,
          'b' => 1,
          ^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
                'c' => 1
                ^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
          'abcdefg' => 0,
          'abcdef'  => 0,
          'gijk'    => 0,
          'a'       => 0,
          'b' => 1,
          'c' => 1
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned hash values, prefer key when least offenses' do
      expect_offense(<<~RUBY)
        hash = {
          'abcdefg' => 0,
          'abcdef'  => 0,
          ^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          'gijk' => 0,
          'a' => 0,
          'b' => 1,
                'c' => 1
                ^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
          'abcdefg' => 0,
          'abcdef' => 0,
          'gijk' => 0,
          'a' => 0,
          'b' => 1,
          'c' => 1
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned hash keys with mixed hash style' do
      expect_offense(<<~RUBY)
        headers = {
          "Content-Type" => 0,
           Authorization: 1
           ^^^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        headers = {
          "Content-Type" => 0,
          Authorization: 1
        }
      RUBY
    end

    it 'registers an offense and corrects misaligned hash values, works separate for each hash' do
      expect_offense(<<~RUBY)
        hash = {
          'abcdefg' => 0,
          'abcdef'  => 0,
          ^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          'gijk' => 0
        }

        hash = {
          'abcdefg' => 0,
          'abcdef'       => 0,
          ^^^^^^^^^^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
          'gijk' => 0
        }
      RUBY

      expect_correction(<<~RUBY)
        hash = {
          'abcdefg' => 0,
          'abcdef' => 0,
          'gijk' => 0
        }

        hash = {
          'abcdefg' => 0,
          'abcdef' => 0,
          'gijk' => 0
        }
      RUBY
    end

    describe 'table and key config' do
      let(:cop_config) do
        {
          'EnforcedHashRocketStyle' => %w[table key],
          'EnforcedColonStyle' => %w[table key]
        }
      end

      it 'registers an offense and corrects misaligned hash values, ' \
         'prefer table because it is specified first' do
        expect_offense(<<~RUBY)
          hash = {
            'abcdefg' => 0,
            'abcdef'  => 0,
            'gijk'    => 0,
            'a'       => 0,
            'b' => 1,
            ^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
                  'c' => 1
                  ^^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
          }
        RUBY

        expect_correction(<<~RUBY)
          hash = {
            'abcdefg' => 0,
            'abcdef'  => 0,
            'gijk'    => 0,
            'a'       => 0,
            'b'       => 1,
            'c'       => 1
          }
        RUBY
      end
    end
  end

  context 'with different settings for => and :' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'key',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'registers offenses and correct misaligned entries' do
      expect_offense(<<~RUBY)
        hash1 = {
          a:   0,
          bbb: 1
          ^^^^^^ Align the separators of a hash literal if they span more than one line.
        }
        hash2 = {
            'a' => 0,
          'bbb' => 1
          ^^^^^^^^^^ Align the keys of a hash literal if they span more than one line.
        }
      RUBY

      expect_correction(<<~RUBY)
        hash1 = {
          a:   0,
        bbb:   1
        }
        hash2 = {
            'a' => 0,
            'bbb' => 1
        }
      RUBY
    end

    it 'accepts aligned entries' do
      expect_no_offenses(<<~RUBY)
        hash1 = {
            a: 0,
          bbb: 1
        }
        hash2 = {
          'a' => 0,
          'bbb' => 1
        }
      RUBY
    end
  end

  it 'register no offense for superclass call without args' do
    expect_no_offenses('super')
  end

  it 'register no offense for yield without args' do
    expect_no_offenses('yield')
  end

  context 'with `EnforcedColonStyle`: `table`' do
    let(:cop_config) do
      {
        'EnforcedColonStyle' => 'table'
      }
    end

    context 'and misaligned keys' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo ab: 1,
              c: 2
              ^^^^ Align the keys and values of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          foo ab: 1,
              c:  2
        RUBY
      end
    end

    context 'when using hash value omission', :ruby31 do
      context 'and aligned keys' do
        it 'does not register an offense and corrects' do
          expect_no_offenses(<<~RUBY)
            foo ab: 1,
                c:
          RUBY
        end
      end
    end

    context 'when using anonymous keyword rest arguments', :ruby32 do
      context 'and forwarded keyword rest argument after a hash key' do
        it 'registers an offense on the misaligned key and corrects' do
          expect_offense(<<~RUBY)
            def foo(**)
              bar ab: 1,
                  c: 2, **
                  ^^^^ Align the keys and values of a hash literal if they span more than one line.
            end
          RUBY

          expect_correction(<<~RUBY)
            def foo(**)
              bar ab: 1,
                  c:  2, **
            end
          RUBY
        end
      end

      context 'and aligned keys but forwarded keyword rest argument after' do
        it 'does not register an offense on the `forwarded_kwrestarg`' do
          expect_no_offenses(<<~RUBY)
            def foo(**)
              bar a: 1,
                  b: 2, **
            end
          RUBY
        end
      end

      context 'and a misaligned forwarded keyword rest argument' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            def foo(**)
              bar a: 1,
                    **
                    ^^ Align keyword splats with the rest of the hash if it spans more than one line.
            end
          RUBY

          expect_correction(<<~RUBY)
            def foo(**)
              bar a: 1,
                  **
            end
          RUBY
        end
      end
    end

    context 'when the only item is a kwsplat' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo({**rest})
        RUBY
      end
    end

    context 'and a double splat argument after a hash key' do
      it 'registers an offense on the misaligned key and corrects' do
        expect_offense(<<~RUBY)
          foo ab: 1,
              c: 2, **rest
              ^^^^ Align the keys and values of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          foo ab: 1,
              c:  2, **rest
        RUBY
      end
    end

    context 'and aligned keys but a double splat argument after' do
      it 'does not register an offense on the `kwsplat`' do
        expect_no_offenses(<<~RUBY)
          foo a: 1,
              b: 2, **rest
        RUBY
      end
    end

    context 'and a misaligned double splat argument' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo a: 1,
                **rest
                ^^^^^^ Align keyword splats with the rest of the hash if it spans more than one line.
        RUBY

        expect_correction(<<~RUBY)
          foo a: 1,
              **rest
        RUBY
      end
    end
  end

  context 'with `EnforcedHashRocketStyle`: `table`' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'table'
      }
    end

    context 'and misaligned keys' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo :ab => 1,
              :c => 2
              ^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          foo :ab => 1,
              :c  => 2
        RUBY
      end
    end

    context 'when the only item is a kwsplat' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo({**rest})
        RUBY
      end
    end

    context 'and a double splat argument after a hash key' do
      it 'registers an offense on the misaligned key and corrects' do
        expect_offense(<<~RUBY)
          foo :ab => 1,
              :c => 2, **rest
              ^^^^^^^ Align the keys and values of a hash literal if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          foo :ab => 1,
              :c  => 2, **rest
        RUBY
      end
    end

    context 'and aligned keys but a double splat argument after' do
      it 'does not register an offense on the `kwsplat`' do
        expect_no_offenses(<<~RUBY)
          foo :a => 1,
              :b => 2, **rest
        RUBY
      end
    end

    context 'and a misaligned double splat argument' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo :a => 1,
                **rest
                ^^^^^^ Align keyword splats with the rest of the hash if it spans more than one line.
        RUBY

        expect_correction(<<~RUBY)
          foo :a => 1,
              **rest
        RUBY
      end
    end
  end
end
