-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                LDAP.Read                                  --
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

with Ada.Strings.Unbounded;
with Yolk.Cache.String_Keys;

package LDAP.Read is

   use AWS.LDAP.Client;
   use Ada.Strings.Unbounded;

   package JSON_Cache is new Yolk.Cache.String_Keys
     (Element_Type      => Unbounded_String,
      Cleanup_Size      => 5000,
      Max_Element_Age   => 86400.0,
      Reserved_Capacity => 5000);

   function Search_Company
     (o : in String)
     return String;
   --  Return an LDAP company search as a JSON String.
   --    o : Organization

   function Search
     (Base_Prefix : in String := "";
      Filter      : in String;
      Scope       : in Scope_Type    := LDAP_Scope_Default;
      Attrs       : in Attribute_Set := Null_Set;
      Attrs_Only  : in Boolean       := False)
      return String;
   --  Return an LDAP search as a JSON String.

   function Search_Person
     (o  : in String;
      cn : in String)
     return String;
   --  Return an LDAP person search as a JSON String.
   --    o : Organization
   --    cn : Common Name

   function Search_Persons
     (o : in String)
     return String;
   --  Return an LDAP persons search as a JSON String.
   --    o : Organization

end LDAP.Read;
