##### config
cmake_minimum_required(VERSION 3.15)
project (dotnet)
ENABLE_LANGUAGE(ASM)

#set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_EXE_LINKER_FLAGS "-static")
set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_C_EXTENSIONS OFF CACHE INTERNAL "C compiler extensions OFF")
set(CMAKE_CXX_EXTENSIONS OFF CACHE INTERNAL "C++ compiler extensions OFF")
# for debug
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++14 -O0 -g -rdynamic -Wno-attributes -Wno-narrowing -fpermissive -pthread -fPIC")
# for minimun size
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -std=c++14 -Os -fdata-sections -ffunction-sections -Wno-attributes -Wno-narrowing -fpermissive -pthread")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections -Wl,-Map=map.map")

#### includes
include_directories("../../src/CLR/Include")
include_directories("../../src/HAL/Include")
include_directories("../../src/PAL/Include")
include_directories("../../src/CLR/CorLib")
include_directories("../../src/CLR/Core")
include_directories("../../src/CLR/Diagnostics")
include_directories("../../src/DeviceInterfaces/System.Net")
include_directories("../../src/Windows.Storage")
include_directories("../../src/nanoFramework.System.Text")
include_directories("../../src/CLR/System.Math")
include_directories("../../src/nanoFramework.System.Collections")
include_directories("../../src/nanoFramework.Runtime.Native")
include_directories("../../src/DeviceInterfaces/Networking.Sntp")
include_directories("../../src/nanoFramework.ResourceManager")
include_directories("../../src/nanoFramework.Runtime.Events")
include_directories("../../src/CLR/Helpers/Base64")
include_directories("../../src/CLR/Helpers/nanoprintf")
include_directories("../../src/System.Device.Gpio")
include_directories("./include")

# defines
if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        add_definitions(-DDEBUG=TRUE)
else ()
        add_definitions(-DBUILD_RTM)
endif ()

add_definitions(-DNANOCLR_REFLECTION=TRUE
                -DNANOCLR_SYSTEM_COLLECTIONS=TRUE
                -DSUPPORT_ANY_BASE_CONVERSION=FALSE
                -D_LIB
                -DVERSION_MAJOR=$ENV{NF_VERSION_MAJOR}
                -DVERSION_MINOR=$ENV{NF_VERSION_MINOR}
                -DVERSION_BUILD=$ENV{NF_VERSION_BUILD}
                -DVERSION_REVISION=$ENV{NF_VERSION_REVISION}
                -DVERSION_STRING="$ENV{NF_VERSION}"
                -DOEMSYSTEMINFOSTRING="nanoCLR running on $ENV{NF_BOARD_TARGET}"
                -DTARGETNAMESTRING="$ENV{NF_BOARD_TARGET}"
                -DTARGETINFOSTRING="$ENV{NF_PLATFORM_TARGET_STRING}"
                -DPLATFORMNAMESTRING="$ENV{NF_PLATFORM_TARGET}"
                -DNANOCLR_LIGHT_MATH=TRUE
                -DHAL_REDUCESIZE=TRUE
                -DRUNTIME_MEMORY_PROFILE__extrasmall=TRUE
                -D$ENV{NF_BOARD_CONFIG})

file(GLOB STDAFX
        utils/stdafx.cpp)

file(GLOB STARTUP
        ../../src/CLR/Startup/CLRStartup.cpp)

file(GLOB BASE64
        ../../src/CLR/Helpers/Base64/base64.c)

file(GLOB NANOPRINTF
        ../../src/CLR/Helpers/nanoprintf/nanoprintf.c)

file(GLOB NANO_EVENTS
        ../../src/nanoFramework.Runtime.Events/nf_rt_events_native.cpp
        ../../src/nanoFramework.Runtime.Events/nf_rt_events_native_nanoFramework_Runtime_Events_EventSink.cpp
        ../../src/nanoFramework.Runtime.Events/nf_rt_events_native_nanoFramework_Runtime_Events_NativeEventDispatcher.cpp
        ../../src/nanoFramework.Runtime.Events/nf_rt_events_native_nanoFramework_Runtime_Events_WeakDelegate.cpp)

file(GLOB NANO_PAL
        ../../src/PAL/AsyncProcCall/AsyncCompletions.cpp
        ../../src/PAL/AsyncProcCall/AsyncContinuations.cpp
        target/PAL/blockstorageList_stubs.cpp
        target/PAL/COMDirector_stubs.cpp
        target/PAL/ConfigHelper_stubs.cpp
        ../../src/PAL/Double/nanoPAL_NativeDouble.cpp
        ../../src/CLR/Core/NativeEventDispatcher/NativeEventDispatcher.cpp
        target/PAL/Target_BlockStorage.cpp
        target/PAL/time_stubs.cpp
        target/PAL/Watchdog_stubs.cpp
        target/PAL/CPU_Gpio_weak.cpp
        target/PAL/CPU_Gpio_Linux.cpp)

