defmodule OpenBook.Accounts do
  import Ecto.Query

  alias OpenBook.Accounts.Friend
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

  def get_exercise_open_book_friend_id_mapset(by_user_id) do
    from(f in Friend, select: [f.user_1_id, f.user_2_id])
    |> friendship_involves_user_id(by_user_id)
    |> friendship_has_exercise_open_book()
    |> Repo.all()
    |> extract_friend_ids(by_user_id)
  end

  def get_nutrition_open_book_friend_id_mapset(by_user_id) do
    from(f in Friend, select: [f.user_1_id, f.user_2_id])
    |> friendship_involves_user_id(by_user_id)
    |> friendship_has_nutrition_open_book()
    |> Repo.all()
    |> extract_friend_ids(by_user_id)
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

  ## Helpers

  defp extract_friend_ids(user_id_pairs, user_id) do
    Enum.reduce(user_id_pairs, MapSet.new(), fn
      [^user_id, friend_user_id], friend_ids_acc -> MapSet.put(friend_ids_acc, friend_user_id)
      [friend_user_id, ^user_id], friend_ids_acc -> MapSet.put(friend_ids_acc, friend_user_id)
    end)
  end

  ## Querying DB

  defp get_verification_code_by(params) do
    Repo.get_by(VerificationCode, params)
  end

  ## Query Builders

  defp friendship_involves_user_id(query, user_id) do
    from(f in query, where: f.user_1_id == ^user_id or f.user_2_id == ^user_id)
  end

  defp friendship_has_exercise_open_book(query) do
    from(f in query, where: f.has_exercise_open_book == true)
  end

  defp friendship_has_nutrition_open_book(query) do
    from(f in query, where: f.has_nutrition_open_book == true)
  end
end
