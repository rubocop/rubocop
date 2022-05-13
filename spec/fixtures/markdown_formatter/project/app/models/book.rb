class Book < ActiveRecord::Base
  def someMethod
    foo = bar = baz
    Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(full_document)[1] rescue full_document
  end
end
