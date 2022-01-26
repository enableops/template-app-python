FROM python:3.9-slim-bullseye

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	# utility: for installing https://python-poetry.org
	curl \
	# dependency: for installing https://cryptography.io
	make gcc \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -sSL \
	https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py \
	| python -

WORKDIR /usr/src/app

COPY pyproject.toml poetry.lock ./
RUN $HOME/.poetry/bin/poetry config virtualenvs.create false \
	&& $HOME/.poetry/bin/poetry install --no-dev --no-interaction --no-ansi

COPY app ./app
COPY .env ./

COPY alembic.ini ./
COPY migrations ./migrations

COPY tests ./tests

ARG APP_VERSION
RUN sed -i "3s/.*/version = \"${APP_VERSION}\"/" pyproject.toml

CMD alembic upgrade head \
	&& uvicorn app.main:app --reload --proxy-headers --host 0.0.0.0 --port 8000
