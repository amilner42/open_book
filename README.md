# openbook.health

Stay fit with friends. It's your story. And it's personal.

### Project Status

This is a very experimental project in its early stages. It is currently under casual development by just myself in my
spare time.

TODO(Arie): List features / roadmap once I ship a janky-but-working prototype.

### Development

The project is developed with [Postgres](https://www.postgresql.org/), [Elixir](https://elixir-lang.org/),
[Phoenix](https://www.phoenixframework.org/), and
[LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).

#### Setup

  * Install correct Elixir/Erlang versions in `.tool_versions` with `asdf install`.
  * Fill in environment variables in `.env-template`.
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Production

#### Deployment

I deploy on [fly.io](fly.io). I mostly followed the simple instructions on the
[Phoenix fly deploy guide](https://hexdocs.pm/phoenix/fly.html).

Some helpful commands:

 - `fly deploy`
 - `fly status`
 - `fly logs` (tail)

 - `fly ssh console`
   - Will require `fly ssh issue` first to get ssh certs
   - Once you have a console, `app/bin/open_book remote` to open up IEX connected to the prod instance.
   - As always `use IexHelpers` is a helpful macro for getting all common imports.
   - From there, you have a console to prod, eg: `Repo.all User`...

#### Logging

In production we use [logflare](logflare.app) to retain and analyze our logs. The dashboard is
[here](https://logflare.app/sources/25348).

You can enable logging to logflare in dev (to test logs are as expected). Refer to .env-template to see the ENV variable
flag to flip. The dev dashboard is [here](https://logflare.app/sources/25347).