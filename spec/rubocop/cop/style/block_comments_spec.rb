# frozen_string_literal: true

describe RuboCop::Cop::Style::BlockComments do
  subject(:cop) { described_class.new }

  it 'registers an offense for block comments' do
    inspect_source(cop, <<-END.strip_indent)
      =begin
      comment
      =end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts regular comments' do
    inspect_source(cop,
                   '# comment')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects a block comment into a regular comment' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      =begin
      comment line 1

      comment line 2
      =end
      def foo
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      # comment line 1
      #
      # comment line 2
      def foo
      end
    END
  end

  it 'auto-corrects an empty block comment by removing it' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      =begin
      =end
      def foo
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def foo
      end
    END
  end
end
