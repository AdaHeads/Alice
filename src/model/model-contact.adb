-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2014-, AdaHeads K/S                     --
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

with Ada.Strings.Fixed;
with Configuration;
with System_Messages;

with Model.Contact.Utilities;

package body Model.Contact is

   package Config renames Configuration;

   -----------
   --  "="  --
   -----------

   overriding
   function "=" (Left, Right : in Instance) return Boolean is
   begin
      return Left.Reception_ID = Right.Reception_ID
        and  Left.Contact_ID   = Right.Contact_ID;
   end "=";

   ------------------------
   --  Create_From_JSON  --
   ------------------------

   function Create_From_JSON (JSON : in JSON_Value) return Instance is
   begin
      return (Contact_ID => Contact_Identifier
              (Natural'(JSON.Get (Field => Contact_ID_Key))),
              Reception_ID => Reception_Identifier
                (Natural'(JSON.Get (Field => Reception_ID_Key))),
              Phones => Model.Phone.Create_From_JSON (JSON.Get
                (Field => Phones_Key)));
   end Create_From_JSON;

   --------------------
   --  Extension_Of  --
   --------------------

   function Extension_Of (Object   : Instance;
                          Phone_ID : Phone_Identifier) return String is
   begin
      for Index in Object.Phones.First_Index .. Object.Phones.Last_Index loop
         declare
            Phone : Model.Phone.Instance renames Object.Phones.Element (Index);
         begin
            if Phone.ID = Phone_ID then
               return To_String (Phone.Value);
            end if;
         end;
      end loop;
      return To_String (Model.Phone.No_Phone.Value);
   exception
      when Constraint_Error =>
         return Model.Phone.Null_Extension;
   end Extension_Of;

   -------------
   --  Fetch  --
   -------------

   function Fetch (Reception  : in Reception_Identifier;
                   Contact    : in Contact_Identifier;
                   Auth_Token : in Token.Instance) return Instance is
      Context : constant String := Package_Name & ".Fetch";
   begin
      System_Messages.Debug (Message => "Forwarding token: " &
                               Auth_Token.To_String,
                             Context => Context);
      return Model.Contact.Utilities.Retrieve
        (Reception => Reception,
         Contact   => Contact,
         Token     => Auth_Token.To_String,
         From      => Config.Contact_Server);
   end Fetch;

   -------------
   --  Image  --
   -------------

   function Image (Object : Instance) return String is
      use Ada.Strings.Fixed;

      C_ID : constant String := Trim (Source => Object.Contact_ID'Img,
                                     Side   => Ada.Strings.Left);
      R_ID : constant String := Trim (Source => Object.Reception_ID'Img,
                                        Side   => Ada.Strings.Left);
   begin
      return C_ID & "@" & R_ID & " -> " & Model.Phone.Image (Object.Phones);
   end Image;

end Model.Contact;
