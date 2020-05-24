

include(FindPackageHandleStandardArgs)

message(STATUS "Conan: Using autogenerated Findboost.cmake")
# Global approach
set(boost_FOUND 1)
set(boost_VERSION "1.69.0")

find_package_handle_standard_args(boost REQUIRED_VARS boost_VERSION VERSION_VAR boost_VERSION)
mark_as_advanced(boost_FOUND boost_VERSION)



set(boost_INCLUDE_DIRS "/root/.conan/data/boost/1.69.0/conan/stable/package/98bfc16e03997a700b425f9737cca5d6a2d7eea0/include")
set(boost_INCLUDE_DIR "/root/.conan/data/boost/1.69.0/conan/stable/package/98bfc16e03997a700b425f9737cca5d6a2d7eea0/include")
set(boost_INCLUDES "/root/.conan/data/boost/1.69.0/conan/stable/package/98bfc16e03997a700b425f9737cca5d6a2d7eea0/include")
set(boost_RES_DIRS )
set(boost_DEFINITIONS "-DBOOST_USE_STATIC_LIBS")
set(boost_LINKER_FLAGS_LIST "" "")
set(boost_COMPILE_DEFINITIONS "BOOST_USE_STATIC_LIBS")
set(boost_COMPILE_OPTIONS_LIST "" "")
set(boost_LIBRARIES_TARGETS "") # Will be filled later, if CMake 3
set(boost_LIBRARIES "") # Will be filled later
set(boost_LIBS "") # Same as boost_LIBRARIES
set(boost_SYSTEM_LIBS )
set(boost_FRAMEWORK_DIRS )
set(boost_FRAMEWORKS )
set(boost_FRAMEWORKS_FOUND "") # Will be filled later
set(boost_BUILD_MODULES_PATHS )

# Apple frameworks
if(APPLE)
    foreach(_FRAMEWORK ${boost_FRAMEWORKS})
        # https://cmake.org/pipermail/cmake-developers/2017-August/030199.html
        find_library(CONAN_FRAMEWORK_${_FRAMEWORK}_FOUND NAME ${_FRAMEWORK} PATHS ${boost_FRAMEWORK_DIRS})
        if(CONAN_FRAMEWORK_${_FRAMEWORK}_FOUND)
            list(APPEND boost_FRAMEWORKS_FOUND ${CONAN_FRAMEWORK_${_FRAMEWORK}_FOUND})
        else()
            message(FATAL_ERROR "Framework library ${_FRAMEWORK} not found in paths: ${boost_FRAMEWORK_DIRS}")
        endif()
    endforeach()
endif()

mark_as_advanced(boost_INCLUDE_DIRS
                 boost_INCLUDE_DIR
                 boost_INCLUDES
                 boost_DEFINITIONS
                 boost_LINKER_FLAGS_LIST
                 boost_COMPILE_DEFINITIONS
                 boost_COMPILE_OPTIONS_LIST
                 boost_LIBRARIES
                 boost_LIBS
                 boost_LIBRARIES_TARGETS)

