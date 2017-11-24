# ex_sqs_service

## Usage

  1. Add `ex_sqs_service` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_sqs_service, git: "https://github.com/raisebook/ex_sqs_service", tag: "0.2.0"}]
    end
    ```

  2. Ensure `ex_sqs_service` is started before your application:

    ```elixir
    def application do
      [applications: [:ex_sqs_service]]
    end
    ```
### Building

Run `make` to build test and lint
