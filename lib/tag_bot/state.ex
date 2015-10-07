defmodule TagBot.State do
  
  def start_link do
    Agent.start_link(fn -> HashDict.new end, name: __MODULE__)
  end

  def add_tags(user, tags) do
    Agent.update(__MODULE__, fn users ->
      set = Enum.into( tags, Dict.get(users, user, HashSet.new) )
      Dict.put(users, user, set)
    end)

    :ok
  end

  def remove_tags(user, tags) do
    Agent.update(__MODULE__, fn users ->
      removed_set = Enum.into(tags, HashSet.new)
      set = Dict.get(users, user, HashSet.new)
      Dict.put(users, user, Set.difference(set, removed_set))
    end)

    :ok
  end

  def get_users_for_tag(tag) do
    Agent.get(__MODULE__, fn users ->

      Enum.reduce(Dict.keys(users), [], fn(user, users_with_tag) ->
        tags = Dict.get(users, user)

        if Set.member?(tags, tag) do
          users_with_tag ++ [user]
        else
          users_with_tag
        end

      end)

    end)
  end

  def get_tags_for_user(user) do
    Agent.get(__MODULE__, fn users ->
      Set.to_list(Dict.get(users, user, HashSet.new))
    end)
  end

  def get_users_for_tags(tags) do
    Enum.map(tags, fn(tag) ->
      get_users_for_tag(tag)
    end)
    |> List.flatten
    |> Enum.uniq
  end


end