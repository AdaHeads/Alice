-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2013-, AdaHeads K/S                     --
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

package body View.User is
   function To_JSON (Item  : in     Model.User.Name;
                     Label : in     User_Name_Labels)
                    return JSON.JSON_Value is
      use JSON;
      Data : JSON_Value;
   begin
      Data := Create_Object;

      Data.Set_Field (Field_Name => Label,
                      Field      => String (Item));

      Data.Set_Field (Field_Name => Label,
                      Field      => String (ID));
      return Data;
   end To_JSON;

   function To_JSON (Item  : in     Model.User.Instance)
                     return JSON.JSON_Value is
      use JSON;
      Data : JSON_Value;
   begin
      Data := Create_Object;

      Data.Set_Field (Field_Name => View.Name,
                      Field      => Item.User_Name);

      Data.Set_Field (Field_Name => View.ID,
                      Field      => Item.ID);

      return Data;
   end To_JSON;

   function To_JSON (Item  : in     Model.User.OpenID;
                     Label : in     OpenID_URL_Labels)
                    return JSON.JSON_Value is
      use JSON;
      Data : JSON_Value;
   begin
      Data := Create_Object;

      Data.Set_Field (Field_Name => Label,
                      Field      => Model.User.URL (Item));

      return Data;
   end To_JSON;

   function To_JSON (Item : in     Model.User.OpenID_List)
                    return JSON.JSON_Array is
      use JSON;
      Data : JSON_Array;
   begin
      for OpenID of Item loop
         Append (Arr => Data,
                 Val => View.User.To_JSON (Item  => OpenID,
                                           Label => View.URL));
      end loop;

      return Data;
   end To_JSON;
end View.User;
