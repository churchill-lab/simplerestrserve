FROM rocker/r-ver:4.4

ARG TARGETPLATFORM

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libcurl4-openssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfreetype6-dev \
        libjemalloc-dev \
        libjpeg-dev \
        libpng-dev \
        libssl-dev \
        libtiff5-dev \
        libxml2-dev \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# https://github.com/jemalloc/jemalloc

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so ; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so ; \
    fi

RUN R -e 'install.packages("remotes")'

RUN R -e 'remotes::install_version("RestRserve", version = "1.2.2")' \
 && R -e 'remotes::install_version("gtools", version = "3.9.5")' \
 && R -e 'remotes::install_version("ragg", version="1.3.3")' \
 && R -e 'remotes::install_github("mattjvincent/memCompression")'

EXPOSE 8001

SHELL ["/bin/bash", "-c"]

ENV INSTALL_PATH=/example/R
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY example.R $INSTALL_PATH/example.R

CMD ["Rscript", "/example/R/example.R"]

