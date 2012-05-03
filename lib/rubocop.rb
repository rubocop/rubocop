module Rubocop
  def self.run(options, files)
    cops = []
    cops << Cop::LineLengthCop

    files.each do |file|
      cops.each do |cop_klass|
        cop = cop_klass.new
        cop.inspect(file)
        cop.report
      end
    end
  end

  # Return configuration
  def self.configuration

  end
end

require 'rubocop/cop'
require 'rubocop/cli'