file(GLOB NANO_CLR
        target/Various.cpp
        utils/TimerManager.cpp
        target/WatchDog.cpp
        target/targetRandom.cpp
        target/targetPAL_Time.cpp
        target/targetPAL_Events.cpp
        target/targetHAL_Time.cpp
        target/stdafx.cpp
        target/platform_heap.cpp
        target/ParseOptions_Win32.cpp
        target/nanoHAL_Time.cpp
        ../../src/HAL/nanoHAL_Capabilites.c
        target/Memory.cpp
        target/CLRStartup.cpp
        target/FileStore_Win32.cpp
        target/Generated/CLR_RT_InteropAssembliesTable.cpp)

file(GLOB COR_LIB
        ../../src/CLR/CorLib/corlib_native.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_Binder.cpp
        ../../src/CLR/CorLib/corlib_native_System_AppDomain.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_ConstructorInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_Array.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_FieldInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_Attribute.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_MemberInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_BitConverter.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_MethodBase.cpp
        ../../src/CLR/CorLib/corlib_native_System_Collections_ArrayList.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_PropertyInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_Convert.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_RuntimeFieldInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_DateTime.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_RuntimeMethodInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_Delegate.cpp
        ../../src/CLR/CorLib/corlib_native_System_RuntimeType.cpp
        ../../src/CLR/CorLib/corlib_native_System_Diagnostics_Debug.cpp
        ../../src/CLR/CorLib/corlib_native_System_Runtime_CompilerServices_RuntimeHelpers.cpp
        ../../src/CLR/CorLib/corlib_native_System_Diagnostics_Debugger.cpp
        ../../src/CLR/CorLib/corlib_native_System_Runtime_Remoting_RemotingServices.cpp
        ../../src/CLR/CorLib/corlib_native_System_Double.cpp
        ../../src/CLR/CorLib/corlib_native_System_String.cpp
        ../../src/CLR/CorLib/corlib_native_System_Enum.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_AutoResetEvent.cpp
        ../../src/CLR/CorLib/corlib_native_System_Exception.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_Interlocked.cpp
        ../../src/CLR/CorLib/corlib_native_System_GC.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_ManualResetEvent.cpp
        ../../src/CLR/CorLib/corlib_native_System_Globalization_CultureInfo.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_Monitor.cpp
        ../../src/CLR/CorLib/corlib_native_System_Globalization_DateTimeFormat.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_SpinWait.cpp
        ../../src/CLR/CorLib/corlib_native_System_Guid.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_Thread.cpp
        ../../src/CLR/CorLib/corlib_native_System_MarshalByRefObject.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_Timer.cpp
        ../../src/CLR/CorLib/corlib_native_System_MathInternal.cpp
        ../../src/CLR/CorLib/corlib_native_System_Threading_WaitHandle.cpp
        ../../src/CLR/CorLib/corlib_native_System_MulticastDelegate.cpp
        ../../src/CLR/CorLib/corlib_native_System_TimeSpan.cpp
        ../../src/CLR/CorLib/corlib_native_System_Number.cpp
        ../../src/CLR/CorLib/corlib_native_System_Type.cpp
        ../../src/CLR/CorLib/corlib_native_System_Object.cpp
        ../../src/CLR/CorLib/corlib_native_System_ValueType.cpp
        ../../src/CLR/CorLib/corlib_native_System_Random.cpp
        ../../src/CLR/CorLib/corlib_native_System_WeakReference.cpp
        ../../src/CLR/CorLib/corlib_native_System_Reflection_Assembly.cpp)

file(GLOB STUBS
        ../../src/CLR/Core/Serialization/BinaryFormatter_stub.cpp
        ../../src/CLR/Core/RPC/RPC_stub.cpp
        ../../src/CLR/Core/NativeEventDispatcher/NativeEventDispatcher_stub.cpp
        ../../src/CLR/Messaging/Messaging_stub.cpp
        ../../src/CLR/Core/InterruptHandler/InterruptHandler_stub.cpp
        ../../src/CLR/Core/Hardware/Hardware_stub.cpp
        ../../src/CLR/Debugger/Debugger_stub.cpp
        ../../src/PAL/Profiler/nanoPAL_PerformanceCounters_stubs.cpp)

