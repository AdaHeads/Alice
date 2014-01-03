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

with Response,
     Request_Utilities;

package body Handlers.User is
   use AWS.Response;

   ---------------
   --  Profile  --
   ---------------

   function Profile (Request : in AWS.Status.Data)
                      return AWS.Response.Data
   is
      Response_Object : Response.Object
        := Response.Factory (Request);
   begin

      Response_Object.Content (Request_Utilities.User_Of (Request).To_JSON);
      Response_Object.HTTP_Status_Code (HTTP.OK);

      return Response_Object.Build;

   end Profile;

end Handlers.User;
