defmodule Mix.Tasks.Compile.Protobuffs do

  alias :yecc, as: Yecc
  alias :protobuffs_compiler, as: Compiler
  alias Mix.Utils
  alias Mix.Tasks.Compile.Erlang
  use Mix.Task

  @hidden true
  @shortdoc "Compile protocol buffer files"
  @recursive true

  @moduledoc """
  A task to compile protocol buffer files.

  When this task runs, it will check the mod time of every file, and
  if it has changed, then file will be compiled. Files will be
  compiled in the same source directory with .erl extension.
  You can force compilation regardless of mod times by passing
  the `--force` option.

  ## Command line options

  * `--force` - forces compilation regardless of module times;

  ## Configuration

  * `:protobuff_paths` - directories to find source files.
    Defaults to `["lib"]`, can be configured as:

        [protobuff_paths: ["lib", "other"]]

  * `:protobuff_options` - compilation options that applies
     to protobuff's compiler. There are many other available
     options here: http://www.erlang.org/doc/man/yecc.html#file-1

  """
  def run(args) do
    { opts, _ } = OptionParser.parse(args, switches: [force: :boolean])

    project = Mix.project
    source_paths = project[:protobuff_paths]

    files = lc source_path inlist source_paths do
              Erlang.extract_stale_pairs(source_path, :proto, source_path, :erl, opts[:force])
            end |> List.flatten

    if files == [] do
      :noop
    else
      compile_files(files, project[:protobuff_options] || [])
      :ok
    end
  end

  defp compile_files(files, options) do
    lc { input, output } inlist files do
      options = options ++ [parserfile: Erlang.to_erl_file(output), report: true]
      Erlang.interpret_result(input,
        Compiler.scan_file(Erlang.to_erl_file(input), options))
    end
  end
end
