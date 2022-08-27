# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantFreeze, :config do
  let(:prefix) { nil }

  shared_examples 'immutable objects' do |o|
    it "registers an offense for frozen #{o}" do
      expect_offense([prefix, <<~RUBY].compact.join("\n"), o: o)
        CONST = %{o}.freeze
                ^{o}^^^^^^^ Do not freeze immutable objects, as freezing them has no effect.
      RUBY

      expect_correction([prefix, <<~RUBY].compact.join("\n"))
        CONST = #{o}
      RUBY
    end
  end

  it_behaves_like 'immutable objects', '1'
  it_behaves_like 'immutable objects', '1.5'
  it_behaves_like 'immutable objects', ':sym'
  it_behaves_like 'immutable objects', ':""'
  it_behaves_like 'immutable objects', "'foo'.count"
  it_behaves_like 'immutable objects', '(1 + 2)'
  it_behaves_like 'immutable objects', '(2 > 1)'
  it_behaves_like 'immutable objects', "('a' > 'b')"
  it_behaves_like 'immutable objects', '(a > b)'
  it_behaves_like 'immutable objects', '[1, 2, 3].size'

  shared_examples 'mutable objects' do |o|
    it "allows #{o} with freeze" do
      source = [prefix, "CONST = #{o}.freeze"].compact.join("\n")
      expect_no_offenses(source)
    end
  end

  it_behaves_like 'mutable objects', '[1, 2, 3]'
  it_behaves_like 'mutable objects', '{ a: 1, b: 2 }'
  it_behaves_like 'mutable objects', "'str'"
  it_behaves_like 'mutable objects', '"top#{1 + 2}"'
  it_behaves_like 'mutable objects', "('a' + 'b')"
  it_behaves_like 'mutable objects', "('a' * 20)"
  it_behaves_like 'mutable objects', '(a + b)'
  it_behaves_like 'mutable objects', '([42] * 42)'
  it_behaves_like 'mutable objects', "ENV['foo']"
  it_behaves_like 'mutable objects', "::ENV['foo']"

  it 'allows .freeze on method call' do
    expect_no_offenses('TOP_TEST = Something.new.freeze')
  end

  context 'when the receiver is a string literal' do
    # TODO : It is not yet decided when frozen string will be the default.
    # It has been abandoned in the Ruby 3.0 period, but may default in
    # the long run. So these tests are left with a provisional value of 4.0.
    if RuboCop::TargetRuby.supported_versions.include?(4.0)
      context 'when the target ruby version >= 4.0' do
        let(:ruby_version) { 4.0 }

        context 'when the frozen string literal comment is missing' do
          it_behaves_like 'immutable objects', '"#{a}"'
        end

        context 'when the frozen string literal comment is true' do
          let(:prefix) { '# frozen_string_literal: true' }

          it_behaves_like 'immutable objects', '"#{a}"'
        end

        context 'when the frozen string literal comment is false' do
          let(:prefix) { '# frozen_string_literal: false' }

          it_behaves_like 'immutable objects', '"#{a}"'
        end
      end
    end

    context 'Ruby 3.0 or higher', :ruby30 do
      context 'when the frozen string literal comment is missing' do
        it_behaves_like 'mutable objects', '"#{a}"'
      end

      context 'when the frozen string literal comment is true' do
        let(:prefix) { '# frozen_string_literal: true' }

        it_behaves_like 'mutable objects', '"#{a}"'
      end

      context 'when the frozen string literal comment is false' do
        let(:prefix) { '# frozen_string_literal: false' }

        it_behaves_like 'mutable objects', '"#{a}"'
      end
    end

    context 'Ruby 2.7 or lower', :ruby27 do
      context 'when the frozen string literal comment is missing' do
        it_behaves_like 'mutable objects', '"#{a}"'
      end

      context 'when the frozen string literal comment is true' do
        let(:prefix) { '# frozen_string_literal: true' }

        it_behaves_like 'immutable objects', '"#{a}"'
      end

      context 'when the frozen string literal comment is false' do
        let(:prefix) { '# frozen_string_literal: false' }

        it_behaves_like 'mutable objects', '"#{a}"'
      end
    end

    describe 'Regexp and Range literals' do
      # Ruby 3.0's Regexp and Range literals are frozen.
      #
      # https://bugs.ruby-lang.org/issues/15504
      # https://bugs.ruby-lang.org/issues/16377
      context 'Ruby 3.0 or higher', :ruby30 do
        it_behaves_like 'immutable objects', '/./'
        it_behaves_like 'immutable objects', '(1..5)'
        it_behaves_like 'immutable objects', '(1...5)'
      end

      context 'Ruby 2.7 or lower', :ruby27 do
        it_behaves_like 'mutable objects', '/./'
        it_behaves_like 'mutable objects', '(1..5)'
        it_behaves_like 'mutable objects', '(1...5)'
      end
    end
  end
end
