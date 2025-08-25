defmodule Homecooked.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homecooked.Posts.PostReaction
  alias Homecooked.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    field :image_url, :string
    field :title, :string
    field :description, :string
    field :ingredients_list, :string
    field :recipe, :string
    field :rating, :integer
    field :price_czk_per_portion, :integer
    field :kcal_per_portion, :integer
    field :preparation_time_minutes, :integer
    field :share_token, :string

    belongs_to :user, User
    has_many :reactions, PostReaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :image_url,
      :title,
      :description,
      :ingredients_list,
      :recipe,
      :rating,
      :price_czk_per_portion,
      :kcal_per_portion,
      :preparation_time_minutes,
      :share_token,
      :user_id
    ])
    |> validate_required([
      :image_url,
      :title
    ])
    |> validate_length(:title, max: 256)
    |> validate_length(:description, max: 2048)
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:price_czk_per_portion,
      greater_than_or_equal_to: 0,
      message: "Infinite money glitch?"
    )
    |> validate_number(:kcal_per_portion,
      greater_than_or_equal_to: 0,
      message: "Takhle kalorie bohužel nefungujou."
    )
    |> validate_number(:preparation_time_minutes,
      greater_than_or_equal_to: 0,
      message: "Dobrý cestování časem kámo."
    )
  end
end
