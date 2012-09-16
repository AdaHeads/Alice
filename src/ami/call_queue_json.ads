-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                             Call_Queue_JSON                               --
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

with Ada.Containers;
with Call_List,
     Common;
private with GNATCOLL.JSON;

--  This package can return callqueue information and it in JSON format.
package Call_Queue_JSON is
   use Common;

   function Convert_Queue (Queue : in Call_List.Call_List_Type.Vector)
                           return JSON_String;
   --  returns the entire Call Queue, in JSON format.

   function Convert_Length (Length : in Ada.Containers.Count_Type)
                            return JSON_String;
   --  returns the number of calls waiting in the calling queue.

   function Convert_Call (Call : in Call_List.Call_Type)
                          return JSON_String;
   --  returns the first call in the list.

   function Status_Message (Title   : in String;
                            Message : in String) return JSON_String;
private
   function Convert_Call_To_JSON_Object (Call : in Call_List.Call_Type)
                                         return GNATCOLL.JSON.JSON_Value;
   --  takes a call and converts it to a JSON object.
end Call_Queue_JSON;
