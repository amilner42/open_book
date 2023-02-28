defmodule OpenBook.QueryBuilders do
  @moduledoc """
  A place to put all abstract (model-agnostic) and reusable query builders.

  This should be aliased everywhere as such (for easy ctrl-f):
    alias OpenBook.QueryBuilders, as: QB
  """

  import Ecto.Query

  ## Order By Clauses

  @doc """
  Order a query by `order_by`. Operates on the first bound variable in the query.
  """
  def ordered_by(query, order_by) do
    from(x in query, order_by: ^order_by)
  end

  ## Where Clauses

  @doc """
  Filters to records that contain that `user_id`. Operates on the first bound variable in the query.
  """
  def with_user_id(query, user_ids) do
    from(x in query, where: x.user_id in ^user_ids)
  end

  @doc """
  Filters to records that have a `record.local_datetime >= local_datetime`.

  Operates on the first bound variable in the query.
  """
  def gte_local_datetime(query, local_datetime) do
    from(x in query, where: x.local_datetime >= ^local_datetime)
  end

  @doc """
  Filters to records that have a `record.local_datetime <= local_datetime`.

  Operates on the first bound variable in the query.
  """
  def lte_local_datetime(query, local_datetime) do
    from(x in query, where: x.local_datetime <= ^local_datetime)
  end
end
