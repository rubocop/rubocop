# encoding: utf-8

# `cop` and `source` must be declared with #let.

shared_examples_for 'accepts' do
  it 'accepts' do
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end

shared_examples_for 'mimics MRI 2.1' do |grep_mri_warning|
  if RUBY_ENGINE == 'ruby' && RUBY_VERSION.start_with?('2.1')
    it "mimics MRI #{RUBY_VERSION} built-in syntax checking" do
      inspect_source(cop, source)
      offenses_by_mri = MRISyntaxChecker.offenses_for_source(
        source, cop.name, grep_mri_warning
      )

      # Compare objects before comparing counts for clear failure output.
      cop.offenses.each_with_index do |offense_by_cop, index|
        offense_by_mri = offenses_by_mri[index]
        # Exclude column attribute since MRI does not
        # output column number.
        [:severity, :line, :cop_name].each do |a|
          expect(offense_by_cop.send(a)).to eq(offense_by_mri.send(a))
        end
      end

      expect(cop.offenses.count).to eq(offenses_by_mri.count)
    end
  end
end
