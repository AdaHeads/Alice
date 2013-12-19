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

with Ada.Containers.Hashed_Maps;
--  with Ada.Strings.Hash;
with Ada.Strings.Unbounded;
with Model.Agent_ID;
with ESL.Peer_ID;
with GNATCOLL.JSON;

with Common;
package ESL.Peer is
   use Ada.Containers;
   use Ada.Strings.Unbounded;
   use Model.Agent_ID;
   use ESL.Peer_ID;
   use Common;

   Peer_Not_Found : exception;
   --  When a peer is not found in the list, something is terribly wrong.
   --  It means we have an inconsistant state between Agent and Peer, and
   --  thus, we raise an exception.

   type SIP_Peer_Status_Type is (Unknown, Unregistered, Idle, Busy, Paused);

   type Conditional_Time (Never : Boolean := True) is record
      case Never is
         when True =>
            null;
         when False =>
            Time : Common.Time := Current_Time;
      end case;
   end record;

   function To_String (Item : in Conditional_Time) return String;

   type Instance is tagged
      record
         ID           : Peer_ID_Type;
         Agent_ID     : Agent_ID_Type;
         State        : SIP_Peer_Status_Type := Unregistered;
         Last_State   : SIP_Peer_Status_Type := Unknown;
         Port         : Natural;
         Address      : Unbounded_String;
         Last_Seen    : Conditional_Time;
      end record;

   function Available (Peer : in Instance) return Boolean;

   procedure Seen (Peer : in Instance);
   --  Bump the timestamp for the peer to the current_time.

   procedure Change_State (Peer      : in Instance;
                           New_State : in SIP_Peer_Status_Type);

   function To_JSON (Peer : in Instance)
                     return GNATCOLL.JSON.JSON_Value;
   function To_String (Peer : in Instance) return String;

   function Hash (Peer_ID : Peer_ID_Type) return Hash_Type;

   package Peer_List_Storage is new Ada.Containers.Hashed_Maps
     (Key_Type        => Peer_ID_Type,
      Element_Type    => Instance,
      Hash            => Hash,
      Equivalent_Keys => "=");

   --  function Get_Peers_List return Peer_List_Storage.Map;
   --  function Get_Exten (Peer : in Unbounded_String) return Unbounded_String;

   protected type Peer_List_Type is
      procedure Change_State (ID        : in Peer_ID_Type;
                              New_State : in SIP_Peer_Status_Type);
      function Contains (Peer_ID : in Peer_ID_Type) return Boolean;
      function Count return Natural;
      function Get (Peer_ID : in Peer_ID_Type) return Instance;
      procedure Put (Peer : in Instance);
      procedure Seen (ID : in Peer_ID.Peer_ID_Type);
      function To_String return String;
      function To_JSON return GNATCOLL.JSON.JSON_Value;
   private

      List : Peer_List_Storage.Map;
   end Peer_List_Type;

   Null_Peer : constant Instance;

   List : Peer_List_Type;
   --  Package-visisble singleton.

private
   Null_Peer : constant Instance :=
     (ID           => Null_Peer_ID,
      Agent_ID     => Null_Agent_ID,
      State        => Unregistered,
      Last_State   => Unknown,
      Port         => 0,
      Address      => Null_Unbounded_String,
      Last_Seen    => (Never => True));
end ESL.Peer;
