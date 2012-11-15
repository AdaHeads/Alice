-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                           Model.Organizations                             --
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

with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Hashed_Maps;
with Ada.Strings.Unbounded;
with Common;
with GNATCOLL.JSON;
with GNATCOLL.SQL.Exec;
with Model.Contacts;
with View;

package Model.Organizations is

   type Organization_Object is tagged private;
   Null_Organization_Object : constant Organization_Object;

   type Organization_List_Object is tagged private;
   Null_Organization_List_Object : constant Organization_List_Object;

   function Equal_Elements
     (Left, Right : in Model.Contacts.Contact_Object)
      return Boolean;
   --  Element equality function used by the Attributes_Map.

   package Contacts_Map is new Ada.Containers.Hashed_Maps
     (Key_Type        => Contact_Key,
      Element_Type    => Model.Contacts.Contact_Object,
      Hash            => Key_Hash,
      Equivalent_Keys => Equivalent_Keys,
      "="             => Equal_Elements);
   --  TODO: This needs to be hidden. Perhaps something similar to the way we
   --  handle the Organization_List_Object?

   procedure Add_Contact
     (Self    : in out Organization_Object;
      Contact : in     Model.Contacts.Contact_Object);
   --  Add a contact to Organization.

   function Contacts
     (Self : in Organization_Object)
      return Contacts_Map.Map;
   --  Return all the contacts associated with Organization. Note that this
   --  map is only populated if one of the Get_Full methods has been used to
   --  fetch the organization.

   procedure For_Each
     (Self    : in Organization_List_Object;
      Process : not null access
        procedure (Element : in Organization_Object));
   --  TODO: Write comment

   procedure For_Each_Basic
     (O_Id    : in Organization_Identifier;
      Process : not null access
        procedure (Element : in Organization_Object'Class));
   --  For every organization with O_Id in the database, an Organization_Object
   --  is handed to Process. These organization objects do NOT contain any
   --  contacts.

   procedure For_Each_Full
     (O_Id    : in Organization_Identifier;
      Process : not null access
        procedure (Element : in Organization_Object'Class));
   --  For every organization with O_Id in the database, an Organization_Object
   --  is handed to Process. Included in the Organization_Object is a list of
   --  contacts.

   function Full_Name
     (Self : in Organization_Object)
      return String;
   --  TODO: Write comment

   procedure Get
     (Self : in out Organization_List_Object);
   --  TODO: Write comment

   procedure Get_Basic
     (Self : in out Organization_Object;
      O_Id : in Organization_Identifier);
   --  Get the organization that match O_Id without all the contacts.

   procedure Get_Full
     (Self : in out Organization_Object;
      O_Id : in     Organization_Identifier);
   --  Get the organization that match O_Id. This object contains all the
   --  contacts that are associated with the organization.

   function Identifier
     (Self : in Organization_Object)
      return String;
   --  TODO: Write comment

   function JSON
     (Self : in Organization_Object)
      return GNATCOLL.JSON.JSON_Value;
   --  TODO: Write comment

   function Length
     (Self : in Organization_List_Object)
      return Natural;
   --  TODO: Write comment

   function Organization_Id
     (Self : in Organization_Object)
      return Organization_Identifier;
   --  TODO: Write comment

   function To_JSON_String
     (Self      : in Organization_List_Object;
      View_Mode : in View.Mode := View.Full)
      return Common.JSON_String;
   --  TODO: Write comment

   function To_JSON_String
     (Self      : in Organization_Object;
      View_Mode : in View.Mode := View.Full)
      return Common.JSON_String;
   --  Convert Organization to a JSON string. This call is convenient wrapper
   --  for the View.Organization.To_JSON function.

private

   use Ada.Strings.Unbounded;

   type Cursor is new GNATCOLL.SQL.Exec.Forward_Cursor with null record;

   type Organization_Object is tagged
      record
         C_Map      : Contacts_Map.Map;
         Full_Name  : Unbounded_String := Null_Unbounded_String;
         Identifier : Unbounded_String := Null_Unbounded_String;
         JSON       : GNATCOLL.JSON.JSON_Value := GNATCOLL.JSON.JSON_Null;
         O_Id       : Organization_Identifier := 0;
      end record;

   Null_Organization_Object : constant Organization_Object
     := (C_Map      => Contacts_Map.Empty_Map,
         Full_Name  => Null_Unbounded_String,
         Identifier => Null_Unbounded_String,
         JSON       => GNATCOLL.JSON.JSON_Null,
         O_Id       => 0);

   package Organization_List is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Organization_Object);

   type Organization_List_Object is tagged
      record
         Org_List : Organization_List.List := Organization_List.Empty_List;
      end record;

   Null_Organization_List_Object : constant Organization_List_Object
     := (Org_List => Organization_List.Empty_List);

   function Organization_Element_Basic
     (C : in out Cursor)
      return Organization_Object'Class;
   --  Transforms the low level index based Cursor into the more readable
   --  Organization_Object record. This one does NOT contain any contacts.

      function Organization_Element_Full
     (C : in out Cursor)
      return Organization_Object'Class;
   --  Transforms the low level index based Cursor into the more readable
   --  Organization_Object record. This one DOES contain all contacts
   --  associated with the organization.

end Model.Organizations;
