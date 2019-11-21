FROM rocker/r-ver:3.6.0
LABEL maintainer="Matthew Vincent <matt.vincent@jax.org"> \
	  version="0.1.0"

RUN apt-get update -qq && \
    apt-get install -y \
    git-core \
    libcurl4-gnutls-dev \
    libgit2-dev \
    libjemalloc1 \
    libxml2-dev \
    libssh2-1-dev \
    libssl-dev \
    procps \
    supervisor \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# https://github.com/jemalloc/jemalloc
ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so.1

# install devtools
RUN R -e 'install.packages("devtools")'

# install the dependencies
RUN R -e 'devtools::install_version("base64enc", version = "0.1-3")' \
 && R -e 'devtools::install_version("swagger", version = "3.9.2")' \
 && R -e 'devtools::install_version("tibble", version = "2.1.3")' \
 && R -e 'devtools::install_version("uuid", version = "0.1-2")'
 
# install latest released Rserve
RUN R -e 'devtools::install_url("https://www.rforge.net/Rserve/snapshot/Rserve_1.8-6.tar.gz")'

# install RestRserve
RUN R -e 'devtools::install_github("mattjvincent/RestRserve", ref = "v0.2.0")'

EXPOSE 8001

SHELL ["/bin/bash", "-c"]

ENV INSTALL_PATH /example/R
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY example.R $INSTALL_PATH/example.R

CMD ["Rscript", "/example/R/example.R"]


