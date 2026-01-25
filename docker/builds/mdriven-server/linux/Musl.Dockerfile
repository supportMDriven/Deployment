# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine

RUN apk add --upgrade --no-cache \
        curl \
        unzip \
        jq 

WORKDIR /app

RUN mkdir -p /app_temp

RUN API_ENDPOINT="https://mdriven.net/Rest/ProductRelease/Get?vProduct=ServerCore&platform=linux%20musl" \
    && DOWNLOAD_URL=$(curl -sL "$API_ENDPOINT" | jq -r '.Releases[0]') \
    && curl -L -o release.zip "$DOWNLOAD_URL" \
    && unzip release.zip -d /app_temp \
    && rm release.zip


RUN dotnet nuget add source /mnt/c/capableobjectswush/Xternal/VistaDB --name  XternatVistaDB 


COPY _shared/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
