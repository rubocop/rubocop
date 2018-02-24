FROM ruby:alpine
RUN gem install rubocop
WORKDIR /code
ENTRYPOINT [ "rubocop","." ]