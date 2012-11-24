# encoding: utf-8

module Rubocop
  module Cop
    class Cop
      attr_accessor :offences

      @all = []
      @enabled = []
      @config = {}

      class << self
        attr_accessor :all
        attr_accessor :enabled
        attr_accessor :config
      end

      def self.inherited(subclass)
        puts "Registering cop #{subclass}"
        all << subclass
      end

      def self.enabled
        all.select(&:enabled?)
      end

      def self.enabled?
        true
      end

      def initialize
        @offences = []
      end

      def has_report?
        !@offences.empty?
      end

      def add_offence(file, line_number, line, message)
        @offences << Offence.new(file, line_number, line, message)
      end
    end
  end
end
