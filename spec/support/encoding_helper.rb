# frozen_string_literal: true

# Overwrite the default internal/external encoding for the duration of a block.
# Ruby discourages this by emitting a warning when modifying, these helpers exist
# to suppress these warnings during tests.
module EncodingHelper
  def with_default_internal_encoding(encoding)
    orig_encoding = Encoding.default_internal
    RuboCop::Util.silence_warnings { Encoding.default_internal = encoding }
    yield
  ensure
    RuboCop::Util.silence_warnings { Encoding.default_internal = orig_encoding }
  end

  def with_default_external_encoding(encoding)
    orig_encoding = Encoding.default_external
    RuboCop::Util.silence_warnings { Encoding.default_external = encoding }
    yield
  ensure
    RuboCop::Util.silence_warnings { Encoding.default_external = orig_encoding }
  end
end
