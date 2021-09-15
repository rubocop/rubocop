# frozen_string_literal: true

# Class for generating documentation of all cops departments
# @api private
class CopsDocumentationGenerator # rubocop:disable Metrics/ClassLength
  include ::RuboCop::Cop::Documentation
  # This class will only generate documentation for cops that belong to one of
  # the departments given in the `departments` array. E.g. if we only wanted
  # documentation for Lint cops:
  #
  #   CopsDocumentationGenerator.new(departments: ['Lint']).call
  #
  def initialize(departments: [])
    @departments = departments.map(&:to_sym).sort!
    @cops = RuboCop::Cop::Registry.global
    @config = RuboCop::ConfigLoader.default_configuration
  end

  def call
    YARD::Registry.load!
    departments.each { |department| print_cops_of_department(department) }

    print_table_of_contents
  ensure
    RuboCop::ConfigLoader.default_configuration = nil
  end

  private

  attr_reader :departments, :cops, :config

  def cops_of_department(department)
    cops.with_department(department).sort!
  end

  def cops_body(cop, description, examples_objects, safety_objects, pars) # rubocop:disable Metrics/AbcSize
    content = h2(cop.cop_name)
    content << required_ruby_version(cop)
    content << properties(cop)
    content << "#{description}\n"
    content << safety_object(safety_objects) if safety_objects.any? { |s| !s.text.blank? }
    content << examples(examples_objects) if examples_objects.count.positive?
    content << configurations(pars)
    content << references(cop)
    content
  end

  def examples(examples_object)
    examples_object.each_with_object(h3('Examples').dup) do |example, content|
      content << "\n" unless content.end_with?("\n\n")
      content << h4(example.name) unless example.name == ''
      content << code_example(example)
    end
  end

  def safety_object(safety_object_objects)
    safety_object_objects.each_with_object(h3('Safety').dup) do |safety_object, content|
      next if safety_object.text.blank?

      content << "\n" unless content.end_with?("\n\n")
      content << safety_object.text
      content << "\n"
    end
  end

  def required_ruby_version(cop)
    return '' unless cop.respond_to?(:required_minimum_ruby_version)

    "NOTE: Required Ruby version: #{cop.required_minimum_ruby_version}\n\n"
  end

  # rubocop:disable Metrics/MethodLength
  def properties(cop)
    header = [
      'Enabled by default', 'Safe', 'Supports autocorrection', 'Version Added',
      'Version Changed'
    ]
    autocorrect = if cop.support_autocorrect?
                    "Yes#{' (Unsafe)' unless cop.new(config).safe_autocorrect?}"
                  else
                    'No'
                  end
    cop_config = config.for_cop(cop)
    content = [[
      cop_status(cop_config.fetch('Enabled')),
      cop_config.fetch('Safe', true) ? 'Yes' : 'No',
      autocorrect,
      cop_config.fetch('VersionAdded', '-'),
      cop_config.fetch('VersionChanged', '-')
    ]]
    "#{to_table(header, content)}\n"
  end
  # rubocop:enable Metrics/MethodLength

  def h2(title)
    content = +"\n"
    content << "== #{title}\n"
    content << "\n"
    content
  end

  def h3(title)
    content = +"\n"
    content << "=== #{title}\n"
    content << "\n"
    content
  end

  def h4(title)
    content = +"==== #{title}\n"
    content << "\n"
    content
  end

  def code_example(ruby_code)
    content = +"[source,ruby]\n----\n"
    content << ruby_code.text.gsub('@good', '# good').gsub('@bad', '# bad').strip
    content << "\n----\n"
    content
  end

  def configurations(pars)
    return '' if pars.empty?

    header = ['Name', 'Default value', 'Configurable values']
    configs = pars
              .each_key
              .reject { |key| key.start_with?('Supported') }
              .reject { |key| key.start_with?('AllowMultipleStyles') }
    content = configs.map do |name|
      configurable = configurable_values(pars, name)
      default = format_table_value(pars[name])
      [name, default, configurable]
    end

    h3('Configurable attributes') + to_table(header, content)
  end

  # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
  def configurable_values(pars, name)
    case name
    when /^Enforced/
      supported_style_name = RuboCop::Cop::Util.to_supported_styles(name)
      format_table_value(pars[supported_style_name])
    when 'IndentationWidth'
      'Integer'
    when 'Database'
      format_table_value(pars['SupportedDatabases'])
    else
      case pars[name]
      when String
        'String'
      when Integer
        'Integer'
      when Float
        'Float'
      when true, false
        'Boolean'
      when Array
        'Array'
      else
        ''
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity,Metrics/MethodLength

  def to_table(header, content)
    table = ['|===', "| #{header.join(' | ')}\n\n"].join("\n")
    marked_contents = content.map do |plain_content|
      plain_content.map { |c| "| #{c}" }.join("\n")
    end
    table << marked_contents.join("\n\n")
    table << "\n|===\n"
  end

  def format_table_value(val)
    value =
      case val
      when Array
        if val.empty?
          '`[]`'
        else
          val.map { |config| format_table_value(config) }.join(', ')
        end
      else
        wrap_backtick(val.nil? ? '<none>' : val)
      end
    value.gsub("#{Dir.pwd}/", '').rstrip
  end

  def wrap_backtick(value)
    if value.is_a?(String)
      # Use `+` to prevent text like `**/*.gemspec` from being bold.
      value.start_with?('*') ? "`+#{value}+`" : "`#{value}`"
    else
      "`#{value}`"
    end
  end

  def references(cop)
    cop_config = config.for_cop(cop)
    urls = RuboCop::Cop::MessageAnnotator.new(config, cop.name, cop_config, {}).urls
    return '' if urls.empty?

    content = h3('References')
    content << urls.map { |url| "* #{url}" }.join("\n")
    content << "\n"
    content
  end

  def print_cops_of_department(department)
    selected_cops = cops_of_department(department)
    content = +"= #{department}\n"
    selected_cops.each { |cop| content << print_cop_with_doc(cop) }
    file_name = "#{Dir.pwd}/docs/modules/ROOT/pages/#{department_to_basename(department)}.adoc"
    File.open(file_name, 'w') do |file|
      puts "* generated #{file_name}"
      file.write("#{content.strip}\n")
    end
  end

  def print_cop_with_doc(cop)
    cop_config = config.for_cop(cop)
    non_display_keys = %w[
      Description Enabled StyleGuide Reference Safe SafeAutoCorrect VersionAdded
      VersionChanged
    ]
    pars = cop_config.reject { |k| non_display_keys.include? k }
    description = 'No documentation'
    examples_object = safety_object = []
    cop_code(cop) do |code_object|
      description = code_object.docstring unless code_object.docstring.blank?
      examples_object = code_object.tags('example')
      safety_object = code_object.tags('safety')
    end
    cops_body(cop, description, examples_object, safety_object, pars)
  end

  def cop_code(cop)
    YARD::Registry.all(:class).detect do |code_object|
      next unless RuboCop::Cop::Badge.for(code_object.to_s) == cop.badge

      yield code_object
    end
  end

  def table_of_content_for_department(department)
    type_title = department[0].upcase + department[1..-1]
    filename = "#{department_to_basename(department)}.adoc"
    content = +"=== Department xref:#{filename}[#{type_title}]\n\n"
    cops_of_department(department).each do |cop|
      anchor = cop.cop_name.sub('/', '').downcase
      content << "* xref:#{filename}##{anchor}[#{cop.cop_name}]\n"
    end

    content
  end

  def print_table_of_contents
    path = "#{Dir.pwd}/docs/modules/ROOT/pages/cops.adoc"
    original = File.read(path)
    content = +"// START_COP_LIST\n\n"

    content << table_contents

    content << "\n// END_COP_LIST"

    content = original.sub(%r{// START_COP_LIST.+// END_COP_LIST}m, content)
    File.write(path, content)
  end

  def table_contents
    departments.map { |department| table_of_content_for_department(department) }.join("\n")
  end

  def cop_status(status)
    return 'Disabled' unless status

    status == 'pending' ? 'Pending' : 'Enabled'
  end
end