# Find the real .lib/.a and add them to boost_LIBS and boost_LIBRARY_LIST
set(boost_LIBRARY_LIST boost_wave boost_container boost_contract boost_exception boost_graph boost_iostreams boost_locale boost_log boost_program_options boost_random boost_regex boost_serialization boost_wserialization boost_coroutine boost_context boost_timer boost_thread boost_chrono boost_date_time boost_atomic boost_filesystem boost_system boost_type_erasure boost_log_setup boost_math_c99 boost_math_c99f boost_math_c99l boost_math_tr1 boost_math_tr1f boost_math_tr1l boost_stacktrace_addr2line boost_stacktrace_backtrace boost_stacktrace_basic boost_stacktrace_noop boost_unit_test_framework pthread)
set(boost_LIB_DIRS "/root/.conan/data/boost/1.69.0/conan/stable/package/98bfc16e03997a700b425f9737cca5d6a2d7eea0/lib")
foreach(_LIBRARY_NAME ${boost_LIBRARY_LIST})
    unset(CONAN_FOUND_LIBRARY CACHE)
    find_library(CONAN_FOUND_LIBRARY NAME ${_LIBRARY_NAME} PATHS ${boost_LIB_DIRS}
                 NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    if(CONAN_FOUND_LIBRARY)
        list(APPEND boost_LIBRARIES ${CONAN_FOUND_LIBRARY})
        if(NOT ${CMAKE_VERSION} VERSION_LESS "3.0")
            # Create a micro-target for each lib/a found
            set(_LIB_NAME CONAN_LIB::boost_${_LIBRARY_NAME})
            if(NOT TARGET ${_LIB_NAME})
                # Create a micro-target for each lib/a found
                add_library(${_LIB_NAME} UNKNOWN IMPORTED)
                set_target_properties(${_LIB_NAME} PROPERTIES IMPORTED_LOCATION ${CONAN_FOUND_LIBRARY})
            else()
                message(STATUS "Skipping already existing target: ${_LIB_NAME}")
            endif()
            list(APPEND boost_LIBRARIES_TARGETS ${_LIB_NAME})
        endif()
        message(STATUS "Found: ${CONAN_FOUND_LIBRARY}")
    else()
        message(STATUS "Library ${_LIBRARY_NAME} not found in package, might be system one")
        list(APPEND boost_LIBRARIES_TARGETS ${_LIBRARY_NAME})
        list(APPEND boost_LIBRARIES ${_LIBRARY_NAME})
    endif()
endforeach()
set(boost_LIBS ${boost_LIBRARIES})

foreach(_FRAMEWORK ${boost_FRAMEWORKS_FOUND})
    list(APPEND boost_LIBRARIES_TARGETS ${_FRAMEWORK})
    list(APPEND boost_LIBRARIES ${_FRAMEWORK})
endforeach()

foreach(_SYSTEM_LIB ${boost_SYSTEM_LIB})
    list(APPEND boost_LIBRARIES_TARGETS ${_SYSTEM_LIB})
    list(APPEND boost_LIBRARIES ${_SYSTEM_LIB})
endforeach()

set(CMAKE_MODULE_PATH "/root/.conan/data/boost/1.69.0/conan/stable/package/98bfc16e03997a700b425f9737cca5d6a2d7eea0/" ${CMAKE_MODULE_PATH})
set(CMAKE_PREFIX_PATH "/root/.conan/data/boost/1.69.0/conan/stable/package/98bfc16e03997a700b425f9737cca5d6a2d7eea0/" ${CMAKE_PREFIX_PATH})

foreach(_BUILD_MODULE_PATH ${boost_BUILD_MODULES_PATHS})
    include(${_BUILD_MODULE_PATH})
endforeach()

if(NOT ${CMAKE_VERSION} VERSION_LESS "3.0")
    # Target approach
    if(NOT TARGET boost::boost)
        add_library(boost::boost INTERFACE IMPORTED)
        
    if(boost_INCLUDE_DIRS)
      set_target_properties(boost::boost PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${boost_INCLUDE_DIRS}")
    endif()
    set_property(TARGET boost::boost PROPERTY INTERFACE_LINK_LIBRARIES ${boost_LIBRARIES_TARGETS} ${boost_SYSTEM_LIBS} "${boost_LINKER_FLAGS_LIST}")
    set_property(TARGET boost::boost PROPERTY INTERFACE_COMPILE_DEFINITIONS ${boost_COMPILE_DEFINITIONS})
    set_property(TARGET boost::boost PROPERTY INTERFACE_COMPILE_OPTIONS "${boost_COMPILE_OPTIONS_LIST}")

            
    # Library dependencies
    include(CMakeFindDependencyMacro)
    find_dependency(ZLIB REQUIRED)
    get_target_property(tmp ZLIB::ZLIB INTERFACE_LINK_LIBRARIES)
    if(tmp)
      set_property(TARGET boost::boost APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${tmp})
    endif()
    get_target_property(tmp ZLIB::ZLIB INTERFACE_COMPILE_DEFINITIONS)
    if(tmp)
      set_property(TARGET boost::boost APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS ${tmp})
    endif()
    get_target_property(tmp ZLIB::ZLIB INTERFACE_INCLUDE_DIRECTORIES)
    if(tmp)
      set_property(TARGET boost::boost APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${tmp})
    endif()
    find_dependency(BZip2 REQUIRED)
    get_target_property(tmp BZip2::BZip2 INTERFACE_LINK_LIBRARIES)
    if(tmp)
      set_property(TARGET boost::boost APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${tmp})
    endif()
    get_target_property(tmp BZip2::BZip2 INTERFACE_COMPILE_DEFINITIONS)
    if(tmp)
      set_property(TARGET boost::boost APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS ${tmp})
    endif()
    get_target_property(tmp BZip2::BZip2 INTERFACE_INCLUDE_DIRECTORIES)
    if(tmp)
      set_property(TARGET boost::boost APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${tmp})
    endif()
    endif()
endif()
