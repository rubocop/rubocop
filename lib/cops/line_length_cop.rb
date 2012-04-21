class LineLengthCop
  def inspect(file)
    IO.readlines(file).select { |line| line.size > 80 }.each do |line|
      puts "#{line} is longer than 80 chars"
    end
  end
end
