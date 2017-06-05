# frozen_string_literal: true

describe RuboCop::Cop::Style::MultilineMemoization, :config do
  subject(:cop) { described_class.new(config) }
  let(:message) { 'Wrap multiline memoization blocks in `begin` and `end`.' }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, expected|
    let(:source) { code }

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([message])
    end

    it 'auto-corrects' do
      expect(autocorrect_source(cop, code)).to eq(expected)
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'with all enforced styles' do
    context 'with a single line memoization' do
      it_behaves_like 'code without offense',
                      'foo ||= bar'

      it_behaves_like 'code without offense', <<-END.strip_indent
        foo ||=
          bar
      END
    end

    context 'with a multiline memoization' do
      context 'without a `begin` and `end` block' do
        context 'when there is another block on the first line' do
          it_behaves_like 'code without offense', <<-END.strip_indent
            foo ||= bar.each do |b|
              b.baz
              bb.ax
            end
          END
        end

        context 'when there is another block on the following line' do
          it_behaves_like 'code without offense', <<-END.strip_indent
            foo ||=
              bar.each do |b|
                b.baz
                b.bax
              end
          END
        end

        context 'when there is a conditional on the first line' do
          it_behaves_like 'code without offense', <<-END.strip_indent
            foo ||= if bar
                      baz
                    else
                      bax
                    end
          END
        end

        context 'when there is a conditional on the following line' do
          it_behaves_like 'code without offense', <<-END.strip_indent
            foo ||=
              if bar
                baz
              else
                bax
              end
          END
        end
      end
    end
  end

  context 'EnforcedStyle: keyword' do
    let(:cop_config) { { 'EnforcedStyle' => 'keyword' } }
    include_examples 'with all enforced styles'

    context 'with a multiline memoization' do
      context 'without a `begin` and `end` block' do
        context 'when the expression is wrapped in parentheses' do
          it_behaves_like 'code with offense',
                          <<-END.strip_indent,
                            foo ||= (
                              bar
                              baz
                            )
                          END
                          <<-END.strip_indent
                            foo ||= begin
                              bar
                              baz
                            end
                          END

          it_behaves_like 'code with offense',
                          <<-END.strip_indent,
                            foo ||=
                              (
                                bar
                                baz
                              )
                          END
                          <<-END.strip_indent
                            foo ||=
                              begin
                                bar
                                baz
                              end
                          END

          it_behaves_like 'code with offense',
                          <<-END.strip_indent,
                            foo ||= (bar ||
                                     baz)
                          END
                          <<-END.strip_indent
                            foo ||= begin
                                    bar ||
                                     baz
                                    end
                          END
        end
      end

      context 'with a `begin` and `end` block on the first line' do
        it_behaves_like 'code without offense', <<-END.strip_indent
          foo ||= begin
            bar
            baz
          end
        END
      end

      context 'with a `begin` and `end` block on the following line' do
        it_behaves_like 'code without offense', <<-END.strip_indent
          foo ||=
            begin
            bar
            baz
          end
        END
      end
    end
  end

  context 'EnforcedStyle: braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }
    include_examples 'with all enforced styles'

    context 'with a multiline memoization' do
      context 'without braces' do
        context 'when the expression is wrapped in' \
                ' `begin` and `end` keywords' do
          it_behaves_like 'code with offense',
                          <<-END.strip_indent,
                            foo ||= begin
                              bar
                              baz
                            end
                          END
                          <<-END.strip_indent
                            foo ||= (
                              bar
                              baz
                            )
                          END

          it_behaves_like 'code with offense',
                          <<-END.strip_indent,
                            foo ||=
                              begin
                                bar
                                baz
                              end
                          END
                          <<-END.strip_indent
                            foo ||=
                              (
                                bar
                                baz
                              )
                          END
        end
      end

      context 'with parentheses on the first line' do
        it_behaves_like 'code without offense', <<-END.strip_indent
          foo ||= (
            bar
            baz
          )
        END
      end

      context 'with parentheses block on the following line' do
        it_behaves_like 'code without offense', <<-END.strip_indent
          foo ||=
            (
            bar
            baz
          )
        END
      end
    end
  end
end
