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

with ESL.Client.Tasking;
with ESL.Packet_Keys;

with PBX;
with PBX.Magic_Constants;

with System_Messages;

package body Model.Peer.List.Observers is
   use ESL.Packet_Keys;

   Peer_State_Observer : Peer_State_Observers
     (Observing => ESL.Client.Tasking.Event_Stream
        (Client => PBX.Client,
         Stream => ESL.Packet_Keys.CUSTOM));
   pragma Unreferenced (Peer_State_Observer);

   Reload_Config_Observer : Reload_Config_Observers
     (Observing => ESL.Client.Tasking.Event_Stream
        (Client => PBX.Client,
         Stream => ESL.Packet_Keys.RELOADXML));
   pragma Unreferenced (Reload_Config_Observer);

   ---------------------------
   --  Peer_State Observer  --
   ---------------------------

   overriding
   procedure Notify (Observer : access Peer_State_Observers;
                     Packet   : in     ESL.Packet.Instance;
                     Client   : in     ESL.Client.Reference) is
      use ESL;

      pragma Unreferenced (Observer);
      pragma Unreferenced (Client);
      package Constants renames PBX.Magic_Constants;

      Context   : constant String      :=
        Package_Name & ".Notify (Peer_State observer)";
      pragma Unreferenced (Context);

      Subevent : String renames Packet.Field (Event_Subclass).Decoded_Value;

   begin
      if Subevent = Constants.Sofia_Register then
         declare
            ID : constant Model.Peer.Identification :=
              To_Unbounded_String
                (Packet.Field (Key => Username).Decoded_Value);
            Expire_Delta : Natural := 0;
         begin

            Expire_Delta :=
              Natural'Value (Packet.Field (Key => Expires).Decoded_Value);

            Model.Peer.List.Get_Singleton.Register
              (Identity => ID,
               Contact  => Packet.Field (Key => Contact).Decoded_Value,
               Expiry   => Expire_Delta);

         end;
      elsif Subevent = Constants.Sofia_Unregister then
         declare
            ID : constant Model.Peer.Identification :=
              To_Unbounded_String
                (Packet.Field (Key => Username).Decoded_Value);
         begin
            Model.Peer.List.Get_Singleton.Unregister (Identity => ID);
         end;
      end if;
   end Notify;

   ------------------------------
   --  Config reload Observer  --
   ------------------------------

   overriding
   procedure Notify (Observer : access Reload_Config_Observers;
                     Packet   : in     ESL.Packet.Instance;
                     Client   : in     ESL.Client.Reference) is
      use ESL;

      pragma Unreferenced (Observer, Packet, Client);

      Context   : constant String      :=
        Package_Name & ".Notify (Config reload observer)";
   begin
      System_Messages.Error
        (Context => Context,
         Message => "Reloading peer state, but no observer " &
           " is able to respond to it, in fear of deadlocking.");
   end Notify;

begin
   System_Messages.Information (Context => Package_Name,
                                Message => "Attaching observers.");

end Model.Peer.List.Observers;
