# MixProtobuffs

You'll need to add erlang_protobuffs as a dep in your project.  Also put
your .proto files in a proto/ directory.

This will output a .beam file with the parser and an .hrl file in the
src/ directory.  The hrl file will then be wrapped by an ex file.

For instance, if you have a file named point.proto containing
```
message Point {
    required int32 x = 1;
    required int32 y = 2;
    optional string label = 3;
}
```

This will result in two .beam files named point_pb.beam and point.beam,
a hrl file named point_pb.hrl in src/, and a point.ex file in lib/.  The ex
file wraps the record so you can use it in the normal elixir way:
```
:point.new
:point.y
```
It also wraps the encoding/decoding functions:
```
Point.encode_point(:point.new)
Point.decode_point(binary)
```
