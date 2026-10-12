pragma SPARK_Mode (On);

package Maximus_Gauntlet
  with Abstract_State => Arena_Memory,
       Initializes    => Arena_Memory
is

   type Byte is mod 256;

   Arena_Bytes : constant := 67_108_864;   --  64 MiB

   subtype Arena_Index  is Positive range 1 .. Arena_Bytes;
   subtype Arena_Offset is Natural  range 0 .. Arena_Bytes;

   Max_Chunk : constant := 4_096;

   type Byte_Array is array (Positive range <>) of Byte;

   function Injected (B : Byte) return Boolean
     is (B in 16#00# | 16#1B# | 16#3C# | 16#3E#);

   function Arena_Byte (I : Arena_Index) return Byte
     with Global => Arena_Memory;

   procedure Process_Payload
     (Chunk : Byte_Array;
      Fill  : in out Arena_Offset;
      Hits  : out Natural;
      Clean : out Boolean)
   with
     Global => (In_Out => Arena_Memory),
     Pre    => Chunk'First = 1
               and then Chunk'Length <= Max_Chunk
               and then Fill <= Arena_Bytes - Chunk'Length,
     Post   => Fill = Fill'Old + Chunk'Length
               and then Hits <= Chunk'Length
               and then Clean = (Hits = 0)
               and then Clean = (for all K in Chunk'Range => not Injected (Chunk (K)))
               and then (for all K in Chunk'Range => Arena_Byte (Fill'Old + K) = Chunk (K));

   procedure Purge_At_Dawn (Fill : out Arena_Offset)
   with
     Global => (In_Out => Arena_Memory),
     Post   => Fill = 0
               and then (for all K in Arena_Index => Arena_Byte (K) = 0);

end Maximus_Gauntlet;
