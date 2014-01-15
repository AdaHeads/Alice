-------------------------------------------------------------------------------
--                                                                           --
--                      Copyright (C) 2012-, AdaHeads K/S                    --
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

with Ada.Exceptions;
with AWS.Dispatchers.Callback;

with Build_Constants;
with Handlers.Route;
with PBX;
with SIGHUP;
with SIGHUP_Handler;
with System_Messages;
with Unexpected_Exception;

with Util.Process_Control;
with Util.Server;
with Util.Command_Line;

with Model.User.List;
--  Self-registering observers.
with Model.Call.Observers;
pragma Unreferenced (Model.Call.Observers);
with Model.Peer.List.Observers;
pragma Unreferenced (Model.Peer.List.Observers);

procedure Alice is
   use System_Messages;
   use Util;
   use Build_Constants;

   Context     : constant String := "Alice";

   Web_Server : Server.HTTP := Server.Create
     (Unexpected => Unexpected_Exception.Callback);

   procedure Initialize_Model;

   procedure Initialize_Model is
   begin
      Model.User.List.Get_Singleton.Reload_Map;
   end Initialize_Model;

begin
   if Command_Line.Got_Argument ("--help") then
      --  TODO!
      --  Command_Line.Show_Arguments;
      null;
      return;
   end if;

   Initialize_Model;

   SIGHUP.Register (Handler => SIGHUP_Handler.Caught_Signal'Access);
   PBX.Start;
   Web_Server.Start
     (Dispatchers => AWS.Dispatchers.Callback.Create
                       (Handlers.Route.Callback'Access));

   Process_Control.Wait;
   --  Wait here until we get a SIGINT, SIGTERM or SIGPWR.

   Web_Server.Stop;
   PBX.Stop;
   SIGHUP.Stop;

   System_Messages.Information (Message => Server_Name & " shutdown complete.",
                                Context => Context);
exception
   when Event : others =>
      System_Messages.Critical
        (Message => "Shutting down Alice due to unhandled exception: " &
           Ada.Exceptions.Exception_Information (Event),
         Context => Context);
      Web_Server.Stop;
      PBX.Stop;
end Alice;
