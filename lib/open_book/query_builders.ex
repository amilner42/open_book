defmodule OpenBook.QueryBuilders do
  @moduledoc """
  A place to put all abstract (model-agnostic) and reusable query builders.

  This should be aliased everywhere as such (for easy ctrl-f):
    alias OpenBook.QueryBuilders, as: QB
  """

  import Ecto.Query

  @doc """
  Order a query by `order_by`. Operates on the first bound variable in the query.
  """
  def ordered_by(query, order_by) do
    from(x in query, order_by: ^order_by)
  end
end
