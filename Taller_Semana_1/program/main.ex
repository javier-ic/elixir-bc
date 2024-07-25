defmodule InventoryManager do
  defstruct inventory: [], car: []

  def add_product(%InventoryManager{inventory: inventory} = inventory_manager, name, price, stock) do
    id = Enum.count(inventory) + 1

    new_item = %{
      id: id,
      name: name,
      price: price,
      stock: stock
    }

    %{inventory_manager | inventory: inventory ++ [new_item]}
  end

  def list_products(%InventoryManager{inventory: inventory}) do
    IO.puts("\n\n *** INVENTARIO *** \n")

    Enum.each(inventory, fn inventory ->
      IO.puts(
        "#{inventory.id} -> #{inventory.name} | Valor: $#{inventory.price} | Cantidad: (#{inventory.stock})"
      )
    end)

    IO.puts("\n*** ... ***\n")
  end

  def increase_stock(
        %InventoryManager{inventory: items, car: car} = inventory_manager,
        id,
        quantity
      ) do
    item_updated =
      Enum.map(items, fn item ->
        if(item.id == id) do
          %{item | stock: item.stock + quantity}
        else
          item
        end
      end)

    %{inventory_manager | inventory: item_updated}
  end

  def sell_product(
        %InventoryManager{inventory: items, car: car} = inventory_manager,
        id,
        quantity
      ) do
    item_to_sell = Enum.find(items, &(&1.id == id))

    item_updated =
      Enum.map(items, fn item ->
        if(item.id == id) do
          item_sold = %{item | stock: quantity}
          %{item | stock: item.stock - quantity}
        else
          item
        end
      end)

    %{
      inventory_manager
      | inventory: item_updated,
        car: car ++ [%{item_to_sell | stock: quantity}]
    }
  end

  def view_car(%InventoryManager{car: car}) do
    IO.puts("\n\n *** CARRITO *** \n")

    Enum.each(car, fn item ->
      IO.puts("#{item.id} -> #{item.name} | Valor: $#{item.price} | Cantidad: (#{item.stock})")
    end)

    items = Enum.reduce(car, 0, fn item, acc -> item.stock + acc end)
    total = Enum.reduce(car, 0, fn item, acc -> item.price * item.stock + acc end)

    IO.puts("--------------------------------")
    IO.puts("Productos (#{items}) -> Total: $#{total} \n\n")
    IO.puts("\n*** ... ***\n")
  end

  def checkout(%InventoryManager{inventory: inventory, car: car} = inventory_manager) do
    IO.puts("\n\n *** FIN DE LA COMPRA *** \n")

    total = Enum.reduce(car, 0, fn item, acc -> item.price * item.stock + acc end)
    IO.puts("\n\nTotal a pagar: #{total}\n")
    IO.puts("*** Gracias por su compra ***")
    IO.puts("\n*** ... ***\n")

    %{inventory_manager | car: []}
  end

  def run do
    inventory_manager = %InventoryManager{}
    loop(inventory_manager)
  end

  defp loop(inventory_manager) do
    IO.puts("""
    *******************
    Gestor de productos
    1. Agregar producto
    2. Listar productos
    3. Aumentar Stock
    4. Vender producto
    5. Ver carrito
    6. Finalizar compra
    0. Salir
    *******************
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el nombre del producto: ")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el valor del producto: ")
        price = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese cantidad inicial del producto: ")
        stock = IO.gets("") |> String.trim() |> String.to_integer()
        inventory_manager = add_product(inventory_manager, name, price, stock)
        loop(inventory_manager)

      2 ->
        list_products(inventory_manager)
        loop(inventory_manager)

      3 ->
        IO.write("Ingrese el id del producto para aumentar el stock: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese la cantidad a aumentar: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventory_manager = increase_stock(inventory_manager, id, quantity)
        loop(inventory_manager)

      4 ->
        IO.write("Ingrese el id del producto a vender: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese la cantidad: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventory_manager = sell_product(inventory_manager, id, quantity)
        loop(inventory_manager)

      5 ->
        view_car(inventory_manager)
        loop(inventory_manager)

      6 ->
        inventory_manager = checkout(inventory_manager)
        loop(inventory_manager)

      0 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(inventory_manager)
    end
  end
end

InventoryManager.run()
