## Compile the PHAR in the first multi-stage image ##
FROM php:8.1-cli-alpine as build

ENV COMPOSER_ALLOW_SUPERUSER=1

# Copy Composer from official image
COPY --from=composer/composer:2-bin /composer /usr/bin/composer

# Allow to generate .phar files
RUN echo -e "[PHP]\nphar.readonly = Off" >> /usr/local/etc/php/php.ini

WORKDIR /app/

# Copy sources files
COPY ./ /app/

ARG VERSION

# Install dependencies and build PHAR
RUN composer install --no-dev --quiet && /app/bin/build -v$VERSION


## Create the final image ##
FROM php:8.1-cli-alpine

# Copy the PHAR file from the first multi-stage image to the final image
COPY --from=build /app/deployer.phar /usr/local/bin/deployer

## Make deployer executable and check that it can be executed
RUN chmod +x /usr/local/bin/deployer && deployer --version

# Call deployer automatically
ENTRYPOINT ["/usr/local/bin/deployer"]
