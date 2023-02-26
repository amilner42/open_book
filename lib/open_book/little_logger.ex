defmodule OpenBook.LittleLogger do
  @moduledoc """
  The wrapper around the elixir `Logger` with some logging helpers. We currently pipe our logs to Logflare.

  This should be aliased everywhere as such (for easy ctrl-f):
    alias OpenBook.LittleLogger, as: LL
  """
  require Logger

  ## Metadata

  @doc """
  Add the current user ID to the logger metadata.
  """
  def metadata_add_current_user_id(user_id) do
    Logger.metadata(current_user: user_id)
  end

  @doc """
  Add the current page name to the logger metadata.
  """
  def metadata_add_current_page(page_name) do
    Logger.metadata(current_page: page_name)
  end

  ## Logging

  ### Info

  @doc """
  For logging a message with no extra metadata.
  """
  def info(message) do
    Logger.info(message)
  end

  @doc """
  Log an event.
  """
  def info_event(event_name) do
    Logger.info("[EVENT] #{event_name}", %{event_name: event_name})
  end

  @doc """
  Log an event w. metadata.
  """
  def info_event(event_name, event_data) do
    event_data_key = String.to_atom("#{event_name}_event_data")
    event_data_str = Enum.map_join(event_data, " && ", fn {key, val} -> "#{key} = #{val}" end)

    Logger.info("[EVENT] #{event_name} :: #{event_data_str}", %{
      :event_name => event_name,
      event_data_key => event_data
    })
  end

  ### Warn

  @doc """
  For warning logging a message with no extra metadata.
  """
  def warn(message) do
    Logger.warn(message)
  end

  ### Error

  @doc """
  For error logging a message with no extra metadata.
  """
  def error(message) do
    Logger.error(message)
  end
end
