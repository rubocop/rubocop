FROM ruby:2.5.0
RUN gem install rubocop
WORKDIR /code
ENTRYPOINT [ "rubocop","." ]