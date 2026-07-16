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

      class << self
        # The signature is a property of the index, not of the cop, and computing
        # it stats every indexed file, so all cops sharing an index share one
        # computation. A single-entry cache (instead of a hash keyed by index)
        # avoids retaining stale graphs in long-lived processes.
        attr_accessor :cached_index_signature
      end

      def external_dependency_checksum
        return nil unless project_index

        @external_dependency_checksum ||= Digest::SHA1.hexdigest(
          project_index_signature.join("\n")
        )
      end

      private

      # Returns the definitions among `definitions` that live in a file other than the
      # one being inspected, ordered by path and line. Definitions without a `file://`
      # URI (e.g. Rubydex's built-in declarations) are ignored.
      def definitions_in_other_files(definitions)
        current = processed_source.file_path

        definitions
          .select { |definition| definition.location.uri.start_with?(FILE_URI_PREFIX) }
          .reject { |definition| File.identical?(definition.location.to_file_path, current) }
          .sort_by do |definition|
          [definition.location.to_file_path,
           definition.location.start_line]
        end
      end

      def prior_definition_in_other_file(definitions)
        definitions_in_other_files(definitions).first
      end

      # Resolves a constant node the way Ruby does: the first segment through
      # the lexical nesting and every following segment inside the previous
      # one. (Qualified names cannot be passed to `resolve_constant` as a
      # whole, since it only applies the nesting to the full name.)
      def resolve_constant_in_index(const_node)
        segments = const_node.const_name.split('::')
        nesting = const_node.absolute? ? [] : lexical_nesting_of(const_node)

        declaration = project_index.resolve_constant(segments.first, nesting)
        segments.drop(1).each do |segment|
          return nil unless declaration.is_a?(Rubydex::Namespace)

          declaration = project_index.resolve_constant(segment, [declaration.name])
        end

        declaration
      end

      # The lexical nesting the node's constants resolve through, outermost
      # first. Only scopes whose *body* contains the node count: a class or
      # module's identifier and superclass expression are evaluated before its
      # scope exists, so ancestors reached through them are excluded.
      def lexical_nesting_of(node)
        nesting = []
        child = node

        node.each_ancestor do |ancestor|
          if ancestor.type?(:class, :module) && child.equal?(ancestor.body)
            nesting << ancestor.identifier.const_name
          end
          child = ancestor
        end

        nesting.reverse
      end

      # The declaration of `declaration`'s singleton class, or nil when no
      # singleton method is defined on it anywhere in the project.
      def indexed_singleton_of(declaration)
        project_index["#{declaration.name}::<#{declaration.name.split('::').last}>"]
      end

      # A namespace without any singleton method has no singleton-class
      # declaration of its own, so the lookup starts from the first ancestor
      # that has one; its `find_member` covers the rest of the chain.
      def indexed_singleton_member(namespace, member_name)
        namespace.ancestors.each do |ancestor|
          singleton = indexed_singleton_of(ancestor)
          return singleton.find_member(member_name) if singleton
        end

        nil
      end

      # Whether an ancestor of `scope` other than `scope` itself defines
      # `member_name`.
      def inherited_index_member?(scope, member_name)
        scope.ancestors.any? do |ancestor|
          ancestor.name != scope.name && ancestor.member(member_name)
        end
      end

      def same_file?(path, other)
        return true if File.identical?(path, other)

        normalized = [path, other].map { |p| File.expand_path(p).tr('\\', '/') }
        normalized.uniq.one? || (Platform.windows? && normalized[0].casecmp?(normalized[1]))
      end

      def project_index_signature
        index, signature = ProjectIndexHelp.cached_index_signature
        return signature if index.equal?(project_index)

        compute_project_index_signature.tap do |computed|
          ProjectIndexHelp.cached_index_signature = [project_index, computed]
        end
      end

      def compute_project_index_signature
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
