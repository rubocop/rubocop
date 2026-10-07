# frozen_string_literal: true

# Makes every instance of a cop raise from one of its callbacks, the way a cop
# with a bug would.
module FailingCopHelper
  def make_cop_fail(cop_class, callback, error, message)
    allow(cop_class).to receive(:new).and_wrap_original do |new, *args|
      cop = new.call(*args)
      allow(cop).to receive(callback).and_raise(error, message)
      cop
    end
  end
end
