# frozen_string_literal: true

describe RuboCop::Cop::Lint::FloatOutOfRange do
  subject(:cop) { described_class.new }

  context 'on 0.0' do
    let(:source) { '0.0' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on tiny little itty bitty floats' do
    let(:source) { '1.1e-100' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on respectably sized floats' do
    let(:source) { '55.7e89' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on whopping big floats which tip the scales' do
    let(:source) { '9.9999e999' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        9.9999e999
        ^^^^^^^^^^ Float out of range.
      RUBY
    end
  end

  context 'on floats so close to zero that nobody can tell the difference' do
    let(:source) { '1.0e-400' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        1.0e-400
        ^^^^^^^^ Float out of range.
      RUBY
    end
  end
end
