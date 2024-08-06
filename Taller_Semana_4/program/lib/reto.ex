defmodule Messenger do
  @moduledoc """
  Este modulo permite crear chats independientes entre dos personas.

  Ejemplo de uso:

  // Crea las personas que van a interactuar en el chat
  p1 = Messenger.Person.new("Thor")
  p2 = Messenger.Person.new("Loki")

  // Creamos varios mensajes teniendo en cuenta el parametro FROM y el TO.
  msg1 = Messenger.Message.new(p1, p2, "Hola!")
  msg2 = Messenger.Message.new(p2, p1, "Como estas?")
  msg3 = Messenger.Message.new(p1, p2, "Bien gracias")

  // Se inicia una sala de Chat, se pueden tener varias salas independientes.
  chat1 = Messenger.Chat.start()

  // Enviamos los mensajes a la sala de chat creado anteriormente.
  Messenger.Chat.send_message(chat1, msg1)
  Messenger.Chat.send_message(chat1, msg2)
  Messenger.Chat.send_message(chat1, msg3)

  // Imprime los mensajes enviados a la sala de chat.
  Messenger.Chat.print_chat(chat1)

  Respuesta ->

    |######################################################
    |DE: Thor
    |PARA: Loki
    |MESSAGE: Hola!
    |######################################################

    |######################################################
    |DE: Loki
    |PARA: Thor
    |MESSAGE: Como estas?
    |######################################################

    |######################################################
    |DE: Thor
    |PARA: Loki
    |MESSAGE: Bien gracias
    |######################################################
  """
  defmodule Person do
    @moduledoc """
    Con este modulo, definimos la estructura de una persona.
    """
    defstruct name: "", id: ""

    def new(name) do
      id = UUID.uuid1()
      %Messenger.Person{name: name, id: id}
    end
  end

  defmodule Message do
    @moduledoc """
    Con este modulo, creamos un nuevo mensaje que debe tener un remitente (from) y un destinatario(to).
    """
    defstruct id: 0, from: %Messenger.Person{}, to: %Messenger.Person{}, message: ""

    def new(%Messenger.Person{} = from, %Messenger.Person{} = to, message) do
      %Message{id: UUID.uuid1(), from: from, to: to, message: message}
    end
  end

  defmodule Chat do
    def start() do
      spawn(fn -> loop([]) end)
    end

    def send_message(process_id, %Message{} = message) do
      send(process_id, {:new, message})
    end

    def print_chat(process_id) do
      send(process_id, {:print})
    end

    defp loop(chats) do
      receive do
        {:new, %Messenger.Message{} = message} ->
          chats_updated = chats ++ [message]
          loop(chats_updated)

        {:print} ->
          Enum.each(chats, fn e ->
            IO.puts("""

            |######################################################
            |DE: #{e.from.name}
            |PARA: #{e.to.name}
            |MESSAGE: #{e.message}
            |######################################################
            """)
          end)

          loop(chats)

        _ ->
          IO.puts("Error")
          loop(chats)
      end
    end
  end
end
