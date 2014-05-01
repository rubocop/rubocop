# encoding: utf-8

RSpec::Matchers.define :find_offenses_in do |code|
  match do |cop|
    inspect_source(cop, [code])
    cop.offenses.any?
  end
end
