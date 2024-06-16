defmodule PhoenixNotif.MixProject do
  @moduledoc false

  use Mix.Project

  @version "0.1.0"
  @description "A drop-in replacement for notification system in Phoenix."
  @source_url "https://github.com/cozy-elixir/phoenix_notif"

  def project do
    [
      app: :phoenix_notif,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      docs: docs(),
      package: package(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, ">= 0.20.0"},
      {:ecto, ">= 3.11.0"},
      {:esbuild, "~> 0.2", only: :dev},
      {:bandit, "~> 1.1", only: :dev},
      {:styler, "~> 0.11.9", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.16", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.34", only: [:dev], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{GitHub: @source_url},
      files: ~w"""
      assets/phoenix_notif/
      priv/
      lib/
      mix.exs
      package.json
      README.md
      """
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd --cd assets npm install"],
      "assets.build": ["esbuild esm", "esbuild cjs", "esbuild iife", "esbuild iife_min"],
      "assets.watch": ["esbuild esm --watch"],
      publish: ["assets.build", "hex.publish", "tag"],
      tag: &tag_release/1
    ]
  end

  defp tag_release(_) do
    Mix.shell().info("Tagging release as v#{@version}")
    System.cmd("git", ["tag", "v#{@version}"])
    System.cmd("git", ["push", "--tags"])
  end
end
