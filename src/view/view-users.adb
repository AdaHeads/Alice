-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2013-, AdaHeads K/S                     --
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

--  with View.User;

package body View.Users is
   function To_JSON (Item : in     Model.User.Instance)
                    return GNATCOLL.JSON.JSON_Array is
      use GNATCOLL.JSON;
      Data : JSON_Array;
   begin
      raise Program_Error with "View.Users.To_JSON - Not implemented";

      return Data;
--        for User of Item loop
--           Append (Arr => Data,
--                   Val => View.User.To_JSON (Item  => User));
--        end loop;
--
--        return Data;
   end To_JSON;
end View.Users;
