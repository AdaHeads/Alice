-------------------------------------------------------------------------------
--                                                                           --
--                                   AMI                                     --
--                                                                           --
--                                 Action                                    --
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

with Ada.Strings.Unbounded;

with AMI.Callback;
with AMI.Generic_Protocol_Strings;
with AMI.Client;
with Model.Call;
with Model.Call_ID;
package AMI.Action is
   use Ada.Strings.Unbounded;
   use AMI.Client;
   use Model.Call_ID;
   use Model.Call;
   
   type Status_Type is
     (Success,
      No_Agent_Found,
      No_Call_Found,
      Unregistered_Agent,
      Agent_Already_In_Call,
      Unknown_Error);

   procedure Login
     (Client   : access Client_Type;
      Username : in     String;
      Secret   : in     String;
      Callback : in     AMI.Callback.Callback_Type
      := AMI.Callback.Login_Callback'Access
     );

   procedure Bridge (Client   : access Client_Type;
                     ChannelA : in     String;
                     ChannelB : in     String;
                     Callback : in     AMI.Callback.Callback_Type
                     := AMI.Callback.Null_Callback'Access);

   procedure Ping (Client   : access Client_Type;
                   Callback : in     AMI.Callback.Callback_Type
                   := AMI.Callback.Ping_Callback'Access);

   --     --------------------------------------------------------
   --     --  Should be out of the AMI directory.

   --     procedure Bridge_Call (Call_Id_1 : in     Unbounded_String;
   --                            Call_Id_2 : in     Unbounded_String;
   --                            Status    :    out Status_Type);

   procedure Redirect (Client    : access Client_Type;
                       Channel   : in     String;
                       Extension : in     String;
                       Callback  : in     AMI.Callback.Callback_Type
                         := AMI.Callback.Null_Callback'Access);
   --  Takes a call from the call_Queue, and redirects it to the channel.

   --     procedure Get_Version; --  return String;

   procedure Park (Client   : access Client_Type;
                   Call     : in     Call_Type;
                   Callback : in AMI.Callback.Callback_Type :=
                     AMI.Callback.Login_Callback'Access);

   --     procedure Unpark ( --  Agent_ID : in     String;
   --                       Call_Id : in     String;
   --                       Status  :    out Status_Type);

   --     procedure Register_Agent (Phone_Name  : in Unbounded_String;
   --                               Computer_Id : in Unbounded_String);

   procedure Hangup (Client   : access Client_Type;
                     Call_ID  : in     Call_ID_Type;
                     Callback : in     AMI.Callback.Callback_Type
                       := AMI.Callback.Null_Callback'Access);

   --     --  Checks if the internal call queue is the same on Asterisk.
   --  --     procedure Consistency_Check;

   --     procedure Startup_Sequence;
   --     --  TODO: Write comment.

   --     procedure Test_Status_Print;
   --     --  TODO: Write comment.
   --     ---------------------------------------------------------

private
   package Protocol_Strings is
     new AMI.Generic_Protocol_Strings (Asynchronous => True);
   use Protocol_Strings;
end AMI.Action;
