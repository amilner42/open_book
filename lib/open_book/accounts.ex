defmodule OpenBook.Accounts do
  import Ecto.Query

  alias OpenBook.Accounts.User
  alias OpenBook.Accounts.VerificationCode
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Repo

  ## DB Mutations

  def insert_new_user!(params = %{display_name: _, phone: _}) do
    LL.info_event("insert_new_user!", params)

    %User{}
    |> User.changeset(params)
    |> Repo.insert!()
  end

  def insert_new_vc!(user_id) do
    LL.info_event("insert_new_vc!", %{user_id: user_id})

    VerificationCode.new_vc_changeset(user_id)
    |> Repo.insert!()
  end

  ## DB Queries

  def get_user!(user_id) do
    Repo.get!(User, user_id)
  end

  def get_user(user_id) do
    Repo.get(User, user_id)
  end

  def get_users(user_ids) do
    from(u in User, where: u.id in ^user_ids)
    |> Repo.all()
  end

  def get_users_as_map(user_ids) do
    get_users(user_ids)
    |> Enum.reduce(%{}, fn user, result_acc ->
      Map.put(result_acc, user.id, user)
    end)
  end

  # TODO(Arie): Check VC is not expired.
  def get_user_from_valid_verification_code(verification_code) do
    case get_verification_code_by(%{code: verification_code}) do
      %VerificationCode{user_id: user_id} ->
        get_user!(user_id)

      _ ->
        nil
    end
  end

  # Private

  ## Querying DB

  defp get_verification_code_by(params) do
    Repo.get_by(VerificationCode, params)
  end
end
