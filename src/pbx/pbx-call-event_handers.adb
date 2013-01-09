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

with AMI.Channel_ID;

package body PBX.Call.Event_Handers is

   procedure Dial (Packet : in Parser.Packet_Type);

      ------------
   --  Dial  --
   ------------

   procedure Dial (Packet : in Parser.Packet_Type) is
      Context   : constant String := Package_Name & ".Dial";
      Call      : Instance;

      Sub_Event   : String renames Packet.Get_Value (Parser.SubEvent);
      Channel     : String renames Packet.Get_Value (Parser.Channel);
      Destination : String renames Packet.Get_Value (Parser.Destination);
   begin
      --  There is a sequence to a Dial event represented by a SubEvent.
      --  It consists of "Begin" or "End"
      if Sub_Event = "Begin" then
         if AMI.Channel_ID.Value (Channel).Is_Local then
            Create_And_Insert
              (Inbound        => False,
               Channel        => Channel,
               State          => Dialing,
               B_Leg          => Destination);
         else
            --  The call should already exist, just update the B_Leg and
            --  set state to dialing

            Get (Channel => Value (Channel)).Dial (Value (Destination));

         end if;

      --  When a Dial event ends, the call is over, and must thus be removed
      --  From the call list.
      elsif Sub_Event = "End" then
         Get (Channel => Value (Channel)).End_Dial;
      else
         System_Messages.Notify
           (Error, Package_Name & "." & Context & ": " &
              "unknown SubEvent: " &
              To_String (Packet.Get_Value (Parser.SubEvent)));
      end if;
   end Dial;

   procedure Join (Packet : in Parser.Packet_Type) is
      Call         : PBX.Call.Instance;
      Temp_Value   : Unbounded_String;
   begin
      Call.ID := Call_ID.Create (Packet.Get_Value (Parser.UniqueID));
      Call.Inbound := True;  --  Join implies an inbound call.

      --  See if the call already exists
      if Model.Calls.List.Contains (Call_ID => Call.ID) then
         Call := Model.Calls.List.Get (Call.ID);
         Call.State := Requeued;
      else
         Call.State := Newly_Arrived;
         Call.Arrived := Current_Time;
      end if;

      Call.Queue := Packet.Get_Value (Parser.Queue);
      Call.Channel := Channel_ID.Value
        (To_String (Packet.Get_Value (Parser.Channel)));
      Model.Calls.List.Insert (Call);

      Notification.Broadcast
        (Client_Notification.Queue.Join (C => Call).To_JSON);
   exception
         when others =>
         System_Messages.Notify
           (Error,
            "My_Callbacks.Join: Got a Join event, " &
              "on a channel there is not in the channel list. " &
              "Channel: " &
                 To_String (Temp_Value));
   end Join;

   procedure Register_Handlers is
   begin
      AMI.Observers.Register (Event   => AMI.Event.Dial,
                              Handler => Dial'Access);
   end Register_Handlers;
end PBX.Call.Event_Handers;
