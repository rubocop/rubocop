# frozen_string_literal: true

# rubocop:disable RSpec/PredicateMatcher
RSpec.describe RuboCop::CLI::Command::JSONSchema, :restore_registry do
  fixture_dir = File.join(File.expand_path('../../..', __dir__), 'fixtures/json_schema')

  it "finds rubocop's own config valid" do
    config_path = File.join(RuboCop::ConfigFinder::RUBOCOP_HOME, '.rubocop.yml')
    errors = validate_config_file(config_path, strict: false)
    expect(errors).to be_empty
  end

  it "finds all of rubocop's default values for cops valid" do
    config_path = RuboCop::ConfigLoader::DEFAULT_FILE
    config = RuboCop::ConfigLoader.load_yaml_configuration(config_path)
    config.transform_values!(&:compact) # get rid of the "~"s
    errors = validate_config(config, strict: true)
    expect(errors).to be_empty
  end

  it 'finds a typical config valid' do
    config_path = File.join(fixture_dir, 'rubocop_valid.yml')
    errors = validate_config_file(config_path, strict: true)
    expect(errors).to be_empty
  end

  it 'finds plenty of errors in an obviously invalid file' do
    config_path = File.join(fixture_dir, 'rubocop_invalid.yml')
    errors = validate_config_file(config_path)
    expect(errors.length).to be > 15
  end

  # Could expand this with everything in "RuboCop::Config#validate spec"

  it 'validates config properties' do
    errors = validate_config_string <<~YAML
      inherit_from:
        a: ".rubocop_todo.yml"
    YAML
    expect(errors).not_to be_empty

    errors = validate_config_string <<~YAML
      inherit_from:
        - ".rubocop_todo.yml"
    YAML
    expect(errors).to be_empty

    errors = validate_config_string <<~YAML
      inherit_from: .rubocop_todo.yml
    YAML
    expect(errors).to be_empty
  end

  it 'validates types for cops' do
    errors = validate_config_string <<~YAML
      Layout/ArgumentAlignment:
        Enabled: 1
        AllowedNames:
          - ex
          - 1
    YAML
    expect(errors).not_to be_empty

    errors = validate_config_string <<~YAML
      Layout/ArgumentAlignment:
        Enabled: true
        AllowedNames:
          - ex
          - b
    YAML
    expect(errors).to be_empty
  end

  it 'validates enums for some cops' do
    errors = validate_config_string <<~YAML
      Layout/ArgumentAlignment:
        EnforcedStyle: blah
    YAML
    expect(errors).not_to be_empty

    errors = validate_config_string <<~YAML
      Layout/ArgumentAlignment:
        EnforcedStyle: with_first_argument
    YAML
    expect(errors).to be_empty
  end

  def validate_config_string(config_str, strict: false)
    config = YAML.safe_load(config_str)
    validate_config(config, strict: strict)
  end

  def validate_config_file(config_path, strict: false)
    config = RuboCop::ConfigLoader.load_yaml_configuration(config_path)
    validate_config(config, strict: strict)
  end

  def validate_config(config, strict: false)
    require 'json_schemer'
    schema = build_json_schema(strict: strict)
    result = JSONSchemer.schema(schema, output_format: 'basic').validate(config)
    result['errors']&.map { |r| r['error'] } || []
  end

  def build_json_schema(strict: false)
    env = RuboCop::CLI::Environment.new({}, RuboCop::ConfigStore.new, [])
    cmd = described_class.new(env)
    cmd.schema_builder.build_json_schema(strict: strict)
  end
end
# rubocop:enable RSpec/PredicateMatcher
