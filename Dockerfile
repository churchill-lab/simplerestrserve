FROM rocker/r-ver:4.4

ARG TARGETPLATFORM

ENV R_CRAN_PKGS="Rcpp \
    remotes \
    R6 \
    uuid \
    checkmate \
    mime \
    jsonlite \
    digest"

ENV R_FORGE_PKGS=Rserve

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libcurl4-openssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libssl-dev \
        libjemalloc-dev \
        zlib1g-dev && \
    install2.r -r http://www.rforge.net/ $R_FORGE_PKGS && \
    install2.r $R_CRAN_PKGS && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# https://github.com/jemalloc/jemalloc

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so ; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so ; \
    fi


# install RestRserve
RUN R -e 'install.packages("RestRserve")' \
 && R -e 'remotes::install_github("mattjvincent/memCompression")'

EXPOSE 8001

SHELL ["/bin/bash", "-c"]

ENV INSTALL_PATH=/example/R
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY example.R $INSTALL_PATH/example.R

CMD ["Rscript", "/example/R/example.R"]

