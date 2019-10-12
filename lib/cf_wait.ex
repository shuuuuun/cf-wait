defmodule CfWait do
  @moduledoc """
  Documentation for CfWait.
  """

  @doc """
  Hello world.

  ## Examples

      iex> CfWait.hello()
      :world

  """
  def hello do
    :world
  end

  def start(_type, _args) do
    CfWait.Supervisor.start_link
  end
end
