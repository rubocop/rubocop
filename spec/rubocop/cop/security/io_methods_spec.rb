# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::IoMethods, :config do
  shared_examples 'offense' do |current, preferred, method_name|
    it "registers and corrects an offense when using `#{method_name}`" do
      expect_offense(<<~RUBY, current: current)
        #{current}
        ^{current} `File.#{method_name}` is safer than `IO.#{method_name}`.
      RUBY

      expect_correction(<<~RUBY)
        #{preferred}
      RUBY
    end
  end

  shared_examples 'accepts' do |code|
    it "does not register an offense when using `#{code}`" do
      expect_no_offenses(<<~RUBY)
        #{code}
      RUBY
    end
  end

  context 'when using `IO` receiver and variable argument' do
    it_behaves_like 'offense', 'IO.read(path)', 'File.read(path)', 'read'
    it_behaves_like 'offense', 'IO.write(path, "hi")', 'File.write(path, "hi")', 'write'
    it_behaves_like 'offense', 'IO.binread(path)', 'File.binread(path)', 'binread'
    it_behaves_like 'offense', 'IO.binwrite(path, "hi")', 'File.binwrite(path, "hi")', 'binwrite'
    it_behaves_like 'offense', 'IO.readlines(path)', 'File.readlines(path)', 'readlines'
    it 'registers and corrects an offense when using `foreach`' do
      expect_offense(<<~RUBY)
        IO.foreach(path) { |x| puts x }
        ^^^^^^^^^^^^^^^^ `File.foreach` is safer than `IO.foreach`.
      RUBY

      expect_correction(<<~RUBY)
        File.foreach(path) { |x| puts x }
      RUBY
    end
  end

  context 'when using `IO` receiver and string argument' do
    it_behaves_like 'offense', 'IO.read("command")', 'File.read("command")', 'read'
    it_behaves_like 'offense', 'IO.write("command", "hi")', 'File.write("command", "hi")', 'write'
    it_behaves_like 'offense', 'IO.binwrite("command", "hi")', 'File.binwrite("command", "hi")', 'binwrite'
    it_behaves_like 'offense', 'IO.binwrite(path, "hi")', 'File.binwrite(path, "hi")', 'binwrite'
    it_behaves_like 'offense', 'IO.readlines("command")', 'File.readlines("command")', 'readlines'
    it 'registers and corrects an offense when using `foreach`' do
      expect_offense(<<~RUBY)
        IO.foreach("command") { |x| puts x }
        ^^^^^^^^^^^^^^^^^^^^^ `File.foreach` is safer than `IO.foreach`.
      RUBY

      expect_correction(<<~RUBY)
        File.foreach("command") { |x| puts x }
      RUBY
    end
  end

  context 'when using `File` receiver' do
    it_behaves_like 'accepts', 'File.read(path)'
    it_behaves_like 'accepts', 'File.binread(path)'
    it_behaves_like 'accepts', 'File.binwrite(path, "hi")'
    it_behaves_like 'accepts', 'File.readlines(path)'
    it_behaves_like 'accepts', 'File.foreach(path) { |x| puts x }'
  end

  context 'when using no receiver' do
    it_behaves_like 'accepts', 'read("command")'
    it_behaves_like 'accepts', 'write("command", "hi")'
    it_behaves_like 'accepts', 'binwrite("command", "hi")'
    it_behaves_like 'accepts', 'readlines("command")'
    it_behaves_like 'accepts', 'foreach("command") { |x| puts x }'
  end

  context 'when using `IO` receiver and string argument that starts with a pipe character (`"| command"`)' do
    it_behaves_like 'accepts', 'IO.read("| command")'
    it_behaves_like 'accepts', 'IO.write("| command", "hi")'
    it_behaves_like 'accepts', 'IO.binwrite("| command", "hi")'
    it_behaves_like 'accepts', 'IO.readlines("| command")'
    it_behaves_like 'accepts', 'IO.foreach("| command") { |x| puts x }'
  end

  context 'when using `IO` receiver and string argument that starts with a pipe character (`" | command"`)' do
    it_behaves_like 'accepts', 'IO.read(" | command")'
    it_behaves_like 'accepts', 'IO.write(" | command", "hi")'
    it_behaves_like 'accepts', 'IO.binwrite(" | command", "hi")'
    it_behaves_like 'accepts', 'IO.readlines(" | command")'
    it_behaves_like 'accepts', 'IO.foreach(" | command") { |x| puts x }'
  end
end
