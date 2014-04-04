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

--  with Ada.Exceptions;
--  with Black.Response;

package Unexpected_Exception is

   Package_Name : constant String := "Unexpected_Exception";

   --  function Callback
   --    return Black.Exceptions.Unexpected_Exception_Handler;
   --  --  Return a callback for the Unexpected_Exception response.

   --  procedure Unexpected_Exception_Handler
   --    (E      : in     Ada.Exceptions.Exception_Occurrence;
   --     Log    : in out Black.Log.Object;
   --     Error  : in     Black.Exceptions.Data;
   --     Answer : in out Black.Response.Instance);
   --  --  Take care of unhandled exceptions, which in this context means
   --  --  log the disaster and send a 500 response object to the client.

end Unexpected_Exception;
