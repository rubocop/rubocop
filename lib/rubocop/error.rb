# encoding: utf-8

module RuboCop
  # An Error exception is different from an Offense with severity 'error'
  # When this exception is raised, it means that RuboCop is unable to perform
  # a requested action (probably due to misconfiguration) and must stop
  # immediately, rather than carrying on
  class Error < StandardError
  end
end
