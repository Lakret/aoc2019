defmodule Aoc2019.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Aoc2019.Worker.start_link(arg)
      # {Aoc2019.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aoc2019.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
