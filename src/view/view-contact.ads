-------------------------------------------------------------------------------
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

with Common;
with GNATCOLL.JSON;
with Model.Contact;
with Model.Contacts;

package View.Contact is

   use Common;
   use GNATCOLL.JSON;

   function To_JSON
     (Instance : in Model.Contact.Object)
      return JSON_Value;
   --  Convert Instance to a JSON object.

   function To_JSON_Array
     (Instance : in Model.Contacts.List)
      return JSON_Array;
   --  Convert Instance to a JSON array.

   function To_JSON_String
     (Instance : in Model.Contact.Object)
      return JSON_String;
   --  Convert Instance to a JSON string.

end View.Contact;
