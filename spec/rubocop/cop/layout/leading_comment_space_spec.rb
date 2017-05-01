# frozen_string_literal: true

describe RuboCop::Cop::Layout::LeadingCommentSpace do
  subject(:cop) { described_class.new }

  it 'registers an offense for comment without leading space' do
    inspect_source(cop, '#missing space')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for # followed by no text' do
    expect_no_offenses('#')
  end

  it 'does not register an offense for more than one space' do
    expect_no_offenses('#   heavily indented')
  end

  it 'does not register an offense for more than one #' do
    expect_no_offenses('###### heavily indented')
  end

  it 'does not register an offense for only #s' do
    expect_no_offenses('######')
  end

  it 'does not register an offense for #! on first line' do
    expect_no_offenses(<<-END.strip_indent)
      #!/usr/bin/ruby
      test
    END
  end

  it 'registers an offense for #! after the first line' do
    inspect_source(cop, <<-END.strip_indent)
      test
      #!/usr/bin/ruby
    END
    expect(cop.offenses.size).to eq(1)
  end

  context 'file named config.ru' do
    it 'does not register an offense for #\ on first line' do
      inspect_source(cop,
                     ['#\ -w -p 8765',
                      'test'],
                     '/some/dir/config.ru')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for #\ after the first line' do
      inspect_source(cop,
                     ['test',
                      '#\ -w -p 8765'],
                     '/some/dir/config.ru')
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'file not named config.ru' do
    it 'registers an offense for #\ on first line' do
      inspect_source(cop,
                     ['#\ -w -p 8765',
                      'test'],
                     '/some/dir/test_case.rb')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for #\ after the first line' do
      inspect_source(cop,
                     ['test',
                      '#\ -w -p 8765'],
                     '/some/dir/test_case.rb')
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts rdoc syntax' do
    expect_no_offenses(<<-END.strip_indent)
      #++
      #--
      #:nodoc:
    END
  end

  it 'accepts sprockets directives' do
    expect_no_offenses('#= require_tree .')
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, '#comment')
    expect(new_source).to eq('# comment')
  end

  it 'accepts =begin/=end comments' do
    expect_no_offenses(<<-END.strip_indent)
      =begin
      #blahblah
      =end
    END
  end
end
