# frozen_string_literal: true

require 'mdl'

desc 'Lint markdown files'
task :markdown_lint do
  exclude = [
    'MD002', # First header should be a top level header
    'MD013', # Line length
    'MD024', # Multiple headers with the same content
    'MD033'  # Inline HTML
  ]

  ruleset = MarkdownLint::RuleSet.new
  ruleset.load_default
  rules = ruleset.rules
  MarkdownLint::Style.load(MarkdownLint::Config[:style], rules)
  rules = rules.map(&:first).reject { |name| exclude.include?(name) }.join(',')

  begin
    MarkdownLint.run(['-r', rules] + Dir['**/*.md'])
  rescue SystemExit => e
    exit 1 unless e.success?
  end
end
