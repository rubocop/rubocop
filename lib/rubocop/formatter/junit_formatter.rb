# frozen_string_literal: true

require 'rexml/document'

#
# This code is based on https://github.com/mikian/rubocop-junit-formatter.
#
# Copyright (c) 2015 Mikko Kokkonen
#
# MIT License
#
# https://github.com/mikian/rubocop-junit-formatter/blob/master/LICENSE.txt
#
module RuboCop
  module Formatter
    # This formatter formats the report data in JUnit format.
    class JUnitFormatter < BaseFormatter
      def initialize(output, options = {})
        super

        @document = REXML::Document.new.tap do |document|
          document << REXML::XMLDecl.new
        end
        testsuites = REXML::Element.new('testsuites', @document)
        testsuite = REXML::Element.new('testsuite', testsuites)
        @testsuite = testsuite.tap do |element|
          element.add_attributes('name' => 'rubocop')
        end
      end

      def file_finished(file, offenses)
        offenses.group_by(&:cop_name).each do |cop_name, grouped_offenses|
          REXML::Element.new('testcase', @testsuite).tap do |testcase|
            testcase.attributes['classname'] = file.gsub(
              /\.rb\Z/, ''
            ).gsub("#{Dir.pwd}/", '').tr('/', '.')
            testcase.attributes['name'] = cop_name

            add_failure_to(testcase, grouped_offenses, cop_name)
          end
        end
      end

      def finished(_inspected_files)
        @document.write(output, 2)
      end

      private

      def add_failure_to(testcase, offenses, cop_name)
        # One failure per offense. Zero failures is a passing test case,
        # for most surefire/nUnit parsers.
        offenses.each do |offense|
          REXML::Element.new('failure', testcase).tap do |failure|
            failure.attributes['type'] = cop_name
            failure.attributes['message'] = offense.message
            failure.add_text(offense.location.to_s)
          end
        end
      end
    end
  end
end
