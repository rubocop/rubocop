# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::PluralizationGrammar do
  subject(:cop) { described_class.new }
  before(:each) do
    inspect_source(cop, source)
  end

  shared_examples 'enforces pluralization grammar' do |method_name|
    context "When #{method_name} is called on an unknown variable" do
      context "when using the plural form ##{method_name}s" do
        let(:source) { "some_variable.#{method_name}s" }
        it 'does not register an offense' do
          expect(cop.offenses).to be_empty
        end
      end

      context "when using the singular form ##{method_name}" do
        let(:source) { "some_method.#{method_name}" }

        it 'does not register an offense' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    [1, 1.0].each do |singular_literal|
      context "when mis-pluralizing #{method_name} with #{singular_literal}" do
        let(:source) { "#{singular_literal}.#{method_name}s.ago" }
        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.highlights).to eq(["#{singular_literal}.#{method_name}s"])
          expect(cop.messages).to eq(
            ["Prefer `#{singular_literal}.#{method_name}`."]
          )
        end

        it 'autocorrects to be grammatically correct' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq("#{singular_literal}.#{method_name}.ago")
        end
      end

      context "when using the singular form ##{method_name}" do
        let(:source) { "#{singular_literal}.#{method_name}" }
        it 'does not register an offense' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context "when #{method_name} is called on any other literal number" do
      [-rand(2..1000),
       rand(-1.0...0),
       -1,
       0,
       rand(0...1.0),
       rand(2..1000)].each do |plural_number|
        context "when using the plural form ##{method_name}s" do
          let(:source) { "#{plural_number}.#{method_name}s" }
          it 'does not register an offense' do
            expect(cop.offenses).to be_empty
          end
        end

        context "when using the singular form ##{method_name}" do
          let(:source) { "#{plural_number}.#{method_name}.from_now" }
          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.highlights).to eq(["#{plural_number}.#{method_name}"])
            expect(cop.messages).to eq(
              ["Prefer `#{plural_number}.#{method_name}s`."]
            )
          end

          it 'autocorrects to be grammatically correct' do
            new_source = autocorrect_source(cop, source)
            expect(new_source)
              .to eq("#{plural_number}.#{method_name}s.from_now")
          end
        end
      end
    end
  end

  it_behaves_like 'enforces pluralization grammar', 'second'
  it_behaves_like 'enforces pluralization grammar', 'minute'
  it_behaves_like 'enforces pluralization grammar', 'hour'
  it_behaves_like 'enforces pluralization grammar', 'day'
  it_behaves_like 'enforces pluralization grammar', 'week'
  it_behaves_like 'enforces pluralization grammar', 'fortnight'
  it_behaves_like 'enforces pluralization grammar', 'month'
  it_behaves_like 'enforces pluralization grammar', 'year'
end
