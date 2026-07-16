# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ProjectIndexHelp, :project_index do
  let(:helper_class) do
    Class.new do
      include RuboCop::Cop::ProjectIndexHelp

      attr_accessor :project_index

      public :project_index_signature, :resolve_constant_in_index
    end
  end

  describe '#resolve_constant_in_index' do
    it 'resolves a qualified reference to a member of a nested namespace' do
      source = <<~RUBY
        module A
          module B
            class C
            end
          end

          B::C
        end
      RUBY
      helper = helper_class.new
      helper.project_index = build_index('file:///nested.rb' => source)

      processed = RuboCop::ProcessedSource.new(source, RUBY_VERSION.to_f)
      ref = processed.ast.each_node(:const).find { |node| node.const_name == 'B::C' }

      expect(helper.resolve_constant_in_index(ref).name).to eq('A::B::C')
    end
  end

  describe '#project_index_signature' do
    it 'is computed once per index across cops sharing it' do
      index = build_index('file:///foo.rb' => "class Foo\nend\n")
      first, second = Array.new(2) do
        helper_class.new.tap { |helper| helper.project_index = index }
      end

      expect(first.project_index_signature).to eq(second.project_index_signature)
      expect(second.project_index_signature).to be(first.project_index_signature)
    end

    it 'is recomputed when the index changes' do
      first = helper_class.new.tap do |helper|
        helper.project_index = build_index('file:///foo.rb' => "class Foo\nend\n")
      end
      second = helper_class.new.tap do |helper|
        helper.project_index = build_index('file:///bar.rb' => "class Bar\nend\n")
      end

      expect(first.project_index_signature).not_to eq(second.project_index_signature)
    end
  end
end
