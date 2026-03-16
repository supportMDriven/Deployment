# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/sdk:8.0-noble-amd64

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        jq \
        locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && rm -rf /var/lib/apt/lists/* 

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

RUN mkdir -p /app_temp

RUN API_ENDPOINT="https://mdriven.net/Rest/ProductRelease/Get?vProduct=TurnkeyCore&platform=linux" \
    && DOWNLOAD_URL=$(curl -sL "$API_ENDPOINT" | jq -r '.Releases[0]') \
    && curl -L -o release.zip "$DOWNLOAD_URL" \
    && unzip release.zip -d /app_temp \
    && rm release.zip

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

