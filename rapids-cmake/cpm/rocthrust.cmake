#=============================================================================
# Copyright (c) 2021-2023, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
# MIT License
#
# Modifications Copyright (c) 2023-2024 Advanced Micro Devices, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#=============================================================================
include_guard(GLOBAL)

include("${rapids-cmake-dir}/cpm/_init_hip_options.cmake")

#[=======================================================================[.rst:
rapids_cpm_rocthrust
--------------------

Allow projects to find or build `rocthrust` via `CPM` with built-in
tracking of these dependencies for correct export support.

  rapids_cpm_rocthrust([BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [PREFER_LOCAL <prefer-local>]
                     [USE_LOCAL <use-local>]
                     [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: rocthrust
.. include:: common_package_args.txt

IMPORTANT: Only support for local rocThrust installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This module is currently implemented to always look for a local
rocThrust installation. Installation via download is not supported
right now. This means that the `PREFER_LOCAL` and `USE_LOCAL`
options (cf. next section) do not have any effect.

Prefer/Use Local rocThrust Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

(IMPORTANT: This section describes a feature that is not implemented currently.)

If you specify the key-value pair `PREFER_LOCAL ON`, this function first look for a local
version of `rocThrust`, e.g., one from a ROCm installation.
The default behavior is that of `PREFER_LOCAL OFF`, i.e., that rocThrust is downloaded
from its Git repository.

If you specify the key-value pair `USE_LOCAL ON` instead, this function will ONLY look
for a local version  of `rocThrust`. An error will be reported if no local version could be found.
The default behavior is that of `USE_LOCAL OFF`.
Option `PREFER_LOCAL <value>` has no effect if `USE_LOCAL ON` is specified.

(Note that instead of the values "ON" and "OFF", alternative values can be specified such as
TRUE/FALSE, YES/NO, Y/N, ...; more details:
https://cmake.org/cmake/help/latest/command/if.html#constant)

There is also the option to override the behavior via the environment variables:

`RAPIDS_CMAKE_ROCTHRUST_PREFER_LOCAL`
`RAPIDS_CMAKE_ROCTHRUST_USE_LOCAL`

Result Targets
^^^^^^^^^^^^^^
  roc::rocthrust target will be created
  <namespace>::Thrust target will be created (only available if HIP_AS_CUDA option is set).

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`rocthrust_SOURCE_DIR` is set to the path to the source directory of rocthrust.
  :cmake:variable:`rocthrust_BINARY_DIR` is set to the path to the build directory of  rocthrust.
  :cmake:variable:`rocthrust_ADDED`      is set to a true value if rocthrust has not been added before.
  :cmake:variable:`rocthrust_VERSION`    is set to the version of rocthrust specified by the versions.json.
  :cmake:variable:`Thrust_SOURCE_DIR` Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`Thrust_BINARY_DIR` Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`Thrust_ADDED`      Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`Thrust_VERSION`    Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).

#]=======================================================================]
# cmake-lint: disable=R0915
function(rapids_cpm_rocthrust)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rocthrust")

  set(options)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET USE_LOCAL PREFER_LOCAL)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Fix up RAPIDS_UNPARSED_ARGUMENTS to have EXPORT_SETS as this is need for rapids_cpm_find
  if(_RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS INSTALL_EXPORT_SET ${_RAPIDS_INSTALL_EXPORT_SET})
  endif()
  if(_RAPIDS_BUILD_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS BUILD_EXPORT_SET ${_RAPIDS_BUILD_EXPORT_SET})
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(rocthrust version repository tag shallow exclude)
  set(to_exclude OFF)
  if(NOT _RAPIDS_INSTALL_EXPORT_SET OR exclude)
    set(to_exclude ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(rocthrust ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")

  # # note: order doesn't matter
  # if (_RAPIDS_PREFER_LOCAL)
  #   set(CPM_USE_LOCAL_PACKAGES ON)
  # elseif($ENV{RAPIDS_CMAKE_ROCTHRUST_PREFER_LOCAL}) # note: can't OR with if condition as $ENV{..} may eval to ""
  #   set(CPM_USE_LOCAL_PACKAGES ON)
  # endif()

  set(CPM_LOCAL_PACKAGES_ONLY ON) # always look for a local package for the time being
  # note: order doesn't matter
  # if (_RAPIDS_USE_LOCAL)
  #   set(CPM_LOCAL_PACKAGES_ONLY ON)
  # elseif($ENV{RAPIDS_CMAKE_ROCTHRUST_USE_LOCAL}) # note: can't OR with if condition as $ENV{..} may eval to ""
  #   set(CPM_LOCAL_PACKAGES_ONLY ON)
  # endif()

  rapids_cpm_find(rocthrust ${version} ${_RAPIDS_UNPARSED_ARGUMENTS}
                  CPM_ARGS
                    # FIND_PACKAGE_ARGUMENTS EXACT # we also accept more recent versions
                    GIT_REPOSITORY ${repository}
                    GIT_TAG ${tag}
                    GIT_SHALLOW ${shallow}
                    PATCH_COMMAND ${patch_command}
                    EXCLUDE_FROM_ALL ${to_exclude}
                    OPTIONS "DOWNLOAD_ROCPRIM ON")

  # if (NOT TARGET roc::rocthrust AND TARGET rocthrust)
  #   if (NOT DEFINED rocthrust_BINARY_DIR)
  #     message(rocthrust_BINARY_DIR "Expected variable rocthrust_BINARY_DIR to be defined")
  #   endif()
  #   # Target is named 'rocthrust' if this is NOT a local installation.

  #   # CPM runs the rocThrust CMakeLists.txt, which creates the CMake package file
  #   # _deps/rocthrust-build/thrust/rocthrust-config.cmake.
  #   # Below, we specify the parent dir of this file as `find_package` search dir
  #   # for `rocthrust`.
  #   include("${rapids-cmake-dir}/export/find_package_root.cmake")
  #   rapids_export_find_package_root(BUILD rocthrust "${rocthrust_BINARY_DIR}/thrust"
  #                                   EXPORT_SET ${_RAPIDS_BUILD_EXPORT_SET})
  # elseif(NOT TARGET roc::rocthrust)
  #   message(FATAL_ERROR "Expected rocthrust or roc::rocthrust to exist")
  # endif()

  # include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  # rapids_cpm_display_patch_status(rocthrust)

  # Propagate up variables that CPMFindPackage provide
  set(rocthrust_SOURCE_DIR "${rocthrust_SOURCE_DIR}" PARENT_SCOPE)
  set(rocthrust_BINARY_DIR "${rocthrust_BINARY_DIR}" PARENT_SCOPE)
  set(rocthrust_ADDED "${rocthrust_ADDED}" PARENT_SCOPE)
  set(rocthrust_VERSION ${version} PARENT_SCOPE)

  if (HIP_AS_CUDA)
    set(Thrust_SOURCE_DIR "${rocthrust_SOURCE_DIR}" PARENT_SCOPE)
    set(Thrust_BINARY_DIR "${rocthrust_BINARY_DIR}" PARENT_SCOPE)
    set(Thrust_ADDED "${rocthrust_ADDED}" PARENT_SCOPE)
    set(Thrust_VERSION ${version} PARENT_SCOPE)
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cpm_thrust NAMESPACE namespaces_name)
    rapids_cpm_rocthrust(${ARGN})

    if (NOT TARGET ${namespaces_name}::Thrust)
      get_property(rocthrust_orig TARGET roc::rocthrust PROPERTY ALIASED_TARGET)
      if ("${rocthrust_orig}" STREQUAL "")
        add_library(${namespaces_name}::Thrust ALIAS roc::rocthrust)
      else()
        add_library(${namespaces_name}::Thrust ALIAS "${rocthrust_orig}")
      endif()
    endif()
  endfunction()
endif()
