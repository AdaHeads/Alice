-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                         Model.Contacts_Attributes                         --
--                                                                           --
--                                  SPEC                                     --
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
with GNATCOLL.SQL.Exec;

package Model.Contacts_Attributes is

   type Contact_Attributes_Object is tagged private;
   Null_Contact_Attributes : constant Contact_Attributes_Object;

   function Create
     (C_Id : in Contact_Identifier;
      O_Id : in Organization_Identifier;
      JSON : in GNATCOLL.JSON.JSON_Value)
      return Contact_Attributes_Object;
   --  Create a Contact_Attributes_Object.

   procedure For_Each
     (C_Id    : in Contact_Identifier;
      Process : not null access
        procedure (Element : in Contact_Attributes_Object'Class));
   --  For every contact_attributes row with C_Id in the database, a
   --  Contact_Attributes_Object is handed to Process.

   procedure For_Each
     (C_Id    : in Contact_Identifier;
      O_Id    : in Organization_Identifier;
      Process : not null access
        procedure (Element : in Contact_Attributes_Object'Class));
   --  For every contact_attributes row with C_Id and O_Id in the database, a
   --  Contact_Attributes_Object is handed to Process.

   function Get
     (C_Id : in Contact_Identifier;
      O_Id : in Organization_Identifier)
      return Contact_Attributes_Object;
   --  Return the contact attribute set that belongs to C_Id and O_Id.

   function Contact_Id
     (Contact_Attributes : in Contact_Attributes_Object)
      return Contact_Identifier;

   function JSON
     (Contact_Attributes : in Contact_Attributes_Object)
      return GNATCOLL.JSON.JSON_Value;

   function Organization_Id
     (Contact_Attributes : in Contact_Attributes_Object)
      return Organization_Identifier;

   function To_JSON
     (Contact_Attributes : in Contact_Attributes_Object)
     return Common.JSON_String;

private

   type Cursor is new GNATCOLL.SQL.Exec.Forward_Cursor with null record;

   type Contact_Attributes_Object is tagged
      record
         C_Id : Contact_Identifier := 0;
         O_Id : Organization_Identifier := 0;
         JSON : GNATCOLL.JSON.JSON_Value := GNATCOLL.JSON.JSON_Null;
      end record;

   Null_Contact_Attributes : constant Contact_Attributes_Object :=
                               (C_Id => 0,
                                O_Id => 0,
                                JSON => GNATCOLL.JSON.JSON_Null);

   function Contact_Attributes_Element
     (C : in out Cursor)
      return Contact_Attributes_Object'Class;
   --  Transforms the low level index based Cursor into the more readable
   --  Contact_Attributes_Object record.

end Model.Contacts_Attributes;
