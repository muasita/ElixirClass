defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build grid
    #due to piping, every method in this flow must return the same datatype - in this case, a %Identicon.Image{}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    gridVal = 
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1) #the &mirror_row/1 is how we pass function refs in Elixir. &function_name/arity#
      |> List.flatten #makes a list of lists into one list of values (that were in the other list)
      |> Enum.with_index #Since elixir is too cool for indices, this takes ever element in a list and makes it a tuple: [{value01, 0}, {value2, 1}, etc...]

    %Identicon.Image{image | grid: gridVal}
    #take everything from the image piped in, consume it, and create a new image struct with this additional value declared after the pipe
  end

  def mirror_row(row) do
    # -> [145, 46, 20]
    [first, second | _tail] = row
    # [145, 46, 200, 46, 145] ->
    row ++ [second, first]
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    #Above is an example of pattern matching in the method definition. Neat.
    #the pipe _tail tells elixir that we acknoledge that hex_list has more than three values,
    # but remember, with the _var, we just don't care about anything after the pipe!
    %Identicon.Image{image | color: {r, g, b}}
    #Here we're creating a new struct that consumes the image passed into pick_color/1
    #In functional programming, there is no image.color = rgb... there is just data.
  end



  def hash_input(input) do
    hexVal = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hexVal}
  end
end
