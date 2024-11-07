defmodule Meta.Validator do
  defmacro build(fields) do
    quote do
      def changeset(changeset, params \\ %{}) do
        changeset
        |> cast(params, [:name, :email])
        |> validations(unquote(fields))
      end

      defp validations(changeset, fields) do
        Enum.reduce(fields, changeset, fn {field, conditions}, acc ->
          acc
          |> required(field, conditions)
          |> unique(field, conditions)
          |> length(field, conditions)
        end)
      end

      defp required(changeset, field, {:required, true}) do
        Ecto.Changeset.validate_required(changeset, [field])
      end

      defp required(changeset, _field, _conditions) do
        changeset
      end

      defp unique(changeset, field, {:unique_constraint, true}) do
        Ecto.Changeset.unique_constraint(changeset, field)
      end

      defp unique(changeset, _field, _condition) do
        changeset
      end

      defp length(changeset, field, %{length: {min, max}}) do
        Ecto.Changeset.validate_length(changeset, field, min: min, max: max)
      end

      defp length(changeset, _field, _params) do
        changeset
      end
    end
  end
end
