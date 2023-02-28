defmodule OpenBook.DateHelpers do
  @moduledoc """
  Some misc. date helpers.
  """

  def readable_date(user_local_date, other_date, :human_relative_lingo_with_prefix) do
    case Date.diff(user_local_date, other_date) do
      -1 ->
        "tomorrow"

      0 ->
        "today"

      1 ->
        "yesterday"

      # TODO(Arie): This can have more relative dates ("this upcoming friday") etc.
      _ ->
        "#{Calendar.strftime(other_date, "%A, %b %d")}"
    end
  end

  def naive_start_of_day(naive_date_time) do
    %{naive_date_time | hour: 0, minute: 0, second: 0}
  end

  def naive_end_of_day(naive_date_time) do
    %{naive_date_time | hour: 23, minute: 59, second: 59}
  end
end
