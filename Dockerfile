FROM elixir:1.3

RUN mkdir -p /app/deps

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /app
COPY . /app
RUN mix deps.get
ENV MIX_ENV=test

CMD ["/bin/bash"]
