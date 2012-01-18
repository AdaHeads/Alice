-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                 Data.Get                                  --
--                                                                           --
--                                  SPEC                                     --
--                                                                           --
--                     Copyright (C) 2012-, AdaHeads K/S                      --
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

package Data.Get is

   function Company
     (Organization : in String)
      return String;
   --  Return a company JSON String for Organization.

   function Person
     (Organization : in String;
      Common_Name  : in String)
      return String;
   --  Return a person JSON String for Organization and Common Name.

   function Persons
     (Organization : in String)
      return String;
   --  Return a persons JSON String for Organization.

end Data.Get;
