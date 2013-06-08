# MixProtobuffs

You'll need to add erlang_protobuffs as a dep in your project.  Also put your .proto files in a proto/ directory.

This will output a .beam file with the parser and an .hrl file in the proto/ directory.  I recommend wrapping the records
in the .hrl file with Elixir records using import.

Future steps:  generate wrapper automatically.