file(GLOB CORE
        ../../src/CLR/Core/Cache.cpp
        ../../src/CLR/Core/Checks.cpp
        ../../src/CLR/Core/CLR_RT_DblLinkedList.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Array.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_ArrayList.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_BinaryBlob.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Delegate.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Delegate_List.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Finalizer.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Lock.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_LockRequest.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Node.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Queue.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Stack.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_String.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_Timer.cpp
        ../../src/CLR/Core/CLR_RT_HeapBlock_WaitForObject.cpp
        ../../src/CLR/Core/CLR_RT_HeapCluster.cpp
        ../../src/CLR/Core/CLR_RT_Interop.cpp
        ../../src/CLR/Core/CLR_RT_Memory.cpp
        ../../src/CLR/Core/CLR_RT_ObjectToEvent_Destination.cpp
        ../../src/CLR/Core/CLR_RT_ObjectToEvent_Source.cpp
        ../../src/CLR/Core/CLR_RT_RuntimeMemory.cpp
        ../../src/CLR/Core/CLR_RT_StackFrame.cpp
        ../../src/CLR/Core/CLR_RT_SystemAssembliesTable.cpp
        ../../src/CLR/Core/CLR_RT_UnicodeHelper.cpp
        ../../src/CLR/Core/Core.cpp
        ../../src/CLR/Core/Execution.cpp
        ../../src/CLR/Core/GarbageCollector.cpp
        ../../src/CLR/Core/GarbageCollector_Compaction.cpp
        ../../src/CLR/Core/GarbageCollector_ComputeReachabilityGraph.cpp
        ../../src/CLR/Core/Interpreter.cpp
        ../../src/CLR/Core/nanoprintf.c
        ../../src/CLR/Core/Streams.cpp
        ../../src/CLR/Core/StringTable.cpp
        ../../src/CLR/Core/StringTableData.cpp
        ../../src/CLR/Core/Thread.cpp
        ../../src/CLR/Core/TypeSystem.cpp
        ../../src/CLR/Core/TypeSystemLookup.cpp
        ../../src/CLR/Core/Various.cpp)

file(GLOB FEATURES
        ../../src/CLR/WireProtocol/WireProtocol_MonitorCommands.c
        ../../src/CLR/WireProtocol/WireProtocol_Message.c
        ../../src/CLR/WireProtocol/WireProtocol_HAL_Interface.c
        ../../src/CLR/WireProtocol/WireProtocol_App_Interface.c
        ../../src/CLR/WireProtocol/targetHAL_time.cpp
        ../../src/CLR/Core/Serialization/BinaryFormatter.cpp
        ../../src/CLR/Core/RPC/CLR_RT_HeapBlock_EndPoint.cpp
        ../../src/CLR/Core/NativeEventDispatcher/NativeEventDispatcher.cpp
        ../../src/CLR/Messaging/Messaging.cpp
        ../../src/CLR/Core/InterruptHandler/InterruptHandler.cpp
        ../../src/CLR/Core/Hardware/Hardware.cpp
        ../../src/CLR/Diagnostics/Info.cpp
        ../../src/CLR/Diagnostics/Profile.cpp
        ../../src/CLR/Diagnostics/Profiler.cpp
        ../../src/CLR/Debugger/Debugger.cpp
        ../../src/CLR/Debugger/Debugger_minimal.cpp)

file(GLOB ASSEMBLIES
        ../../src/nanoFramework.System.Text/nf_system_text_System_Text_UTF8Decoder.cpp
        ../../src/nanoFramework.System.Text/nf_system_text_System_Text_UTF8Encoding.cpp
        ../../src/nanoFramework.System.Text/nf_system_text.cpp
        ../../src/CLR/System.Math/nf_native_system_math_System_Math.cpp
        ../../src/CLR/System.Math/nf_native_system_math.cpp
        ../../src/nanoFramework.System.Collections/nf_system_collections.cpp
        ../../src/nanoFramework.System.Collections/nf_system_collections_System_Collections_Queue.cpp
        ../../src/nanoFramework.System.Collections/nf_system_collections_System_Collections_Stack.cpp
        ../../src/nanoFramework.Runtime.Native/nf_rt_native.cpp
        ../../src/nanoFramework.Runtime.Native/nf_rt_native_nanoFramework_Runtime_Hardware_SystemInfo.cpp
        ../../src/nanoFramework.Runtime.Native/nf_rt_native_nanoFramework_Runtime_Native_ExecutionConstraint.cpp
        ../../src/nanoFramework.Runtime.Native/nf_rt_native_nanoFramework_Runtime_Native_GC.cpp
        ../../src/nanoFramework.Runtime.Native/nf_rt_native_nanoFramework_Runtime_Native_Power.cpp
        ../../src/nanoFramework.Runtime.Native/nf_rt_native_nanoFramework_Runtime_Native_Rtc_stubs.cpp
        ../../src/nanoFramework.ResourceManager/nf_system_resourcemanager.cpp
        ../../src/nanoFramework.ResourceManager/nf_system_resourcemanager_nanoFramework_Runtime_Native_ResourceUtility.cpp
        ../../src/nanoFramework.ResourceManager/nf_system_resourcemanager_System_Resources_ResourceManager.cpp
        ../../src/System.Device.Gpio/sys_dev_gpio_native.cpp
        ../../src/System.Device.Gpio/sys_dev_gpio_native_System_Device_Gpio_GpioPin.cpp
        ../../src/System.Device.Gpio/sys_dev_gpio_native_System_Device_Gpio_GpioController.cpp)

add_executable(dotnet-nf
                ${NANO_CLR}
                ${STDAFX}
                ${BASE64}
                ${NANOPRINTF}
                ${NANO_PAL}
                ${STARTUP}
                ${COR_LIB}
                ${STUBS}
                ${CORE}
                ${FEATURES}
                ${NANO_EVENTS}
                ${ASSEMBLIES}
                utils/utils.cpp
                main.cpp)

target_link_libraries(dotnet-nf -lgpiod)
