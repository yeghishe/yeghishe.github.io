FROM ruby:2.1.10-alpine
MAINTAINER Yeghishe Piruzyan ypiruzyan@gmail.com

RUN apk add --update alpine-sdk python
RUN gem install jekyll -v 3.2.1

EXPOSE 9003
VOLUME ["/src"]
WORKDIR /src

COPY Gemfile* /src/
RUN bundle install

CMD ["sh", "-c", "jekyll serve"]
