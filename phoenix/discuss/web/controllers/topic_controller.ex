defmodule Discuss.TopicController do
  use Discuss.Web, :controller
  alias Discuss.Topic
    # like class inheritance. Imports a ton of stuff from Discuss.Web.ex/controller

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
    #this plug only runs when the listed routes are called.
  plug :check_topic_owner when action in [:update, :edit, :delete]
    #this declares a function plug, used only within this controller.
    #this plug will fire :check_topic_owner when it detects the listed functions called,
    #firing right before those functions.

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "you don't own this topic")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    topics = Repo.all(Topic) #note here that were passing in a module - this will return all the data records of this module type
    render conn, "index.html", topics: topics #this makes the @topics property availible to index.html.eex
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    # the get! will return an error if the topic_id isn't found
    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    # IO.puts "++++"
    # IO.inspect conn #The focus of Phoenix. CONN IS AWESOME
    # IO.puts "++++"
    # IO.inspect params #Help us parse the URL.
    # IO.puts "++++"

    struct = %Topic{}
    params = %{}
    changeset = Topic.changeset(struct, params)
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params) do
    IO.inspect(params)
    # When using the params obj, must use pattern matching to access values within since keys are strings
    %{"topic" => topic} = params # can also put this inplace of params in the method definition
    changeset = Topic.changeset(%Topic{}, topic)

    changeset = conn.assigns.user # takes current user off connection object
    |> build_assoc(:topics) # passed into build assoc, which creates a topic struct 
    |> Topic.changeset(topic) # which is passed into Topic.changeset as first arg. 
                              # the resulting topic that is created has an association to the current user

    case Repo.insert(changeset) do
      {:ok, _topic} -> 
        #IO.inspect(topic)
        conn
        |> put_flash(:info, "topic created") #shows single use messages to the user, destroyed upon next user action shown. shown in templates/layout/app.html.eex:26-27
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} -> 
        #IO.inspect(changeset)
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id) #Repo module will fo get a Topic out of our Topic Table that has the topic_id.
      #syntax is Repo.get(Module, prop_to_filter_by)
      IO.inspect(topic)
    changeset = Topic.changeset(topic) #using Topic.ex/:changeset function here

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id)
    |> Repo.delete!

    conn
    |> put_flash(:info, "Topic deleted")
    |> redirect(to: topic_path(conn, :index))
  end
end