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

with AMI.Callback;
with AMI.Generic_Protocol_Strings;
with AMI.Client;

with Model.Channel_ID;
with Model.Peer_ID;

package AMI.Action is
   use Ada.Strings.Unbounded;
   use AMI.Client;
   use AMI.Callback;
   use Model.Channel_ID;
   use Model.Peer_ID;

   procedure Absolute_Timeout (Client           : access Client_Type;
                               Channel_ID       : in     Channel_ID_Type;
                               Timeout          : in     Duration := 20.0;
                               Response_Handler : in     Callback_Type
                               := AMI.Callback.Null_Callback'Access) is null;
   --  Set Absolute Timeout (Priv : system, call, all)
   --  This will hangup a specified channel after a certain number of seconds,
   --  thereby actively ending the call.
   --  Asterisk will acknowledge the timeout setting with a
   --  Timeout Set message.

   --  TOOD: Convert to function returning Action_Request
   procedure Agent_Callback_Login
     (Agent     : in String;
      --  Agent ID of the agent to log in to the system,
      --  as specified in agents.conf.
      Extension : String;
      --  Extension to use for callback.
      Context   : String := "";
      Acknlowledgde_Call : Boolean := False;
      --  Set to true to require an acknowledgement (the agent pressing the
      --  # key) to accept the call when agent is called back.
      WrapupTime         : Duration := 0.0)
   is null;
   --  Sets an agent as logged in to the queue system in callback mode
   --  Logs the specified agent in to the Asterisk queue system in callback
   --  mode. When a call is distributed to this agent,
   --  it will ring the specified extension.

   procedure Agent_Logoff (Agent : in String;
                           --  Agent ID of the agent to log off
                           Soft  : in Boolean := False
                           --  Set to true to not hangup existing calls.
                          ) is null;
   --  Logs off the specified agent for the queue system.

   procedure Bridge (Client   : access Client_Type;
                     ChannelA : in     String;
                     ChannelB : in     String;
                     Callback : in     AMI.Callback.Callback_Type
                     := AMI.Callback.Null_Callback'Access);
   --  Bridge: Bridge two channels already in the PBX (Priv: call,all)

   procedure Core_Show_Channels (Client           : access Client_Type;
                                 Response_Handler : in     Callback_Type
                                 := AMI.Callback.Null_Callback'Access);
   --  Ask the AMI to reveal the the current channels. They will be spawned as
   --  events.

   procedure Extension_State (Client           : access Client_Type;
                              Context          : in     String;
                              Extension        : in     String;
                              Response_Handler : in     Callback_Type
                              := AMI.Callback.Null_Callback'Access) is null;
   --  This will report one of the following statuses:
   --  -1 : Extension not found
   --  0 : Idle
   --  1 : In Use
   --  4 : Unavailable
   --  8 : Ringing

   procedure Hangup (Client   : access Client_Type;
                     Call_ID  : in     String;
                     Callback : in     AMI.Callback.Callback_Type
                     := AMI.Callback.Null_Callback'Access);

   procedure Login (Client   : access Client_Type;
                    Username : in     String;
                    Secret   : in     String;
                    Callback : in     AMI.Callback.Callback_Type
                    := AMI.Callback.Login_Callback'Access);
   --  Login to the AMI socket. This is mandatory, and the socket will
   --  close after a timeout if login is not sent immidiately
   --  after the socket connection is established.

   procedure Logoff (Client           : access Client_Type;
                     Response_Handler : in     AMI.Callback.Callback_Type
                     := AMI.Callback.Null_Callback'Access) is null;
   --  Logs off the current manager session.

   procedure Originate (Client           : access Client_Type;
                        Peer_ID          : in     Peer_ID_Type;
                        Context          : in     String;
                        Extension        : in     String;
                        Priority         : in     Natural;
                        Response_Handler : in     Callback_Type
                        := AMI.Callback.Null_Callback'Access);
   --  Originate Call (Priv: originate,all)

   procedure Park (Client           : access Client_Type;
                   Channel          : in     String;
                   --  Channel name to park
                   Fallback_Channel : in     String;
                   --  Channel to announce park info to
                   --  (and return the call to if the parking times out).
                   Timeout          : in Natural := 60000;
                   --  Number of milliseconds to wait before callback.
                   Callback         : in AMI.Callback.Callback_Type :=
                     AMI.Callback.Login_Callback'Access);
   --  Park a channel (Priv: call,all).

   procedure Ping (Client   : access Client_Type;
                   Callback : in     AMI.Callback.Callback_Type
                   := AMI.Callback.Null_Callback'Access);
   --  Ping is a sort of dummy call that returns a pong response. It can be
   --  Used to provide a keep-alive refresh on a socket with a timeout.

   procedure Queues (Client   : access Client_Type;
                     Callback : in     AMI.Callback.Callback_Type
                     := AMI.Callback.Null_Callback'Access) is null;
   --  Queue Status (Priv: <none>).
   --  Checks statistical information about calls delivered to the existing
   --  queues, as well as the corresponding service level.

   procedure Redirect (Client    : access Client_Type;
                       Channel   : in     Channel_ID_Type;
                       Extension : in     String;
                       Callback  : in     AMI.Callback.Callback_Type
                       := AMI.Callback.Null_Callback'Access);
   --  Redirect: Redirect (transfer) a call (Priv: call,all)
   --  Sends an active channel to an extension.

   --     procedure Get_Version; --  return String;

   --     procedure Unpark ( --  Agent_ID : in     String;
   --                       Call_Id : in     String;
   --                       Status  :    out Status_Type);

   --     procedure Register_Agent (Phone_Name  : in Unbounded_String;
   --                               Computer_Id : in Unbounded_String);

   procedure SIP_Peers (Client   : access Client_Type;
                        Callback : in     AMI.Callback.Callback_Type
                        := AMI.Callback.Null_Callback'Access);
   --  Lists the currently configured SIP peers along with their status.

   procedure Status (Client     : access Client_Type;
                     Channel_ID : in     Channel_ID_Type;
                     Callback   : in     AMI.Callback.Callback_Type
                     := Null_Callback'Access) is null;

private
   package Protocol_Strings is
     new AMI.Generic_Protocol_Strings (Asynchronous => True);
   use Protocol_Strings;
end AMI.Action;
