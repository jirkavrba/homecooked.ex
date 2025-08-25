defmodule Homecooked.Posts do
  alias Homecooked.Repo
  alias Homecooked.Posts.Post
  alias Homecooked.Posts.PostReaction
  alias Homecooked.Users.User
  import Ecto.Query, only: [from: 2]
  require Logger

  @reaction_emojis [
    "❤️",
    "👍",
    "😂",
    "😮",
    "🤮",
    "😋"
  ]

  def reaction_emojis, do: @reaction_emojis

  def create_post(attrs, user) do
    share_token = Base.encode16(:rand.bytes(16), case: :lower)

    attrs =
      attrs
      |> Map.put(:user_id, user.id)
      |> Map.put(:share_token, share_token)

    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def change_post(post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def upload_post_image(path) do
    with {:ok, original_raw} <- File.read(path),
         {:ok, original} <- Image.from_binary(original_raw),
         {:ok, resized} <- Image.thumbnail(original, 512),
         {:ok, temp_file} <- create_temp_file(),
         {:ok, _result} <- Image.write(resized, temp_file),
         {:ok, uploaded_file_url} <- upload_file(temp_file) do
      {:ok, uploaded_file_url}
    else
      error ->
        Logger.error("Error when uploading image: #{error}")
        {:error, "Error uploading image."}
    end
  end

  defp create_temp_file() do
    case System.tmp_dir() do
      nil ->
        {:error, "Cannot create temp file"}

      temp_dir ->
        random_hash = Base.encode16(:rand.bytes(16), case: :lower)
        temp_file = Path.join(temp_dir, "#{random_hash}.jpg")

        {:ok, temp_file}
    end
  end

  defp upload_file(temp_file) do
    basename = Path.basename(temp_file)
    destination = Path.join([:code.priv_dir(:homecooked), "static", "uploads", basename])

    Logger.info("Storing uploaded file to #{destination}")

    case File.cp(temp_file, destination) do
      :ok -> {:ok, "/uploads/#{basename}"}
      {:error, _posix} -> {:error, "Error copying file."}
    end
  end

  @spec get_user_feed(%User{}, %Post{} | nil) :: {:ok, Paginator.Page.t()} | {:error, term()}
  def get_user_feed(user, last_post \\ nil) do
    user = Repo.preload(user, :followed_users)
    followed_user_ids = Enum.map(user.followed_users, fn %User{id: id} -> id end)
    all_user_ids = followed_user_ids ++ [user.id]

    last_post_cursor =
      if is_nil(last_post),
        do: nil,
        else: Paginator.cursor_for_record(last_post, [:inserted_at, :id])

    query =
      from p in Post,
        where: p.user_id in ^all_user_ids,
        preload: [:user, [reactions: :user]],
        order_by: [desc: :inserted_at]

    page =
      Repo.paginate(query,
        after: last_post_cursor,
        cursor_fields: [{:inserted_at, :desc}, :id]
      )

    {:ok, page}
  end

  def add_reaction(post_id, user, reaction_emoji) do
    %PostReaction{}
    |> PostReaction.changeset(%{
      "user_id" => user.id,
      "post_id" => post_id,
      "reaction_emoji" => reaction_emoji
    })
    |> Repo.insert()
  end
end
