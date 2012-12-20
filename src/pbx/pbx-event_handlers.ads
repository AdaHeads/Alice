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
with AMI.Parser;

package PBX.Event_Handlers is

   Package_Name : constant String := "PBX.Event_Handlers";

   Not_Implemented : exception;

   procedure Peer_Status (Packet : in Parser.Packet_Type);
   procedure Core_Show_Channel (Packet : in Parser.Packet_Type);
   procedure Core_Show_Channels_Complete (Packet : in Parser.Packet_Type);
   procedure Default_Callback (Packet : in Parser.Packet_Type);

   procedure Dial (Packet : in Parser.Packet_Type);
   --  A dial event occurs when a peer actively dials an extension.

   procedure Hangup        (Packet : in Parser.Packet_Type);
   procedure Join          (Packet : in Parser.Packet_Type);

   procedure Leave         (Packet : in Parser.Packet_Type);
   --  A Leave event occurs when a channel leaves a Queue for any reason.
   --  E.g. hangup or pickup. This is responsible tagging calls as picked up,
   --  but does not touch the channel.

   procedure Queue_Abandon (Packet : in Parser.Packet_Type);
   --  procedure Unlink_Callback     (Event_List : in Event_List_Type.Map);

   procedure Parked_Call (Packet : in Parser.Packet_Type);
   procedure Peer_Entry (Packet : in Parser.Packet_Type);

   procedure Peer_List_Complete (Packet : in Parser.Packet_Type);

   procedure Bridge (Packet : in Parser.Packet_Type);

end PBX.Event_Handlers;
