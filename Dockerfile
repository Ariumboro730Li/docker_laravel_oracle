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

RUN apt-get update \
    && apt-get install -y git

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN printf "memory_limit = 256M\n\
post_max_size = 100M\n\
max_file_uploads = 100\n\
max_execution_time = -1\n\
request_terminate_timeout = -1" > /usr/local/etc/php/conf.d/manual-conf.ini


# Install Oracle Instant Client and OCI8 extension
# ENV ORACLE_INSTANT_CLIENT_VERSION=21.6
# ENV ORACLE_HOME=/usr/local/instantclient

# RUN mkdir -p /usr/local/instantclient \
#     && cd /usr/local/instantclient \
#     && curl -O https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_INSTANT_CLIENT_VERSION}0/instantclient-basic-linux.x64-${ORACLE_INSTANT_CLIENT_VERSION}.0.0dbru.zip \
#     && curl -O https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_INSTANT_CLIENT_VERSION}0/instantclient-sdk-linux.x64-${ORACLE_INSTANT_CLIENT_VERSION}.0.0dbru.zip \
#     && unzip instantclient-basic-linux.x64-${ORACLE_INSTANT_CLIENT_VERSION}.0.0dbru.zip \
#     && unzip instantclient-sdk-linux.x64-${ORACLE_INSTANT_CLIENT_VERSION}.0.0dbru.zip \
#     && rm instantclient-basic-linux.x64-${ORACLE_INSTANT_CLIENT_VERSION}.0.0dbru.zip \
#     && rm instantclient-sdk-linux.x64-${ORACLE_INSTANT_CLIENT_VERSION}.0.0dbru.zip \
#     && ln -s ${ORACLE_HOME}/libclntsh.so.${ORACLE_INSTANT_CLIENT_VERSION} ${ORACLE_HOME}/libclntsh.so \
#     && ln -s ${ORACLE_HOME}/libocci.so.${ORACLE_INSTANT_CLIENT_VERSION} ${ORACLE_HOME}/libocci.so \
#     && echo ${ORACLE_HOME} > /etc/ld.so.conf.d/oracle-instantclient.conf \
#     && ldconfig

# RUN docker-php-ext-configure oci8 --with-oci8=instantclient,${ORACLE_HOME} \
#     && docker-php-ext-install oci8

# # Verify OCI8 installation
# RUN php -m | grep oci8