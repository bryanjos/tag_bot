defmodule TagBot.Mixfile do
  use Mix.Project

  def project do
    [app: :tag_bot,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :slack],
     mod: {TagBot, []}]
  end

  defp deps do
    [{:slack, "~> 0.2.0"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"}]
  end
end
