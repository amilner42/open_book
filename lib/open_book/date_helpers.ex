defmodule OpenBook.DateHelpers do
  @moduledoc """
  Some misc. date helpers.
  """

  def readable_date(date, :calendar_date) do
    "#{Calendar.strftime(date, "%A, %b %d")}"
  end

  def readable_date(user_local_date, other_date, :human_relative_lingo) do
    case Date.diff(user_local_date, other_date) do
      -1 ->
        "tomorrow"

      0 ->
        "today"

      1 ->
        "yesterday"

      _ ->
        readable_date(other_date, :calendar_date)
    end
  end

  def naive_start_of_day(%Date{} = date), do: NaiveDateTime.new!(date, %Time{hour: 0, minute: 0, second: 0})

  def naive_start_of_day(%NaiveDateTime{} = naive_date_time),
    do: naive_start_of_day(NaiveDateTime.to_date(naive_date_time))

  def naive_end_of_day(%Date{} = date), do: NaiveDateTime.new!(date, %Time{hour: 23, minute: 59, second: 59})
  def naive_end_of_day(naive_date_time), do: naive_end_of_day(NaiveDateTime.to_date(naive_date_time))
end
