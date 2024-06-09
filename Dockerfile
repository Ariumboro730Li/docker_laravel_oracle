# Install PHP and composer

FROM php:8.3.1RC3-fpm
# FROM  php:7.1-fpm
# FROM php:7.1.3-fpm


# Install PDO and MySQL extensions (already in your original Dockerfile)
RUN docker-php-ext-install pdo pdo_mysql

# Install the GD extension
RUN apt-get update \
    && apt-get install -y libpng-dev libjpeg-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install LDAP extension
RUN apt-get update && \
    apt-get install -y libldap2-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install ldap

# Check if the MongoDB extension is installed
# RUN if ! [ -z "$(php -m | grep mongodb)" ]; then \
#         echo "MongoDB extension is already installed."; \
#     else \
#         echo "Installing MongoDB extension..." \
#         && pecl install mongodb \
#         && docker-php-ext-enable mongodb \
#         && echo "MongoDB extension installed successfully."; \
#     fi

# Update package lists and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y zlib1g-dev libzip-dev

# install nodejs and npm extension
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs \
    npm  

# Check if the Zip extension is installed
RUN if ! [ -z "$(php -m | grep zip)" ]; then \
        echo "Zip extension is already installed."; \
    else \
        echo "Installing Zip extension..." \
        && pecl install zip \
        && docker-php-ext-enable zip \
        && echo "Zip extension installed successfully."; \
    fi

# RUN chmod -R 777 /var/www/html/

# Check if the redis extension is installed
# RUN if ! [ -z "$(php -m | grep redis)" ]; then \
#         echo "Redis extension is already installed."; \
#     else \
#         echo "Installing Redis extension..." \
#         && pecl install redis \
#         && docker-php-ext-enable redis \
#         && echo "Redis extension installed successfully."; \
#     fi

RUN apt-get update \
    && apt-get install -y git

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN printf "memory_limit = 256M\n\
post_max_size = 100M\n\
max_file_uploads = 100\n\
max_execution_time = -1\n\
request_terminate_timeout = -1" > /usr/local/etc/php/conf.d/manual-conf.ini

# WORKDIR /var/www/html
# CMD [ "sh", "-c", "php artisan serve --host=0.0.0.0 --port=9090" ]