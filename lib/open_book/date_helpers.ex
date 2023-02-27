defmodule OpenBook.DateHelpers do
  @moduledoc """
  Some misc. date helpers.
  """

  def readable_date(user_local_date, other_date, :human_relative_lingo_with_prefix) do
    case IO.inspect(Date.diff(user_local_date, other_date)) do
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
end
