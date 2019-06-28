# This class process files and collect results
class InspectConductor
  class << self
    def conductor_class(is_parallel)
      is_parallel ? ParallelConductor : SingleConductor
    end
  end

  attr_reader :errors, :warnings, :error_results, :inspected_files, :all_passed

  def initialize(files, formatter_set, fail_fast)
    @files = files
    @fail_fast= fail_fast
    @formatter_set = formatter_set

    @errors = []
    @warnings = []
    @error_results = []
    @inspected_files = []
    @all_passed = false

    @stop = false
  end

  def run_inspect
    results = inspect_files { |f| yield f }

    @all_passed = true
    results.each do |process_result|
      if process_result.error_file?
        @error_results << process_result
        next
      end

      @all_passed = @all_passed && process_result.passed

      filepath = process_result.filepath
      inspect_result = process_result.inspect_result

      @inspected_files << filepath
      @errors.concat(inspect_result.errors)
      @warnings.concat(inspect_result.warnings)
    end
  end

  private

  attr_reader :formatter_set

  def check_inspect_stop(process_result)
    passed = process_result.passed

    # if error raised or not passed and fail_fast option set, we need stop
    # but when ParallelConductor, the process will graceful shutdown
    need_exit = (process_result.error_file? || (!passed && @fail_fast))
    @stop = true if need_exit
  end

  def file_inspect_finished(process_result)
    if process_result.error_file?
      formatter_set.file_finished(process_result.filepath, process_result.error.offenses.compact.sort.freeze)
    else
      formatter_set.file_finished(process_result.filepath, process_result.inspect_result.offenses)
    end
  end
end

# When parallel option set, we use parallel gem
class ParallelConductor < InspectConductor
  def initialize(*)
    super
    @files = @files.dup # files is frozen array
  end

  # when @stop is true, abort all files
  def next_file
    return Parallel::Stop if @stop || @files.empty?
    @files.pop
  end

  # when the block finished, parallel gem call this method on main process with result
  def inspect_finished(_item, _i, process_result)
    file_inspect_finished(process_result)
    check_inspect_stop(process_result)
  end

  private

  def inspect_files
    Parallel.map(method(:next_file), finish: method(:inspect_finished)) do |f|
      yield f
    end
  end
end

class SingleConductor < InspectConductor

  private

  def inspect_files
    @files.map do |f|
      next if @stop

      process_result = yield f
      file_inspect_finished(process_result)
      check_inspect_stop(process_result)

      process_result
    end.compact
  end
end
