# frozen_string_literal: true

require 'open3'

# The reincarnation of syntax cop :)
module MRISyntaxChecker
  module_function

  def offenses_for_source(source, fake_cop_name = 'Syntax', grep_message = nil)
    if source.is_a?(Array)
      source_lines = source
      source = source_lines.join("\n")
    else
      source_lines = source.each_line.to_a
    end

    source_buffer = Parser::Source::Buffer.new('test', 1)
    source_buffer.source = source

    offenses = check_syntax(source).each_line.map do |line|
      check_line(line, source_lines, source_buffer, fake_cop_name,
                 grep_message)
    end

    offenses.compact
  end

  def check_line(line, source_lines, source_buffer, fake_cop_name,
                 grep_message)
    line_number, severity, message = process_line(line)
    return unless line_number
    return if grep_message && !message.include?(grep_message)
    begin_pos = source_lines[0...(line_number - 1)].reduce(0) do |a, e|
      a + e.length + 1
    end
    RuboCop::Cop::Offense.new(severity,
                              Parser::Source::Range.new(source_buffer,
                                                        begin_pos,
                                                        begin_pos + 1),
                              message.capitalize,
                              fake_cop_name)
  end

  def check_syntax(source)
    raise 'Must be running with MRI' unless RUBY_ENGINE == 'ruby'

    stdin, stderr, thread = nil

    # It's extremely important to run the syntax check in a
    # clean environment - otherwise it will be extremely slow.
    if defined? Bundler
      Bundler.with_clean_env do
        stdin, _, stderr, thread = Open3.popen3('ruby', '-cw')
      end
    else
      stdin, _, stderr, thread = Open3.popen3('ruby', '-cw')
    end

    stdin.write(source)
    stdin.close
    thread.join

    stderr.read
  end

  def process_line(line)
    match_data = line.match(/.+:(\d+): (warning: )?(.+)/)
    return nil unless match_data
    line_number, warning, message = match_data.captures
    severity = warning ? :warning : :error
    [line_number.to_i, severity, message]
  end
end
