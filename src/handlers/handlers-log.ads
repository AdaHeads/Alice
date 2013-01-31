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

with AWS.Dispatchers.Callback;

with Response.Not_Cached;

package Handlers.Log is

   function Callback_Critical
     return AWS.Dispatchers.Callback.Handler;
   --  Return a callback for the CRITICAL log handler.

   function Callback_Error
     return AWS.Dispatchers.Callback.Handler;
   --  Return a callback for the ERROR log handler.

   function Callback_Info
     return AWS.Dispatchers.Callback.Handler;
   --  Return a callback for the INFO log handler.

private

   procedure Critical_Log
     (Instance : in out Response.Object);
   --  TODO: write comment

   function Critical_Response is new Response.Not_Cached.Generate_Response
     (Generate_Document => Critical_Log);
   --  Generate the AWS.Response.Data that ultimately is delivered to the user.

   procedure Error_Log
     (Instance : in out Response.Object);
   --  TODO: write comment

   function Error_Response is new Response.Not_Cached.Generate_Response
     (Generate_Document => Error_Log);
   --  Generate the AWS.Response.Data that ultimately is delivered to the user.

   procedure Info_Log
     (Instance : in out Response.Object);
   --  TODO: write comment

   function Info_Response is new Response.Not_Cached.Generate_Response
     (Generate_Document => Info_Log);
   --  Generate the AWS.Response.Data that ultimately is delivered to the user.

end Handlers.Log;
