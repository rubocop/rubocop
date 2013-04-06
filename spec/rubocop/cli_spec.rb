# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Report
    describe CLI do
      let(:cli) { CLI.new }
      before(:each) { $stdout = StringIO.new }
      after(:each) { $stdout = STDOUT }

      it 'exits cleanly when -h is used' do
        -> { cli.run ['-h'] }.should exit_with_code(0)
        -> { cli.run ['--help'] }.should exit_with_code(0)
        message = ['Usage: rubocop [options] [file1, file2, ...]',
                   '    -d, --[no-]debug                 Display debug info',
                   '    -e, --emacs                      Emacs style output',
                   '    -c, --config FILE                Configuration file',
                   '    -s, --silent                     Silence summary',
                   '    -v, --version                    Display version']
        $stdout.string.should == (message * 2).join("\n") + "\n"
      end

      it 'checks a given correct file and returns 0' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts 'x = 0'
        end
        begin
          cli.run(['example.rb']).should == 0
          $stdout.string.uncolored.should ==
            "\n1 files inspected, 0 offences detected\n"
        ensure
          File.delete 'example.rb'
        end
      end

      it 'checks a given file with faults and returns 1' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts 'x = 0 '
        end
        begin
          cli.run(['example.rb']).should == 1
          $stdout.string.uncolored.should ==
            ['== example.rb ==',
             'C:  2: Trailing whitespace detected.',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n")
        ensure
          File.delete 'example.rb'
        end
      end

      it 'can report in emacs style' do
        File.open('example1.rb', 'w') { |f| f.puts 'x= 0 ', 'y ' }
        File.open('example2.rb', 'w') { |f| f.puts "\tx = 0" }
        begin
          cli.run(['--emacs', 'example1.rb', 'example2.rb']).should == 1
          $stdout.string.uncolored.should ==
            ['example1.rb:1: C: Missing encoding comment.',
             'example1.rb:1: C: Trailing whitespace detected.',
             "example1.rb:1: C: Surrounding space missing for operator '='.",
             'example1.rb:2: C: Trailing whitespace detected.',
             'example2.rb:1: C: Missing encoding comment.',
             'example2.rb:1: C: Tab detected.',
             '',
             '2 files inspected, 6 offences detected',
             ''].join("\n")
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'ommits summary when --silent passed' do
        File.open('example1.rb', 'w') { |f| f.puts 'x = 0 ' }
        File.open('example2.rb', 'w') { |f| f.puts "\tx = 0" }
        begin
          cli.run(['--emacs',
                   '--silent',
                   'example1.rb',
                   'example2.rb']).should == 1
          $stdout.string.should ==
            ['example1.rb:1: C: Missing encoding comment.',
             'example1.rb:1: C: Trailing whitespace detected.',
             'example2.rb:1: C: Missing encoding comment.',
             'example2.rb:1: C: Tab detected.',
             ''].join("\n")
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'can be configured with option to disable a certain error' do
        File.open('example1.rb', 'w') { |f| f.puts 'x = 0 ' }
        File.open('rubocop.yml', 'w') do |f|
          f.puts('Encoding:',
                 '  Enabled: false',
                 '',
                 'Indentation:',
                 '  Enabled: false')
        end
        begin
          return_code = cli.run(['-c', 'rubocop.yml', 'example1.rb'])
          $stdout.string.uncolored.should ==
            ['== example1.rb ==',
             'C:  1: Trailing whitespace detected.',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n")
          return_code.should == 1
        ensure
          File.delete 'example1.rb'
          File.delete 'rubocop.yml'
        end
      end

      it 'can be configured with project config to disable a certain error' do
        FileUtils.mkdir 'example_src'
        File.open('example_src/example1.rb', 'w') { |f| f.puts 'x = 0 ' }
        File.open('example_src/.rubocop.yml', 'w') do |f|
          f.puts('Encoding:',
                 '  Enabled: false',
                 '',
                 'Indentation:',
                 '  Enabled: false')
        end
        begin
          return_code = cli.run(['example_src/example1.rb'])
          $stdout.string.uncolored.should ==
            ['== example_src/example1.rb ==',
             'C:  1: Trailing whitespace detected.',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n")
          return_code.should == 1
        ensure
          FileUtils.rm_rf 'example_src'
        end
      end

      it 'can use an alternative max line length from a config file' do
        FileUtils.mkdir 'example_src'
        File.open('example_src/example1.rb', 'w') { |f| f.puts '#' * 90 }
        File.open('example_src/.rubocop.yml', 'w') do |f|
          f.puts('LineLength:',
                 '  Enabled: true',
                 '  Max: 100')
        end
        begin
          return_code = cli.run(['example_src/example1.rb'])
          $stdout.string.uncolored.should ==
            ['== example_src/example1.rb ==',
             'C:  1: Missing encoding comment.',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n")
          return_code.should == 1
        ensure
          FileUtils.rm_rf 'example_src'
        end
      end

      it 'finds no violations when checking the rubocop source code' do
        cli.run
        $stdout.string.uncolored.should =~
          /files inspected, 0 offences detected\n/
      end

      it 'can process a file with an invalide UTF-8 byte sequence' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts "# \xf9\x29"
        end
        begin
          cli.run(['--emacs', 'example.rb']).should == 0
        ensure
          File.delete 'example.rb'
        end
      end

      it 'has configuration for all cops in .rubocop.yml' do
        cop_names = Cop::Cop.all.map do |cop_class|
          cop_class.name.split('::').last
        end
        YAML.load_file('.rubocop.yml').keys.sort.should == cop_names.sort
      end
    end
  end
end
