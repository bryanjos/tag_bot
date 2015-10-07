defmodule TagBot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(TagBot.RTM, [ Application.get_env(:tag_bot, :token), [] ]),
      worker(TagBot.State, [])
    ]

    opts = [strategy: :one_for_one, name: TagBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
