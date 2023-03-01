defmodule OpenBook.Share do
  import Ecto.Query

  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Repo
  alias OpenBook.Share.DayStatsLink

  # DB Queries

  def get_day_stats_link_by_code!(code) do
    LL.info_event("get_day_stats_link_by_code!", %{code: code})

    Repo.get_by!(DayStatsLink, code: code)
  end
end
