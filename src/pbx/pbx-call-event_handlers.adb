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
with AMI.Observers;
with AMI.Event;
with AMI.Parser;
with AMI.Trace;
with View.Call;
with Model.Agent;
with Model.Agents;

with Handlers.Notifications;
with Client_Notification.Queue;
with Client_Notification.Call;

package body PBX.Call.Event_Handlers is
   use AMI.Trace;
   use Model.Agent;

   package Notification renames Handlers.Notifications;

   procedure Bridge (Packet : in Parser.Packet_Type);

   procedure Dial (Packet : in Parser.Packet_Type);

   procedure Join (Packet : in Parser.Packet_Type);

   procedure Leave (Packet : in Parser.Packet_Type);

   procedure Hangup (Packet : in Parser.Packet_Type);

   procedure Parked_Call (Packet : in Parser.Packet_Type);

   --------------
   --  Bridge  --
   --------------

   procedure Bridge (Packet : in Parser.Packet_Type) is
      Context   : constant String      := Package_Name & ".Bridge";
      Channel1  : Channel_Identification renames
                    Value (Packet.Get_Value (Parser.Channel1));
      Channel2  : String renames Packet.Get_Value (Parser.Channel2);
      Agent     : Agent_Type := Null_Agent;
   begin
      Agent := Model.Agents.Get (Get (Channel1).Assigned_To);

      if Agent = Null_Agent then
         AMI.Trace.Log
           (Error, Context & ": null agent detected!");
      end if;

      Get (Channel1).Change_State (New_State => Speaking);
      AMI.Trace.Log
        (Debug, Context & ": channel1: " & Packet.Get_Value (Parser.Channel1));
      AMI.Trace.Log
        (Debug, Context & ": channel2: " & Channel2);
      AMI.Trace.Log
        (Debug, Context & ": " &
           Client_Notification.Call.Pickup
           (C => Get (Channel1)).To_JSON.Write);

      Notification.Broadcast
        (Client_Notification.Call.Pickup (Get (Channel1)).To_JSON);
   end Bridge;

   ------------
   --  Dial  --
   ------------

   procedure Dial (Packet : in Parser.Packet_Type) is
      Context   : constant String := Package_Name & ".Dial";

      Sub_Event   : String renames Packet.Get_Value (Parser.SubEvent);
      Channel     : Channel_Identification renames
                      Value (Packet.Get_Value (Parser.Channel));
   begin
      --  There is a sequence to a Dial event represented by a SubEvent.
      --  It consists of "Begin" or "End"
      if Sub_Event = "Begin" then
         if not PBX.Call.Has (Channel_ID => Channel) then
            AMI.Trace.Log (Debug, Context & "creating call:");
            Create_And_Insert
              (Inbound        => not AMI.Channel_ID.Value
                 (To_String (Channel)).Is_Local,
               Channel        => Channel,
               State          => Dialing,
               B_Leg          =>
                 Value (Packet.Get_Value (Parser.Destination)));
         else
            AMI.Trace.Log (Debug, Context & "found call:");
            --  The call should already exist, just update the B_Leg and
            --  set state to dialing

            Get (Channel => Channel).Dial
              (Value (Packet.Get_Value (Parser.Destination)));

         end if;

         if not Get (Channel => Channel).Inbound then
            Get (Channel => Channel).Assign
              (Model.Agent_ID.Create ("1"));
         end if;

         AMI.Trace.Log (Debug, Context & "Begin: " &  View.Call.To_JSON
                        (Get (Channel => Channel)).Write);

         --  When a Dial event ends, the call is over, and must thus be removed
         --  From the call list.
      elsif Sub_Event = "End" then
         Get (Channel => Channel).End_Dial;

         AMI.Trace.Log (Debug, Context & "End: " & View.Call.To_JSON
                        (Get (Channel => Channel)).Write);
      else
         AMI.Trace.Log
           (Error, Context & ": " &
              "unknown SubEvent: " & Sub_Event);
      end if;
   end Dial;

      --------------
   --  Hangup  --
   --------------

   procedure Hangup (Packet : in Parser.Packet_Type) is
      Context : constant String := Package_Name & ".Hangup";
      Channel : String renames Packet.Get_Value (Parser.Channel);
   begin
      Notification.Broadcast
        (Client_Notification.Call.Hangup
           (Remove (Channel_ID => Value (Channel))).To_JSON);
   exception
      when Call.Not_Found =>
         AMI.Trace.Log (Error, Context & " Call not found: " & Channel);
      when others =>
         AMI.Trace.Log (Error, Context & ": unkown exception");
         raise;

   end Hangup;

   ------------
   --  Join  --
   ------------

   procedure Join (Packet : in Parser.Packet_Type) is
      --  Context   : constant String := Package_Name & ".Join";
      Channel     : Channel_Identification renames
                      Value (Packet.Get_Value (Parser.Channel));
   begin
      Create_And_Insert
        (Inbound        => True,
         Channel        => Channel,
         State          => Queued);

      Get (Channel => Channel).Change_State (New_State => Queued);

      Notification.Broadcast
        (Client_Notification.Queue.Join
           (Get (Channel => Channel)).To_JSON);
   end Join;

   -------------
   --  Leave  --
   -------------

   procedure Leave (Packet : in Parser.Packet_Type) is
      --  Context : constant String := Package_Name & ".Leave";
      Channel     : Channel_Identification renames
                      Value (Packet.Get_Value (Parser.Channel));
   begin
      Get (Channel => Channel).Change_State (New_State => Transferring);

      Notification.Broadcast
        (Client_Notification.Queue.Leave
           (Get (Channel => Channel)).To_JSON);
   end Leave;

   procedure Parked_Call (Packet : in Parser.Packet_Type) is
      Context : constant String := Package_Name & ".Parked_Call";
      Channel : Channel_Identification renames
                  Value (Packet.Get_Value (Parser.Channel));
   begin
      Get (Channel).Change_State (New_State => Parked);
      --  Broadcast it.
      Notification.Broadcast
        (Client_Notification.Call.Park (C => Get (Channel)).To_JSON);
      AMI.Trace.Log (Debug, Client_Notification.Call.Park
                              (Get (Channel)).To_JSON.Write);
   end Parked_Call;

   procedure Register_Handlers is
   begin
      AMI.Observers.Register (Event   => AMI.Event.Dial,
                              Handler => Dial'Access);
      AMI.Observers.Register (Event   => AMI.Event.Bridge,
                              Handler => Bridge'Access);
      AMI.Observers.Register (Event   => AMI.Event.Join,
                              Handler => Join'Access);
      AMI.Observers.Register (Event   => AMI.Event.Leave,
                              Handler => Leave'Access);
      AMI.Observers.Register (Event   => AMI.Event.Hangup,
                              Handler => Hangup'Access);
      AMI.Observers.Register (Event   => AMI.Event.ParkedCall,
                              Handler => Parked_Call'Access);
   end Register_Handlers;

begin
   Register_Handlers;
end PBX.Call.Event_Handlers;
