# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module VariableInspector
      describe NodeScanner do
        describe '.scan_nodes_in_scope' do
          let(:ast) do
            processed_source = Rubocop::SourceParser.parse(source)
            processed_source.ast
          end

          let(:source) do
            <<-END
              class SomeClass
                foo = 1.to_s
                bar = 2.to_s
                def some_method
                  baz = 3.to_s
                end
              end
            END
          end

          # (class
          #   (const nil :SomeClass) nil
          #   (begin
          #     (lvasgn :foo
          #       (send
          #         (int 1) :to_s))
          #     (lvasgn :bar
          #       (send
          #         (int 2) :to_s))
          #     (def :some_method
          #       (args)
          #       (lvasgn :baz
          #         (send
          #           (int 3) :to_s)))))

          it 'does not scan children of inner scope node' do
            scanned_node_count = 0

            NodeScanner.scan_nodes_in_scope(ast) do |node|
              scanned_node_count += 1
              fail if node.type == :lvasgn && node.children.first == :baz
            end

            expect(scanned_node_count).to eq(9)
          end

          it 'scans nodes with depth first order' do
            index = 0

            NodeScanner.scan_nodes_in_scope(ast) do |node|
              case index
              when 0
                expect(node.type).to eq(:const)
              when 1
                expect(node.type).to eq(:begin)
              when 2
                expect(node.type).to eq(:lvasgn)
              when 3
                expect(node.type).to eq(:send)
              when 4
                expect(node.type).to eq(:int)
              when 5
                expect(node.type).to eq(:lvasgn)
              end

              index += 1
            end

            expect(index).not_to eq(0)
          end

          let(:trace) { [] }

          before do
            NodeScanner.scan_nodes_in_scope(ast) do |node|
              short_info = node.type.to_s
              node.children.each do |child|
                break if child.is_a?(Parser::AST::Node)
                short_info << " #{child.inspect}"
              end
              trace << short_info
            end
          end

          context 'when invoking a method ' +
                  'which is taking block and normal arguments' do
            let(:source) do
              <<-END
                some_method(foo = 1) do |block_arg|
                  content_of_block = 2
                end
                puts foo
              END
            end

            # (begin
            #   (block
            #     (send nil :some_method
            #       (lvasgn :foo
            #         (int 1)))
            #     (args
            #       (arg :block_arg))
            #     (lvasgn :content_of_block
            #       (int 2)))
            #   (send nil :puts
            #     (lvar :foo)))

            it 'scans the method node and its normal argument nodes' do
              expect(trace).to eq([
                'block',
                'send nil :some_method',
                'lvasgn :foo',
                'int 1',
                'send nil :puts',
                'lvar :foo'
              ])
            end
          end

          context 'when opening singleton class of an instance' do
            let(:source) do
              <<-END
                instance = Object.new
                class << instance
                  content_of_singleton_class = 1
                end
                p instance
              END
            end

            # (begin
            #   (lvasgn :instance
            #     (send
            #       (const nil :Object) :new))
            #   (sclass
            #     (lvar :instance)
            #     (lvasgn :content_of_singleton_class
            #       (int 1)))
            #   (send nil :p
            #     (lvar :instance)))

            it 'scans the subject instance node' do
              expect(trace).to eq([
                'lvasgn :instance',
                'send',
                'const nil :Object',
                'sclass',
                'lvar :instance',
                'send nil :p',
                'lvar :instance'
              ])
            end
          end

          context 'when defining singleton method' do
            let(:source) do
              <<-END
                instance = Object.new
                def instance.some_method(method_arg)
                  content_of_method = 2
                end
                p instance
              END
            end

            # (begin
            #   (lvasgn :instance
            #     (send
            #       (const nil :Object) :new))
            #   (defs
            #     (lvar :instance) :some_method
            #     (args
            #       (arg :method_arg))
            #     (lvasgn :content_of_method
            #       (int 2)))
            #   (send nil :p
            #     (lvar :instance)))

            it 'scans the subject instance node' do
              expect(trace).to eq([
                'lvasgn :instance',
                'send',
                'const nil :Object',
                'defs',
                'lvar :instance',
                'send nil :p',
                'lvar :instance'
              ])
            end
          end

          context 'when scanning around post while loop' do
            let(:source) do
              <<-END
                begin
                  foo = 1
                end while foo > 10
                puts foo
              END
            end

            # (begin
            #   (while-post
            #     (send
            #       (lvar :foo) :>
            #       (int 10))
            #     (kwbegin
            #       (lvasgn :foo
            #         (int 1))))
            #   (send nil :puts
            #     (lvar :foo)))

            it 'scans loop body nodes first then condition nodes' do
              expect(trace).to eq([
                'while_post',
                'kwbegin',
                'lvasgn :foo',
                'int 1',
                'send',
                'lvar :foo',
                'int 10',
                'send nil :puts',
                'lvar :foo'
              ])
            end
          end

          context 'when scanning around post until loop' do
            let(:source) do
              <<-END
                begin
                  foo = 1
                end until foo < 10
                puts foo
              END
            end

            # (begin
            #   (until-post
            #     (send
            #       (lvar :foo) :<
            #       (int 10))
            #     (kwbegin
            #       (lvasgn :foo
            #         (int 1))))
            #   (send nil :puts
            #     (lvar :foo)))

            it 'scans loop body nodes first then condition nodes' do
              expect(trace).to eq([
                'until_post',
                'kwbegin',
                'lvasgn :foo',
                'int 1',
                'send',
                'lvar :foo',
                'int 10',
                'send nil :puts',
                'lvar :foo'
              ])
            end
          end
        end
      end
    end
  end
end
