defmodule OpenBook.Share do
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Repo
  alias OpenBook.Share.DayStatsLink

  # DB Mutations

  def generate_new_day_stats_link!(by_user_id, date) do
    LL.info_event("generate_new_day_stats_link!", %{by_user_id: by_user_id, date: date})

    DayStatsLink.new_link_changeset(by_user_id, date)
    |> Repo.insert!()
  end

  # DB Queries

  def get_day_stats_link_by_code!(code) do
    LL.info_event("get_day_stats_link_by_code!", %{code: code})

    Repo.get_by!(DayStatsLink, code: code)
  end
end
