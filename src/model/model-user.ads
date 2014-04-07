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

with Ada.Containers,
     Ada.Containers.Hashed_Maps,
     Ada.Strings.Unbounded;

with Model.Call,
     Model.Peer;

with GNATCOLL.JSON;

private
with
  ESL.UUID;

package Model.User is
   use GNATCOLL.JSON;
   use Model;

   Package_Name : constant String := "Model.User";

   ID_String         : constant String := "id";
   User_String       : constant String := "user";
   Name_String       : constant String := "name";
   Peer_String       : constant String := "peer";
   Extension_String  : constant String := "extension";
   Peer_ID_String    : constant String := Peer_String & "_id";
   Users_String      : constant String := User_String & "s";
   Groups_String     : constant String := "groups";
   Identity_String   : constant String := "identity";
   Identities_String : constant String := "identities";

   Parking_Lot_Prefix   : constant String := "park+";
   Receptionist_String  : constant String := "Receptionist";
   Administrator_String : constant String := "Administrator";
   Service_Agent_String : constant String := "Service agent";

   Call_URI_Prefix      : constant String := "user/";

   type States is (Unknown, Signed_Out, Idle, Paused, Away);

   type Name is new String;

   type Identities is new Ada.Strings.Unbounded.Unbounded_String;

   type Instance is tagged private;

   type Reference is access all Instance;

   function Authenticated (Object : in Instance) return Boolean;

   function Create (User_ID : in Identifications;
                    Object  : GNATCOLL.JSON.JSON_Value) return Instance;

   function Create (Object  : GNATCOLL.JSON.JSON_Value) return Instance;

   function Create (User_ID : in Identifications;
                    Object  : GNATCOLL.JSON.JSON_Value) return Reference;

   function "<" (Left, Right : in Instance) return Boolean;

   overriding
   function "=" (Left, Right : in Instance) return Boolean;

   overriding
   function "=" (Left, Right : in Identities) return Boolean;

   function Image (Object : in Instance) return String;

   function Identification (Object : in Instance) return Identifications;

   function Parking_Lot_Identifier (Object : in Instance) return String;

   function Current_Call (Object : in Instance)
                          return Model.Call.Identification;

   procedure Assign_Call (User_ID : in Model.User_Identifier;
                          Call_ID : in Model.Call.Identification);

   function Image (Identification : Identifications) return String;

   function Image (Identity : Identities) return String;

   procedure Park_Current_Call (Object : in Instance);

   type Permission is (Receptionist, Service_Agent, Administrator);
   type Permission_List is array (Permission) of Boolean;

   No_Permissions : constant Permission_List := (others => False);

   function Permissions (User : in Instance) return Permission_List;

   function Value (Item : in String) return Identifications;

   function Value (Item : in String) return Identities;

   function To_JSON (Object : in Instance) return JSON_Value;

   procedure Change_State (Object    :    out Instance;
                           New_State : in     States);

   function Current_State (Object : in Instance) return States;

   function Peer (Object : in Instance) return Model.Peer.Instance;
   --  Returns the peer currently associated with the user.

   function Call_URI (Object : in Instance) return String;

   function No_User return Instance;
   pragma Inline (No_User);

   Null_User     : constant Reference;
   Null_Identity : constant Identities;
   Null_Identification : constant Identifications;
private
   use Model.Call;
   package Peers renames Model.Peer;

   Null_Identification : constant Identifications := 0;
   Null_User           : constant Reference       := null;
   Null_Identity       : constant Identities      := To_Unbounded_String ("");

   type Instance is tagged record
      ID            : Identifications            := Null_Identification;
      Current_State : States                     := Unknown;
      Peer          : Model.Peer.Identification  := Peers.Null_Identification;
      Attributes    : GNATCOLL.JSON.JSON_Value   := Create;
   end record;

   subtype Identity_Keys is Ada.Strings.Unbounded.Unbounded_String;

   function Key_Of (Item : Identities)
                   return Ada.Strings.Unbounded.Unbounded_String;

   function Identity_Of (Item : Ada.Strings.Unbounded.Unbounded_String)
                        return Identities;

   function Hash (Identity : Identities) return Ada.Containers.Hash_Type;

   function Hash (Identification : Identifications)
                  return Ada.Containers.Hash_Type;

   package Call_Allocation_Storage is new Ada.Containers.Hashed_Maps
     (Key_Type        => Identifications,
      Element_Type    => Model.Call.Identification,
      Hash            => Hash,
      Equivalent_Keys => "=",
      "="             => ESL.UUID."=");

   package User_Storage is new Ada.Containers.Hashed_Maps
     (Key_Type        => Identifications,
      Element_Type    => User.Instance,
      Hash            => Hash,
      Equivalent_Keys => "=");

   subtype User_Maps is  User_Storage.Map;

   package Lookup_Storage is new Ada.Containers.Hashed_Maps
     (Key_Type        => User.Identities,
      Element_Type    => Model.User_Identifier,
      Hash            => Hash,
      Equivalent_Keys => "=");

   subtype Identity_Maps is Lookup_Storage.Map;

   Call_Allocation : Call_Allocation_Storage.Map :=
     Call_Allocation_Storage.Empty_Map;

end Model.User;
