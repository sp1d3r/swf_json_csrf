FROM php:7.4-cli
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN echo "" > index.html
EXPOSE 8080
CMD [ "php", "-S", "0.0.0.0:8080" ]

