defmodule Homecooked.Repo.Migrations.AddReactionsToPosts do
  use Ecto.Migration

  def change do
    create table(:post_reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :reaction_emoji, :string

      timestamps(type: :utc_datetime)
    end

    create index(:post_reactions, [:user_id])
    create index(:post_reactions, [:post_id])
  end
end
