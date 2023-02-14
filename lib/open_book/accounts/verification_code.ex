defmodule OpenBook.Accounts.VerificationCode do
  use Ecto.Schema

  import Ecto.Changeset

  @verification_code_length 6
  @min_verification_code_integer String.to_integer("#{1}#{String.duplicate("0", @verification_code_length - 1)}")
  @max_verification_code_integer String.to_integer(String.duplicate("9", @verification_code_length))

  schema "verification_codes" do
    field :code, :string
    field :user_id, :id

    timestamps()
  end

  @doc """
  Generates a URL-friendly verification code string.
  If you need it to be human friendly, pass in the `human_friendly: true` option. This should only be used if a user
  needs to input the code manually. Otherwise, an uglier and far more secure verification code is generated which
  should be used in cases where we send the user a text with a URL.
  """
  def generate_url_friendly_verification_code(opts) do
    human_friendly = opts[:human_friendly]

    if human_friendly do
      "#{Enum.random(@min_verification_code_integer..@max_verification_code_integer)}"
    else
      :crypto.strong_rand_bytes(@verification_code_length)
      |> Base.url_encode64(case: :lower, padding: true)
    end
  end

  ## Changesets

  def new_vc_changeset(user_id) do
    code = generate_url_friendly_verification_code(%{})

    change(%__MODULE__{})
    |> put_change(:user_id, user_id)
    |> put_change(:code, code)
  end
end
