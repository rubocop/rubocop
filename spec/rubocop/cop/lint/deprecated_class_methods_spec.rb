# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::DeprecatedClassMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for File.exists?' do
    inspect_source(cop, 'File.exists?(o)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['`File.exists?` is deprecated in favor of `File.exist?`.'])
  end

  it 'registers an offense for ::File.exists?' do
    inspect_source(cop, '::File.exists?(o)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['`File.exists?` is deprecated in favor of `File.exist?`.'])
  end

  it 'does not register an offense for File.exist?' do
    inspect_source(cop, 'File.exist?(o)')
    expect(cop.messages).to be_empty
  end

  it 'registers an offense for Dir.exists?' do
    inspect_source(cop, 'Dir.exists?(o)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['`Dir.exists?` is deprecated in favor of `Dir.exist?`.'])
  end

  it 'auto-corrects File.exists? with File.exist?' do
    new_source = autocorrect_source(cop, 'File.exists?(something)')
    expect(new_source).to eq('File.exist?(something)')
  end

  it 'auto-corrects Dir.exists? with Dir.exist?' do
    new_source = autocorrect_source(cop, 'Dir.exists?(something)')
    expect(new_source).to eq('Dir.exist?(something)')
  end
end
