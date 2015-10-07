defmodule TagBot.RTM do
  use Slack

  alias TagBot.State

  def init(initial_state, slack) do
    IO.inspect "Connected as #{slack.me.name}"
    {:ok, initial_state}
  end

  def handle_message(message = %{ type: "message", text: "tagbot add tag " <> tags, user: user }, slack, state) do
    tags = String.split(tags)

    message_to_send = case State.add_tags(slack.users[user].name, tags) do
      :ok ->
        "#{tags} added"
      { :error, reason } ->
        "#{tags} not added. reason: #{reason}"
    end

    send_message(message_to_send, message.channel, slack)

    {:ok, state }
  end

  def handle_message(message = %{ type: "message", text: "tagbot remove tag " <> tags, user: user }, slack, state) do

    tags = String.split(tags)

    message_to_send = case State.remove_tags(slack.users[user].name, tags) do
      :ok ->
        "#{tags} removed"
      { :error, reason } ->
        "#{tags} not removed. reason: #{reason}"
    end

    send_message(message_to_send, message.channel, slack)

    { :ok, state }
  end

  def handle_message(message = %{ type: "message", text: "tagbot my tags", user: user }, slack, state) do
    message_to_send = Enum.join(State.get_tags_for_user(slack.users[user].name), ", ")

    send_message(message_to_send, message.channel, slack)

    {:ok, state ++ [message.text]}
  end

  def handle_message(message = %{ type: "message", text: "tagbot whois #" <> tag }, slack, state) do
    message_to_send =  Enum.join(State.get_users_for_tag(tag), ", ")

    send_message(message_to_send, message.channel, slack)

    {:ok, state }
  end

  def handle_message(message = %{ type: "message", text: text }, slack, state) do
    tags = look_for_tags_in_message(text)

    if tags == [] do
      {:ok, state}
    else
      users = State.get_users_for_tags(tags)
      users = Enum.join(users, ", ")

      send_message("(#{users}) #{text}", message.channel, slack)

      { :ok, state }    
    end
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def look_for_tags_in_message(message) do
    Enum.reduce(String.split(message), [], fn
      ("#" <> tag, tags) ->
        tag = String.replace(tag, ~r/\p{P}/, "")

        tags ++ [tag]
      (_, tags) ->
        tags
    end)
  end
end