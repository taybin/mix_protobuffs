defmodule Mix.Tasks.Compile.Protobuffs do
  alias :protobuffs_compile, as: Compiler
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
    Defaults to `["proto"]`, can be configured as:

        [protobuff_paths: ["proto", "other"]]

  * `:protobuff_options` - compilation options that applies
     to protobuff's compiler. There are many other available
     options here: http://www.erlang.org/doc/man/yecc.html#file-1

  """
  def run(args) do
    { opts, _ } = OptionParser.parse(args, switches: [force: :boolean])

    proto_path = "proto"
    options = [output_include_dir: to_char_list(proto_path),
               output_ebin_dir: to_char_list("ebin")]

    files = Erlang.extract_stale_pairs(proto_path, "proto", proto_path, "hrl", opts[:force])

    if files == [] do
      :noop
    else
      compile_files(files, options || [])
      :ok
    end
  end

  defp compile_files(files, options) do
    lc { input, output } inlist files do
      result = Compiler.scan_file(to_char_list(input), options)
      Erlang.interpret_result(input, {result, :true}, "proto" )
    end
  end
end
