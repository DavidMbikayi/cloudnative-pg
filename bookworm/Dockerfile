ARG PG_MAJOR=14
ARG PG_MINOR=1
ARG PG_VERSION=${PG_MAJOR}.${PG_MINOR}

FROM postgres:${PG_VERSION}-bookworm

ARG CITUS_VERSION=13.0.1
ARG SEARCH_VERSION=0.15.10
# Set ARG values as environment variables
ENV CITUS_VERSION=${CITUS_VERSION}
ENV SEARCH_VERSION=${SEARCH_VERSION}

# Do not split the description, otherwise we will see a blank space in the labels
LABEL name="PostgreSQL Container Images" \
      vendor="David Mbikayi" \
      version="${PG_VERSION}" \
      release="7" \
      summary="PostgreSQL Container images." \
      description="This Docker image contains PostgreSQL and Barman Cloud based on Postgres 17.4-bookworm."

LABEL org.opencontainers.image.description="This Docker image contains PostgreSQL and Barman Cloud based on Postgres 17.4-bookworm."

COPY requirements.txt /


# install Citus
RUN set -xe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       wget \
    ; \
    curl -s https://install.citusdata.com/community/deb.sh | bash;  \
		apt-get update; \
    apt-get install -y postgresql-${PG_MAJOR}-citus-${CITUS_VERSION} \
                          postgresql-${PG_MAJOR}-hll=2.18.citus-1 \
                          postgresql-${PG_MAJOR}-topn=2.7.0.citus-1 ; \
    curl -fsSL  https://github.com/paradedb/paradedb/releases/download/v${SEARCH_VERSION}/postgresql-${PG_MAJOR}-pg-search_${SEARCH_VERSION}-1PARADEDB-bookworm_amd64.deb \
        -o postgresql-${PG_MAJOR}-pg-search_${SEARCH_VERSION}-1PARADEDB-bookworm_amd64.deb; \
    dpkg -i postgresql-${PG_MAJOR}-pg-search_${SEARCH_VERSION}-1PARADEDB-bookworm_amd64.deb; \
    apt-get purge -y --auto-remove curl wget ; \
    rm -rf postgresql-${PG_MAJOR}-pg-search_${SEARCH_VERSION}-1PARADEDB-bookworm_amd64.deb; \
    rm -rf /var/lib/apt/lists/*


# Install additional extensions
RUN set -xe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "postgresql-${PG_MAJOR}-pgaudit" \
        "postgresql-${PG_MAJOR}-pgvector" \
        "postgresql-${PG_MAJOR}-pg-failover-slots" \
    ; \
    rm -fr /tmp/* ; \
    rm -rf /var/lib/apt/lists/*;

# Install barman-cloud
RUN set -xe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # We require build-essential and python3-dev to build lz4 on arm64 since there isn't a pre-compiled wheel available
        build-essential python3-dev \
        python3-pip \
        python3-psycopg2 \
        python3-setuptools \
    ; \
    pip3 install --break-system-packages --upgrade pip; \
    # TODO: Remove --no-deps once https://github.com/pypa/pip/issues/9644 is solved
    pip3 install --break-system-packages --no-deps -r requirements.txt; \
    apt-get remove -y --purge --autoremove build-essential python3-dev; \
    rm -rf /var/lib/apt/lists/*;

# Change the uid of postgres to 26
RUN usermod -u 26 postgres
USER 26