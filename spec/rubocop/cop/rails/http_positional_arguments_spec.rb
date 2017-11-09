# frozen_string_literal: true

describe RuboCop::Cop::Rails::HttpPositionalArguments do
  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'does not register an offense for post method' do
      expect_no_offenses('post :create, user_id: @user.id')
    end

    it 'does not register an offense for patch method' do
      expect_no_offenses('patch :update, user_id: @user.id')
    end

    it 'does not register an offense for delete method' do
      expect_no_offenses('delete :destroy, id: @user.id')
    end

    it 'accepts for not HTTP method' do
      expect_no_offenses('puts :create, user_id: @user.id')
    end

    describe 'when using process' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          process :new, method: :get, params: { user_id: @user.id }
        RUBY
      end
    end

    [
      'params: { user_id: @user.id }',
      'xhr: true',
      'session: { foo: \'bar\' }',
      'format: :json'
    ].each do |keyword_args|
      describe "when using keyword args #{keyword_args}" do
        let(:source) do
          "get :new, #{keyword_args}"
        end

        it 'does not register an offense' do
          inspect_source(source)
          expect(cop.messages.empty?).to be(true)
        end
      end
    end

    describe '.get' do
      let(:source) do
        'get :new, user_id: @user.id'
      end

      it 'does not register an offense' do
        expect_no_offenses('get :new, user_id: @user.id')
      end

      it 'does not auto-correct' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end

      describe 'no params' do
        it 'does not register an offense' do
          expect_no_offenses('get :new')
        end
      end
    end

    describe '.patch' do
      let(:source) do
        <<-RUBY.strip_indent
        patch :update,
                  id: @user.id,
                  ac: {
                    article_id: @article1.id,
                    profile_id: @profile1.id,
                    content: 'Some Text'
                  }
        RUBY
      end

      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          patch :update,
                    id: @user.id,
                    ac: {
                      article_id: @article1.id,
                      profile_id: @profile1.id,
                      content: 'Some Text'
                    }
        RUBY
      end

      it 'does not auto-correct' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end
    end

    describe '.post' do
      let(:source) do
        <<-RUBY.strip_indent
        post :create,
                  id: @user.id,
                  ac: {
                    article_id: @article1.id,
                    profile_id: @profile1.id,
                    content: 'Some Text'
                  }
        RUBY
      end

      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          post :create,
                    id: @user.id,
                    ac: {
                      article_id: @article1.id,
                      profile_id: @profile1.id,
                      content: 'Some Text'
                    }
        RUBY
      end

      it 'does not auto-correct' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end
    end

    %w[post get patch put delete].each do |keyword|
      it 'does not register an offense when keyword' do
        source = "@user.#{keyword}.id = ''"
        inspect_source(source)
        expect(cop.offenses.size).to eq(0)
      end
    end

    it 'does not auto-correct http action when method' do
      source = 'post user_attrs, id: 1'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct http action when symbol' do
      source = 'post :user_attrs, id: 1'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct' do
      source = 'post(:user_attrs, id: 1)'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not register when post is found' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if post.stint_title.present?
         true
         end
      RUBY
    end

    it 'does not remove quotes when single quoted' do
      source = "get '/auth/linkedin/callback'"
      new_source = autocorrect_source(source)
      expect(new_source).to eq("get '/auth/linkedin/callback'")
    end

    it 'does not remove quotes when double quoted' do
      source = 'get "/auth/linkedin/callback"'
      new_source = autocorrect_source(source)
      expect(new_source).to eq('get "/auth/linkedin/callback"')
    end

    it 'does not add headers keyword when env or headers are used' do
      source = 'get some_path(profile.id), {},'
      source += " 'HTTP_REFERER' => p_url(p.id).to_s"
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not duplicate brackets when hash is already supplied' do
      source = 'get some_path(profile.id), '
      source += '{ user_id: @user.id, profile_id: p.id },'
      source += " 'HTTP_REFERER' => p_url(p.id).to_s"
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct http action when params is a method call' do
      source = 'post :create, confirmation_data'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct http action when params and action names ' \
      'are method calls' do
      source = 'post user_attrs, params'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    # rubocop:disable LineLength
    it 'does not auto-correct http action when parameter matches keyword name' do
      source = 'post :create, id: 7, comment: { body: "hei" }'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct http action when format keyword included ' \
      'but not alone' do
      source = 'post :create, id: 7, format: :rss'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct when params is a lvar' do
      source = <<-RUBY.strip_indent
        params = { id: 1 }
        post user_attrs, params
      RUBY
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end

    it 'does not auto-correct http action when params is a method call ' \
      'with chain' do
      source = 'post user_attrs, params.merge(foo: bar)'
      inspect_source(source)
      expect(cop.offenses.size).to eq(0)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(source)
    end
  end

  context 'rails 5 and above', :rails5 do
    subject(:cop) { described_class.new }

    it 'registers an offense for post method' do
      source = 'post :create, user_id: @user.id'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for patch method' do
      source = 'patch :update, user_id: @user.id'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for delete method' do
      source = 'delete :destroy, id: @user.id'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts for not HTTP method' do
      expect_no_offenses('puts :create, user_id: @user.id')
    end

    describe 'when using process' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          process :new, method: :get, params: { user_id: @user.id }
        RUBY
      end
    end

    [
      'params: { user_id: @user.id }',
      'xhr: true',
      'session: { foo: \'bar\' }',
      'format: :json'
    ].each do |keyword_args|
      describe "when using keyword args #{keyword_args}" do
        let(:source) do
          "get :new, #{keyword_args}"
        end

        it 'does not register an offense' do
          inspect_source(source)
          expect(cop.messages.empty?).to be(true)
        end
      end
    end

    describe '.get' do
      let(:source) do
        'get :new, user_id: @user.id'
      end

      let(:corrected_result) do
        'get :new, params: { user_id: @user.id }'
      end

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          get :new, user_id: @user.id
          ^^^ Use keyword arguments instead of positional arguments for http call: `get`.
        RUBY
      end

      it 'autocorrects offense' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(corrected_result)
      end

      describe 'no params' do
        it 'does not register an offense' do
          expect_no_offenses('get :new')
        end
      end
    end

    describe '.patch' do
      let(:source) do
        <<-RUBY.strip_indent
        patch :update,
                  id: @user.id,
                  ac: {
                    article_id: @article1.id,
                    profile_id: @profile1.id,
                    content: 'Some Text'
                  }
        RUBY
      end

      let(:corrected_result) do
        <<-RUBY.strip_indent
        patch :update, params: { id: @user.id, ac: {
                    article_id: @article1.id,
                    profile_id: @profile1.id,
                    content: 'Some Text'
                  } }
        RUBY
      end

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          patch :update,
          ^^^^^ Use keyword arguments instead of positional arguments for http call: `patch`.
                    id: @user.id,
                    ac: {
                      article_id: @article1.id,
                      profile_id: @profile1.id,
                      content: 'Some Text'
                    }
        RUBY
      end

      it 'autocorrects offense' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(corrected_result)
      end
    end

    describe '.post' do
      let(:source) do
        <<-RUBY.strip_indent
        post :create,
                  id: @user.id,
                  ac: {
                    article_id: @article1.id,
                    profile_id: @profile1.id,
                    content: 'Some Text'
                  }
        RUBY
      end

      let(:corrected_result) do
        <<-RUBY.strip_indent
        post :create, params: { id: @user.id, ac: {
                    article_id: @article1.id,
                    profile_id: @profile1.id,
                    content: 'Some Text'
                  } }
        RUBY
      end

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          post :create,
          ^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
                    id: @user.id,
                    ac: {
                      article_id: @article1.id,
                      profile_id: @profile1.id,
                      content: 'Some Text'
                    }
        RUBY
      end

      it 'autocorrects offense' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(corrected_result)
      end
    end

    %w[post get patch put delete].each do |keyword|
      it 'does not register an offense when keyword' do
        source = "@user.#{keyword}.id = ''"
        inspect_source(source)
        expect(cop.offenses.size).to eq(0)
      end
    end

    it 'auto-corrects http action when method' do
      source = 'post user_attrs, id: 1'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      expected = 'post user_attrs, params: { id: 1 }'
      expect(new_source).to eq(expected)
    end

    it 'auto-corrects http action when symbol' do
      source = 'post :user_attrs, id: 1'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      expected = 'post :user_attrs, params: { id: 1 }'
      expect(new_source).to eq(expected)
    end

    it 'maintains parentheses in auto-correcting' do
      source = 'post(:user_attrs, id: 1)'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      expected = 'post(:user_attrs, params: { id: 1 })'
      expect(new_source).to eq(expected)
    end

    it 'does not register when post is found' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if post.stint_title.present?
         true
         end
      RUBY
    end

    it 'does not remove quotes when single quoted' do
      source = "get '/auth/linkedin/callback'"
      new_source = autocorrect_source(source)
      expect(new_source).to eq("get '/auth/linkedin/callback'")
    end

    it 'does not remove quotes when double quoted' do
      source = 'get "/auth/linkedin/callback"'
      new_source = autocorrect_source(source)
      expect(new_source).to eq('get "/auth/linkedin/callback"')
    end

    it 'does add headers keyword when env or headers are used' do
      source = 'get some_path(profile.id), {},'
      source += " 'HTTP_REFERER' => p_url(p.id).to_s"
      new_source = autocorrect_source(source)
      output = 'get some_path(profile.id),'
      output += " headers: { 'HTTP_REFERER' => p_url(p.id).to_s }"
      expect(new_source).to eq(output)
    end

    it 'does not duplicate brackets when hash is already supplied' do
      source = 'get some_path(profile.id), '
      source += '{ user_id: @user.id, profile_id: p.id },'
      source += " 'HTTP_REFERER' => p_url(p.id).to_s"
      new_source = autocorrect_source(source)
      output = 'get some_path(profile.id), params:'
      output += ' { user_id: @user.id, profile_id: p.id },'
      output += " headers: { 'HTTP_REFERER' => p_url(p.id).to_s }"
      expect(new_source).to eq(output)
    end

    it 'auto-corrects http action when params is a method call' do
      source = 'post :create, confirmation_data'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      output = 'post :create, params: confirmation_data'
      expect(new_source).to eq(output)
    end

    it 'auto-corrects http action when parameter matches special keyword name' do
      source = 'post :create, id: 7, comment: { body: "hei" }'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      output = 'post :create, params: { id: 7, comment: { body: "hei" } }'
      expect(new_source).to eq(output)
    end

    it 'auto-corrects http action when format keyword included but not alone' do
      source = 'post :create, id: 7, format: :rss'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      output = 'post :create, params: { id: 7, format: :rss }'
      expect(new_source).to eq(output)
    end

    it 'auto-corrects http action when params is a lvar' do
      source = <<-RUBY.strip_indent
        params = { id: 1 }
        post user_attrs, params
      RUBY
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        params = { id: 1 }
        post user_attrs, params: params
      RUBY
    end

    it 'auto-corrects http action when params and action name are method calls' do
      source = 'post user_attrs, params'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      expected = 'post user_attrs, params: params'
      expect(new_source).to eq(expected)
    end

    it 'auto-corrects http action when params is a method call with chain' do
      source = 'post user_attrs, params.merge(foo: bar)'
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
      new_source = autocorrect_source(source)
      expected = 'post user_attrs, params: params.merge(foo: bar)'
      expect(new_source).to eq(expected)
    end
  end
end
# rubocop:enable LineLength
