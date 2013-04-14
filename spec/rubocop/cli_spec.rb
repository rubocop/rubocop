# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Report
    describe CLI do
      let(:cli) { CLI.new }
      before(:each) { $stdout = StringIO.new }
      after(:each) { $stdout = STDOUT }

      it 'exits cleanly when -h is used' do
        expect { cli.run ['-h'] }.to exit_with_code(0)
        expect { cli.run ['--help'] }.to exit_with_code(0)
        message = ['Usage: rubocop [options] [file1, file2, ...]',
                   '    -d, --[no-]debug                 Display debug info',
                   '    -e, --emacs                      Emacs style output',
                   '    -c, --config FILE                Configuration file',
                   '    -s, --silent                     Silence summary',
                   '    -v, --version                    Display version']
        expect($stdout.string).to eq((message * 2).join("\n") + "\n")
      end

      it 'exits cleanly when -v is used' do
        expect { cli.run ['-v'] }.to exit_with_code(0)
        expect { cli.run ['--version'] }.to exit_with_code(0)
        expect($stdout.string).to eq((Rubocop::VERSION + "\n") * 2)
      end

      it 'checks a given correct file and returns 0' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts 'x = 0'
          f.puts 'puts x'
        end
        begin
          expect(cli.run(['example.rb'])).to eq(0)
          expect($stdout.string.uncolored)
            .to eq("\n1 files inspected, 0 offences detected\n")
        ensure
          File.delete 'example.rb'
        end
      end

      it 'checks a given file with faults and returns 1' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts 'x = 0 '
          f.puts 'puts x'
        end
        begin
          expect(cli.run(['example.rb'])).to eq(1)
          expect($stdout.string.uncolored)
            .to eq ['== example.rb ==',
                    'C:  2: Trailing whitespace detected.',
                    '',
                    '1 files inspected, 1 offences detected',
                    ''].join("\n")
        ensure
          File.delete 'example.rb'
        end
      end

      it 'can report in emacs style', ruby: 1.9 do
        File.open('example1.rb', 'w') { |f| f.puts 'x= 0 ', 'y ', 'puts x' }
        File.open('example2.rb', 'w') { |f| f.puts "\tx = 0", 'puts x' }
        begin
          expect(cli.run(['--emacs', 'example1.rb', 'example2.rb'])).to eq(1)
          expect($stdout.string.uncolored)
            .to eq(
            ['example1.rb:1: C: Missing encoding comment.',
             'example1.rb:1: C: Trailing whitespace detected.',
             "example1.rb:1: C: Surrounding space missing for operator '='.",
             'example1.rb:2: C: Trailing whitespace detected.',
             'example2.rb:1: C: Missing encoding comment.',
             'example2.rb:1: C: Tab detected.',
             '',
             '2 files inspected, 6 offences detected',
             ''].join("\n"))
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'can report in emacs style', ruby: 2.0 do
        File.open('example1.rb', 'w') { |f| f.puts 'x= 0 ', 'y ', 'puts x' }
        File.open('example2.rb', 'w') { |f| f.puts "\tx = 0", 'puts x' }
        begin
          expect(cli.run(['--emacs', 'example1.rb', 'example2.rb'])).to eq(1)
          expect($stdout.string.uncolored)
            .to eq(
            ['example1.rb:1: C: Trailing whitespace detected.',
             "example1.rb:1: C: Surrounding space missing for operator '='.",
             'example1.rb:2: C: Trailing whitespace detected.',
             'example2.rb:1: C: Tab detected.',
             '',
             '2 files inspected, 4 offences detected',
             ''].join("\n"))
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'ommits summary when --silent passed', ruby: 1.9 do
        File.open('example1.rb', 'w') { |f| f.puts 'puts 0 ' }
        File.open('example2.rb', 'w') { |f| f.puts "\tputs 0" }
        begin
          expect(cli.run(['--emacs',
                          '--silent',
                          'example1.rb',
                          'example2.rb'])).to eq(1)
          expect($stdout.string).to eq(
            ['example1.rb:1: C: Missing encoding comment.',
             'example1.rb:1: C: Trailing whitespace detected.',
             'example2.rb:1: C: Missing encoding comment.',
             'example2.rb:1: C: Tab detected.',
             ''].join("\n"))
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'ommits summary when --silent passed', ruby: 2.0 do
        File.open('example1.rb', 'w') { |f| f.puts 'puts 0 ' }
        File.open('example2.rb', 'w') { |f| f.puts "\tputs 0" }
        begin
          expect(cli.run(['--emacs',
                          '--silent',
                          'example1.rb',
                          'example2.rb'])).to eq(1)
          expect($stdout.string).to eq(
            ['example1.rb:1: C: Trailing whitespace detected.',
             'example2.rb:1: C: Tab detected.',
             ''].join("\n"))
        ensure
          File.delete 'example1.rb'
          File.delete 'example2.rb'
        end
      end

      it 'can be configured with option to disable a certain error' do
        File.open('example1.rb', 'w') { |f| f.puts 'puts 0 ' }
        File.open('rubocop.yml', 'w') do |f|
          f.puts('Encoding:',
                 '  Enabled: false',
                 '',
                 'Indentation:',
                 '  Enabled: false')
        end
        begin
          expect(cli.run(['-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
          expect($stdout.string.uncolored).to eq(
            ['== example1.rb ==',
             'C:  1: Trailing whitespace detected.',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n"))
        ensure
          File.delete 'example1.rb'
          File.delete 'rubocop.yml'
        end
      end

      it 'can be configured with project config to disable a certain error' do
        FileUtils.mkdir 'example_src'
        File.open('example_src/example1.rb', 'w') { |f| f.puts 'puts 0 ' }
        File.open('example_src/.rubocop.yml', 'w') do |f|
          f.puts('Encoding:',
                 '  Enabled: false',
                 '',
                 'Indentation:',
                 '  Enabled: false')
        end
        begin
          expect(cli.run(['example_src/example1.rb'])).to eq(1)
          expect($stdout.string.uncolored).to eq(
            ['== example_src/example1.rb ==',
             'C:  1: Trailing whitespace detected.',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n"))
        ensure
          FileUtils.rm_rf 'example_src'
        end
      end

      it 'can use an alternative max line length from a config file' do
        FileUtils.mkdir 'example_src'
        File.open('example_src/example1.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts '#' * 90
        end
        File.open('example_src/.rubocop.yml', 'w') do |f|
          f.puts('LineLength:',
                 '  Enabled: true',
                 '  Max: 100')
        end
        begin
          expect(cli.run(['example_src/example1.rb'])).to eq(0)
          expect($stdout.string.uncolored).to eq(
            ['', '1 files inspected, 0 offences detected',
             ''].join("\n"))
        ensure
          FileUtils.rm_rf 'example_src'
        end
      end

      it 'can have different config files in different directories' do
        %w(src lib).each do |dir|
          FileUtils.mkdir_p "example/#{dir}"
          File.open("example/#{dir}/example1.rb", 'w') do |f|
            f.puts '# encoding: utf-8'
            f.puts '#' * 90
          end
        end
        File.open('example/src/.rubocop.yml', 'w') do |f|
          f.puts('LineLength:',
                 '  Enabled: true',
                 '  Max: 100')
        end
        begin
          expect(cli.run(['example'])).to eq(1)
          expect($stdout.string.uncolored).to eq(
            ['== example/lib/example1.rb ==',
             'C:  2: Line is too long. [90/79]',
             '',
             '2 files inspected, 1 offences detected',
             ''].join("\n"))
        ensure
          FileUtils.rm_rf 'example'
        end
      end

      it 'finds no violations when checking the rubocop source code' do
        cli.run
        expect($stdout.string.uncolored).to match(
          /files inspected, 0 offences detected\n/
        )
      end

      it 'registers an offence for a syntax error' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts 'class Test'
          f.puts 'en'
        end
        begin
          expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
          unexpected_part = RUBY_VERSION >= '2.0' ? 'end-of-input' : '$end'
          expect($stdout.string.uncolored).to eq(
            ["example.rb:3: E: Syntax error, unexpected #{unexpected_part}, " +
             'expecting keyword_end',
             '',
             '1 files inspected, 1 offences detected',
             ''].join("\n"))
        ensure
          File.delete 'example.rb'
        end
      end

      it 'can process a file with an invalid UTF-8 byte sequence' do
        File.open('example.rb', 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts "# \xf9\x29"
        end
        begin
          expect(cli.run(['--emacs', 'example.rb'])).to eq(0)
        ensure
          File.delete 'example.rb'
        end
      end

      it 'has configuration for all cops in .rubocop.yml' do
        cop_names = Cop::Cop.all.map do |cop_class|
          cop_class.name.split('::').last
        end
        expect(YAML.load_file('.rubocop.yml').keys.sort).to eq(cop_names.sort)
      end
    end
  end
end
