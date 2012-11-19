-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                  Model                                    --
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

with Ada.Strings.Hash;

package body Model is

   -----------------------
   --  Equivalent_Keys  --
   -----------------------

   function Equivalent_Keys
     (Left, Right : in Attributes_Identifier)
      return Boolean
   is
   begin
      return Left = Right;
   end Equivalent_Keys;

   -----------------------
   --  Equivalent_Keys  --
   -----------------------

   function Equivalent_Keys
     (Left, Right : in Organization_Contact_Identifier)
      return Boolean
   is
   begin
      return Left = Right;
   end Equivalent_Keys;

   ----------------
   --  Key_Hash  --
   ----------------

   function Key_Hash
     (Key : in Attributes_Identifier)
      return Ada.Containers.Hash_Type
   is
   begin
      return Ada.Strings.Hash
        (Contact_Identifier'Image (Key.C_Id) &
           Organization_Identifier'Image (Key.O_Id));
   end Key_Hash;

   ----------------
   --  Key_Hash  --
   ----------------

   function Key_Hash
     (Key : in Organization_Contact_Identifier)
      return Ada.Containers.Hash_Type
   is
   begin
      return Ada.Strings.Hash
        (Contact_Identifier'Image (Key.C_Id) &
           Organization_Identifier'Image (Key.O_Id));
   end Key_Hash;

end Model;
