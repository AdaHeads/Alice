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

package AMI.Channel_ID is
   type Technologies    is (SIP);
   type Peer_Name       is new Ada.Strings.Unbounded.Unbounded_String;
   type Sequence_Number is mod 16 ** 8;

   function Image (Item : in Sequence_Number) return String;

   function Value (Item : in String) return Sequence_Number;

   Invalid_ID : exception;

   type Instance (Temporary : Boolean) is tagged record
      case Temporary is
         when False =>
            Parked     : Boolean;
            AsyncGoto  : Boolean;
            Technology : Technologies;
            Peer       : Peer_Name;
            Sequence   : Sequence_Number;
         when True =>
            null;
      end case;
   end record;

   function Value (Item : in String) return Instance;

   function Create (Item : in String) return Instance renames Value;
   pragma Obsolescent (Create);

   function Image (Item : in Instance) return String;

   function "<" (Left  : in Instance;
                 Right : in Instance) return Boolean;

   function "=" (Left  : in Instance;
                 Right : in Instance) return Boolean;

   function Validate (Item : in String) return Boolean;
   --  Non-exception-raising way of checking whether a string can be
   --  converted into a Channel_ID

   Null_Channel_ID : constant Instance;

   subtype Channel_ID_Type is Instance;
   pragma Obsolescent (Channel_ID_Type);

private

   Null_Channel_ID : constant Instance :=
                       (Temporary  => False,
                        Parked     => True,
                        AsyncGoto  => True,
                        Technology => SIP,
                        Peer       => To_Unbounded_String (""),
                        Sequence   => 16#ffffffff#);
end AMI.Channel_ID;
