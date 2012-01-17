-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                 Request                                   --
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

with AWS.Status;
with AWS.Response;
with My_Configuration;

package Request is

   JSON_MIME_Type : constant String := "application/json";

   package My renames My_Configuration;
   --  Easier to read and write.

   function Company
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  Get the company JSON based on the id GET parameter.

   function Persons
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  Get the persons JSON based on the id GET parameter.

   function Build_Response
     (Status_Data : in AWS.Status.Data;
      Content     : in String)
      return AWS.Response.Data;
   --  Build the response and compress it if the client supports it.

end Request;
