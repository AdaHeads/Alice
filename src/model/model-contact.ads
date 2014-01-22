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

with Ada.Containers.Vectors;
with GNATCOLL.JSON;
private
with Ada.Strings.Unbounded,
     Ada.Strings.Unbounded.Equal_Case_Insensitive;

package Model.Contact is
   use Model;
   use GNATCOLL.JSON;

   Package_Name : constant String := "Model.Contact";

   Contact_ID_Key        : constant String := "contact_id";
   Reception_ID_Key      : constant String := "reception_id";
   Telephone_Numbers_Key : constant String := "telephonenumbers";

   type Instance is tagged private;

   function Create_From_JSON (JSON : in JSON_Value) return Instance;
   --  Constructs a new instance, based on a JSON map.

   function Fetch (Reception : in Reception_Identifier;
                   Contact   : in Contact_Identifier) return Instance;
   --  Fetches a given contact@reception from a contact service.

   function Extension_Of (Object : Instance;
                          Phone  : Phone_Identifier) return String;
   --  Returns the specific extension assciated with the Phone_Identifer.

   function Image (Object : Instance) return String;
   --  Returns a string representation of the instance.

   function "=" (Left, Right : in Instance) return Boolean;
   --  Equals operation. Two instances are considered equal if both their
   --  reception identifier and contact identifier are equal.

   No_Contact : constant Instance;
   --  No-object reference.

   Null_Extension : constant String;

private
   use Ada.Strings.Unbounded;

   Null_Extension : constant String := "";

   package Phones_Storage is new Ada.Containers.Vectors
     (Index_Type   => Phone_Identifier,
      Element_Type => Unbounded_String,
      "="          => Ada.Strings.Unbounded.Equal_Case_Insensitive);

   subtype Phone_List is Phones_Storage.Vector;

   function Create_From_JSON (JSON : in JSON_Array) return Phone_List;

   type Instance is tagged
      record
         Contact_ID   : Contact_Identifier;
         Reception_ID : Reception_Identifier;
         Phones       : Phone_List;
      end record;

   No_Contact : constant Instance :=
     (Contact_ID   => 0,
      Reception_ID => Model.Null_Reception_Identifier,
      Phones       => Phones_Storage.Empty_Vector);

   function Image (Phones : Phone_List) return String;

end Model.Contact;
