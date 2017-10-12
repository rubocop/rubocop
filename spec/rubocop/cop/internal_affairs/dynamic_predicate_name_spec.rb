# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::DynamicPredicateName, :config do
  let(:transpose_configure_cop_name) { 'Naming/PredicateName' }

  subject(:cop) { described_class.new(config) }

  context 'with blacklisted prefixes' do
    let(:cop_config) do
      { 'NamePrefix' => %w[has_ is_],
        'NamePrefixBlacklist' => %w[has_ is_] }
    end

    %w[has is].each do |prefix|
      it 'registers an offense when method name starts with known prefix' do
        inspect_source(<<-RUBY.strip_indent)
          def_node_matcher :#{prefix}_attr, <<-PATTERN
            (send nil :puts
              (str "hello"))
          PATTERN
        RUBY
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(["Rename `#{prefix}_attr` to `attr?`."])
        expect(cop.highlights).to eq([":#{prefix}_attr"])
      end
    end

    it 'accepts method name that starts with unknown prefix' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def_node_matcher :have_attr, <<-PATTERN
          (send nil :puts
            (str "hello"))
        PATTERN
      RUBY
    end
  end

  context 'without blacklisted prefixes' do
    let(:cop_config) do
      { 'NamePrefix' => %w[has_ is_], 'NamePrefixBlacklist' => [] }
    end

    %w[has is].each do |prefix|
      it 'registers an offense when method name starts with known prefix' do
        inspect_source(<<-RUBY.strip_indent)
          def_node_matcher :#{prefix}_attr, '(send nil :puts (str "hello"))'
        RUBY
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(["Rename `#{prefix}_attr` to `#{prefix}_attr?`."])
        expect(cop.highlights).to eq([":#{prefix}_attr"])
      end
    end

    it 'accepts method name that starts with unknown prefix' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def_node_matcher :have_attr, <<-PATTERN
          (send nil :puts
            (str "hello"))
        PATTERN
      RUBY
    end
  end

  context 'with whitelisted predicate names' do
    let(:cop_config) do
      { 'NamePrefix' => %w[is_], 'NamePrefixBlacklist' => %w[is_],
        'NameWhitelist' => %w[is_a?] }
    end

    it 'accepts method name which is in whitelist' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def_node_matcher :is_a?, <<-PATTERN
          (send nil :puts
            (str "hello"))
        PATTERN
      RUBY
    end
  end
end
