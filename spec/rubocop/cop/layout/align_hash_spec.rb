# frozen_string_literal: true

describe RuboCop::Cop::Layout::AlignHash, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'not on separate lines' do
    it 'accepts single line hash' do
      expect_no_offenses('func(a: 0, bb: 1)')
    end

    it 'accepts several pairs per line' do
      expect_no_offenses(<<-END.strip_indent)
        func(a: 1, bb: 2,
             ccc: 3, dddd: 4)
      END
    end

    it "does not auto-correct pairs that don't start a line" do
      source = <<-END.strip_indent
        render :json => {:a => messages,
                         :b => :json}, :status => 404
        def example
          a(
            b: :c,
            d: e(
              f: g
            ), h: :i)
        end
      END
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(source)
    end
  end

  context 'always inspect last argument hash' do
    let(:cop_config) do
      {
        'EnforcedLastArgumentHashStyle' => 'always_inspect'
      }
    end

    it 'registers offense for misaligned keys in implicit hash' do
      inspect_source(cop, <<-END.strip_indent)
        func(a: 0,
          b: 1)
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers offense for misaligned keys in explicit hash' do
      inspect_source(cop, <<-END.strip_indent)
        func({a: 0,
          b: 1})
      END
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'always ignore last argument hash' do
    let(:cop_config) do
      {
        'EnforcedLastArgumentHashStyle' => 'always_ignore'
      }
    end

    it 'accepts misaligned keys in implicit hash' do
      expect_no_offenses(<<-END.strip_indent)
        func(a: 0,
          b: 1)
      END
    end

    it 'accepts misaligned keys in explicit hash' do
      expect_no_offenses(<<-END.strip_indent)
        func({a: 0,
          b: 1})
      END
    end
  end

  context 'ignore implicit last argument hash' do
    let(:cop_config) do
      {
        'EnforcedLastArgumentHashStyle' => 'ignore_implicit'
      }
    end

    it 'accepts misaligned keys in implicit hash' do
      expect_no_offenses(<<-END.strip_indent)
        func(a: 0,
          b: 1)
      END
    end

    it 'registers offense for misaligned keys in explicit hash' do
      inspect_source(cop, <<-END.strip_indent)
        func({a: 0,
          b: 1})
      END
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'ignore explicit last argument hash' do
    let(:cop_config) do
      {
        'EnforcedLastArgumentHashStyle' => 'ignore_explicit'
      }
    end

    it 'registers offense for misaligned keys in implicit hash' do
      inspect_source(cop, <<-END.strip_indent)
        func(a: 0,
          b: 1)
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts misaligned keys in explicit hash' do
      expect_no_offenses(<<-END.strip_indent)
        func({a: 0,
          b: 1})
      END
    end
  end

  let(:cop_config) do
    {
      'EnforcedHashRocketStyle' => 'key',
      'EnforcedColonStyle' => 'key'
    }
  end

  context 'with default configuration' do
    it 'registers an offense for misaligned hash keys' do
      inspect_source(cop, <<-END.strip_indent)
        hash1 = {
          a: 0,
           bb: 1
        }
        hash2 = {
          'ccc' => 2,
         'dddd'  =>  2
        }
      END
      expect(cop.messages).to eq(['Align the elements of a hash ' \
                                  'literal if they span more than ' \
                                  'one line.'] * 2)
      expect(cop.highlights).to eq(['bb: 1',
                                    "'dddd'  =>  2"])
    end

    it 'registers an offense for misaligned mixed multiline hash keys' do
      inspect_source(cop, <<-END.strip_indent)
        hash = { a: 1, b: 2,
                c: 3 }
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts aligned hash keys' do
      expect_no_offenses(<<-END.strip_indent)
        hash1 = {
          a: 0,
          bb: 1,
        }
        hash2 = {
          'ccc' => 2,
          'dddd'  =>  2
        }
      END
    end

    it 'registers an offense for separator alignment' do
      inspect_source(cop, <<-END.strip_indent)
        hash = {
            'a' => 0,
          'bbb' => 1
        }
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(["'bbb' => 1"])
    end

    context 'with implicit hash as last argument' do
      it 'registers an offense for misaligned hash keys' do
        inspect_source(cop, <<-END.strip_indent)
          func(a: 0,
            b: 1)
        END
        expect(cop.offenses.size).to eq(1)
      end

      it 'registers an offense for right alignment of keys' do
        inspect_source(cop, <<-END.strip_indent)
          func(a: 0,
             bbb: 1)
        END
        expect(cop.offenses.size).to eq(1)
      end

      it 'accepts aligned hash keys' do
        expect_no_offenses(<<-END.strip_indent)
          func(a: 0,
               b: 1)
        END
      end

      it 'accepts an empty hash' do
        expect_no_offenses('h = {}')
      end
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        hash1 = { a: 0,
             bb: 1,
                   ccc: 2 }
        hash2 = { :a   => 0,
             :bb  => 1,
                  :ccc  =>2 }
      END

      # Separator and value are not corrected in 'key' mode.
      expect(new_source).to eq(<<-END.strip_indent)
        hash1 = { a: 0,
                  bb: 1,
                  ccc: 2 }
        hash2 = { :a   => 0,
                  :bb  => 1,
                  :ccc  =>2 }
      END
    end

    it 'auto-corrects alignment for mixed multiline hash keys' do
      new_sources = autocorrect_source(cop, <<-END.strip_indent)
        hash = { a: 1, b: 2,
                c: 3 }
      END
      expect(new_sources).to eq(<<-END.strip_indent)
        hash = { a: 1, b: 2,
                 c: 3 }
      END
    end

    context 'ruby >= 2.0', :ruby20 do
      it 'auto-corrects alignment when using double splat ' \
         'in an explicit hash' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          Hash(foo: 'bar',
                 **extra_params
          )
        END

        expect(new_source).to eq(<<-END.strip_indent)
          Hash(foo: 'bar',
               **extra_params
          )
        END
      end

      it 'auto-corrects alignment when using double splat in braces' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          {foo: 'bar',
                 **extra_params
          }
        END

        expect(new_source).to eq(<<-END.strip_indent)
          {foo: 'bar',
           **extra_params
          }
        END
      end
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
      expect_no_offenses(<<-END.strip_indent)
        hash1 = {
          'a'   => 0,
          'bbb' => 1
        }
        hash2 = {
          a:   0,
          bbb: 1
        }
      END
    end

    it 'accepts an empty hash' do
      expect_no_offenses('h = {}')
    end

    it 'accepts a multiline array of single line hashes' do
      expect_no_offenses(<<-END.strip_indent)
        def self.scenarios_order
            [
              { before:   %w( l k ) },
              { ending:   %w( m l ) },
              { starting: %w( m n ) },
              { after:    %w( n o ) }
            ]
          end
      END
    end

    it 'accepts hashes that use different separators' do
      expect_no_offenses(<<-END.strip_indent)
        hash = {
          a: 1,
          'bbb' => 2
        }
      END
    end

    context 'ruby >= 2.0', :ruby20 do
      it 'accepts hashes that use different separators and double splats' do
        expect_no_offenses(<<-END.strip_indent)
          hash = {
            a: 1,
            'bbb' => 2,
            **foo
          }
        END
      end

      it 'accepts hashes that use different separators and double splats' do
        expect_no_offenses(<<-END.strip_indent)
          hash = {
            a: 1,
            **kw
          }
        END
      end
    end

    it 'registers an offense for misaligned hash values' do
      inspect_source(cop, <<-END.strip_indent)
        hash1 = {
          'a'   =>  0,
          'bbb' => 1
        }
        hash2 = {
          a:   0,
          bbb:1
        }
      END
      expect(cop.highlights).to eq(["'a'   =>  0",
                                    'bbb:1'])
    end

    it 'registers an offense for misaligned hash keys' do
      inspect_source(cop, <<-END.strip_indent)
        hash1 = {
          'a'   =>  0,
         'bbb'  =>  1
        }
        hash2 = {
           a:  0,
          bbb: 1
        }
      END
      expect(cop.highlights).to eq(["'a'   =>  0",
                                    "'bbb'  =>  1",
                                    'a:  0',
                                    'bbb: 1'])
    end

    it 'registers an offense for misaligned hash rockets' do
      inspect_source(cop, <<-END.strip_indent)
        hash = {
          'a'   => 0,
          'bbb'  => 1
        }
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        hash1 = { a: 0,
             bb:   1,
                   ccc: 2 }
        hash2 = { 'a' => 0,
             'bb' =>   1,
                   'ccc'  =>2 }
      END
      expect(new_source).to eq(<<-END.strip_indent)
        hash1 = { a:   0,
                  bb:  1,
                  ccc: 2 }
        hash2 = { 'a'   => 0,
                  'bb'  => 1,
                  'ccc' => 2 }
      END
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
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'junk',
        'EnforcedColonStyle' => 'junk'
      }
    end
    it 'fails' do
      src = <<-END.strip_indent
        hash = {
          a: 0,
          bb: 1
        }
      END
      expect { inspect_source(cop, src) }.to raise_error(RuntimeError)
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
      expect_no_offenses(<<-END.strip_indent)
        hash1 = {
            a: 0,
          bbb: 1
        }
        hash2 = {
            'a' => 0,
          'bbb' => 1
        }
      END
    end

    it 'accepts an empty hash' do
      expect_no_offenses('h = {}')
    end

    it 'registers an offense for misaligned hash values' do
      inspect_source(cop, <<-END.strip_indent)
        hash = {
            'a' =>  0,
          'bbb' => 1
        }
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for misaligned hash rockets' do
      inspect_source(cop, <<-END.strip_indent)
        hash = {
            'a'  => 0,
          'bbb' =>  1
        }
      END
      expect(cop.offenses.size).to eq(1)
    end

    context 'ruby >= 2.0', :ruby20 do
      it 'accepts hashes with different separators' do
        expect_no_offenses(<<-END.strip_indent)
          {a: 1,
            'b' => 2,
             **params}
        END
      end
    end

    include_examples 'not on separate lines'

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        hash1 = { a: 0,
             bb:    1,
                   ccc: 2 }
        hash2 = { a => 0,
             bb =>    1,
                   ccc  =>2 }
      END
      expect(new_source).to eq(<<-END.strip_indent)
        hash1 = { a: 0,
                 bb: 1,
                ccc: 2 }
        hash2 = { a => 0,
                 bb => 1,
                ccc => 2 }
      END
    end

    it "doesn't break code by moving long keys too far left" do
      # regression test; see GH issue 2582
      new_source = autocorrect_source(cop, ['{',
                                            '  sjtjo: sjtjo,',
                                            '  too_ono_ilitjion_tofotono_o: ' \
                                            'too_ono_ilitjion_tofotono_o,',
                                            '}'])
      expect(new_source).to eq(['{',
                                '  sjtjo: sjtjo,',
                                'too_ono_ilitjion_tofotono_o: ' \
                                'too_ono_ilitjion_tofotono_o,',
                                '}'].join("\n"))
    end
  end

  context 'with different settings for => and :' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'key',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'registers offenses for misaligned entries' do
      inspect_source(cop, <<-END.strip_indent)
        hash1 = {
          a:   0,
          bbb: 1
        }
        hash2 = {
            'a' => 0,
          'bbb' => 1
        }
      END
      expect(cop.highlights).to eq(['bbb: 1', "'bbb' => 1"])
    end

    it 'accepts aligned entries' do
      expect_no_offenses(<<-END.strip_indent)
        hash1 = {
            a: 0,
          bbb: 1
        }
        hash2 = {
          'a' => 0,
          'bbb' => 1
        }
      END
    end
  end
end
