import Config

config :phoenix, :json_library, Jason

if Mix.env() == :dev do
  esbuild = fn args ->
    [
      args: ~w(./phoenix_notif --bundle) ++ args,
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]
  end

  config :esbuild,
    version: "0.21.5",
    esm: esbuild.(~w(--format=esm --sourcemap --outfile=../priv/static/phoenix_notif.esm.js)),
    cjs: esbuild.(~w(--format=cjs --sourcemap --outfile=../priv/static/phoenix_notif.cjs.js)),
    iife:
      esbuild.(~w(--format=iife --target=es2016 --global-name=PhoenixNotif --outfile=../priv/static/phoenix_notif.js)),
    iife_min:
      esbuild.(
        ~w(--format=iife --target=es2016 --global-name=PhoenixNotif --minify --outfile=../priv/static/phoenix_notif.min.js)
      )
end
