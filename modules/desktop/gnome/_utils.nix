{ lib }:

{
  int32_t = lib.gvariant.mkInt32;
  string = lib.gvariant.type.string;
  tuple = lib.gvariant.mkTuple;
  emptyArray = lib.gvariant.mkEmptyArray;

  mkDconf = { lockAll ? true }: settings: [
    { inherit settings lockAll; }
  ];
}
