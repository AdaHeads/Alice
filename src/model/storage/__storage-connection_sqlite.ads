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

with GNATCOLL.SQL.Exec;
with GNATCOLL.SQL.Sqlite;

with Alice_Configuration;

private package Storage.Connection is

   use Alice_Configuration;

   Description : constant GNATCOLL.SQL.Exec.Database_Description :=
                   GNATCOLL.SQL.Sqlite.Setup (Config.Get (SQLite_Database));

   function Get_Connection
     return GNATCOLL.SQL.Exec.Database_Connection is
      (GNATCOLL.SQL.Exec.Get_Task_Connection (Description));

end Storage.Connection;
