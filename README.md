<!-- MIT License
  --
  -- Modifications Copyright (c) 2024 Advanced Micro Devices, Inc.
  --
  -- Permission is hereby granted, free of charge, to any person obtaining a copy
  -- of this software and associated documentation files (the "Software"), to deal
  -- in the Software without restriction, including without limitation the rights
  -- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  -- copies of the Software, and to permit persons to whom the Software is
  -- furnished to do so, subject to the following conditions:
  --
  -- The above copyright notice and this permission notice shall be included in all
  -- copies or substantial portions of the Software.
  --
  -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  -- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  -- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  -- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  -- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  -- SOFTWARE.
-->

# ROCm-DS CMake

> [!CAUTION]
> This release is an *early-access* software technology preview. Running production workloads is *not* recommended.

> [!NOTE]
> This repository will be eventually moved to the [ROCm-DS](https://github.com/rocm-ds) Github organization.

<!-- **NOTE:** For the latest stable [README.md](https://github.com/ROCm/ROCmDS-cmake/blob/main/README.md) ensure you are on the default branch. -->

## Overview

This is a collection of CMake modules that are useful for all ROCm-DS
projects. By sharing the code in a single place it makes rolling out CMake
fixes easier.

> [!NOTE]
> This ROCm&trade; port is derived from the NVIDIA RAPIDS&reg; RAPIDS-CMake project. It aims to
follow the latter's directory structure, file naming and API naming as closely as possible to minimize porting friction for users that are interested in using both projects.

## Installation

The `rapids-cmake` module is designed to be acquired via CMake's [Fetch
Content](https://cmake.org/cmake/help/latest/module/FetchContent.html) into your project.

```cmake

cmake_minimum_required(...)

if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/<PROJECT>_RAPIDS.cmake)
  file(DOWNLOAD https://raw.githubusercontent.com/ROCm/ROCmDS-CMake/branch-<VERSION_MAJOR>.<VERSION_MINOR>/RAPIDS.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/<PROJECT>_RAPIDS.cmake)
endif()
include(${CMAKE_CURRENT_BINARY_DIR}/<PROJECT>_RAPIDS.cmake)

include(rapids-cmake)
include(rapids-cpm)
include(rapids-cuda)
include(rapids-export)
include(rapids-find)

project(....)
```

Note that we recommend you install `rapids-cmake` into the root `CMakeLists.txt` of
your project before the first `project` call. This allows us to offer features such as
`rapids_hip_architectures()`

## Usage

`rapids-cmake` provides a collection of useful CMake settings that any ROCmDS project may use.
While they maybe common, we know that they aren't universal and might need to be composed in
different ways.

To use function provided by `rapids-cmake` projects have two options:
- Call `include(rapids-<component>)` as that imports all commonly used functions for that component
- Load each function independently via `include(${rapids-cmake-dir}/<component>/<function_name>.cmake)`


## Components

Complete online documentation for all components can be found at:

  https://docs.rapids.ai/api/rapids-cmake/nightly/api.html


### cmake
The `rapids-cmake` module contains helpful general CMake functionality

- `rapids_cmake_build_type( )` handles initialization of `CMAKE_BUILD_TYPE`
- `rapids_cmake_support_conda_env( target [MODIFY_PREFIX_PATH])` Establish a target that holds the CONDA environment
  include and link directories.
- `rapids_cmake_write_version_file( <file> )` Write a C++ header with a projects MAJOR, MINOR, and PATCH defines

### cpm

The `rapids-cpm` module contains CPM functionality to allow projects to acquire dependencies consistently.
For consistency, all targets brought in via `rapids-cpm` are GLOBAL targets.

- `rapids_cpm_init()` handles initialization of the CPM module.
- `rapids_cpm_find(<project> name BUILD_EXPORT_SET <name> INSTALL_EXPORT_SET <name>)` Will search for a module and fall back to installing via CPM. Offers support to track dependencies for easy package exporting

### cuda

The `rapids-cuda` module contains core functionality to allow projects to build CUDA code robustly.
The most commonly used function are:

- `rapids_cuda_init_architectures(<project_name>)` handles initialization of `CMAKE_CUDA_ARCHITECTURE`. MUST BE CALLED BEFORE `PROJECT()`
- `rapids_cuda_init_runtime(<mode>)` handles initialization of `CMAKE_CUDA_RUNTIME_LIBRARY`.
- `rapids_cuda_patch_toolkit()` corrects bugs in the CUDAToolkit module that are being upstreamed.

### cython

The `rapids_cython` functions allow projects to easily build cython modules using
[scikit-build](https://scikit-build.readthedocs.io/en/latest/).

- `rapids_cython_init()` handles initialization of scikit-build and cython.
- `rapids_create_modules([CXX] [SOURCE_FILES <src1> <src2> ...] [LINKED_LIBRARIES <lib1> <lib2> ... ]  [INSTALL_DIR <install_path>] [MODULE_PREFIX <module_prefix>] )` will create cython modules for each provided source file


### export

The `rapids-export` module contains core functionality to allow projects to easily record and write out
build and install dependencies, that come from `find_package` or `cpm`

- `rapids_export(<type> <project> EXPORT_SET <name>)` write out all the require components of a
  projects config module so that the `install` or `build` directory can be imported via `find_package`. See `rapids_export` documentation for full documentation


### find

The `rapids-find` module contains core functionality to allow projects to easily generate FindModule
or export `find_package` calls:

The most commonly used function are:

- `rapids_find_package(<project_name> BUILD_EXPORT_SET <name> INSTALL_EXPORT_SET <name> )` Combines `find_package` and support to track dependencies for easy package exporting
- `rapids_generate_module(<PackageName> HEADER_NAMES <paths...> LIBRARY_NAMES <names...> )` Generate a FindModule for the given package. Allows association to export sets so the generated FindModule can be shipped with the project

### test

The `rapids_test` functions simplify CTest resource allocation, allowing for
tests to run in parallel without overallocating GPU resources.

The most commonly used functions are:
- `rapids_test_add(NAME <test_name> GPUS <N> PERCENT <N>)`: State how many GPU resources a single
  test requires


## Overriding RAPIDS.cmake

At times projects or developers will need to verify ``rapids-cmake`` branches. To do this you can set variables that control which repository ``RAPIDS.cmake`` downloads, which should be done like this:

```cmake
  # To override the version that is pulled:
  set(rapids-cmake-version "<version>")

  # To override the GitHub repository:
  set(rapids-cmake-repo "<my_fork>")

  # To use an exact Git SHA:
  set(rapids-cmake-sha "<my_git_sha>")

  # To use a Git tag:
  set(rapids-cmake-tag "<my_git_tag>")

  # To override the repository branch:
  set(rapids-cmake-branch "<my_feature_branch>")

  # Or to override the entire repository URL (e.g. to use a GitLab repo):
  set(rapids-cmake-url "https://gitlab.com/<my_user>/<my_fork>/-/archive/<my_branch>/<my_fork>-<my_branch>.zip")

  # To override the usage of fetching the repository without git info
  # This only works when specifying
  #
  # set(rapids-cmake-fetch-via-git "ON")
  # set(rapids-cmake-branch "branch-<cal_ver>")
  #
  # or
  # set(rapids-cmake-fetch-via-git "ON")
  # set(rapids-cmake-url "https://gitlab.com/<my_user>/<private_fork>/")
  # set(rapids-cmake-sha "ABC123")
  #
  set(rapids-cmake-fetch-via-git "ON")

  file(DOWNLOAD https://raw.githubusercontent.com/ROCm/rapids-cmake/branch-23.12/RAPIDS.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
  include(${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
```

A few notes:

- An explicitly defined ``rapids-cmake-url`` will always be used
- `rapids-cmake-sha` takes precedence over `rapids-cmake-tag`
- `rapids-cmake-tag` takes precedence over `rapids-cmake-branch`
- It is advised to always set `rapids-cmake-version` to the version expected by the repo your modifications will pull

<!-- ## Contributing

Review the [CONTRIBUTING.md](https://github.com/ROCm/rapids-cmake/blob/main/CONTRIBUTING.md) file for information on how to contribute code and issues to the project. -->
