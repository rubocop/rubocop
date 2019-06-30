# frozen_string_literal: true

# This class process files and collect results
class InspectConductor
  class << self
    def conductor_class(is_parallel)
      is_parallel ? ParallelConductor : SingleConductor
    end
  end

  attr_reader :errors, :warnings, :error_results, :inspected_files, :all_passed

  def initialize(files, formatter_set, fail_fast, process_num)
    @files = files
    @fail_fast = fail_fast
    @formatter_set = formatter_set
    @process_num = process_num

    @errors = []
    @warnings = []
    @error_results = []
    @inspected_files = []
    @all_passed = false

    @process_results = []
    @stop = false
  end

  def run_inspect
    inspect_files { |f| yield f }
  ensure
    save_results
  end

  def first_error_object
    @error_results.first ? @error_results.first.error : nil
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
    offenses = if process_result.error_file?
                 process_result.error.offenses.compact.sort.freeze
               else
                 process_result.inspect_result.offenses
               end

    formatter_set.file_finished(process_result.filepath, offenses)
    @process_results << process_result
  end

  def save_results
    @all_passed = true
    @process_results.each do |process_result|
      if process_result.error_file?
        @error_results << process_result
        @all_passed = false
        next
      end

      @all_passed &&= process_result.passed

      @inspected_files << process_result.filepath

      inspect_result = process_result.inspect_result
      @errors.concat(inspect_result.errors)
      @warnings.concat(inspect_result.warnings)
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

  # parallel gem call this method on main process with result
  def inspect_finished(_item, _index, process_result)
    file_inspect_finished(process_result)
    check_inspect_stop(process_result)
  end

  private

  def inspect_files
    Parallel.each(method(:next_file),
                  finish: method(:inspect_finished),
                  in_process: @process_num) do |f|
      yield f
    end
  end
end

# When parallel option doesn't set, we use normal loop
class SingleConductor < InspectConductor
  private

  def inspect_files
    @files.each do |f|
      process_result = yield f
      file_inspect_finished(process_result)
      check_inspect_stop(process_result)

      break if @stop
    end
  end
end
