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

with Ada.Containers.Indefinite_Ordered_Maps;
private with Ada.Strings.Unbounded;
with GNATCOLL.JSON;

with ESL.UUID;
with Common;

package Model.Call is
   use Common;
   use ESL.UUID;

   Package_Name : constant String := "Model.Call";

   Not_Found       : exception;
   Null_Channel    : exception;
   Null_ID         : exception;
   Already_Bridged : exception;
   Invalid_ID      : exception;
   --  Appropriately named exceptions.

   subtype Identification is ESL.UUID.Instance;
   --  Call identification.

   function "=" (Left, Right : in Identification) return Boolean;

   function To_String (Item : in Identification) return String;
   function Image (Item : in Identification) return String renames To_String;
   --  Image function.

   function Value (Item : String) return Identification;
   --  Conversion.

   type States is
     (Unknown, Pending,
      Created,
      Queued,
      IVR,
      Transferring,
      Speaking, Dialing, Delegated, Ended,
      Parked, Transferred);
   --  Valid states for the call.

   type Priority_Level is (Invalid, Low, Normal, High);
   --  Priority level inherited from the base organization priority.

   type Instance is tagged private;
   --  Call instance.

   function ID (Obj : in Instance) return Model.Call.Identification;
   function State (Obj : in Instance) return States;
   function Inbound (Obj : in Instance) return Boolean;
   function Extension (Obj : in Instance) return String;
   function From_Extension (Obj : in Instance) return String;
   function B_Leg (Obj : in Instance) return Identification;
   function Arrival_Time (Obj : in Instance) return Common.Time;
   function Assigned_To (Obj : in Instance) return Natural;
   function Organization_ID (Obj : in Instance) return
     Organization_Identifier;
   --  Accessor methods

   procedure Change_State (Obj : in Instance; New_State : in States);

   --  Mutator methods.

   procedure Link (ID_1, ID_2 : in Identification);

   procedure Unlink (ID : in Identification);

   function List_Empty return Boolean;
   function List return GNATCOLL.JSON.JSON_Value;
   function Queued_Calls return GNATCOLL.JSON.JSON_Value;
   procedure For_Each (Process : access procedure (Item : Instance)) is null;
   function Queue_Count return Natural;

   function Get (Call : Identification) return Instance;

   function Has (ID : Identification) return Boolean;

   function Highest_Prioirity return Instance;

   function Remove (ID : in Identification) return Instance;

   function Queue_Empty return Boolean;
   --  Reveals if there are currently calls available for pickup.

   --  ^Collection operations.

   function Null_Instance return Instance;

   Null_Identification         : constant Identification;
   --  ^Explicit null values.

   procedure Create_And_Insert
     (Inbound         : in Boolean;
      ID              : in Identification;
      Organization_ID : in Organization_Identifier;
      State           : in States := Unknown;
      Extension       : in String := "";
      From_Extension  : in String := "");

   --  ^Constructors

   function To_JSON (Obj : in Instance) return GNATCOLL.JSON.JSON_Value;
   --  TODO: Move this to the view package.

private
   use Ada.Strings.Unbounded;

   Null_Identification : constant Identification
     := ESL.UUID.Null_UUID;
   Next_Identification : Identification := Null_Identification;

   type Instance is tagged
      record
         ID              : Identification;
         State           : States;
         Inbound         : Boolean;
         Extension       : Unbounded_String;
         Organization_ID : Organization_Identifier := 0;
         Assigned_To     : Natural := 0;
         From_Extension  : Unbounded_String;
         B_Leg           : Identification;
         Arrived         : Time := Current_Time;
      end record;

   package Call_Storage is new
     Ada.Containers.Indefinite_Ordered_Maps
       (Key_Type     => Identification,
        Element_Type => Instance);

   protected Call_List is
      procedure Insert (Item : in Instance);
      function Empty return Boolean;
      procedure Change_State (ID        : in Identification;
                              New_State : in States);
      function Contains (ID : in Identification) return Boolean;
      procedure Enqueue (ID : in Identification);
      pragma Obsolescent (Enqueue);
      procedure Dequeue (ID : in Identification);
      pragma Obsolescent (Dequeue);
      function First return Instance;

      function Get (ID : in Identification) return Instance;
      procedure Link (ID_1 : in Identification;
                      ID_2 : in Identification);
      procedure Unlink (ID : in Identification);
      function Queued return Natural;
      procedure Remove (ID : in Identification);

      function To_JSON (Only_Queued : Boolean := False)
                        return GNATCOLL.JSON.JSON_Value;
      procedure Update (ID : in Identification;
                        Process : not null access procedure
                          (Key     : in     Identification;
                           Element : in out Instance));
      pragma Obsolescent (Update);
   private
      List                 : Call_Storage.Map;
      Number_Queued        : Natural := 0;
   end Call_List;

end Model.Call;
