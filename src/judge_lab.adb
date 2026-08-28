-- ============================================================
--  HusGraal — Judge Lab Implementation
--  "Iustitia omnibus." (Spravedlnost vsem.)
--
--  Zizka: slepý na obe oci. Nikdy neprohrál.
--  SIC nebo NON. Mathematice proved.
-- ============================================================

pragma SPARK_Mode (On);

package body Judge_Lab is

   procedure File_Case (C    : in out Court_Case;
                        Kind : Case_Kind;
                        Prio : Case_Priority;
                        J    : Jurisdiction := EU;
                        Art  : Legal_Article := None) is
   begin
      -- Vinny dokud neprokaze nevinu. Bezpecnostni princip.
      C.Kind     := Kind;
      C.Priority := Prio;
      C.Status   := Under_Review;
      C.Juris    := J;
      C.Article  := Art;
      C.Decision := NON;
   end File_Case;

   procedure Render_Verdict (C      : in out Court_Case;
                             Result : Verdict;
                             Reason : Verdict_Reason) is
   begin
      C.Decision := Result;
      C.Reason   := Reason;
      C.Status   := Verdict_Made;
   end Render_Verdict;

   procedure Enforce (C : in out Court_Case) is
   begin
      C.Status   := Enforced;
      C.Enforced := True;
   end Enforce;

   procedure Appeal (C : in out Court_Case) is
   begin
      -- Jedno odvolani. Zizka znovu posoudí. Prisneji.
      C.Status   := Under_Review;
      C.Appealed := True;
   end Appeal;

   procedure Archive (C : in out Court_Case) is
   begin
      C.Status := Archived;
   end Archive;

   procedure Count_Case (Counter : in out Case_Counter) is
   begin
      Counter := Counter + 1;
   end Count_Case;

   function Conviction_Rate (SIC_Count : Case_Counter;
                             Total     : Case_Counter) return Natural is
      Rate : Natural;
   begin
      Rate := Natural (SIC_Count) * 100 / Natural (Total);
      if Rate > 100 then
         Rate := 100;
      end if;
      return Rate;
   end Conviction_Rate;

   function License_Compatible (A, B : License_Type) return Boolean is
   begin
      if A = Charter or B = Charter then return True; end if;
      if A = Public_Domain or B = Public_Domain then return True; end if;
      if A = B then return True; end if;
      if A in Apache_2_0 | MIT | BSD_3 and B in Apache_2_0 | MIT | BSD_3
      then return True; end if;
      if (A in Apache_2_0 | MIT | BSD_3 and B in GPL_3 | LGPL_3 | MPL_2)
         or (B in Apache_2_0 | MIT | BSD_3 and A in GPL_3 | LGPL_3 | MPL_2)
      then return True; end if;
      if (A = LGPL_3 and B = GPL_3) or (A = GPL_3 and B = LGPL_3)
      then return True; end if;
      return False;
   end License_Compatible;

   function Verify_Standard_700 (Coins : Natural;
                                 Silver_Grams : Natural) return Verdict is
   begin
      if Silver_Grams >= Coins * Standard_700_Grams then
         return SIC;
      else
         return NON;
      end if;
   end Verify_Standard_700;

end Judge_Lab;
