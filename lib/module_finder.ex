defmodule ModuleFinder do
  def find_module(module_atom) do
    path_chain = module_atom
                 |> Atom.to_string
                 |> String.split(".")
                 |> tl # to remove the Elixir-base module
                 |> Enum.map(fn(e) -> pascal_to_cebab(e) end)
  end

  def pascal_to_cebab(str) do
    << "_", rem::binary >> = Regex.replace(~r/([A-Z])/, str, fn(x) -> "_" <> String.downcase(x) end, global: true)
    rem
  end

  def find_files(dir, name) do
    {:ok, files} = File.ls(dir)
    (find_sub_dirs(dir, name, files) ++ scan_files(dir, name, files))
    |> List.flatten
  end

  def scan_files(dir, name, files) do
    Enum.filter(files, fn(n) ->
      name == n
    end)
    |> Enum.map(fn(n) -> "#{dir}/#{n}" end)
  end

  def find_sub_dirs(dir, name, files) do
    files
    |> Enum.filter(fn(n) -> File.dir?("#{dir}/#{n}") end)
    |> Enum.map(fn(n) -> find_files("#{dir}/#{n}", name) end)
  end
end
