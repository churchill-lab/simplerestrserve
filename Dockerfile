FROM rocker/r-ver:4.1
LABEL author="Matthew Vincent <mattjvincent@gmail.com>"
LABEL version="1.0.0"

ENV R_FORGE_PKGS Rserve
ENV R_CRAN_PKGS Rcpp R6 uuid checkmate mime jsonlite remotes

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libcurl4-openssl-dev \
        libssl-dev \
        libjemalloc-dev \
        zlib1g-dev && \
    install2.r -r http://www.rforge.net/ $R_FORGE_PKGS && \
    install2.r $R_CRAN_PKGS && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# https://github.com/jemalloc/jemalloc
ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so

# install RestRserve
RUN R -e 'remotes::install_github("rexyai/RestRserve@v1.1.1")' \
 && R -e 'remotes::install_github("mattjvincent/memCompression")'

EXPOSE 8001

SHELL ["/bin/bash", "-c"]

ENV INSTALL_PATH /example/R
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY example.R $INSTALL_PATH/example.R

CMD ["Rscript", "/example/R/example.R"]
