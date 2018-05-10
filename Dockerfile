FROM ruby:2.3.3

WORKDIR /workdir
ADD . /workdir

RUN apt update && \
    apt install -y nodejs
RUN gem install dashing
RUN gem install bundler
RUN bundle

EXPOSE 3030
CMD ["dashing", "start"]

