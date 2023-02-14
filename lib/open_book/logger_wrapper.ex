defmodule OpenBook.LoggerWrapper do
  @moduledoc """
  The wrapper around the elixir `Logger` with some logging helpers.

  We currently pipe our logs to Logflare.
  """
  require Logger

  ## Metadata

  @doc """
  Add the current user ID to the logger metadata.
  """
  def metadata_add_current_user_id(user_id) do
    Logger.metadata(current_user: user_id)
  end

  ## Logging

  @doc """
  For logging a message with no extra metadata.
  """
  def info(message) do
    Logger.info(message)
  end

  @doc """
  For warning logging a message with no extra metadata.
  """
  def warn(message) do
    Logger.warn(message)
  end

  @doc """
  For error logging a message with no extra metadata.
  """
  def error(message) do
    Logger.error(message)
  end
end
