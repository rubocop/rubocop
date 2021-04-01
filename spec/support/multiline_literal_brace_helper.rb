# frozen_string_literal: true

module MultilineLiteralBraceHelper
  # Construct the source code for the braces. For instance, for an array
  # the `open` brace would be `[` and the `close` brace would be `]`, so
  # you could construct the following:
  #
  #     braces(true, 'a', 'b', 'c', false)
  #
  #     [ # line break indicated by `true` as the first argument.
  #     a,
  #     b,
  #     c] # no line break indicated by `false` as the last argument.
  #
  # This method also supports multi-line arguments. For example:
  #
  #     braces(true, 'a', ['{', 'foo: bar', '}'], true)
  #
  #     [ # line break indicated by `true` as the first argument.
  #     a,
  #     {
  #     foo: bar
  #     } # line break indicated by `true` as the last argument.
  #     ]
  def braces(open_line_break, *args, close_line_break)
    args = default_args if args.empty?

    open + (open_line_break ? "\n" : '') +
      args.map { |a| a.respond_to?(:join) ? a.join("\n") : a }.join(",\n") +
      (close_line_break ? "\n" : '') + close
  end

  def default_args
    [a, b + b_comment]
  end

  # Construct a piece of source code for brace layout testing. This farms
  # out most of the work to `#braces` but it also includes a prefix and suffix.
  def construct(*args)
    "#{prefix}#{braces(*args)}\n#{suffix}"
  end
end
