#=============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
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
rapids_cpm_jitify_hip
--------------

.. versionadded:: v21.10.00

Allow projects to find or build ROCm `Jitify` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the current rapids-cmake version of ROCm Jitify `as specified in the version file <cpm_versions>`
for  consistency across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_jitify_hip( [BUILD_EXPORT_SET <export-name>]
                  [INSTALL_EXPORT_SET <export-name>]
                  [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: jitify_hip
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^

  jitify::jitify target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`jitify_SOURCE_DIR` is set to the path to the source directory of Jitify.
  :cmake:variable:`jitify_BINARY_DIR` is set to the path to the build directory of  Jitify.
  :cmake:variable:`jitify_ADDED`      is set to a true value if Jitify has not been added before.
  :cmake:variable:`jitify_VERSION`    is set to the version of Jitify specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_jitify_hip)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.jitify")

  set(options)
  set(one_value INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Fix up RAPIDS_UNPARSED_ARGUMENTS to have EXPORT_SETS as this is need for rapids_cpm_find
  if(_RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS INSTALL_EXPORT_SET ${_RAPIDS_INSTALL_EXPORT_SET})
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details("jitify-hip" version repository tag shallow exclude)
  set(to_exclude OFF)
  if(NOT _RAPIDS_INSTALL_EXPORT_SET OR exclude)
    set(to_exclude ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command("jitify-hip" ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(jitify ${version} ${ARGN} {_RAPIDS_UNPARSED_ARGUMENTS}
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${to_exclude})

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status("jitify-hip")

  # Propagate up variables that CPMFindPackage provide
  set(jitify_SOURCE_DIR "${jitify_SOURCE_DIR}" PARENT_SCOPE)
  set(jitify_BINARY_DIR "${jitify_BINARY_DIR}" PARENT_SCOPE)
  set(jitify_ADDED "${jitify_ADDED}" PARENT_SCOPE)
  set(jitify_VERSION ${version} PARENT_SCOPE)

  # jitify creates the correct namespace aliases
endfunction()

if (HIP_AS_CUDA)
  function(rapids_cpm_jitify)
    rapids_cpm_jitify_hip(${ARGN})
  endfunction()
endif()
