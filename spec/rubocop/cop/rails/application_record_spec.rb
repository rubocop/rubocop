# frozen_string_literal: true

describe RuboCop::Cop::Rails::ApplicationRecord do
  let(:msgs) { [described_class::MSG] }

  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'allows ApplicationRecord to be defined' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class ApplicationRecord < ActiveRecord::Base
        end
      RUBY
    end

    it 'allows models that subclass ActiveRecord::Base' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class MyModel < ActiveRecord::Base
        end
      RUBY
    end

    it 'allows a single-line class definitions' do
      expect_no_offenses('class MyModel < ActiveRecord::Base; end')
    end

    it 'allows namespaced models that subclass ActiveRecord::Base' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Nested
          class MyModel < ActiveRecord::Base
          end
        end
      RUBY
    end

    it 'allows models defined using nested constants' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Nested::MyModel < ActiveRecord::Base
        end
      RUBY
    end

    it 'allows models defined using Class.new' do
      expect_no_offenses('MyModel = Class.new(ActiveRecord::Base)')
    end

    it 'allows nested models defined using Class.new' do
      expect_no_offenses('Nested::MyModel = Class.new(ActiveRecord::Base)')
    end

    it 'allows anonymous models' do
      expect_no_offenses('Class.new(ActiveRecord::Base) {}')
    end

    it 'allows ApplicationRecord defined using Class.new' do
      expect_no_offenses('ApplicationRecord = Class.new(ActiveRecord::Base)')
    end
  end

  context 'rails 5', :rails5 do
    subject(:cop) { described_class.new }

    it 'allows ApplicationRecord to be defined' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class ApplicationRecord < ActiveRecord::Base
        end
      RUBY
    end

    it 'corrects models that subclass ActiveRecord::Base' do
      source = "class MyModel < ActiveRecord::Base\nend"
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq("class MyModel < ApplicationRecord\nend")
    end

    it 'corrects single-line class definitions' do
      source = 'class MyModel < ActiveRecord::Base; end'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('class MyModel < ApplicationRecord; end')
    end

    it 'corrects namespaced models that subclass ActiveRecord::Base' do
      source = "module Nested\n  class MyModel < ActiveRecord::Base\n  end\nend"
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq("module Nested\n  class MyModel < ApplicationRecord\n  end\nend")
    end

    it 'corrects models defined using nested constants' do
      source = "class Nested::MyModel < ActiveRecord::Base\nend"
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq("class Nested::MyModel < ApplicationRecord\nend")
    end

    it 'corrects models defined using Class.new' do
      source = 'MyModel = Class.new(ActiveRecord::Base)'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('MyModel = Class.new(ApplicationRecord)')
    end

    it 'corrects nested models defined using Class.new' do
      source = 'Nested::MyModel = Class.new(ActiveRecord::Base)'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('Nested::MyModel = Class.new(ApplicationRecord)')
    end

    it 'corrects anonymous models' do
      source = 'Class.new(ActiveRecord::Base) {}'
      inspect_source(cop, source)
      expect(cop.messages).to eq(msgs)
      expect(cop.highlights).to eq(['ActiveRecord::Base'])
      expect(autocorrect_source(cop, source))
        .to eq('Class.new(ApplicationRecord) {}')
    end

    it 'allows ApplicationRecord defined using Class.new' do
      expect_no_offenses('ApplicationRecord = Class.new(ActiveRecord::Base)')
    end
  end
end
