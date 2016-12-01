defmodule Cards do
  #new function
  def hello do
    #note the implicit return of the last value
    "hi there!"
  end

  def create_deck do
    #notice the complete and total lack of objs... everything is data
    values = ["Ace", "Two", "Three", "Four", "Five"]
    suits = ["Hearts", "Spades", "Diamonds", "Clubs"]

    for suit <- suits, value <- values do
      # for every suit in suits, execute this doblock with each value in values
      "#{value} of #{suit}"
      #for is essentially a mapping function... this will return a new list
    end
    #Data is elixir is immutable... everything returns new data, anything made by create_deck/0 will NEVER be reassigned. 
  end

  def shuffle(deck) do
    # this def is shuffle/1... make sure your arity is correct!
    Enum.shuffle(deck)
    #Docs: http://elixir-lang.org/docs/stable/elixir/Enum.html#shuffle/1 check out rest of Enum module as well.
  end

  def contains?(deck, card) do
    # if function returns a bool, then convention is to name it with 
    Enum.member?(deck, card)
  end

  def deal(deck, hand_size) do
    Enum.split(deck, hand_size)
    #this will create a tuple where the first value will be the hand, and the second val will be the remaining deck.
    #this key value pair, but without the keys... the location of the object (first pos, second pos) will determine
    #what the values mean
  end

  def save(deck, filename) do
    #whenever we need to write Erlang code under elixir, we write the :erlang symbol
    #this code is using :erlang's built in term_to_binary function
    #which we're going save using the Elixir File module.
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary) 
  end

  def load(filename) do
    {status, binary} = File.read(filename)
    #Instructor note: Try to avoid if statements at all possible cost. Try to use
    #case statements like the one below and pattern matching
    case status do
      :ok -> :erlang.binary_to_term binary
      :error -> "that file doesn't exist"
    end
  end
end