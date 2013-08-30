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

with AWS.Response;
with Response.Not_Cached;

private
package Handlers.CORS_Preflight is

   function Callback
     return AWS.Response.Callback;
   --  Return a callback for the OPTIONS CORS preflight response (200).

private

   procedure Generate_Document
     (Instance : in out Response.Object);
   --  Add a generated JSON_String to Response_Object and set HTTP status code
   --  to 200.

   function JSON_Response is new Response.Not_Cached.Generate_Response
     (Generate_Document => Generate_Document);
   --  Generate the AWS.Response.Data that ultimately is delivered to the user.
   --  In the case of a CORS preflight request all we return is an empty JSON
   --  string, ie. {}.

end Handlers.CORS_Preflight;
