-- ============================================================
--  HusGraal — Judge Lab (Ada/SPARK 2026)
--
--  Iustitia omnibus. Sine pretio retis.
--  (Spravedlnost vsem. Za cenu site.)
--
--  Verdikt: SIC nebo NON. Zadna seda zona.
--  Mathematice proved. Neni mozne halucinovat.
--
--  Agent: Zizka — slepý, neporazeny, spravedlivy
--
--  Autor: Pan Jeskyne
--  Organizace: Rebirth Phoenix Foundation Charter
--  Licence: Apache 2.0
-- ============================================================

pragma SPARK_Mode (On);

package Judge_Lab is

   -- =========================================================
   --  Verdikt — SIC nebo NON.
   -- =========================================================

   type Verdict is (SIC, NON);

   type Verdict_Reason is (
      License_OK, License_Violation,
      Code_Proved, Code_Unproved,
      Agent_Certified, Agent_Rejected,
      Contract_Safe, Contract_Vuln,
      KYC_Passed, KYC_Failed,
      Audit_Clean, Audit_Suspicious,
      GDPR_Compliant, GDPR_Violation,
      AI_Act_Compliant, AI_Act_Violation,
      DSA_Compliant, DSA_Violation,
      DSG_Compliant, DSG_Violation,
      DMCA_Compliant, DMCA_Violation,
      CCPA_Compliant, CCPA_Violation,
      HIPAA_Compliant, HIPAA_Violation);

   -- =========================================================
   --  Jurisdikce
   -- =========================================================

   type Jurisdiction is (
      CH,    -- Svycarsko (DSG, OR, ZGB)
      EU,    -- Evropska unie (GDPR, EU AI Act, DSA, DMA)
      US,    -- Spojene staty (DMCA, CCPA, COPPA, SOX)
      CZ,    -- Ceska republika
      DE,    -- Nemecko
      UK,    -- Spojena kralovstvi
      CA,    -- Kanada
      AU,    -- Australie
      JP,    -- Japonsko
      SG,    -- Singapur
      INTL); -- Mezinarodni (WIPO, Bernska umluva)

   -- =========================================================
   --  Pravni paragrafy
   -- =========================================================

   type Legal_Article is (
      -- CH
      CH_DSG_Art_5, CH_DSG_Art_6, CH_DSG_Art_25, CH_DSG_Art_32,
      CH_OR_Art_328b, CH_URG_Art_2, CH_URG_Art_10, CH_URG_Art_19,
      -- EU
      EU_GDPR_Art_4, EU_GDPR_Art_6, EU_GDPR_Art_9, EU_GDPR_Art_13,
      EU_GDPR_Art_17, EU_GDPR_Art_20, EU_GDPR_Art_22, EU_GDPR_Art_25,
      EU_GDPR_Art_32, EU_GDPR_Art_83,
      EU_AI_Act_Art_6, EU_AI_Act_Art_9, EU_AI_Act_Art_13, EU_AI_Act_Art_50,
      EU_DSA_Art_16, EU_DMA_Art_5,
      EU_InfoSoc_Art_2, EU_InfoSoc_Art_3,
      -- US
      US_DMCA_Sec_512, US_DMCA_Sec_1201,
      US_CCPA_Sec_1798, US_COPPA_Sec_6, US_CFAA_Sec_1030,
      US_SOX_Sec_302, US_HIPAA_164, US_FTC_Sec_5,
      US_GPL3_Sec_4, US_GPL3_Sec_5, US_Apache2_Sec_4,
      -- INTL
      WIPO_Berne_Art_2, WIPO_Berne_Art_9, WIPO_TRIPs_Art_10,
      None);

   -- =========================================================
   --  Typy pripadu
   -- =========================================================

   type Case_Kind is (
      License_Audit, Code_Verification, Agent_Certification,
      Smart_Contract_Audit, KYC_Verification, Behavior_Audit,
      Regulatory_Compliance, Data_Protection,
      IP_Enforcement, AI_Act_Compliance);

   type Case_Priority is (Critical, High, Normal, Low);
   type Case_Status is (Filed, Under_Review, Verdict_Made, Enforced, Archived);

   Max_Case_ID : constant := 999_999;
   subtype Case_ID is Positive range 1 .. Max_Case_ID;

   type Court_Case is record
      ID       : Case_ID := 1;
      Kind     : Case_Kind := License_Audit;
      Priority : Case_Priority := Normal;
      Status   : Case_Status := Filed;
      Decision : Verdict := NON;
      Reason   : Verdict_Reason := Audit_Suspicious;
      Juris    : Jurisdiction := EU;
      Article  : Legal_Article := None;
      Appealed : Boolean := False;
      Enforced : Boolean := False;
   end record;

   -- =========================================================
   --  Zizka — operace
   -- =========================================================

   procedure File_Case (C    : in out Court_Case;
                        Kind : Case_Kind;
                        Prio : Case_Priority;
                        J    : Jurisdiction := EU;
                        Art  : Legal_Article := None)
     with Pre  => C.Status = Filed,
          Post => C.Status = Under_Review and C.Kind = Kind
                  and C.Juris = J and C.Article = Art;

   procedure Render_Verdict (C      : in out Court_Case;
                             Result : Verdict;
                             Reason : Verdict_Reason)
     with Pre  => C.Status = Under_Review,
          Post => C.Status = Verdict_Made and
                  C.Decision = Result and C.Reason = Reason;

   procedure Enforce (C : in out Court_Case)
     with Pre  => C.Status = Verdict_Made,
          Post => C.Status = Enforced and C.Enforced = True;

   procedure Appeal (C : in out Court_Case)
     with Pre  => C.Status = Verdict_Made and C.Appealed = False,
          Post => C.Status = Under_Review and C.Appealed = True;

   procedure Archive (C : in out Court_Case)
     with Pre  => C.Status = Enforced,
          Post => C.Status = Archived;

   -- Licencni matice
   type License_Type is (Apache_2_0, MIT, GPL_3, LGPL_3,
                         BSD_3, MPL_2, Proprietary, Public_Domain, Charter);

   function License_Compatible (A, B : License_Type) return Boolean;

   -- Standard 700
   Standard_700_Grams : constant := 12;

   function Verify_Standard_700 (Coins : Natural;
                                 Silver_Grams : Natural) return Verdict
     with Pre  => Coins <= 99_999_999,
          Post => (if Silver_Grams >= Coins * Standard_700_Grams
                   then Verify_Standard_700'Result = SIC
                   else Verify_Standard_700'Result = NON);

   -- Statistiky
   type Case_Counter is new Natural range 0 .. Max_Case_ID;

   procedure Count_Case (Counter : in out Case_Counter)
     with Pre  => Counter < Case_Counter'Last,
          Post => Counter = Counter'Old + 1;

   function Conviction_Rate (SIC_Count : Case_Counter;
                             Total     : Case_Counter) return Natural
     with Pre  => Total > 0,
          Post => Conviction_Rate'Result <= 100;

end Judge_Lab;
