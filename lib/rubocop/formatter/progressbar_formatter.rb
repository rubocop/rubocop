# frozen_string_literal: true

require 'ruby-progressbar'

module RuboCop
  module Formatter
    # This formatter displays only a progressbar and no additional output.
    #
    class ProgressbarFormatter < BaseFormatter
      def started(target_files)
        super

        file_phrase = target_files.count == 1 ? 'file' : 'files'

        # 185/407 files |====== 45 ======>                    |  ETA: 00:00:04
        # %c / %C       |       %w       >         %i         |       %e
        bar_format = " %c/%C #{file_phrase} |%w>%i| %e "

        @progressbar = ProgressBar.create(
          output: output,
          total: target_files.count,
          format: bar_format,
          autostart: false
        )

        @progressbar.start
      end

      def file_finished(_file, offenses)
        @progressbar.clear unless offenses.empty?

        @progressbar.increment
      end
    end
  end
end
