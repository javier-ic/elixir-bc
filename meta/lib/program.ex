defmodule Meta do
  alias Meta.User
  alias Meta.Repo

  def newUser(name, email) do
    %User{}
    |> User.changeset(%{name: name, email: email})
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        IO.puts("Usuario creado: #{user.name}")
        {:ok, user}

      {:error, changeset} ->
        IO.puts("Error al crear el usuario: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end
end
