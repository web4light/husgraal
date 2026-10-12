pragma SPARK_Mode (On);

package body Maximus_Gauntlet
  with Refined_State => (Arena_Memory => Arena)
is

   type Arena_Array is array (Arena_Index) of Byte;

   Arena : Arena_Array := (others => 0);

   function Arena_Byte (I : Arena_Index) return Byte
   is (Arena (I));

   procedure Process_Payload
     (Chunk : Byte_Array;
      Fill  : in out Arena_Offset;
      Hits  : out Natural;
      Clean : out Boolean)
   is
      Start : constant Arena_Offset := Fill;
   begin
      Hits  := 0;
      Clean := True;

      for I in Chunk'Range loop
         Arena (Start + I) := Chunk (I);

         if Injected (Chunk (I)) then
            Hits  := Hits + 1;
            Clean := False;
         end if;

         pragma Loop_Invariant (Hits <= I);
         pragma Loop_Invariant (Clean = (Hits = 0));
         pragma Loop_Invariant
           (Clean = (for all K in Chunk'First .. I => not Injected (Chunk (K))));
         pragma Loop_Invariant
           (for all K in Chunk'First .. I => Arena (Start + K) = Chunk (K));
      end loop;

      Fill := Start + Chunk'Length;
   end Process_Payload;

   procedure Purge_At_Dawn (Fill : out Arena_Offset) is
   begin
      for I in Arena_Index loop
         Arena (I) := 0;
         pragma Loop_Invariant
           (for all K in Arena_Index'First .. I => Arena (K) = 0);
      end loop;

      Fill := 0;
   end Purge_At_Dawn;

end Maximus_Gauntlet;
