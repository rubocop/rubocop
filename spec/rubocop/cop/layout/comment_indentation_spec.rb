# frozen_string_literal: true

describe RuboCop::Cop::Layout::CommentIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config
      .new('Layout/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }

  context 'on outer level' do
    it 'accepts a correctly indented comment' do
      expect_no_offenses('# comment')
    end

    it 'accepts a comment that follows code' do
      expect_no_offenses('hello # comment')
    end

    it 'accepts a documentation comment' do
      inspect_source(cop, <<-END.strip_indent)
        =begin
        Doc comment
        =end
          hello
         #
        hi
      END
      expect(cop.highlights).to eq(['#'])
    end

    it 'registers an offense for an incorrectly indented (1) comment' do
      inspect_source(cop, ' # comment')
      expect(cop.messages)
        .to eq(['Incorrect indentation detected (column 1 instead of 0).'])
      expect(cop.highlights).to eq(['# comment'])
    end

    it 'registers an offense for an incorrectly indented (2) comment' do
      inspect_source(cop, '  # comment')
      expect(cop.messages)
        .to eq(['Incorrect indentation detected (column 2 instead of 0).'])
    end

    it 'registers an offense for each incorrectly indented comment' do
      inspect_source(cop, <<-END.strip_indent)
        # a
          # b
            # c
        # d
        def test; end
      END
      expect(cop.messages)
        .to eq(['Incorrect indentation detected (column 0 instead of 2).',
                'Incorrect indentation detected (column 2 instead of 4).',
                'Incorrect indentation detected (column 4 instead of 0).'])
    end
  end

  it 'registers offenses before __END__ but not after' do
    inspect_source(cop, <<-END.strip_indent)
       #
      __END__
        #
    END
    expect(cop.messages)
      .to eq(['Incorrect indentation detected (column 1 instead of 0).'])
  end

  context 'around program structure keywords' do
    it 'accepts correctly indented comments' do
      inspect_source(cop, <<-END.strip_indent)
        #
        def m
          #
          if a
            #
            b
          # this is accepted
          elsif aa
            # this is accepted
          else
            #
          end
          #
          case a
          # this is accepted
          when 0
            #
            b
          end
          # this is accepted
        rescue
        # this is accepted
        ensure
          #
        end
        #
      END
      expect(cop.offenses).to eq([])
    end

    context 'with a blank line following the comment' do
      it 'accepts a correctly indented comment' do
        expect_no_offenses(<<-END.strip_indent)
          def m
            # comment

          end
        END
      end
    end
  end

  context 'near various kinds of brackets' do
    it 'accepts correctly indented comments' do
      inspect_source(cop, <<-END.strip_indent)
        #
        a = {
          #
          x: [
            1
            #
          ],
          #
          y: func(
            1
            #
          )
          #
        }
        #
      END
      expect(cop.offenses).to eq([])
    end

    it 'is unaffected by closing bracket that does not begin a line' do
      inspect_source(cop, <<-END.strip_indent)
        #
        result = []
      END
      expect(cop.messages).to eq([])
    end
  end

  it 'auto-corrects' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
       # comment
      hash1 = { a: 0,
           # comment
                bb: 1,
                ccc: 2 }
        if a
        #
          b
        # this is accepted
        elsif aa
          # so is this
        elsif bb
      #
        else
         #
        end
        case a
        # this is accepted
        when 0
          # so is this
        when 1
           #
          b
        end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      # comment
      hash1 = { a: 0,
                # comment
                bb: 1,
                ccc: 2 }
        if a
          #
          b
        # this is accepted
        elsif aa
          # so is this
        elsif bb
        #
        else
          #
        end
        case a
        # this is accepted
        when 0
          # so is this
        when 1
          #
          b
        end
    END
  end
end
