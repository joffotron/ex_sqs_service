defmodule SqsService.Message do
  @moduledoc """
  Struct that contains data from the SQS Message
  """
  defstruct [
    :body,
    :queue_name,
    :receipt_handle,
    :message_id
  ]
end

defmodule SqsService do
 @moduledoc """
  Service that is responsible for the low-level communication with AWS SQS
  """
  require Logger

  alias SqsService.Message

  @spec get_message(queue_name :: binary) :: SqsService.Message
  def get_message(queue_name) do
    case queue_name |> sqs_receive_message do
      {:ok, response} -> {:ok, response} |> process_message(queue_name)
      {:error, err} -> {:error, err}
    end
  end

  @spec process_message(response :: ExAws.Request.response_t, queue_name :: binary) :: SqsService.Message
  def process_message(response, queue_name) do
    {:ok, %{body: sqs_message}} = response
    sqs_message |> parse_receive_response(queue_name)
  end

  @spec mark_done({:no_message, any()}) :: {:no_message, any()}
  def mark_done({:no_message, _} = passthrough), do: passthrough

  @spec mark_done({:ok, %Message{}}) :: {:ok, String.t}
  def mark_done({:ok, %Message{message_id: message_id, queue_name: queue_name} = message}) do
    {:ok, _} = sqs_delete_message(message)
    Logger.info "Deleted message #{message_id} from #{queue_name}"
    {:ok, "Message Ack'd/Deleted"}
  end

  defp sqs_receive_message(queue_name) do
    Logger.debug fn -> "Requesting message from #{queue_name}"  end

    queue_name |> ExAws.SQS.receive_message
               |> ExAws.request
  end

  defp sqs_delete_message(%Message{receipt_handle: handle, queue_name: queue_name}) do
    queue_name |> ExAws.SQS.delete_message(handle)
               |> ExAws.request
  end

  defp parse_receive_response(%{messages: []}, _), do: {:no_message, nil}
  defp parse_receive_response(sqs_message, queue_name) do
    first_message = sqs_message.messages |> List.first
    {:ok, %Message{
      message_id:  first_message.message_id,
      queue_name: queue_name,
      receipt_handle: first_message.receipt_handle,
      body: decode_body(first_message)
      }}
  end

  defp decode_body(message) do
    {:ok, body} = message.body |> Poison.decode

    case body do
      %{"TopicArn" => _} -> decode_sns_body(body)
      _ -> body
    end
  end

  defp decode_sns_body(body) do
    {:ok, sns} = body["Message"] |> Poison.decode
    sns
  end
end
