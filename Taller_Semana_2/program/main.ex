defmodule Library do
  defstruct books: [],
            users: []

  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil ->
        {:error, "Usuario no encontrado"}

      book == nil ->
        {:error, "Libro no disponible"}

      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library =
          Enum.map(library, fn
            b when b.isbn == isbn -> updated_book
            b -> b
          end)

        updated_users =
          Enum.map(users, fn
            u when u.id == user_id -> updated_user
            u -> u
          end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil ->
        {:error, "Usuario no encontrado"}

      book == nil ->
        {:error, "Libro no encontrado en los libros prestados del usuario"}

      true ->
        updated_book = %{book | available: true}

        updated_user = %{
          user
          | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))
        }

        updated_library =
          Enum.map(library, fn
            b when b.isbn == isbn -> updated_book
            b -> b
          end)

        updated_users =
          Enum.map(users, fn
            u when u.id == user_id -> updated_user
            u -> u
          end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(%Library{books: books}) do
    IO.puts("""
    *** LISTADO DE LIBROS ***
    -------------------------
    """)

    Enum.each(books, fn item ->
      IO.puts("* ISBN: #{item.isbn} | Título: #{item.title} (#{item.author})")
    end)
  end

  def find_by_isbn(%Library{books: books}, isbn) do
    book = Enum.find(books, fn book -> book.isbn == isbn end)

    if book do
      if book.available do
        IO.write("""
        ------------------------------------------
        El libro con ISBN: #{isbn} está disponible
        ------------------------------------------
        """)
      else
        IO.write("""
        ------------------------------------------
        El libro con ISBN: #{isbn} NO está disponible
        ------------------------------------------
        """)
      end
    else
      IO.write("""
      ------------------------------------------
      El libro con ISBN: #{isbn} no fue encontrado
      ------------------------------------------
      """)
    end
  end

  def list_users(users) do
    IO.puts("""
    *** LISTADO DE USUARIOS ***
    -------------------------
    """)

    Enum.each(users, fn item ->
      IO.puts("* ID: #{item.id} | #{item.name}")
    end)

    users
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  defp loop(library_manager) do
    IO.puts("""

    ******************************************************************
    Gestión de libros:
      1. Agregar libros a la colección de la biblioteca.
      2. Listar todos los libros disponibles en la biblioteca.
      3. Verificar la disponibilidad de un libro por su ISBN.
    Gestion de Usuarios:
      4. Registrar nuevos usuarios en la biblioteca.
      5. Listar todos los usuarios registrados.
    Prestamo de Libros:
      6. Permitir a los usuarios pedir prestado un libro disponible.
      7. Permitir a los usuarios devolver un libro prestado.
      8. Listar todos los libros prestados a un usuario en particular.
    Adicionales:
      9. Listar libros prestados o pendientes de devolución
      10. Listar usuarios que tienen libros prestados

    [0. Salir]
    ******************************************************************

    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Título: ")
        title = IO.gets("") |> String.trim()

        IO.write("Autor: ")
        author = IO.gets("") |> String.trim()

        IO.write("ISBN: ")
        isbn = IO.gets("") |> String.trim()

        book = %Book{title: title, author: author, isbn: isbn, available: true}

        loop(%{library_manager | books: add_book(library_manager.books, book)})

      2 ->
        books_available = Enum.filter(library_manager.books, fn e -> e.available end)
        list_books(%{library_manager | books: books_available})
        loop(library_manager)

      3 ->
        IO.write("ISBN: ")
        isbn = IO.gets("") |> String.trim()
        find_by_isbn(library_manager, isbn)
        loop(library_manager)

      4 ->
        IO.write("Nombre: ")
        name = IO.gets("") |> String.trim()
        users = library_manager.users
        users = add_user(users, %User{name: name, id: Enum.count(users) + 1, borrowed_books: []})
        loop(%{library_manager | users: users})

      5 ->
        list_users(library_manager.users)
        loop(library_manager)

      6 ->
        IO.write("ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("ISBN: ")
        isbn = IO.gets("") |> String.trim()

        books = library_manager.books
        users = library_manager.users

        library_manager =
          case borrow_book(books, users, id, isbn) do
            {:ok, books, users} ->
              IO.puts("""
              El libro fue asignado exitosamente
              """)

              %{library_manager | books: books, users: users}

            {:error, message} ->
              IO.puts("""

              *** Ocurrió un error: (#{message}) ***

              """)

              library_manager

            _ ->
              library_manager
          end

        loop(library_manager)

      7 ->
        IO.write("ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("ISBN: ")
        isbn = IO.gets("") |> String.trim()

        books = library_manager.books
        users = library_manager.users

        library_manager =
          case return_book(books, users, id, isbn) do
            {:ok, books, users} ->
              IO.puts("""
              El libro fue retornado exitosamente
              """)

              %{library_manager | books: books, users: users}

            {:error, message} ->
              IO.puts("""

              *** Ocurrió un error: (#{message}) ***

              """)

              library_manager

            _ ->
              library_manager
          end

        loop(library_manager)

      8 ->
        IO.write("ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        users = library_manager.users
        books = books_borrowed_by_user(users, id)

        list_books(%Library{books: books})
        loop(library_manager)

      9 ->
        books_unavailable = Enum.filter(library_manager.books, fn e -> !e.available end)
        list_books(%{library_manager | books: books_unavailable})
        loop(library_manager)

      10 ->
        users =
          Enum.filter(library_manager.users, fn e ->
            Enum.count(e.borrowed_books) > 0
          end)

        list_users(users)
        loop(library_manager)

      0 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(library_manager)
    end
  end

  def run do
    library_manager = %Library{}

    books = [
      %Book{
        title: "Cien años de soledad",
        author: "Gabriel García Márquez",
        isbn: "100",
        available: true
      },
      %Book{
        title: "1984",
        author: "George Orwell",
        isbn: "200",
        available: true
      },
      %Book{
        title: "Orgullo y prejuicio",
        author: "Jane Austen",
        isbn: "300",
        available: true
      }
    ]

    users = [
      %User{
        id: 1,
        name: "Juan Pérez",
        borrowed_books: []
      },
      %User{
        id: 2,
        name: "María García",
        borrowed_books: []
      },
      %User{
        id: 3,
        name: "Carlos López",
        borrowed_books: []
      }
    ]

    loop(%{library_manager | books: books, users: users})
  end
end

Library.run()
