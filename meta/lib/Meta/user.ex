defmodule Meta.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    timestamps()
  end

  import Meta.Validator

  build(%{
    name: %{
      required: true,
      length: {1, 10}
    },
    email: %{
      required: true,
      length: {3, 30},
      unique_constraint: true
    }
  })
end

# def changeset(user, attr) do
#   user
#   |> cast(attr, [:name, :email])
#   |> validate_required([:name, :email])
#   |> unique_constraint(:email)
#   |> validate_length(:name, min: 5, max: 10)
# end
