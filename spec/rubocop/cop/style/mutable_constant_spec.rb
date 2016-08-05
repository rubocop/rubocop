# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MutableConstant do
  subject(:cop) { described_class.new }

  let(:prefix) { nil }

  shared_examples :mutable_objects do |o|
    context 'when assigning with =' do
      it "registers an offense for #{o} assigned to a constant" do
        source = [prefix, "CONST = #{o}"].compact.join("\n")
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'auto-corrects by adding .freeze' do
        source = [prefix, "CONST = #{o}"].compact.join("\n")
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("#{source}.freeze")
      end
    end

    context 'when assigning with ||=' do
      it "registers an offense for #{o} assigned to a constant" do
        source = [prefix, "CONST ||= #{o}"].compact.join("\n")
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'auto-corrects by adding .freeze' do
        source = [prefix, "CONST ||= #{o}"].compact.join("\n")
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq("#{source}.freeze")
      end
    end
  end

  it_behaves_like :mutable_objects, '[1, 2, 3]'
  it_behaves_like :mutable_objects, '{ a: 1, b: 2 }'
  it_behaves_like :mutable_objects, "'str'"
  it_behaves_like :mutable_objects, '"top#{1 + 2}"'

  shared_examples :immutable_objects do |o|
    it "allows #{o} to be assigned to a constant" do
      source = [prefix, "CONST = #{o}"].compact.join("\n")
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it "allows #{o} to be ||= to a constant" do
      source = [prefix, "CONST ||= #{o}"].compact.join("\n")
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like :immutable_objects, '1'
  it_behaves_like :immutable_objects, '1.5'
  it_behaves_like :immutable_objects, ':sym'

  it 'allows method call assignments' do
    inspect_source(cop, 'TOP_TEST = Something.new')
    expect(cop.offenses).to be_empty
  end

  context 'when performing a splat assignment' do
    it 'allows an immutable value' do
      inspect_source(cop, 'FOO = *(1...10)')
      expect(cop.offenses).to be_empty
    end

    it 'allows a frozen array value' do
      inspect_source(cop, 'FOO = *[1...10].freeze')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a mutable value' do
      source = 'BAR = *[1, 2, 3]'

      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)

      corrected = autocorrect_source(cop, source)

      expect(corrected).to eq('BAR = *[1, 2, 3].freeze')
    end
  end

  context 'when assigning an array without brackets' do
    it 'adds brackets when auto-correcting' do
      new_source = autocorrect_source(cop, 'XXX = YYY, ZZZ')
      expect(new_source).to eq 'XXX = [YYY, ZZZ].freeze'
    end
  end

  context 'when the constant is a frozen string literal' do
    context 'when the target ruby version >= 3.0' do
      let(:ruby_version) { 3.0 }

      context 'when the frozen string literal comment is missing' do
        it_behaves_like :immutable_objects, '"#{a}"'
      end

      context 'when the frozen string literal comment is true' do
        let(:prefix) { '# frozen_string_literal: true' }
        it_behaves_like :immutable_objects, '"#{a}"'
      end

      context 'when the frozen string literal comment is false' do
        let(:prefix) { '# frozen_string_literal: false' }
        it_behaves_like :immutable_objects, '"#{a}"'
      end
    end if RuboCop::Config::KNOWN_RUBIES.include?(3.0)

    context 'when the target ruby version >= 2.3' do
      let(:ruby_version) { 2.3 }

      context 'when the frozen string literal comment is missing' do
        it_behaves_like :mutable_objects, '"#{a}"'
      end

      context 'when the frozen string literal comment is true' do
        let(:prefix) { '# frozen_string_literal: true' }
        it_behaves_like :immutable_objects, '"#{a}"'
      end

      context 'when the frozen string literal comment is false' do
        let(:prefix) { '# frozen_string_literal: false' }
        it_behaves_like :mutable_objects, '"#{a}"'
      end
    end
  end
end
