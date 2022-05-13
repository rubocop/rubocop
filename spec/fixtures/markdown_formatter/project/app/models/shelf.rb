# frozen_string_literal: true

# Book class comment
class Book < ActiveRecord::Base
  def some_method
    Regexp.new(%r{\A<p>(.*)</p>\Z}m).match(full_document)[1]
  rescue StandardError
    full_document
  end
end
