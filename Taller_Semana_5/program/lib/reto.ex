defmodule Messenger do
  defmodule Person do
    defstruct name: "", id: ""

    def new(name) do
      id = UUID.uuid1()
      %Messenger.Person{name: name, id: id}
    end
  end

  defmodule Message do
    defstruct id: 0, from: %Messenger.Person{}, to: %Messenger.Person{}, message: ""

    def new(%Messenger.Person{} = from, %Messenger.Person{} = to, message) do
      %Message{id: UUID.uuid1(), from: from, to: to, message: message}
    end
  end

  defmodule Chat do
    use GenServer

    def start_link do
      IO.puts("[Messenger] starting the worker")
      GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def send_message(%Message{} = message) do
      GenServer.call(__MODULE__, {:new, message})
    end

    def print_chat() do
      GenServer.cast(__MODULE__, {:print})
    end

    @impl true
    def init(:ok) do
      {:ok, []}
    end

    @impl true
    def handle_call({:new, %Message{} = message}, _from, chats) do
      new_chats = Enum.concat(chats, [message])
      {:reply, message, new_chats}
    end

    @impl true
    def handle_cast({:print}, chats) do
      Enum.each(chats, fn e ->
        IO.puts("""
        |######################################################
        |DE: #{e.from.name}
        |PARA: #{e.to.name}
        |MESSAGE: #{e.message}
        |######################################################

        """)
      end)

      {:noreply, chats}
    end
  end
end
