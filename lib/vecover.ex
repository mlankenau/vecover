defmodule Vecover do

  @template """
  "hi HitLine ctermbg=Cyan guibg=Cyan
  "hi MissLine ctermbg=Magenta guibg=Magenta
  hi HitSign ctermfg=Green cterm=bold gui=bold guifg=Green
  hi MissSign ctermfg=Red cterm=bold gui=bold guifg=Red

  sign define hit  linehl=HitLine  texthl=HitSign  text=>>
  sign define miss linehl=MissLine texthl=MissSign text=:(

  "Generated by simplecov-vim
  let s:coverage = {__PLACEHOLDER__}

  let s:generatedTime = __GENERATED_TIME__

  function! BestCoverage(coverageForName)
    let matchBadness = strlen(a:coverageForName)
    for filename in keys(s:coverage)
      let matchQuality = match(a:coverageForName, filename . "$")
      if (matchQuality >= 0 && matchQuality < matchBadness)
        let found = filename
      endif
    endfor

    if exists("found")
      return s:coverage[found]
    else
      echom "No coverage recorded for " . a:coverageForName
      return [[],[]]
    endif
  endfunction

  let s:signs = {}
  let s:signIndex = 1

  function! s:CoverageSigns(filename)
    let [hits,misses] = BestCoverage(a:filename)

    if (getftime(a:filename) > s:generatedTime)
      echom "File is newer than coverage report which was generated at " . strftime("%c", s:generatedTime)
    endif

    if (! exists("s:signs['".a:filename."']"))
      let s:signs[a:filename] = []
    endif

    for hit in hits
      let id = s:signIndex
      let s:signIndex += 1
      let s:signs[a:filename] += [id]
      exe ":sign place ". id ." line=".hit." name=hit  file=" . a:filename
    endfor

    for miss in misses
      let id = s:signIndex
      let s:signIndex += 1
      let s:signs[a:filename] += [id]
      exe ":sign place ".id." line=".miss." name=miss file=" . a:filename
    endfor
  endfunction

  function! s:ClearCoverageSigns(filename)
    if(exists("s:signs['". a:filename."']"))
      for signId in s:signs[a:filename]
        exe ":sign unplace ".signId
      endfor
      let s:signs[a:filename] = []
    endif
  endfunction

  let s:filename = expand("<sfile>")
  function! s:AutocommandUncov(sourced)
    if(a:sourced == s:filename)
      call s:ClearCoverageSigns(expand("%:p"))
    endif
  endfunction

  command! -nargs=0 Cov call s:CoverageSigns(expand("%:p"))
  command! -nargs=0 Uncov call s:ClearCoverageSigns(expand("%:p"))

  augroup SimpleCov
    au!
    exe "au SourcePre ".expand("<sfile>:t")." call s:AutocommandUncov(expand('<afile>:p'))"
  augroup end

  Cov
  """

  def start(compile_path, _opts) do
    :cover.start
    :cover.compile_beam_directory(compile_path |> to_char_list)

    fn() ->
      coverage = :cover.modules |> Enum.map(fn(mod) ->
                   {:ok, lines} = :cover.analyze(mod, :line)
                   lines
                 end)
                 |> generate_vim_data()

      content =
        String.replace(@template, "__PLACEHOLDER__", coverage)
        |> String.replace("__GENERATED_TIME__", Integer.to_string(div(:erlang.system_time, 1_000_000_000)))
      File.write("coverage.vim", content)
    end
  end

  def module_map() do
    {output, 0} = System.cmd("grep", ["-ri", "defmodule",  "."])
    output
    |> String.split("\n")
    |> Enum.map(fn(l) ->
      ~r/([^:]+):.*defmodule +(.*) +/
      |> Regex.run(l)
      |> case do
        [_all, file, module_name] ->
          {"Elixir." <> module_name, file}
        _ ->
          nil
      end
    end)
    |> Enum.filter(fn(e) -> e end)
    |> Enum.into(%{})
  end

  def generate_vim_data(list) do
    mod_map = module_map()
    list
    |> Enum.map(fn(lines) ->
      lines |> Enum.map(fn(line) ->
        {{module, line}, {coverred, _uncovered}} = line
        path = mod_map[Atom.to_string(module)]
        {path, line, coverred}
      end)
    end)
    |> List.flatten
    |> Enum.group_by(fn ({path, _line, _}) -> path end)
    |> Enum.map(fn({src, lines}) ->
      {
        src,
        Enum.filter(lines, fn({_, lines, mark}) -> mark == 1 && lines > 0 end) |> Enum.map(&(elem &1, 1)),
        Enum.filter(lines, fn({_, lines, mark}) -> mark == 0 && lines > 0 end) |> Enum.map(&(elem &1, 1))
      }
    end)
    |> Enum.filter(fn({src, _good, _bad}) -> src end)
    |> Enum.map(fn({src, good, bad}) -> "'#{src}': [#{list_to_str good}, #{list_to_str bad}] " end)
    |> Enum.join(",")
  end

  def list_to_str(list) do
    entries = list
              |> Enum.map(fn(i) -> Integer.to_string(i) end)
              |> Enum.join(", ")
    "[#{entries}]"
  end
end
