# Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; version 2 of the
# License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301  USA


step("Run try programm")
########################

find_program(TRY try
  PATHS ${CTEST_BINARY_DIRECTORY}
  PATH_SUFFIXES Debug Release RelWithDebInfo
  NO_DEFAULT_PATH
)
#message("try executable: ${TRY}")

execute_process(COMMAND ${TRY})

step("Install")
###############

execute_process(COMMAND ${CMAKE_COMMAND}
  --build .
  --target install
  -- DESTDIR=${CTEST_BINARY_DIRECTORY}/install
  WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}
)

step("Configure test project")
##############################

file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY}/test)
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/test)

execute_process(COMMAND ${CMAKE_COMMAND}
  -DWITH_CONCPLS=${CTEST_BINARY_DIRECTORY}/install/usr/local
  ${CTEST_SOURCE_DIRECTORY}/test
  WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}/test
  RESULT_VARIABLE config_result
)

if(config_result)
  message(ERROR "Failed to configure test project")
  return()
endif()


step("Build test project")
##########################

execute_process(COMMAND ${CMAKE_COMMAND}
  --build .
  --target test
  WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}/test
  RESULT_VARIABLE build_result
)

if(build_result)
  message(ERROR "Failed to build test project")
  return()
endif()


step("Execute test programm")
#############################

find_program(TEST test
  PATHS ${CTEST_BINARY_DIRECTORY}/test
  PATH_SUFFIXES Debug Release RelWithDebInfo
  NO_DEFAULT_PATH
)
message("test executable: ${TEST}")

execute_process(COMMAND ${TEST})
