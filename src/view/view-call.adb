-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                View.Call                                  --
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

with Model.Call_ID;
with Ada.Strings.Unbounded;
with Ada.Characters.Handling;

package body View.Call is
   use GNATCOLL.JSON;
   use Model.Call_ID;

   function Status_Message (Title   : in String;
                            Message : in String) return JSON_String is
      JSON : constant JSON_Value := Create_Object;
   begin
      JSON.Set_Field (View.Status, Title);
      JSON.Set_Field ("description", Message);
      return To_JSON_String (JSON.Write);
   end Status_Message;

   function To_JSON (Call : in Model.Call.Call_Type)
                     return GNATCOLL.JSON.JSON_Value is
      use Model.Call;
      use Ada.Strings.Unbounded;
      use Ada.Characters.Handling;

      Root : constant JSON_Value := Create_Object;
      Value : constant JSON_Value := Create_Object;
      --  Org_ID : Ada.Strings.Unbounded.Unbounded_String;
      --  Org_Prefix : constant String := "org_id";
   begin
      if Call /= Null_Call then
--           Org_ID := Ada.Strings.Unbounded.Tail
--             (Call.Queue,
--              Ada.Strings.Unbounded.Length (Call.Queue) - Org_Prefix'Length);

         Value.Set_Field (View.State_S, To_Lower (Call.State'Img));
         Value.Set_Field (View.Inbound, Call.Inbound);
         Value.Set_Field (View.Assigned_To_S, Call.Assigned_To.To_String);
         Value.Set_Field (View.Channel, Call.Channel.Image);
         Value.Set_Field (View.Organization_Id, To_String (Call.Queue));
         Value.Set_Field (View.Call_ID_S,  To_String (Call.ID));
         Value.Set_Field (View.Arrival_Time_S, Unix_Timestamp (Call.Arrived));
         Root.Set_Field (View.Call_S, Value);

      end if;
      return Root;
   end To_JSON;
end View.Call;
