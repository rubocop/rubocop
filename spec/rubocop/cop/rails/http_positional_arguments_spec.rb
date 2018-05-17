# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HttpPositionalArguments do
  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'does not register an offense for get method' do
      expect_no_offenses('get :create, user_id: @user.id')
    end

    it 'does not register an offense for post method' do
      expect_no_offenses('post :create, user_id: @user.id')
    end

    it 'does not register an offense for patch method' do
      expect_no_offenses('patch :update, user_id: @user.id')
    end

    it 'does not register an offense for put method' do
      expect_no_offenses('put :update, user_id: @user.id')
    end

    it 'does not register an offense for delete method' do
      expect_no_offenses('delete :destroy, id: @user.id')
    end

    it 'does not register an offense for head method' do
      expect_no_offenses('head :destroy, id: @user.id')
    end

    it 'does not register an offense for process method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        process :new, method: :get, params: { user_id: @user.id }
      RUBY
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
          expect_no_offenses(source)
        end
      end
    end

    describe '.get' do
      it 'does not register an offense' do
        expect_no_offenses('get :new, user_id: @user.id')
      end

      describe 'no params' do
        it 'does not register an offense' do
          expect_no_offenses('get :new')
        end
      end
    end

    describe '.patch' do
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
    end

    describe '.post' do
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
    end

    %w[get post patch put head delete].each do |keyword|
      it 'does not register an offense when keyword is used ' \
        'in a chained method call' do
        expect_no_offenses("@user.#{keyword}.id = ''")
      end
    end
  end

  context 'rails 5 and above', :rails5 do
    subject(:cop) { described_class.new }

    it 'registers an offense for get method' do
      expect_offense(<<-RUBY.strip_indent)
        get :create, user_id: @user.id
        ^^^ Use keyword arguments instead of positional arguments for http call: `get`.
      RUBY
    end

    it 'registers an offense for post method' do
      expect_offense(<<-RUBY.strip_indent)
        post :create, user_id: @user.id
        ^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY
    end

    it 'registers an offense for patch method' do
      expect_offense(<<-RUBY.strip_indent)
        patch :update, user_id: @user.id
        ^^^^^ Use keyword arguments instead of positional arguments for http call: `patch`.
      RUBY
    end

    it 'registers an offense for put method' do
      expect_offense(<<-RUBY.strip_indent)
        put :create, user_id: @user.id
        ^^^ Use keyword arguments instead of positional arguments for http call: `put`.
      RUBY
    end

    it 'registers an offense for delete method' do
      expect_offense(<<-RUBY.strip_indent)
        delete :create, user_id: @user.id
        ^^^^^^ Use keyword arguments instead of positional arguments for http call: `delete`.
      RUBY
    end

    it 'registers an offense for head method' do
      expect_offense(<<-RUBY.strip_indent)
        head :create, user_id: @user.id
        ^^^^ Use keyword arguments instead of positional arguments for http call: `head`.
      RUBY
    end

    it 'accepts non HTTP methods' do
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
      'method: :get',
      'params: { user_id: @user.id }',
      'xhr: true',
      'session: { foo: \'bar\' }',
      'format: :json',
      'headers: {}',
      'body: "foo"',
      'flash: {}',
      'as: :json',
      'env: "test"'
    ].each do |keyword_args|
      describe "when using keyword args #{keyword_args}" do
        it 'does not register an offense' do
          expect_no_offenses("get :new, #{keyword_args}")
        end
      end
    end

    describe '.get' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          get :new, user_id: @user.id
          ^^^ Use keyword arguments instead of positional arguments for http call: `get`.
        RUBY
      end

      it 'autocorrects offense' do
        new_source = autocorrect_source('get :new, user_id: @user.id')
        expect(new_source).to eq('get :new, params: { user_id: @user.id }')
      end

      describe 'no params' do
        it 'does not register an offense' do
          expect_no_offenses('get :new')
        end
      end
    end

    describe '.patch' do
      it 'autocorrects offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          patch :update,
                id: @user.id,
                ac: {
                  article_id: @article1.id,
                  profile_id: @profile1.id,
                  content: 'Some Text'
                }
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          patch :update, params: { id: @user.id, ac: {
                  article_id: @article1.id,
                  profile_id: @profile1.id,
                  content: 'Some Text'
                } }
        RUBY
      end
    end

    describe '.post' do
      it 'autocorrects offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          post :create,
               id: @user.id,
               ac: {
                 article_id: @article1.id,
                 profile_id: @profile1.id,
                 content: 'Some Text'
               }
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
        post :create, params: { id: @user.id, ac: {
               article_id: @article1.id,
               profile_id: @profile1.id,
               content: 'Some Text'
             } }
        RUBY
      end
    end

    %w[head post get patch put delete].each do |keyword|
      it 'does not register an offense when keyword' do
        expect_no_offenses("@user.#{keyword}.id = ''")
      end
    end

    it 'auto-corrects http action when method' do
      new_source = autocorrect_source('post user_attrs, id: 1')
      expect(new_source).to eq('post user_attrs, params: { id: 1 }')
    end

    it 'auto-corrects http action when symbol' do
      new_source = autocorrect_source('post :user_attrs, id: 1')
      expect(new_source).to eq('post :user_attrs, params: { id: 1 }')
    end

    it 'maintains parentheses when auto-correcting' do
      new_source = autocorrect_source('post(:user_attrs, id: 1)')
      expect(new_source).to eq('post(:user_attrs, params: { id: 1 })')
    end

    it 'maintains quotes when auto-correcting' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        get '/auth/linkedin/callback', id: 1
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        get '/auth/linkedin/callback', params: { id: 1 }
      RUBY
    end

    it 'does add session keyword when session is used' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        get some_path(profile.id), {}, 'HTTP_REFERER' => p_url(p.id).to_s
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        get some_path(profile.id), session: { 'HTTP_REFERER' => p_url(p.id).to_s }
      RUBY
    end

    it 'does not duplicate brackets when hash is already supplied' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        get some_path(profile.id), { user_id: @user.id, profile_id: p.id }, 'HTTP_REFERER' => p_url(p.id).to_s
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        get some_path(profile.id), params: { user_id: @user.id, profile_id: p.id }, session: { 'HTTP_REFERER' => p_url(p.id).to_s }
      RUBY
    end

    it 'auto-corrects http action when params is a method call' do
      new_source = autocorrect_source('post :create, confirmation_data')
      expect(new_source).to eq('post :create, params: confirmation_data')
    end

    it 'auto-corrects http action when parameter matches ' \
      'special keyword name' do
      new_source = autocorrect_source(<<-RUBY)
        post :create, id: 7, comment: { body: "hei" }
      RUBY

      expect(new_source).to eq(<<-RUBY)
        post :create, params: { id: 7, comment: { body: "hei" } }
      RUBY
    end

    it 'auto-corrects http action when format keyword included but not alone' do
      new_source = autocorrect_source('post :create, id: 7, format: :rss')
      expect(new_source).to eq('post :create, params: { id: 7, format: :rss }')
    end

    it 'auto-corrects http action when params is a lvar' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        params = { id: 1 }
        post user_attrs, params
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        params = { id: 1 }
        post user_attrs, params: params
      RUBY
    end

    it 'auto-corrects http action when params and action name ' \
      'are method calls' do
      new_source = autocorrect_source('post user_attrs, params')
      expect(new_source).to eq('post user_attrs, params: params')
    end

    it 'auto-corrects http action when params is a method call with chain' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        post user_attrs, params.merge(foo: bar)
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        post user_attrs, params: params.merge(foo: bar)
      RUBY
    end
  end
end
