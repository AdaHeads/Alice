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

with My_Handlers;
with PBX;
with System_Message.Critical;
with System_Message.Info;
with Yolk.Process_Control;
with Yolk.Process_Owner;
with Yolk.Server;
with Unexpected_Exception;

with
  AGI.Callbacks,
  My_Callbacks;

pragma Unreferenced (AGI.Callbacks);
pragma Unreferenced (My_Callbacks);

procedure Alice is
   use System_Message;
   use Yolk.Process_Control;
   use Yolk.Process_Owner;
   use Yolk.Server;

   Alice_Version : constant String := "0.40";

   Web_Server : HTTP := Create
     (Unexpected => Unexpected_Exception.Callback);
begin
   PBX.Start;
   Web_Server.Start (Dispatchers => My_Handlers.Get);

   Info.Alice_Start (Message => "Server version " & Alice_Version);

   Wait;
   --  Wait here until we get a SIGINT, SIGTERM or SIGPWR.

   Web_Server.Stop;
   PBX.Stop;

   Info.Alice_Stop;
exception
   when Event : Username_Does_Not_Exist =>
      Critical.Unknown_User (Event);
   when Event : others =>
      Critical.Alice_Shutdown_With_Exception (Event);
      Web_Server.Stop;
      PBX.Stop;
end Alice;
