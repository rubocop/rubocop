# frozen_string_literal: true

# `cop` and `source` must be declared with #let.

RSpec.shared_examples_for 'misaligned' do |annotated_source, used_style|
  config_to_allow_offenses = if used_style
                               { 'EnforcedStyleAlignWith' => used_style.to_s }
                             else
                               { 'Enabled' => false }
                             end
  annotated_source.strip_indent.split(/\n\n/).each do |chunk|
    chunk << "\n" unless chunk.end_with?("\n")
    source = chunk.lines.reject { |line| line =~ /^ *\^/ }.join
    name = source.gsub(/\n(?=[a-z ])/, ' <newline> ').gsub(/\s+/, ' ')

    it "registers an offense for mismatched #{name}" do
      expect_offense(chunk)
      expect(cop.config_to_allow_offenses).to eq(config_to_allow_offenses)
    end

    it "auto-corrects mismatched #{name}" do
      raise if chunk !~
               /\^\^\^ `end` at (\d), \d is not aligned with `.*` at \d, (\d)./

      line_index = Integer(Regexp.last_match(1)) - 1
      correct_indentation = ' ' * Integer(Regexp.last_match(2))
      expect(autocorrect_source(source))
        .to eq(source.lines[0...line_index].join +
               "#{correct_indentation}#{source.lines[line_index].strip}\n")
    end
  end
end

RSpec.shared_examples_for 'aligned' do |alignment_base, arg, end_kw, name|
  name ||= alignment_base
  name = name.gsub(/\n/, ' <newline>')
  it "accepts matching #{name} ... end" do
    inspect_source("#{alignment_base} #{arg}\n#{end_kw}")
    expect(cop.offenses).to be_empty
  end
end

RSpec.shared_examples_for 'debugger' do |name, src|
  it "reports an offense for a #{name} call" do
    inspect_source(src)
    src = [src] if src.is_a? String
    expect(cop.offenses.size).to eq(src.size)
    expect(cop.messages)
      .to eq(src.map { |s| "Remove debugger entry point `#{s}`." })
    expect(cop.highlights).to eq(src)
  end
end

RSpec.shared_examples_for 'non-debugger' do |name, src|
  it "does not report an offense for #{name}" do
    inspect_source(src)
    expect(cop.offenses).to be_empty
  end
end
