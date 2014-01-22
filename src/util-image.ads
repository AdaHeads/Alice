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

with Model;

package Util.Image is

   function Image (Reception_ID : in Model.Reception_Identifier) return String;
   function Image (Contact_ID : in Model.Contact_Identifier) return String;
   function Image (Phone_ID : in Model.Phone_Identifier) return String;
   --  Image utility shortcuts.

   function Trim_Left (Item : in String) return String;
   function Trim_Right (Item : in String) return String;
   function Trim_Both (Item : in String) return String;
end Util.Image;
