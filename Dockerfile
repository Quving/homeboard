FROM ruby:latest

WORKDIR /workdir
ADD . /workdir

RUN apt update && \
    apt install -y nodejs
RUN gem install dashing
RUN bundle

EXPOSE 3030
CMD ["dashing", "start"]

