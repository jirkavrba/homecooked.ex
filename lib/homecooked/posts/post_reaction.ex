defmodule Homecooked.Posts.PostReaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Homecooked.Posts
  alias Homecooked.Posts.Post
  alias Homecooked.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "post_reactions" do
    field :reaction_emoji, :string

    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :reaction_emoji,
      :post_id,
      :user_id
    ])
    |> validate_required([:reaction_emoji, :post_id, :user_id])
    |> validate_inclusion(:reaction_emoji, Posts.reaction_emojis())
  end
end
