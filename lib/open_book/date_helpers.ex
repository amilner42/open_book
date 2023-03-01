defmodule OpenBook.DateHelpers do
  @moduledoc """
  Some miscellaneous date helpers.
  """

  @doc ~S"""
  Get a readable date, overloaded for different formats.

  ## Exmples

  iex> OpenBook.DateHelpers.readable_date(~D[2022-02-02], :calendar_date)
  "Wednesday, Feb 02"
  """
  def readable_date(date, :calendar_date) do
    "#{Calendar.strftime(date, "%A, %b %d")}"
  end

  @doc ~S"""
  Get a readable date, overloaded for different formats.

  ## Examples:

    iex> today = Date.utc_today()
    iex> OpenBook.DateHelpers.readable_date(today, today, :human_relative_lingo)
    "today"
    iex> yesterday = Date.add(today, -1)
    iex> OpenBook.DateHelpers.readable_date(today, yesterday, :human_relative_lingo)
    "yesterday"
    iex> far_back_date = Date.add(today, -10)
    iex> OpenBook.DateHelpers.readable_date(today, far_back_date, :human_relative_lingo)
    OpenBook.DateHelpers.readable_date(far_back_date, :calendar_date)
  """
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

  @doc ~S"""
  Return a new NaiveDateTime for the start of the passed Date/NaiveDateTime.

  ## Examples

  iex> OpenBook.DateHelpers.naive_start_of_day(~D[2022-02-02])
  ~N[2022-02-02 00:00:00]

  iex> OpenBook.DateHelpers.naive_start_of_day(~N[2022-01-30 11:01:01])
  ~N[2022-01-30 00:00:00]
  """
  def naive_start_of_day(%Date{} = date), do: NaiveDateTime.new!(date, %Time{hour: 0, minute: 0, second: 0})

  def naive_start_of_day(%NaiveDateTime{} = naive_date_time),
    do: naive_start_of_day(NaiveDateTime.to_date(naive_date_time))

  @doc ~S"""
  Return a new NaiveDateTime for the end of the passed Date/NaiveDateTime.

  ## Examples

  iex> OpenBook.DateHelpers.naive_end_of_day(~D[2022-02-02])
  ~N[2022-02-02 23:59:59]

  iex> OpenBook.DateHelpers.naive_end_of_day(~N[2022-01-30 11:01:01])
  ~N[2022-01-30 23:59:59]
  """
  def naive_end_of_day(%Date{} = date), do: NaiveDateTime.new!(date, %Time{hour: 23, minute: 59, second: 59})
  def naive_end_of_day(naive_date_time), do: naive_end_of_day(NaiveDateTime.to_date(naive_date_time))
end
