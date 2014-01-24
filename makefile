###############################################################################
#                                                                             #
#                                  Alice                                      #
#                                                                             #
#                                Make File                                    #
#                                                                             #
#                       Copyright (C) 2012-, AdaHeads K/S                     #
#                                                                             #
#  This is free software;  you can redistribute it  and/or modify it          #
#  under terms of the  GNU General Public License as published  by the        #
#  Free Software  Foundation;  either version 3,  or (at your option) any     #
#  later version.  This software is distributed in the hope  that it will     #
#  be useful, but WITHOUT ANY WARRANTY;  without even the implied warranty    #
#  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU        #
#  General Public License for  more details.                                  #
#  You should have  received  a copy of the GNU General  Public  License      #
#  distributed  with  this  software;   see  file COPYING3.  If not, go       #
#  to http://www.gnu.org/licenses for a complete copy of the license.         #
#                                                                             #
###############################################################################

RELEASE=`git tag | tail -n1`
GIT_REV=`git rev-parse --short HEAD`

ifeq ($(PROCESSORS),)
PROCESSORS=`(test -f /proc/cpuinfo && grep -c ^processor /proc/cpuinfo) || echo 1`
endif

all:
	gnatmake -j${PROCESSORS} -P alice

debug:
	BUILDTYPE=Debug gnatmake -j${PROCESSORS} -P alice

clean: cleanup_messy_temp_files
	gnatclean -P alice
	BUILDTYPE=Debug gnatclean -P alice

git-head: all
	cp exe/alice exe/alice-${RELEASE}-${GIT_REV}
	echo alice-${RELEASE}-${GIT_REV} > release.latest

tests: all
	@make -C db_src
	@./src/tests/build
	@./src/tests/run

cleanup_messy_temp_files:
	find . -name "*~" -type f -print0 | xargs -0 -r /bin/rm

fix-whitespace:
	@find src -name '*.ad?' | xargs --no-run-if-empty egrep -l '	| $$' | grep -v '^b[~]' | xargs --no-run-if-empty perl -i -lpe 's|	|        |g; s| +$$||g'
