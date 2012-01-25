-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                LDAP.Read                                  --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                     Copyright (C) 2012-, AdaHeads K/S                     --
--                                                                           --
--  This is free software;  you can redistribute it and/or modify it         --
--  under terms of the  GNU General Public License  as published by the      --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with AWS.LDAP.Thin;
with GNATCOLL.JSON;
with Yolk.Utilities;

package body LDAP.Read is

   function To_JSON
     (Dir     : in Directory;
      Message : in LDAP_Message)
      return GNATCOLL.JSON.JSON_Value;
   --  Convert a LDAP message to a JSON object.

   --------------
   --  Search  --
   --------------

   function Search
     (Base       : in String;
      Filter     : in String;
      Scope      : in Scope_Type    := LDAP_Scope_Default;
      Attrs      : in Attribute_Set := Null_Set;
      Attrs_Only : in Boolean       := False)
      return String
   is
      use GNATCOLL.JSON;

      A_Server : Server;
      LDAP_MSG : LDAP_Message;
   begin
      A_Server := Pop_Server;

      LDAP_MSG := Search
        (Get_Directory (A_Server),
         Base,
         Filter,
         Scope,
         Attrs,
         Attrs_Only);

      Push_Server (A_Server);

      return Write (To_JSON (Get_Directory (A_Server), LDAP_MSG));

   exception
      when Event : others =>
         return Error_Handler (Event, Base & Filter);
   end Search;

   ---------------
   --  To_JSON  --
   ---------------

   function To_JSON
     (Dir     : in Directory;
      Message : in LDAP_Message)
      return GNATCOLL.JSON.JSON_Value
   is
      use AWS.LDAP.Thin;
      use GNATCOLL.JSON;
      use Yolk.Utilities;

      BER          : aliased BER_Element;
      LDAP_MSG     : LDAP_Message;
      Objects_JSON : constant JSON_Value  := Create_Object;
   begin
      LDAP_MSG := First_Entry (Dir, Message);

      while LDAP_MSG /= Null_LDAP_Message loop
         declare
            Attrs      : Unbounded_String;
            Attrs_JSON : constant JSON_Value := Create_Object;
         begin
            Attrs := TUS
              (First_Attribute (Dir, LDAP_MSG, BER'Unchecked_Access));
            loop
               declare
                  RS : constant String_Set := Get_Values
                    (Dir, LDAP_MSG, TS (Attrs));
               begin
                  --  if there is more than one attribute, convert to an array
                  if RS'Length > 1 then
                     declare
                        Values : JSON_Array;
                     begin
                        for K in RS'Range loop
                           Append (Arr => Values,
                                   Val => Create (TS (RS (K))));
                        end loop;
                        Attrs_JSON.Set_Field (Field_Name => TS (Attrs),
                                              Field      => Values);
                     end;
                  else
                     --  Otherwise, just add as a field
                     Attrs_JSON.Set_Field (Field_Name => TS (Attrs),
                                           Field      => TS (RS (1)));

                  end if;
               end;
               Objects_JSON.Set_Field
                 (Get_DN (Dir, LDAP_MSG), Attrs_JSON);
               --  Next element
               Attrs := TUS (Next_Attribute (Dir, LDAP_MSG, BER));

               --  Exit when no more attributes
               exit when Attrs = Null_Unbounded_String;
            end loop;

            Free (BER);
         end;

         --  Get the next entry
         LDAP_MSG := Next_Entry (Dir, LDAP_MSG);
      end loop;

      --  Free memory
      Free (LDAP_MSG);

      return Objects_JSON;
   end To_JSON;

end LDAP.Read;
