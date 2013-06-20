defmodule MixProtobuffs.Mixfile do
  use Mix.Project

  def project do
    [ app: :mix_protobuffs,
      version: "0.9.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    []
  end
end

defmodule Mix.Tasks.Install do
  use Mix.Task
  @shortdoc "Locally install the protobuff compile task."

  def run(_) do
    cmds = "echo 'y' | mix local.install ebin/Elixir.Mix.Tasks.Compile.Protobuffs.beam"
    IO.puts cmds
    IO.puts System.cmd(cmds)
  end
end
