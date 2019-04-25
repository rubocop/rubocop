# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionMethodsFilter, :config do
  cop_config = {
    'PreferredMethods' => {
      'select' => 'filter',
      'find_all' => 'filter'
    }
  }

  subject(:cop) { described_class.new(config) }

  let(:cop_config) { cop_config }

  cop_config['PreferredMethods'].each do |method, preferred_method|
    context 'target ruby version >= 2.6', :ruby26 do
      it "registers an offense for #{method} with block" do
        inspect_source("[1, 2, 3].#{method} { |e| e + 1 }")

        expect(cop.messages)
          .to eq(["Prefer `#{preferred_method}` over `#{method}`."])
      end

      it "registers an offense for #{method} with proc param" do
        inspect_source("[1, 2, 3].#{method}(&:test)")

        expect(cop.messages)
          .to eq(["Prefer `#{preferred_method}` over `#{method}`."])
      end

      it "accepts #{method} with more than 1 param" do
        expect_no_offenses(<<-RUBY.strip_indent)
          [1, 2, 3].#{method}(other, &:test)
        RUBY
      end

      it "accepts #{method} without a block" do
        expect_no_offenses(<<-RUBY.strip_indent)
          [1, 2, 3].#{method}
        RUBY
      end

      it 'auto-corrects to preferred method' do
        new_source = autocorrect_source("some.#{method}(&:test)")
        expect(new_source).to eq("some.#{preferred_method}(&:test)")
      end
    end

    context 'target ruby version < 2.6', :ruby25 do
      it "does not register an offense for #{method} with block" do
        inspect_source("[1, 2, 3].#{method} { |e| e + 1 }")

        expect(cop.offenses.size).to eq(0)
      end

      it "does not register an offense for #{method} with proc param" do
        inspect_source("[1, 2, 3].#{method}(&:test)")

        expect(cop.offenses.size).to eq(0)
      end
    end
  end
end
