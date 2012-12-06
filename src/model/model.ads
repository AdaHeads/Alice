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

with GNATCOLL.SQL.Exec;

package Model is

   type Contact_Identifier is new Natural;
   type Organization_Identifier is new Natural;

   type Organization_Contact_ID is
      record
         CID : Contact_Identifier;
         OID : Organization_Identifier;
      end record;
   --  Identifies the CID contact in the context of the OID organization.

   type Attribute_ID is new Organization_Contact_ID;
   --  Identifies a set of contact attributes for the CID contact in the
   --  context of the OID organization.
   --  The same as Organization_Contact_ID, but renamed for clarity in
   --  the code.

private

   type Database_Cursor is new GNATCOLL.SQL.Exec.Forward_Cursor with null
     record;

end Model;
