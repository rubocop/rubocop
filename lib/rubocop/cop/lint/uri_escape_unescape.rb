# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop identifies places where `URI.escape` can be replaced by
      # `CGI.escape`, `URI.encode_www_form`, `URI.encode_www_form_component`
      # or `ERB::Util.url_encode` depending on your specific use case.
      # Also this cop identifies places where `URI.unescape` can be replaced by
      # `CGI.unescape`, `URI.decode_www_form`,
      # or `URI.decode_www_form_component` depending on your specific use case.
      #
      # @example
      #   # bad
      #   URI.escape('http://example.com')
      #   URI.encode('http://example.com')
      #
      #   # good
      #   CGI.escape('http://example.com')
      #   URI.encode_www_form([['example', 'param'], ['lang', 'en']])
      #   URI.encode_www_form(page: 10, locale: 'en')
      #   URI.encode_www_form_component('http://example.com')
      #   ERB::Util.url_encode('http://example.com')
      #
      #   # bad
      #   URI.unescape(enc_uri)
      #   URI.decode(enc_uri)
      #
      #   # good
      #   CGI.unescape(enc_uri)
      #   URI.decode_www_form(enc_uri)
      #   URI.decode_www_form_component(enc_uri)
      class UriEscapeUnescape < Cop
        ALTERNATE_METHODS_OF_URI_ESCAPE = %w[
          CGI.escape
          URI.encode_www_form
          URI.encode_www_form_component
          ERB::Util.url_encode
        ].freeze
        ALTERNATE_METHODS_OF_URI_UNESCAPE = %w[
          CGI.unescape
          URI.decode_www_form
          URI.decode_www_form_component
        ].freeze

        MSG = '`%<uri_method>s` method is obsolete and should not be used. ' \
              'Instead, use %<replacements>s depending on your specific use ' \
              'case.'.freeze

        def_node_matcher :uri_escape_unescape?, <<-PATTERN
          (send
            (const ${nil? cbase} :URI) ${:escape :encode :unescape :decode}
            ...)
        PATTERN

        def on_send(node)
          uri_escape_unescape?(node) do |top_level, obsolete_method|
            double_colon = top_level ? '::' : ''

            message = format(
              MSG, uri_method: "#{double_colon}URI.#{obsolete_method}",
                   replacements: replacements_string(obsolete_method)
            )

            add_offense(node, message: message)
          end
        end

        private

        def replacements_string(obsolete_method)
          if %i[escape encode].include?(obsolete_method)
            "`#{ALTERNATE_METHODS_OF_URI_ESCAPE[0]}`, " \
            "`#{ALTERNATE_METHODS_OF_URI_ESCAPE[1]}`, " \
            "`#{ALTERNATE_METHODS_OF_URI_ESCAPE[2]}` " \
            "or `#{ALTERNATE_METHODS_OF_URI_ESCAPE[3]}`"
          else
            "`#{ALTERNATE_METHODS_OF_URI_UNESCAPE[0]}`, " \
            "`#{ALTERNATE_METHODS_OF_URI_UNESCAPE[1]}` " \
            "or `#{ALTERNATE_METHODS_OF_URI_UNESCAPE[2]}`"
          end
        end
      end
    end
  end
end
