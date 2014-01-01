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

with Ada.Strings.Unbounded;
with Common;
with Model.Call_ID;
with ESL.Channel;
with GNATCOLL.JSON;

package Model.Call is
   use Ada.Strings.Unbounded;
   use GNATCOLL.JSON;
   use Common;
   use Model.Call_ID;

   BAD_EXTENSION   : exception;
   EMPTY_EXTENSION : exception;

   type Call_State is
     (Unknown, Newly_Arrived, Requeued,
      Speaking, Ringing, OnHold, Delegated, Hung_Up,
      Parked, Bridged);
   type Priority_Level is (Invalid, Low, Normal, High);

   type Call_Type is tagged
      record
         ID             : Call_ID.Call_ID_Type;
         State          : Call_State;
         Inbound        : Boolean;
         Queue_Priority : Priority_Level;
         Channel        : ESL.Channel.Instance;
         Queue          : Unbounded_String;
         Position       : Natural;
         Count          : Natural;
         Bridged_With   : Call_ID.Call_ID_Type;
         Arrived        : Time := Current_Time;
      end record;

   --  function Create

   function To_String (Call : in Call_Type) return String;
   function To_JSON (Call : in Call_Type) return JSON_Value;

   function "=" (Left  : in Call_Type;
                 Right : in Call_Type) return Boolean;

   Null_Call : constant Call_Type;
private
   Null_Call : constant Call_Type :=
     (ID             => Call_ID.Null_Call_ID,
      State          => Unknown,
      Queue_Priority => Invalid,
      Inbound        => False,
      Channel        => ESL.Channel.Create,
      Queue          => Null_Unbounded_String,
      Position       => 0,
      Count          => 0,
      Bridged_With   => Call_ID.Null_Call_ID,
      Arrived        => Current_Time);
end Model.Call;
