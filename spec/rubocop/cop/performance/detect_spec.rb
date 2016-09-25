# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::Detect do
  subject(:cop) { described_class.new(config) }

  let(:collection_method) { nil }

  let(:config) do
    RuboCop::Config.new(
      'Style/CollectionMethods' => {
        'PreferredMethods' => {
          'detect' => collection_method
        }
      }
    )
  end

  described_class::SELECT_METHODS.each do |method|
    it "registers an offense when first is called on #{method}" do
      inspect_source(cop, "[1, 2, 3].#{method} { |i| i % 2 == 0 }.first")

      expect(cop.messages)
        .to eq(["Use `detect` instead of `#{method}.first`."])
    end

    it "doesn't register an offense when first(n) is called on #{method}" do
      inspect_source(cop, "[1, 2, 3].#{method} { |i| i % 2 == 0 }.first(n)")
      expect(cop.offenses).to be_empty
    end

    it "registers an offense when last is called on #{method}" do
      inspect_source(cop, "[1, 2, 3].#{method} { |i| i % 2 == 0 }.last")

      expect(cop.messages)
        .to eq(["Use `reverse.detect` instead of `#{method}.last`."])
    end

    it "doesn't register an offense when last(n) is called on #{method}" do
      inspect_source(cop, "[1, 2, 3].#{method} { |i| i % 2 == 0 }.last(n)")
      expect(cop.offenses).to be_empty
    end

    it "registers an offense when first is called on multiline #{method}" do
      inspect_source(
        cop, %(
        [1, 2, 3].#{method} do
          |i| i % 2 == 0
        end.first)
      )

      expect(cop.messages)
        .to eq(["Use `detect` instead of `#{method}.first`."])
    end

    it "registers an offense when first is called on multiline #{method}" do
      inspect_source(
        cop, %(
        [1, 2, 3].#{method} do
          |i| i % 2 == 0
        end.last)
      )

      expect(cop.messages)
        .to eq(["Use `reverse.detect` instead of `#{method}.last`."])
    end

    it "registers an offense when first is called on #{method} short syntax" do
      inspect_source(cop, "[1, 2, 3].#{method}(&:even?).first")

      expect(cop.messages)
        .to eq(["Use `detect` instead of `#{method}.first`."])
    end

    it "registers an offense when last is called on #{method} short syntax" do
      inspect_source(cop, "[1, 2, 3].#{method}(&:even?).last")

      expect(cop.messages)
        .to eq(["Use `reverse.detect` instead of `#{method}.last`."])
    end

    it "registers an offense when #{method} is called" \
       'on `lazy` without receiver' do
      inspect_source(cop, "lazy.#{method}(&:even?).first")

      expect(cop.messages)
        .to eq(["Use `detect` instead of `#{method}.first`."])
    end

    it "does not register an offense when #{method} is used " \
       'without first or last' do
      inspect_source(cop, "[1, 2, 3].#{method} { |i| i % 2 == 0 }")

      expect(cop.messages).to be_empty
    end

    it "does not register an offense when #{method} is called" \
       'without block or args' do
      inspect_source(cop, "adapter.#{method}.first")

      expect(cop.messages).to be_empty
    end

    it "does not register an offense when #{method} is called" \
       'with args but without ampersand syntax' do
      inspect_source(cop, "adapter.#{method}('something').first")

      expect(cop.messages).to be_empty
    end

    it "does not register an offense when #{method} is called" \
       'on lazy enumerable' do
      inspect_source(cop, "adapter.lazy.#{method} { 'something' }.first")

      expect(cop.messages).to be_empty
    end
  end

  it 'does not register an offense when detect is used' do
    inspect_source(cop, '[1, 2, 3].detect { |i| i % 2 == 0 }')

    expect(cop.messages).to be_empty
  end

  context 'autocorrect' do
    shared_examples 'detect_autocorrect' do |preferred_method|
      context "with #{preferred_method}" do
        let(:collection_method) { preferred_method }
        described_class::SELECT_METHODS.each do |method|
          it "corrects #{method}.first to #{preferred_method} (with block)" do
            new_source = autocorrect_source(
              cop,
              "[1, 2, 3].#{method} { |i| i % 2 == 0 }.first"
            )

            expect(new_source).to eq(
              "[1, 2, 3].#{preferred_method} { |i| i % 2 == 0 }"
            )
          end

          it "corrects #{method}.last to reverse.#{preferred_method} " \
             '(with block)' do
            new_source = autocorrect_source(
              cop,
              "[1, 2, 3].#{method} { |i| i % 2 == 0 }.last"
            )

            expect(new_source).to eq(
              "[1, 2, 3].reverse.#{preferred_method} { |i| i % 2 == 0 }"
            )
          end

          it "corrects #{method}.first to #{preferred_method} (short syntax)" do
            new_source = autocorrect_source(
              cop,
              "[1, 2, 3].#{method}(&:even?).first"
            )

            expect(new_source).to eq("[1, 2, 3].#{preferred_method}(&:even?)")
          end

          it "corrects #{method}.last to reverse.#{preferred_method} " \
             '(short syntax)' do
            new_source = autocorrect_source(
              cop,
              "[1, 2, 3].#{method}(&:even?).last"
            )

            expect(new_source)
              .to eq("[1, 2, 3].reverse.#{preferred_method}(&:even?)")
          end

          it "corrects #{method}.first to #{preferred_method} (multiline)" do
            new_source = autocorrect_source(
              cop,
              %([1, 2, 3].#{method} do
                  |i| i % 2 == 0
                end.first)
            )

            expect(new_source).to eq(
              %([1, 2, 3].#{preferred_method} do
                  |i| i % 2 == 0
                end)
            )
          end

          it "corrects #{method}.last to reverse.#{preferred_method} " \
             '(multiline)' do
            new_source = autocorrect_source(
              cop,
              %([1, 2, 3].#{method} do
                  |i| i % 2 == 0
                end.last)
            )

            expect(new_source).to eq(
              %([1, 2, 3].reverse.#{preferred_method} do
                  |i| i % 2 == 0
                end)
            )
          end

          it "corrects multiline #{method} to #{preferred_method} " \
             'with \'first\' on the last line' do
            new_source = autocorrect_source(
              cop,
              %([1, 2, 3].#{method} { true }
                         .first['x'])
            )

            expect(new_source).to eq(
              %([1, 2, 3].#{preferred_method} { true }['x'])
            )
          end

          it "corrects multiline #{method} to #{preferred_method} " \
             'with \'first\' on the last line (short syntax)' do
            new_source = autocorrect_source(
              cop,
              %([1, 2, 3].#{method}(&:blank?)
                         .first['x'])
            )

            expect(new_source).to eq(
              %([1, 2, 3].#{preferred_method}(&:blank?)['x'])
            )
          end
        end
      end
    end

    it_behaves_like 'detect_autocorrect', 'detect'
    it_behaves_like 'detect_autocorrect', 'find'
  end

  context 'SafeMode true' do
    let(:config) do
      RuboCop::Config.new(
        'Rails' => {
          'Enabled' => true
        },
        'Style/CollectionMethods' => {
          'PreferredMethods' => {
            'detect' => collection_method
          }
        },
        'Performance/Detect' => {
          'SafeMode' => true
        }
      )
    end

    described_class::SELECT_METHODS.each do |method|
      it "doesn't register an offense when first is called on #{method}" do
        inspect_source(cop, "[1, 2, 3].#{method} { |i| i % 2 == 0 }.first")

        expect(cop.offenses).to be_empty
      end
    end
  end
end
