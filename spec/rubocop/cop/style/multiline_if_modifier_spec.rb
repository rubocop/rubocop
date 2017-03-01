# frozen_string_literal: true

describe RuboCop::Cop::Style::MultilineIfModifier do
  subject(:cop) { described_class.new }

  shared_examples 'offense' do |modifier|
    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(["Favor a normal #{modifier}-statement over a modifier" \
                ' clause in a multiline statement.'])
    end
  end

  shared_examples 'no offense' do
    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.messages).to be_empty
    end
  end

  shared_examples 'autocorrect' do |correct_code|
    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(correct_code)
    end
  end

  context 'if guard clause' do
    let(:source) do
      [
        '{',
        '  result: run',
        '} if cond'
      ].join("\n")
    end

    include_examples 'offense', 'if'
    include_examples 'autocorrect', "if cond\n  {\n    result: run\n  }\nend"

    context 'one liner' do
      let(:source) { 'run if cond' }

      include_examples 'no offense'
    end

    context 'multiline condition' do
      let(:source) { "run if cond &&\n       cond2" }

      include_examples 'no offense'
    end

    context 'indented offense' do
      let(:source) do
        [
          '  {',
          '    result: run',
          '  } if cond'
        ].join("\n")
      end

      include_examples 'autocorrect', "  if cond\n" \
                                      "    {\n" \
                                      "      result: run\n" \
                                      "    }\n" \
                                      '  end'
    end
  end

  context 'unless guard clause' do
    let(:source) do
      [
        '{',
        '  result: run',
        '} unless cond'
      ].join("\n")
    end

    include_examples 'offense', 'unless'
    include_examples 'autocorrect', "unless cond\n" \
                                    "  {\n" \
                                    "    result: run\n" \
                                    "  }\n" \
                                    'end'

    context 'one liner' do
      let(:source) { 'run unless cond' }

      include_examples 'no offense'
    end

    context 'multiline condition' do
      let(:source) { "run unless cond &&\n           cond2" }

      include_examples 'no offense'
    end

    context 'indented offense' do
      let(:source) do
        [
          '  {',
          '    result: run',
          '  } unless cond'
        ].join("\n")
      end

      include_examples 'autocorrect', "  unless cond\n" \
                                      "    {\n" \
                                      "      result: run\n" \
                                      "    }\n" \
                                      '  end'
    end
  end
end
