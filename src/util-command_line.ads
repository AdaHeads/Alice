-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2014-, AdaHeads K/S                     --
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

with Ada.Command_Line,
     Ada.Containers.Indefinite_Vectors;

package Util.Command_Line is

   function Command_Name return String
     renames Ada.Command_Line.Command_Name;

   procedure Set_Exit_Failure;
   --  Sets the exit code to EXIT_FAILURE.

   package String_Vectors is
     new Ada.Containers.Indefinite_Vectors (Positive, String);

   function Got_Argument (Parameter : in String) return Boolean;

   function Get
     (Parameter : in String;
      Default   : in String := "")
      return String;
   --  Return the value associated with Parameter, ie. the value that follows
   --  immediately after Parameter in the given command line parameters. Return
   --  Default if Parameter doesn't exist.

   function Get
     (Parameter : in String;
      Prefix    : in String := "--")
      return String_Vectors.Vector;
   --  Return the values associated with Parameter, ie. the values that follow
   --  after Parameter in the given command line parameters.  If Parameter is
   --  not specified on the command line an empty vector is returned.

end Util.Command_Line;
