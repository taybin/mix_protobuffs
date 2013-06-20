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
     options here: https://github.com/basho/erlang_protobuffs

  """
  def run(args) do
    { opts, _ } = OptionParser.parse(args, switches: [force: :boolean])

    source_paths = opts[:proto_paths] || ["proto"]
    options = [output_include_dir: to_char_list("src"),
               output_ebin_dir: to_char_list("ebin")] ++ opts

    files = lc source_path inlist source_paths do
              Erlang.extract_stale_pairs(source_path, "proto", "lib", "ex", opts[:force])
            end |> List.flatten

    if files == [] do
      :noop
    else
      File.mkdir(options[:output_include_dir])  # create "src" if necessary
      compile_files(files, options)
      generate_wrappers(files, options)
      :ok
    end
  end

  defp compile_files(files, options) do
    lc { input, _output } inlist files do
      result = Compiler.scan_file(to_char_list(input), options)
      Erlang.interpret_result(input, {result, :true})
    end
  end

  defp generate_wrappers(files, _options) do
    lc { input, output } inlist files do
      basename = Path.basename(input, ".proto")
      header = "src/" <> basename <> "_pb.hrl"
      records = record_names(header)
      {:ok, file} = File.open(output, [:write])
      IO.write(file, "defmodule #{String.capitalize(basename)} do\n\n")
      lc record inlist records do
        IO.write(file, "  defrecord :#{record}, Record.extract(:#{record}, from: \"#{header}\")\n")
        IO.write(file, "  def encode_#{record}(record), do: :#{basename}_pb.encode_#{record}(record)\n")
        IO.write(file, "  def decode_#{record}(binary), do: :#{basename}_pb.decode_#{record}(binary)\n\n")
      end
      IO.write(file, "end")
      File.close(file)
    end
  end

  defp record_names(header) do
    contents = File.read!(header)
    Regex.scan(%r/record\((.*),/, contents) |> List.flatten
  end
end
