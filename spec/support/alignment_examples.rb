# frozen_string_literal: true

# `cop` and `source` must be declared with #let.

RSpec.shared_examples_for 'misaligned' do |annotated_source, used_style|
  config_to_allow_offenses = if used_style
                               { 'EnforcedStyleAlignWith' => used_style.to_s }
                             else
                               { 'Enabled' => false }
                             end
  annotated_source.split("\n\n").each do |chunk|
    chunk << "\n" unless chunk.end_with?("\n")
    source = chunk.lines.grep_v(/^ *\^/).join
    name = source.gsub(/\n(?=[a-z ])/, ' <newline> ').gsub(/\s+/, ' ')

    it "registers an offense for mismatched #{name} and autocorrects" do
      expect_offense(chunk)
      expect(cop.config_to_allow_offenses).to eq(config_to_allow_offenses)

      raise if chunk !~ /\^\^\^ `end` at (\d), \d is not aligned with `.*` at \d, (\d)./

      line_index = Integer(Regexp.last_match(1)) - 1
      correct_indentation = ' ' * Integer(Regexp.last_match(2))
      expect_correction(
        source.lines[0...line_index].join +
        "#{correct_indentation}#{source.lines[line_index].strip}\n"
      )
    end
  end
end

RSpec.shared_examples_for 'aligned' do |alignment_base, arg, end_kw, name|
  name ||= alignment_base
  name = name.gsub(/\n/, ' <newline>')
  it "accepts matching #{name} ... end" do
    expect_no_offenses("#{alignment_base} #{arg}\n#{end_kw}")
  end
end
