# frozen_string_literal: true

# `cop` and `source` must be declared with #let.

shared_examples_for 'accepts' do
  it 'accepts' do
    inspect_source(source)
    expect(cop.offenses).to be_empty
  end
end

shared_examples_for 'mimics MRI 2.1' do |grep_mri_warning|
  if RUBY_ENGINE == 'ruby' && RUBY_VERSION.start_with?('2.1')
    it "mimics MRI #{RUBY_VERSION} built-in syntax checking" do
      inspect_source(source)
      offenses_by_mri = MRISyntaxChecker.offenses_for_source(
        source, cop.name, grep_mri_warning
      )

      # Compare objects before comparing counts for clear failure output.
      cop.offenses.each_with_index do |offense_by_cop, index|
        offense_by_mri = offenses_by_mri[index]
        # Exclude column attribute since MRI does not
        # output column number.
        %i[severity line cop_name].each do |a|
          expect(offense_by_cop.send(a)).to eq(offense_by_mri.send(a))
        end
      end

      expect(cop.offenses.count).to eq(offenses_by_mri.count)
    end
  end
end

shared_examples_for 'misaligned' do |prefix, alignment_base, arg, end_kw, name|
  name ||= alignment_base
  source = ["#{prefix}#{alignment_base} #{arg}",
            end_kw]

  it "registers an offense for mismatched #{name} ... end" do
    inspect_source(source)
    expect(cop.offenses.size).to eq(1)
    base_regexp = Regexp.escape(alignment_base)
    regexp = /`end` at 2, \d+ is not aligned with `#{base_regexp}` at 1,/
    expect(cop.messages.first).to match(regexp)
    expect(cop.highlights.first).to eq('end')

    other_styles = (cop.supported_styles - [cop.style]).map(&:to_s)
    # In some cases, the code under test will happen to match an alternative
    # style. In other cases, it won't match any style at all
    expect(cop.config_to_allow_offenses).to(
      eq('Enabled' => false).or(
        satisfy { |h| other_styles.include?(h['EnforcedStyleAlignWith']) }
      )
    )
  end

  it "auto-corrects mismatched #{name} ... end" do
    aligned_source = ["#{prefix}#{alignment_base} #{arg}",
                      "#{' ' * prefix.length}#{end_kw.strip}"].join("\n")
    corrected = autocorrect_source(cop, source)
    expect(corrected).to eq(aligned_source)
  end
end

shared_examples_for 'aligned' do |alignment_base, arg, end_kw, name|
  name ||= alignment_base
  name = name.gsub(/\n/, ' <newline>')
  it "accepts matching #{name} ... end" do
    inspect_source(["#{alignment_base} #{arg}",
                    end_kw])
    expect(cop.offenses).to be_empty
  end
end

shared_examples_for 'debugger' do |name, src|
  it "reports an offense for a #{name} call" do
    inspect_source(src)
    src = [src] if src.is_a? String
    expect(cop.offenses.size).to eq(src.size)
    expect(cop.messages)
      .to eq(src.map { |s| "Remove debugger entry point `#{s}`." })
    expect(cop.highlights).to eq(src)
  end
end

shared_examples_for 'non-debugger' do |name, src|
  it "does not report an offense for #{name}" do
    inspect_source(src)
    expect(cop.offenses).to be_empty
  end
end
