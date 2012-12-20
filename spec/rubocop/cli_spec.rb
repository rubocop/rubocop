# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Report
    describe CLI do
      let(:cli) { CLI.new }
      before(:each) { $stdout = StringIO.new }
      after(:each) { $stdout = STDOUT }

      it 'exits cleanly when -h is used' do
        lambda { cli.run ['-h'] }.should exit_with_code(0)
        lambda { cli.run ['--help'] }.should exit_with_code(0)
        message = ['Usage: rubocop [options] [file1, file2, ...]',
                   '    -v, --[no-]verbose               Run verbosely',
                   '    -e, --emacs                      Emacs style output']
        $stdout.string.should == (message * 2).join("\n") + "\n"
      end

      it 'checks a given correct file and returns 0' do
        File.open('example.rb', 'w') { |f|
          f.puts("# encoding: utf-8", "x = 0")
        }
        begin
          cli.run(['example.rb']).should == 0
          $stdout.string.should == "\n1 files inspected, 0 offences detected\n"
        ensure
          File.delete 'example.rb'
        end
      end

      it 'checks a given file with faults and returns 1' do
        File.open('example.rb', 'w') { |f|
          f.puts("# encoding: utf-8", "x = 0 ")
        }
        begin
          cli.run(['example.rb']).should == 1
          $stdout.string.should == ['== example.rb ==',
                                    'C:  1: Trailing whitespace detected.',
                                    '',
                                    '1 files inspected, 1 offences detected',
                                    ''].join("\n")
        ensure
          File.delete 'example.rb'
        end
      end

      it 'can report in emacs style' do
        File.open('example1.rb', 'w') { |f| f.puts 'x = 0 ' }
        File.open('example2.rb', 'w') { |f| f.puts "\tx = 0" }
        begin
          cli.run(['--emacs', 'example1.rb', 'example2.rb']).should == 1
          $stdout.string.should ==
            ['example1.rb:1: C: Missing encoding comment.',
             'example1.rb:1: C: Trailing whitespace detected.',
             'example2.rb:1: C: Missing encoding comment.',
             'example2.rb:1: C: Tab detected.',
             '',
             '2 files inspected, 4 offences detected',
             ''].join("\n")
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'finds no violations when checking the rubocop source code' do
        cli.run
        $stdout.string.should =~ /files inspected, 0 offences detected\n/
      end
    end
  end
end
