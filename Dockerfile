# Base image
FROM python:3-alpine

# Labels and Credits
LABEL \
    name="reNgine" \
    author="Yogesh Ojha <yogesh.ojha11@gmail.com>" \
    description="reNgine is a automated pipeline of recon process, useful for information gathering during web application penetration testing."

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update \
    && apk add --virtual build-deps gcc python3-dev musl-dev \
    && apk add postgresql-dev chromium git netcat-openbsd \
    && pip install psycopg2 \
    && apk del build-deps


# Download and install go 1.13
COPY --from=golang:1.13-alpine /usr/local/go/ /usr/local/go/

# Environment vars
ENV DATABASE="postgres"
ENV GOROOT="/usr/local/go"
ENV GOPATH="/root/go"
ENV PATH="${PATH}:${GOROOT}/bin"
ENV PATH="${PATH}:${GOPATH}/bin"

# Download Go packages
RUN go get -u github.com/tomnomnom/assetfinder github.com/hakluke/hakrawler github.com/haccer/subjack github.com/ffuf/ffuf github.com/tomnomnom/gron

RUN GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx \
    github.com/projectdiscovery/naabu/cmd/naabu \
    github.com/projectdiscovery/subfinder/cmd/subfinder \
    github.com/lc/gau

# Copy requirements
COPY ./requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

# Make directory for app
RUN mkdir /app
WORKDIR /app

# Copy source code
COPY . /app/

# Collect Static
RUN python manage.py collectstatic --no-input --clear

RUN chmod +x /app/tools/get_subdomain.sh
RUN chmod +x /app/tools/get_dirs.sh
RUN chmod +x /app/tools/get_urls.sh
RUN chmod +x /app/tools/takeover.sh
RUN chmod +x /app/tools/ffuf_json_parse.sh
RUN chmod +x /app/tools/get_ffufdirs.sh

# run entrypoint.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]
