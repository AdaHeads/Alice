-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                 JSONIFY                                   --
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
with Storage.Queries;

package JSONIFY is

   procedure Contact
     (C     : in     Storage.Queries.Contact_Cursor;
      Value : in out Common.JSON_Small.Bounded_String);
   --  TODO: Write comment

   procedure Contact_Attributes
     (C     : in out Storage.Queries.Contact_Attributes_Cursor;
      Value : in out Common.JSON_Small.Bounded_String);
   --  TODO: Write comment

   procedure Contact_Full
     (C     : in out Storage.Queries.Contact_Full_Cursor;
      Value : in out Common.JSON_Small.Bounded_String);
   --  TODO: Write comment

   procedure Org_Contacts
     (C     : in out Storage.Queries.Org_Contacts_Cursor;
      Value : in out Common.JSON_Large.Bounded_String);
   --  TODO: Write comment

   procedure Org_Contacts_Attributes
     (C     : in out Storage.Queries.Org_Contacts_Attributes_Cursor;
      Value : in out Common.JSON_Large.Bounded_String);
   --  TODO: Write comment

   procedure Org_Contacts_Full
     (C     : in out Storage.Queries.Org_Contacts_Full_Cursor;
      Value : in out Common.JSON_Large.Bounded_String);
   --  TODO: Write comment

   procedure Organization
     (C     : in     Storage.Queries.Organization_Cursor;
      Value : in out Common.JSON_Small.Bounded_String);
   --  TODO: Write comment

end JSONIFY;
