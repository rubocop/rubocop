# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::MissingExpectCorrection, :config do
  shared_examples 'offense' do |test_code|
    it 'registers an offense' do
      test_code = test_code.lines.map { |line| "    #{line}" }.join
      expect_offense(<<~RUBY)
        RSpec.describe #{cop_under_testing}, :config do
          it 'does something' do
        #{test_code}
          end
        end
      RUBY
    end
  end

  shared_examples 'no offense' do |test_code|
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe #{cop_under_testing}, :config do
          it 'does something' do
        #{test_code}
          end
        end
      RUBY
    end
  end

  context 'for a cop that supports autocorrect', :restore_registry do
    let(:cop_under_testing) do
      stub_cop_class('CopWithAutoCorrect') { extend RuboCop::Cop::AutoCorrector }
    end

    it_behaves_like 'offense', <<~RUBY
      expect_offense('')
      ^^^^^^^^^^^^^^^^^^ When the cop supports autocorrect, `expect_offense` should be followed by `expect_no_corrections` or `expect_correction`.
    RUBY

    it_behaves_like 'no offense', ''

    it_behaves_like 'no offense', <<~RUBY
      expect_offense
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      expect_offense
      expect_correction
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      expect_offense('foo')
      expect_correction('bar')
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      expect_offense
      expect_no_correction
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      expect_offense('foo')
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      expect do
        expect_offense('foo')
      end.to raise_error(RuboCop::Warning)
    RUBY
  end

  context 'for a cop that does not support autocorrect', :restore_registry do
    let(:cop_under_testing) { stub_cop_class('CopWithoutAutoCorrect') }

    it_behaves_like 'no offense', <<~RUBY
      expect_offense('foo')
    RUBY
  end

  context 'when the cop is unknown' do
    let(:cop_under_testing) { 'Foo::Bar' }

    it_behaves_like 'no offense', <<~RUBY
      expect_offense('foo')
    RUBY
  end

  it 'registers no offense when the test file has no described class' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe  do
        it 'does something' do
          expect_offense('foo')
        end
      end
    RUBY
  end

  it 'registers no offense when the test file contains only `RSpec`' do
    expect_no_offenses(<<~RUBY)
      RSpec
    RUBY
  end
end
