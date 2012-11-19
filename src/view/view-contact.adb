-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                               View.Contact                                --
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

with View.Contact_Attributes;

package body View.Contact is

   ---------------
   --  To_JSON  --
   ---------------

   function To_JSON
     (Contact_List : in Contact_List_Object)
      return JSON_Array
   is
      procedure Add_Contact_To_Array
        (Elem : in Model.Contacts.Contact_Object);

      C_Array : JSON_Array := Empty_Array;

      ----------------------------
      --  Add_Contact_To_Array  --
      ----------------------------

      procedure Add_Contact_To_Array
        (Elem : in Model.Contacts.Contact_Object)
      is
      begin
         Append (C_Array, To_JSON (Elem));
      end Add_Contact_To_Array;
   begin
      if Contact_List /= Null_Contact_List_Object then
         Contact_List.For_Each (Add_Contact_To_Array'Access);
      end if;

      return C_Array;
   end To_JSON;

   ---------------
   --  To_JSON  --
   ---------------

   function To_JSON
     (Contact : in Contact_Object)
      return JSON_Value
   is
      Attr_Array : JSON_Array;
      J          : JSON_Value := JSON_Null;
   begin
      if Contact /= Null_Contact_Object then
         J := Create_Object;

         J.Set_Field (Contact_Id, Integer (Contact.Contact_Id));

         J.Set_Field (Full_Name, Contact.Full_Name);

         J.Set_Field (Is_Human, Contact.Is_Human);

         for Elem of Contact.Attributes loop
            Append (Attr_Array, View.Contact_Attributes.To_JSON (Elem));
         end loop;

         if Length (Attr_Array) > 0 then
            J.Set_Field (Attributes, Attr_Array);
         end if;
      end if;

      return J;
   end To_JSON;

   ---------------
   --  To_JSON  --
   ---------------

   function To_JSON
     (Contact : in Contact_Object)
      return JSON_String
   is
   begin
      return To_JSON_String (To_JSON (Contact).Write);
   end To_JSON;

end View.Contact;
