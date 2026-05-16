# frozen_string_literal: true

module RuboCop
  module Cop
    # Common helpers for cops that consult the project-wide static-analysis index
    # via `Cop::Base#project_index`.
    #
    # Mixed-in cops gain the `external_dependency_checksum` override that invalidates
    # the `ResultCache` whenever the indexed project files change on disk.
    # To run index-backed analysis, cops should simply check whether `project_index` is non-nil;
    # the runner only exposes a non-nil index when the user opted in via `AllCops/UseProjectIndex`
    # and the underlying gem is available.
    module ProjectIndexHelp
      BUILTIN_DOCUMENT_URI = 'rubydex:built-in'
      FILE_URI_PREFIX = 'file://'
      # Matches the spurious leading slash before a Windows drive letter that
      # remains after stripping `file://` from a `file:///C:/...` URI.
      WINDOWS_DRIVE_PREFIX = %r{\A/(?=[A-Za-z]:[/\\])}.freeze

      def external_dependency_checksum
        return nil unless project_index

        @external_dependency_checksum ||= Digest::SHA1.hexdigest(
          project_index_signature.join("\n")
        )
      end

      private

      def project_index_signature
        project_index.documents.filter_map do |doc|
          uri = doc.uri
          next if uri == BUILTIN_DOCUMENT_URI

          path = uri.delete_prefix(FILE_URI_PREFIX).sub(WINDOWS_DRIVE_PREFIX, '')
          mtime, size = begin
            stat = File.stat(path)
            [stat.mtime.to_f, stat.size]
          rescue StandardError
            [0, 0]
          end

          "#{path}:#{mtime}:#{size}"
        end.sort
      end
    end
  end
end
