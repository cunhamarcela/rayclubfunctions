

-------------------------------------
Translated Report (Full Report Below)
-------------------------------------

Incident Identifier: 7AD55DBC-F4C4-4091-A441-846E7659A9AE
CrashReporter Key:   8C303817-D8A4-7D9B-CE72-7D6A64AAEC09
Hardware Model:      Mac16,7
Process:             Runner [60148]
Path:                /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Runner
Identifier:          com.rayclub.app
Version:             1.0.7 (13)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd_sim [814]
Coalition:           com.apple.CoreSimulator.SimDevice.3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5 [967]
Responsible Process: SimulatorTrampoline [789]

Date/Time:           2025-05-23 00:12:10.0073 -0300
Launch Time:         2025-05-23 00:12:05.0920 -0300
OS Version:          macOS 15.3.1 (24D70)
Release Type:        User
Report Version:      104

Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Termination Reason: SIGNAL 6 Abort trap: 6
Terminating Process: Runner [60148]

Triggered by Thread:  0

Last Exception Backtrace:
0   CoreFoundation                	       0x1804b9100 __exceptionPreprocess + 160
1   libobjc.A.dylib               	       0x180092da8 objc_exception_throw + 72
2   CoreFoundation                	       0x1804b901c -[NSException initWithCoder:] + 0
3   GoogleSignIn                  	       0x103230204 -[GIDSignIn signInWithOptions:] + 444 (GIDSignIn.m:592)
4   GoogleSignIn                  	       0x10322eb90 -[GIDSignIn signInWithPresentingViewController:hint:additionalScopes:completion:] + 208 (GIDSignIn.m:282)
5   Runner.debug.dylib            	       0x102e030a8 -[FLTGoogleSignInPlugin signInWithHint:additionalScopes:completion:] + 176
6   Runner.debug.dylib            	       0x102e02214 -[FLTGoogleSignInPlugin signInWithCompletion:] + 732
7   Runner.debug.dylib            	       0x102e07284 __FSIGoogleSignInApiSetup_block_invoke.119 + 184
8   Flutter                       	       0x1079268b0 __48-[FlutterBasicMessageChannel setMessageHandler:]_block_invoke + 160
9   Flutter                       	       0x107360478 invocation function for block in flutter::PlatformMessageHandlerIos::HandlePlatformMessage(std::_fl::unique_ptr<flutter::PlatformMessage, std::_fl::default_delete<flutter::PlatformMessage>>) + 108
10  libdispatch.dylib             	       0x18017b314 _dispatch_call_block_and_release + 24
11  libdispatch.dylib             	       0x18017cc08 _dispatch_client_callout + 16
12  libdispatch.dylib             	       0x18018bc2c _dispatch_main_queue_drain + 1276
13  libdispatch.dylib             	       0x18018b720 _dispatch_main_queue_callback_4CF + 40
14  CoreFoundation                	       0x18041cdbc __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__ + 12
15  CoreFoundation                	       0x180417318 __CFRunLoopRun + 1944
16  CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
17  GraphicsServices              	       0x190604b10 GSEventRunModal + 160
18  UIKitCore                     	       0x185b39180 -[UIApplication _run] + 796
19  UIKitCore                     	       0x185b3d378 UIApplicationMain + 124
20  UIKitCore                     	       0x184f0fad4 0x184cd9000 + 2321108
21  Runner.debug.dylib            	       0x102dfebc0 static UIApplicationDelegate.main() + 120
22  Runner.debug.dylib            	       0x102dfeb38 static AppDelegate.$main() + 44
23  Runner.debug.dylib            	       0x102dfec3c __debug_main_executable_dylib_entry_point + 28 (AppDelegate.swift:6)
24  dyld_sim                      	       0x102f05410 start_sim + 20
25  dyld                          	       0x1030a2274 start + 2840
26  ???                           	0xf52e800000000000 ???

Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	       0x1039ad108 __pthread_kill + 8
1   libsystem_pthread.dylib       	       0x10430b408 pthread_kill + 256
2   libsystem_c.dylib             	       0x1801704ec abort + 104
3   libc++abi.dylib               	       0x1802ad100 abort_message + 128
4   libc++abi.dylib               	       0x18029cb04 demangling_terminate_handler() + 300
5   libobjc.A.dylib               	       0x18006f8ac _objc_terminate() + 124
6   Sentry                        	       0x103a53af0 sentrycrashcm_cppexception_callOriginalTerminationHandler + 44 (SentryCrashMonitor_CPPException.cpp:127)
7   Sentry                        	       0x103a544a8 CPPExceptionTerminate() + 2188 (SentryCrashMonitor_CPPException.cpp:210)
8   libc++abi.dylib               	       0x1802ac4d8 std::__terminate(void (*)()) + 12
9   libc++abi.dylib               	       0x1802ac488 std::terminate() + 52
10  libdispatch.dylib             	       0x18017cc1c _dispatch_client_callout + 36
11  libdispatch.dylib             	       0x18018bc2c _dispatch_main_queue_drain + 1276
12  libdispatch.dylib             	       0x18018b720 _dispatch_main_queue_callback_4CF + 40
13  CoreFoundation                	       0x18041cdbc __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__ + 12
14  CoreFoundation                	       0x180417318 __CFRunLoopRun + 1944
15  CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
16  GraphicsServices              	       0x190604b10 GSEventRunModal + 160
17  UIKitCore                     	       0x185b39180 -[UIApplication _run] + 796
18  UIKitCore                     	       0x185b3d378 UIApplicationMain + 124
19  UIKitCore                     	       0x184f0fad4 0x184cd9000 + 2321108
20  Runner.debug.dylib            	       0x102dfebc0 static UIApplicationDelegate.main() + 120
21  Runner.debug.dylib            	       0x102dfeb38 static AppDelegate.$main() + 44
22  Runner.debug.dylib            	       0x102dfec3c __debug_main_executable_dylib_entry_point + 28 (AppDelegate.swift:6)
23  dyld_sim                      	       0x102f05410 start_sim + 20
24  dyld                          	       0x1030a2274 start + 2840

Thread 1:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 2:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 3:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 4:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 5:: com.apple.uikit.eventfetch-thread
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039ad4f4 mach_msg_overwrite + 536
3   libsystem_kernel.dylib        	       0x1039a56cc mach_msg + 20
4   CoreFoundation                	       0x18041cae0 __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x180417008 __CFRunLoopRun + 1160
6   CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
7   Foundation                    	       0x180f1f490 -[NSRunLoop(NSRunLoop) runMode:beforeDate:] + 208
8   Foundation                    	       0x180f1f6b0 -[NSRunLoop(NSRunLoop) runUntilDate:] + 60
9   UIKitCore                     	       0x185be6a34 -[UIEventFetcher threadMain] + 404
10  Foundation                    	       0x180f462d8 __NSThread__start__ + 720
11  libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
12  libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 6:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 7:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 8:
0   libsystem_pthread.dylib       	       0x10430692c start_wqthread + 0

Thread 9:: io.flutter.1.raster
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039ad4f4 mach_msg_overwrite + 536
3   libsystem_kernel.dylib        	       0x1039a56cc mach_msg + 20
4   CoreFoundation                	       0x18041cae0 __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x180417008 __CFRunLoopRun + 1160
6   CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
7   Flutter                       	       0x10738c59c fml::MessageLoopDarwin::Run() + 88
8   Flutter                       	       0x107385348 fml::MessageLoopImpl::DoRun() + 40
9   Flutter                       	       0x10738b238 std::_fl::__function::__func<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0, std::_fl::allocator<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0>, void ()>::operator()() + 184
10  Flutter                       	       0x10738af44 fml::ThreadHandle::ThreadHandle(std::_fl::function<void ()>&&)::$_0::__invoke(void*) + 36
11  libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
12  libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 10:: io.flutter.1.io
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039ad4f4 mach_msg_overwrite + 536
3   libsystem_kernel.dylib        	       0x1039a56cc mach_msg + 20
4   CoreFoundation                	       0x18041cae0 __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x180417008 __CFRunLoopRun + 1160
6   CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
7   Flutter                       	       0x10738c59c fml::MessageLoopDarwin::Run() + 88
8   Flutter                       	       0x107385348 fml::MessageLoopImpl::DoRun() + 40
9   Flutter                       	       0x10738b238 std::_fl::__function::__func<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0, std::_fl::allocator<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0>, void ()>::operator()() + 184
10  Flutter                       	       0x10738af44 fml::ThreadHandle::ThreadHandle(std::_fl::function<void ()>&&)::$_0::__invoke(void*) + 36
11  libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
12  libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 11:: io.flutter.1.profiler
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039ad4f4 mach_msg_overwrite + 536
3   libsystem_kernel.dylib        	       0x1039a56cc mach_msg + 20
4   CoreFoundation                	       0x18041cae0 __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x180417008 __CFRunLoopRun + 1160
6   CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
7   Flutter                       	       0x10738c59c fml::MessageLoopDarwin::Run() + 88
8   Flutter                       	       0x107385348 fml::MessageLoopImpl::DoRun() + 40
9   Flutter                       	       0x10738b238 std::_fl::__function::__func<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0, std::_fl::allocator<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0>, void ()>::operator()() + 184
10  Flutter                       	       0x10738af44 fml::ThreadHandle::ThreadHandle(std::_fl::function<void ()>&&)::$_0::__invoke(void*) + 36
11  libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
12  libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 12:: io.worker.1
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bc98 _pthread_cond_wait + 1192
2   Flutter                       	       0x107363adc std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&) + 24
3   Flutter                       	       0x107381778 fml::ConcurrentMessageLoop::WorkerMain() + 128
4   Flutter                       	       0x107382050 void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*) + 184
5   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
6   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 13:: io.worker.2
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bc98 _pthread_cond_wait + 1192
2   Flutter                       	       0x107363adc std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&) + 24
3   Flutter                       	       0x107381778 fml::ConcurrentMessageLoop::WorkerMain() + 128
4   Flutter                       	       0x107382050 void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*) + 184
5   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
6   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 14:: io.worker.3
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bc98 _pthread_cond_wait + 1192
2   Flutter                       	       0x107363adc std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&) + 24
3   Flutter                       	       0x107381778 fml::ConcurrentMessageLoop::WorkerMain() + 128
4   Flutter                       	       0x107382050 void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*) + 184
5   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
6   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 15:: io.worker.4
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bc98 _pthread_cond_wait + 1192
2   Flutter                       	       0x107363adc std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&) + 24
3   Flutter                       	       0x107381778 fml::ConcurrentMessageLoop::WorkerMain() + 128
4   Flutter                       	       0x107382050 void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*) + 184
5   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
6   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 16:: dart:io EventHandler
0   libsystem_kernel.dylib        	       0x1039aae84 kevent + 8
1   Flutter                       	       0x1078e2624 dart::bin::EventHandlerImplementation::EventHandlerEntry(unsigned long) + 300
2   Flutter                       	       0x1078fe8b0 dart::bin::ThreadStart(void*) + 88
3   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
4   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 17:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 18:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 19:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x1079a9fc8 dart::MutatorThreadPool::OnEnterIdleLocked(dart::MutexLocker*, dart::ThreadPool::Worker*) + 152
4   Flutter                       	       0x107aa7880 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 124
5   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
6   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
7   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
8   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 20:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 21:
0   libsystem_kernel.dylib        	       0x1039a865c __semwait_signal + 8
1   libsystem_c.dylib             	       0x18016d5dc nanosleep + 216
2   libsystem_c.dylib             	       0x18016d3d8 sleep + 48
3   Sentry                        	       0x103a40604 monitorCachedData + 136 (SentryCrashCachedData.c:146)
4   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
5   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 22:: SentryCrash Exception Handler (Secondary)
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039d241c thread_suspend + 104
3   Sentry                        	       0x103a54bc8 handleExceptions + 140 (SentryCrashMonitor_MachException.c:305)
4   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
5   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 23:: SentryCrash Exception Handler (Primary)
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039ad4f4 mach_msg_overwrite + 536
3   libsystem_kernel.dylib        	       0x1039a56cc mach_msg + 20
4   Sentry                        	       0x103a54c00 handleExceptions + 196 (SentryCrashMonitor_MachException.c:313)
5   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
6   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 24:: io.sentry.app-hang-tracker
0   libsystem_kernel.dylib        	       0x1039a865c __semwait_signal + 8
1   libsystem_c.dylib             	       0x18016d5dc nanosleep + 216
2   Foundation                    	       0x180f44c70 +[NSThread sleepForTimeInterval:] + 156
3   Sentry                        	       0x103b071d4 -[SentryThreadWrapper sleepForTimeInterval:] + 44 (SentryThreadWrapper.m:10)
4   Sentry                        	       0x103a1852c -[SentryANRTrackerV1 detectANRs] + 1112 (SentryANRTrackerV1.m:105)
5   Foundation                    	       0x180f462d8 __NSThread__start__ + 720
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 25:: com.apple.NSURLConnectionLoader
0   libsystem_kernel.dylib        	       0x1039a5390 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x1039b66e0 mach_msg2_internal + 76
2   libsystem_kernel.dylib        	       0x1039ad4f4 mach_msg_overwrite + 536
3   libsystem_kernel.dylib        	       0x1039a56cc mach_msg + 20
4   CoreFoundation                	       0x18041cae0 __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x180417008 __CFRunLoopRun + 1160
6   CoreFoundation                	       0x180416704 CFRunLoopRunSpecific + 552
7   CFNetwork                     	       0x184a09ce4 +[__CFN_CoreSchedulingSetRunnable _run:] + 372
8   Foundation                    	       0x180f462d8 __NSThread__start__ + 720
9   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
10  libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 26:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x1079a9fc8 dart::MutatorThreadPool::OnEnterIdleLocked(dart::MutexLocker*, dart::ThreadPool::Worker*) + 152
4   Flutter                       	       0x107aa7880 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 124
5   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
6   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
7   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
8   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 27:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 28:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 29:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 30:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 31:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 32:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 33:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 34:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 35:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 36:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 37:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 38:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 39:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 40:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 41:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 42:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 43:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 44:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 45:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 46:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 47:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 48:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 49:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 50:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 51:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 52:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 53:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 54:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 55:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 56:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 57:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 58:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 59:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 60:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 61:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 62:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 63:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 64:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 65:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 66:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 67:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 68:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8

Thread 69:: DartWorker
0   libsystem_kernel.dylib        	       0x1039a882c __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x10430bcc4 _pthread_cond_wait + 1236
2   Flutter                       	       0x10794c030 dart::ConditionVariable::WaitMicros(dart::Mutex*, long long) + 112
3   Flutter                       	       0x107aa7a00 dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*) + 508
4   Flutter                       	       0x107aa7b58 dart::ThreadPool::Worker::Main(unsigned long) + 116
5   Flutter                       	       0x107a5f70c dart::ThreadStart(void*) + 204
6   libsystem_pthread.dylib       	       0x10430b6f8 _pthread_start + 104
7   libsystem_pthread.dylib       	       0x104306940 thread_start + 8


Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2: 0x0000000000000000   x3: 0x0000000000000000
    x4: 0x00000001802b0dd7   x5: 0x000000016d0a86c0   x6: 0x000000000000006e   x7: 0x0000000000000000
    x8: 0x000000010312c200   x9: 0x03400a062f6ba288  x10: 0x0000000000000051  x11: 0x000000000000000b
   x12: 0x000000000000000b  x13: 0x00000001806c1dce  x14: 0x00000000000007fb  x15: 0x000000008c010054
   x16: 0x0000000000000148  x17: 0x000000008c20f84d  x18: 0x0000000000000000  x19: 0x0000000000000006
   x20: 0x0000000000000103  x21: 0x000000010312c2e0  x22: 0x00000000000f06ff  x23: 0x0000000000000114
   x24: 0x0000600001775800  x25: 0x0000600001775800  x26: 0x0000000000000000  x27: 0x0000000000000000
   x28: 0x0000000000000000   fp: 0x000000016d0a8630   lr: 0x000000010430b408
    sp: 0x000000016d0a8610   pc: 0x00000001039ad108 cpsr: 0x40000000
   far: 0x0000000000000000  esr: 0x56000080  Address size fault

Binary Images:
       0x10309c000 -        0x10311ffff dyld (*) <398a133c-9bcb-317f-a064-a40d3cea3c0f> /usr/lib/dyld
       0x102d54000 -        0x102d57fff com.rayclub.app (1.0.7) <458c427c-c0d4-3206-b2ca-4eca21f9c066> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Runner
       0x102f04000 -        0x102f47fff dyld_sim (*) <aca24c59-ce20-396e-8cae-200a0022fe6f> /Volumes/VOLUME/*/dyld_sim
       0x102df8000 -        0x102e13fff Runner.debug.dylib (*) <aa2f815e-47c7-3cf8-8189-a1c25aa2b399> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Runner.debug.dylib
       0x102ea8000 -        0x102ecffff org.cocoapods.AppAuth (1.7.6) <28071fab-5cca-3d4e-96dd-8d99c512901d> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/AppAuth.framework/AppAuth
       0x102fcc000 -        0x102feffff org.cocoapods.AppCheckCore (11.2.0) <46f5701d-d3e7-3fe7-8247-ea5fabf31930> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/AppCheckCore.framework/AppCheckCore
       0x102e48000 -        0x102e5bfff org.cocoapods.FBLPromises (2.4.0) <a77385af-c81e-34f5-aa1a-e497e686c34c> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/FBLPromises.framework/FBLPromises
       0x1031c4000 -        0x1031e7fff org.cocoapods.GTMAppAuth (4.1.1) <14723571-20a5-3db6-9d4f-41465771c2e7> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/GTMAppAuth.framework/GTMAppAuth
       0x1032bc000 -        0x10330ffff org.cocoapods.GTMSessionFetcher (3.5.0) <cf4eae98-f4f6-31be-9233-e87decce3567> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/GTMSessionFetcher.framework/GTMSessionFetcher
       0x103220000 -        0x103243fff org.cocoapods.GoogleSignIn (8.0.0) <4d187979-dc7f-3dc1-904e-cf8e34db04ea> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/GoogleSignIn.framework/GoogleSignIn
       0x102dd4000 -        0x102ddffff org.cocoapods.GoogleUtilities (8.1.0) <78e59970-2a63-352b-9756-ef4d71bc4966> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/GoogleUtilities.framework/GoogleUtilities
       0x103060000 -        0x10307bfff org.cocoapods.Mantle (2.2.0) <b08d859d-554b-3afe-b7e1-3ad4df1917b8> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/Mantle.framework/Mantle
       0x102dac000 -        0x102db7fff org.cocoapods.OrderedSet (6.0.3) <dad6e974-62ff-3867-8bef-e7bc2a3d7e2c> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/OrderedSet.framework/OrderedSet
       0x103458000 -        0x1034d7fff org.cocoapods.SDWebImage (5.21.0) <19760ae8-d611-3e86-a724-80aede3e7fdd> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/SDWebImage.framework/SDWebImage
       0x103024000 -        0x10302ffff org.cocoapods.SDWebImageWebPCoder (0.14.6) <8c113a38-bc00-37fb-ba60-3de2971369f0> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/SDWebImageWebPCoder.framework/SDWebImageWebPCoder
       0x103a10000 -        0x103c43fff org.cocoapods.Sentry (8.46.0) <6cc0e6e8-8b3b-357c-a7c8-378e8c833fff> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/Sentry.framework/Sentry
       0x103274000 -        0x10327bfff org.cocoapods.app-links (0.0.2) <28885cae-dae5-364f-845f-ee5bf03cbbab> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/app_links.framework/app_links
       0x103298000 -        0x10329ffff org.cocoapods.app-tracking-transparency (0.0.1) <16decbe3-522a-3ae7-a6a7-b3c4bb1a4706> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/app_tracking_transparency.framework/app_tracking_transparency
       0x103354000 -        0x10335ffff org.cocoapods.connectivity-plus (0.0.1) <2eb9c138-e4b5-3fa6-a6d6-650b0d5f874f> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/connectivity_plus.framework/connectivity_plus
       0x103048000 -        0x10304ffff org.cocoapods.device-info-plus (0.0.1) <87289257-efdd-3d93-aca5-ce19528adbb4> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/device_info_plus.framework/device_info_plus
       0x1033e8000 -        0x10340bfff org.cocoapods.flutter-image-compress-common (1.0.0) <79dddc43-33af-3e30-8378-01a6afedadc3> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/flutter_image_compress_common.framework/flutter_image_compress_common
       0x103ed0000 -        0x104083fff org.cocoapods.flutter-inappwebview-ios (0.0.1) <426cb5e9-393d-390d-9d8d-c3098fd91be6> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/flutter_inappwebview_ios.framework/flutter_inappwebview_ios
       0x102e94000 -        0x102e97fff org.cocoapods.flutter-keyboard-visibility (0.0.1) <70a42d32-7d4e-3d64-9099-6a17380663e1> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/flutter_keyboard_visibility.framework/flutter_keyboard_visibility
       0x1033a8000 -        0x1033b7fff org.cocoapods.flutter-local-notifications (0.0.1) <fbc84e44-c15e-3747-a060-08fdd250cbc2> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/flutter_local_notifications.framework/flutter_local_notifications
       0x10337c000 -        0x10337ffff org.cocoapods.flutter-native-splash (2.4.3) <31b3e28b-1aa4-3760-a64b-1ff179459ddd> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/flutter_native_splash.framework/flutter_native_splash
       0x103598000 -        0x1035abfff org.cocoapods.flutter-secure-storage-darwin (10.0.0) <2b358790-2f78-32f9-9d7e-fc81e9c3b677> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/flutter_secure_storage_darwin.framework/flutter_secure_storage_darwin
       0x103688000 -        0x1036e3fff org.cocoapods.health (12.2.0) <640a1db6-f241-32ea-a592-a097de310943> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/health.framework/health
       0x1035d4000 -        0x1035e7fff org.cocoapods.image-picker-ios (0.0.1) <26f5577d-4190-3a07-b61f-bac2d445973b> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/image_picker_ios.framework/image_picker_ios
       0x102e7c000 -        0x102e7ffff org.cocoapods.integration-test (0.0.1) <8ee5b8a5-90c5-3e2e-bad8-404a93a2e6e6> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/integration_test.framework/integration_test
       0x103830000 -        0x1038d7fff org.cocoapods.libwebp (1.5.0) <61293783-b9ec-3648-9ec3-b2c238eb75cc> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/libwebp.framework/libwebp
       0x1033d0000 -        0x1033d3fff org.cocoapods.package-info-plus (0.4.5) <a06c85c2-1707-3c48-b762-8097d6bebdaf> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/package_info_plus.framework/package_info_plus
       0x103608000 -        0x103613fff org.cocoapods.path-provider-foundation (0.0.1) <5bffadd2-1bc4-383d-bcf5-b683655b7cf5> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/path_provider_foundation.framework/path_provider_foundation
       0x103738000 -        0x10375bfff org.cocoapods.sentry-flutter (8.14.2) <b95ff537-dbc5-3f9a-9035-2c3649946cc4> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/sentry_flutter.framework/sentry_flutter
       0x103578000 -        0x10357ffff org.cocoapods.share-plus (0.0.1) <f67510a4-efb0-3750-a956-620ac5c6130f> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/share_plus.framework/share_plus
       0x103784000 -        0x103797fff org.cocoapods.shared-preferences-foundation (0.0.1) <9b15855f-7805-3fde-a8d5-3e9ce0dcd039> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/shared_preferences_foundation.framework/shared_preferences_foundation
       0x1037bc000 -        0x1037cbfff org.cocoapods.sign-in-with-apple (0.0.1) <c3657637-fa0a-37f9-b258-5450f204a99a> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/sign_in_with_apple.framework/sign_in_with_apple
       0x103924000 -        0x103943fff org.cocoapods.sqflite-darwin (0.0.4) <1934506b-b98c-39a6-b6e3-262944f442c9> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/sqflite_darwin.framework/sqflite_darwin
       0x103558000 -        0x10355bfff org.cocoapods.uni-links (0.0.1) <5100a33f-bdfb-3239-80ff-4177a07e9f5f> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/uni_links.framework/uni_links
       0x1037f0000 -        0x103803fff org.cocoapods.url-launcher-ios (0.0.1) <9a6f911b-92fe-3749-ac05-8cb10fa37569> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/url_launcher_ios.framework/url_launcher_ios
       0x10396c000 -        0x103983fff org.cocoapods.video-player-avfoundation (0.0.1) <2b90b308-e60f-370a-bf52-3c8e244a4283> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/video_player_avfoundation.framework/video_player_avfoundation
       0x107300000 -        0x10953bfff io.flutter.flutter (1.0) <4c4c449b-5555-3144-a1d8-b121c05741e4> /Users/USER/Library/Developer/CoreSimulator/Devices/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5/data/Containers/Bundle/Application/D58B140C-81D8-491E-98B5-63E37828087E/Runner.app/Frameworks/Flutter.framework/Flutter
       0x103630000 -        0x103637fff libsystem_platform.dylib (*) <44654135-5ba7-3ea2-b7ef-f77ad1cb1980> /usr/lib/system/libsystem_platform.dylib
       0x1039a4000 -        0x1039dffff libsystem_kernel.dylib (*) <5ea2a242-9786-3af8-b8a9-7899ecc711c8> /usr/lib/system/libsystem_kernel.dylib
       0x104304000 -        0x104313fff libsystem_pthread.dylib (*) <53372391-80ee-3a52-85d2-b0d39816a60b> /usr/lib/system/libsystem_pthread.dylib
       0x1042f0000 -        0x1042fbfff libobjc-trampolines.dylib (*) <a2df0cb8-60af-32a5-8c75-9274d09bdff8> /Volumes/VOLUME/*/libobjc-trampolines.dylib
       0x1800fd000 -        0x180178ff3 libsystem_c.dylib (*) <c2be3ea9-bf05-3c11-b0ff-90fbaad68c1c> /Volumes/VOLUME/*/libsystem_c.dylib
       0x180298000 -        0x1802b3fff libc++abi.dylib (*) <9addd5ea-5408-3940-802a-70436345aa2d> /Volumes/VOLUME/*/libc++abi.dylib
       0x180068000 -        0x1800a3d53 libobjc.A.dylib (*) <a6716887-054e-32ee-8b87-a87811aa3599> /Volumes/VOLUME/*/libobjc.A.dylib
       0x180179000 -        0x1801bdfff libdispatch.dylib (*) <ef0492a6-8ca5-38f0-97bb-df9bdb54c17a> /Volumes/VOLUME/*/libdispatch.dylib
       0x18038d000 -        0x18075afff com.apple.CoreFoundation (6.9) <6fc1e779-5846-3275-bf66-955738404cf6> /Volumes/VOLUME/*/CoreFoundation.framework/CoreFoundation
       0x190601000 -        0x190609fff com.apple.GraphicsServices (1.0) <3126e74d-fd21-3b05-9124-3b2fcf5db07a> /Volumes/VOLUME/*/GraphicsServices.framework/GraphicsServices
       0x184cd9000 -        0x186a19fff com.apple.UIKitCore (1.0) <e83e0347-27d7-34bd-b0d3-51666dfdfd76> /Volumes/VOLUME/*/UIKitCore.framework/UIKitCore
               0x0 - 0xffffffffffffffff ??? (*) <00000000-0000-0000-0000-000000000000> ???
       0x1807da000 -        0x181416fff com.apple.Foundation (6.9) <cf6b28c4-9795-362a-b563-7b1b8c116282> /Volumes/VOLUME/*/Foundation.framework/Foundation
       0x184800000 -        0x184b81fff com.apple.CFNetwork (1.0) <4a0921b7-6bd8-3dd0-a7b0-17d82dbbc75a> /Volumes/VOLUME/*/CFNetwork.framework/CFNetwork

EOF

-----------
Full Report
-----------

{"app_name":"Runner","timestamp":"2025-05-23 00:12:10.00 -0300","app_version":"1.0.7","slice_uuid":"458c427c-c0d4-3206-b2ca-4eca21f9c066","build_version":"13","platform":7,"bundleID":"com.rayclub.app","share_with_app_devs":1,"is_first_party":0,"bug_type":"309","os_version":"macOS 15.3.1 (24D70)","roots_installed":0,"name":"Runner","incident_id":"7AD55DBC-F4C4-4091-A441-846E7659A9AE"}
{
  "uptime" : 1100000,
  "procRole" : "Foreground",
  "version" : 2,
  "userID" : 501,
  "deployVersion" : 210,
  "modelCode" : "Mac16,7",
  "coalitionID" : 967,
  "osVersion" : {
    "train" : "macOS 15.3.1",
    "build" : "24D70",
    "releaseType" : "User"
  },
  "captureTime" : "2025-05-23 00:12:10.0073 -0300",
  "codeSigningMonitor" : 2,
  "incident" : "7AD55DBC-F4C4-4091-A441-846E7659A9AE",
  "pid" : 60148,
  "translated" : false,
  "cpuType" : "ARM-64",
  "roots_installed" : 0,
  "bug_type" : "309",
  "procLaunch" : "2025-05-23 00:12:05.0920 -0300",
  "procStartAbsTime" : 26509241083792,
  "procExitAbsTime" : 26509359033337,
  "procName" : "Runner",
  "procPath" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Runner",
  "bundleInfo" : {"CFBundleShortVersionString":"1.0.7","CFBundleVersion":"13","CFBundleIdentifier":"com.rayclub.app"},
  "storeInfo" : {"deviceIdentifierForVendor":"698618D5-A004-5A9B-970F-E41F1618B273","thirdParty":true},
  "parentProc" : "launchd_sim",
  "parentPid" : 814,
  "coalitionName" : "com.apple.CoreSimulator.SimDevice.3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5",
  "crashReporterKey" : "8C303817-D8A4-7D9B-CE72-7D6A64AAEC09",
  "responsiblePid" : 789,
  "responsibleProc" : "SimulatorTrampoline",
  "codeSigningID" : "com.rayclub.app",
  "codeSigningTeamID" : "",
  "codeSigningFlags" : 570425857,
  "codeSigningValidationCategory" : 10,
  "codeSigningTrustLevel" : 4294967295,
  "instructionByteStream" : {"beforePC":"4wAAVP17v6n9AwCR+OL\/l78DAJH9e8GowANf1sADX9YQKYDSARAA1A==","atPC":"4wAAVP17v6n9AwCR7uL\/l78DAJH9e8GowANf1sADX9ZwCoDSARAA1A=="},
  "bootSessionUUID" : "C42803CE-4117-4394-B6E5-EC2F155250DF",
  "wakeTime" : 7156,
  "sleepWakeUUID" : "118A7F56-41A1-4491-90CB-481E8FFEFB93",
  "sip" : "enabled",
  "exception" : {"codes":"0x0000000000000000, 0x0000000000000000","rawCodes":[0,0],"type":"EXC_CRASH","signal":"SIGABRT"},
  "termination" : {"flags":0,"code":6,"namespace":"SIGNAL","indicator":"Abort trap: 6","byProc":"Runner","byPid":60148},
  "extMods" : {"caller":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"system":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"targeted":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"warnings":0},
  "lastExceptionBacktrace" : [{"imageOffset":1229056,"symbol":"__exceptionPreprocess","symbolLocation":160,"imageIndex":49},{"imageOffset":175528,"symbol":"objc_exception_throw","symbolLocation":72,"imageIndex":47},{"imageOffset":1228828,"symbol":"-[NSException initWithCoder:]","symbolLocation":0,"imageIndex":49},{"imageOffset":66052,"sourceLine":592,"sourceFile":"GIDSignIn.m","symbol":"-[GIDSignIn signInWithOptions:]","imageIndex":9,"symbolLocation":444},{"imageOffset":60304,"sourceLine":282,"sourceFile":"GIDSignIn.m","symbol":"-[GIDSignIn signInWithPresentingViewController:hint:additionalScopes:completion:]","imageIndex":9,"symbolLocation":208},{"imageOffset":45224,"symbol":"-[FLTGoogleSignInPlugin signInWithHint:additionalScopes:completion:]","symbolLocation":176,"imageIndex":3},{"imageOffset":41492,"symbol":"-[FLTGoogleSignInPlugin signInWithCompletion:]","symbolLocation":732,"imageIndex":3},{"imageOffset":62084,"symbol":"__FSIGoogleSignInApiSetup_block_invoke.119","symbolLocation":184,"imageIndex":3},{"imageOffset":6449328,"symbol":"__48-[FlutterBasicMessageChannel setMessageHandler:]_block_invoke","symbolLocation":160,"imageIndex":40},{"imageOffset":394360,"symbol":"invocation function for block in flutter::PlatformMessageHandlerIos::HandlePlatformMessage(std::_fl::unique_ptr<flutter::PlatformMessage, std::_fl::default_delete<flutter::PlatformMessage>>)","symbolLocation":108,"imageIndex":40},{"imageOffset":8980,"symbol":"_dispatch_call_block_and_release","symbolLocation":24,"imageIndex":48},{"imageOffset":15368,"symbol":"_dispatch_client_callout","symbolLocation":16,"imageIndex":48},{"imageOffset":76844,"symbol":"_dispatch_main_queue_drain","symbolLocation":1276,"imageIndex":48},{"imageOffset":75552,"symbol":"_dispatch_main_queue_callback_4CF","symbolLocation":40,"imageIndex":48},{"imageOffset":589244,"symbol":"__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__","symbolLocation":12,"imageIndex":49},{"imageOffset":566040,"symbol":"__CFRunLoopRun","symbolLocation":1944,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":15120,"symbol":"GSEventRunModal","symbolLocation":160,"imageIndex":50},{"imageOffset":15073664,"symbol":"-[UIApplication _run]","symbolLocation":796,"imageIndex":51},{"imageOffset":15090552,"symbol":"UIApplicationMain","symbolLocation":124,"imageIndex":51},{"imageOffset":2321108,"imageIndex":51},{"imageOffset":27584,"sourceFile":"\/<compiler-generated>","symbol":"static UIApplicationDelegate.main()","symbolLocation":120,"imageIndex":3},{"imageOffset":27448,"sourceFile":"\/<compiler-generated>","symbol":"static AppDelegate.$main()","symbolLocation":44,"imageIndex":3},{"imageOffset":27708,"sourceLine":6,"sourceFile":"AppDelegate.swift","symbol":"__debug_main_executable_dylib_entry_point","imageIndex":3,"symbolLocation":28},{"imageOffset":5136,"symbol":"start_sim","symbolLocation":20,"imageIndex":2},{"imageOffset":25204,"symbol":"start","symbolLocation":2840,"imageIndex":0},{"imageOffset":17667199125709389824,"imageIndex":52}],
  "faultingThread" : 0,
  "threads" : [{"triggered":true,"id":36699530,"threadState":{"x":[{"value":0},{"value":0},{"value":0},{"value":0},{"value":6445272535},{"value":6124373696},{"value":110},{"value":0},{"value":4346528256,"symbolLocation":0,"symbol":"_main_thread"},{"value":234198202304930440},{"value":81},{"value":11},{"value":11},{"value":6449536462},{"value":2043},{"value":2348875860},{"value":328},{"value":2350970957},{"value":0},{"value":6},{"value":259},{"value":4346528480,"symbolLocation":224,"symbol":"_main_thread"},{"value":984831},{"value":276},{"value":105553140865024},{"value":105553140865024},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365267976},"cpsr":{"value":1073741824},"fp":{"value":6124373552},"sp":{"value":6124373520},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355445000,"matchesCrashFrame":1},"far":{"value":0}},"queue":"com.apple.main-thread","frames":[{"imageOffset":37128,"symbol":"__pthread_kill","symbolLocation":8,"imageIndex":42},{"imageOffset":29704,"symbol":"pthread_kill","symbolLocation":256,"imageIndex":43},{"imageOffset":472300,"symbol":"abort","symbolLocation":104,"imageIndex":45},{"imageOffset":86272,"symbol":"abort_message","symbolLocation":128,"imageIndex":46},{"imageOffset":19204,"symbol":"demangling_terminate_handler()","symbolLocation":300,"imageIndex":46},{"imageOffset":30892,"symbol":"_objc_terminate()","symbolLocation":124,"imageIndex":47},{"imageOffset":277232,"sourceLine":127,"sourceFile":"SentryCrashMonitor_CPPException.cpp","symbol":"sentrycrashcm_cppexception_callOriginalTerminationHandler","imageIndex":15,"symbolLocation":44},{"imageOffset":279720,"sourceLine":210,"sourceFile":"SentryCrashMonitor_CPPException.cpp","symbol":"CPPExceptionTerminate()","imageIndex":15,"symbolLocation":2188},{"imageOffset":83160,"symbol":"std::__terminate(void (*)())","symbolLocation":12,"imageIndex":46},{"imageOffset":83080,"symbol":"std::terminate()","symbolLocation":52,"imageIndex":46},{"imageOffset":15388,"symbol":"_dispatch_client_callout","symbolLocation":36,"imageIndex":48},{"imageOffset":76844,"symbol":"_dispatch_main_queue_drain","symbolLocation":1276,"imageIndex":48},{"imageOffset":75552,"symbol":"_dispatch_main_queue_callback_4CF","symbolLocation":40,"imageIndex":48},{"imageOffset":589244,"symbol":"__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__","symbolLocation":12,"imageIndex":49},{"imageOffset":566040,"symbol":"__CFRunLoopRun","symbolLocation":1944,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":15120,"symbol":"GSEventRunModal","symbolLocation":160,"imageIndex":50},{"imageOffset":15073664,"symbol":"-[UIApplication _run]","symbolLocation":796,"imageIndex":51},{"imageOffset":15090552,"symbol":"UIApplicationMain","symbolLocation":124,"imageIndex":51},{"imageOffset":2321108,"imageIndex":51},{"imageOffset":27584,"sourceFile":"\/<compiler-generated>","symbol":"static UIApplicationDelegate.main()","symbolLocation":120,"imageIndex":3},{"imageOffset":27448,"sourceFile":"\/<compiler-generated>","symbol":"static AppDelegate.$main()","symbolLocation":44,"imageIndex":3},{"imageOffset":27708,"sourceLine":6,"sourceFile":"AppDelegate.swift","symbol":"__debug_main_executable_dylib_entry_point","imageIndex":3,"symbolLocation":28},{"imageOffset":5136,"symbol":"start_sim","symbolLocation":20,"imageIndex":2},{"imageOffset":25204,"symbol":"start","symbolLocation":2840,"imageIndex":0}]},{"id":36699535,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6124941312},{"value":6407},{"value":6124404736},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6124941312},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699536,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6125514752},{"value":3587},{"value":6124978176},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6125514752},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699537,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6126088192},{"value":4099},{"value":6125551616},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6126088192},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699538,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6126661632},{"value":8451},{"value":6126125056},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6126661632},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699539,"name":"com.apple.uikit.eventfetch-thread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":68182605824000},{"value":0},{"value":68182605824000},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":2},{"value":0},{"value":0},{"value":0},{"value":15875},{"value":3072},{"value":0},{"value":18446744073709551569},{"value":2},{"value":0},{"value":4294967295},{"value":2},{"value":68182605824000},{"value":0},{"value":68182605824000},{"value":6127230328},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":0},"fp":{"value":6127230176},"sp":{"value":6127230096},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":38132,"symbol":"mach_msg_overwrite","symbolLocation":536,"imageIndex":42},{"imageOffset":5836,"symbol":"mach_msg","symbolLocation":20,"imageIndex":42},{"imageOffset":588512,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":49},{"imageOffset":565256,"symbol":"__CFRunLoopRun","symbolLocation":1160,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":7623824,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":208,"imageIndex":53},{"imageOffset":7624368,"symbol":"-[NSRunLoop(NSRunLoop) runUntilDate:]","symbolLocation":60,"imageIndex":53},{"imageOffset":15784500,"symbol":"-[UIEventFetcher threadMain]","symbolLocation":404,"imageIndex":51},{"imageOffset":7783128,"symbol":"__NSThread__start__","symbolLocation":720,"imageIndex":53},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699540,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6127808512},{"value":12803},{"value":6127271936},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6127808512},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699541,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6128381952},{"value":21251},{"value":6127845376},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6128381952},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699542,"frames":[{"imageOffset":10540,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":43}],"threadState":{"x":[{"value":6128955392},{"value":20995},{"value":6128418816},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":0},"fp":{"value":0},"sp":{"value":6128955392},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4365248812},"far":{"value":0}}},{"id":36699544,"name":"io.flutter.1.raster","threadState":{"x":[{"value":0},{"value":21592279046},{"value":8589934592},{"value":103366977912832},{"value":0},{"value":103366977912832},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":2},{"value":0},{"value":0},{"value":0},{"value":24067},{"value":3072},{"value":0},{"value":18446744073709551569},{"value":1099511628034},{"value":0},{"value":4294967295},{"value":2},{"value":103366977912832},{"value":0},{"value":103366977912832},{"value":6131097592},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":0},"fp":{"value":6131097440},"sp":{"value":6131097360},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":38132,"symbol":"mach_msg_overwrite","symbolLocation":536,"imageIndex":42},{"imageOffset":5836,"symbol":"mach_msg","symbolLocation":20,"imageIndex":42},{"imageOffset":588512,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":49},{"imageOffset":565256,"symbol":"__CFRunLoopRun","symbolLocation":1160,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":574876,"symbol":"fml::MessageLoopDarwin::Run()","symbolLocation":88,"imageIndex":40},{"imageOffset":545608,"symbol":"fml::MessageLoopImpl::DoRun()","symbolLocation":40,"imageIndex":40},{"imageOffset":569912,"symbol":"std::_fl::__function::__func<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0, std::_fl::allocator<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0>, void ()>::operator()()","symbolLocation":184,"imageIndex":40},{"imageOffset":569156,"symbol":"fml::ThreadHandle::ThreadHandle(std::_fl::function<void ()>&&)::$_0::__invoke(void*)","symbolLocation":36,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699545,"name":"io.flutter.1.io","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":109964047679488},{"value":0},{"value":109964047679488},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":2},{"value":0},{"value":0},{"value":0},{"value":25603},{"value":3072},{"value":0},{"value":18446744073709551569},{"value":1099511628034},{"value":0},{"value":4294967295},{"value":2},{"value":109964047679488},{"value":0},{"value":109964047679488},{"value":6133243896},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":0},"fp":{"value":6133243744},"sp":{"value":6133243664},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":38132,"symbol":"mach_msg_overwrite","symbolLocation":536,"imageIndex":42},{"imageOffset":5836,"symbol":"mach_msg","symbolLocation":20,"imageIndex":42},{"imageOffset":588512,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":49},{"imageOffset":565256,"symbol":"__CFRunLoopRun","symbolLocation":1160,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":574876,"symbol":"fml::MessageLoopDarwin::Run()","symbolLocation":88,"imageIndex":40},{"imageOffset":545608,"symbol":"fml::MessageLoopImpl::DoRun()","symbolLocation":40,"imageIndex":40},{"imageOffset":569912,"symbol":"std::_fl::__function::__func<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0, std::_fl::allocator<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0>, void ()>::operator()()","symbolLocation":184,"imageIndex":40},{"imageOffset":569156,"symbol":"fml::ThreadHandle::ThreadHandle(std::_fl::function<void ()>&&)::$_0::__invoke(void*)","symbolLocation":36,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699546,"name":"io.flutter.1.profiler","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":123158187212800},{"value":0},{"value":123158187212800},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":2},{"value":0},{"value":0},{"value":0},{"value":28675},{"value":3072},{"value":0},{"value":18446744073709551569},{"value":2},{"value":0},{"value":4294967295},{"value":2},{"value":123158187212800},{"value":0},{"value":123158187212800},{"value":6135390200},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":0},"fp":{"value":6135390048},"sp":{"value":6135389968},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":38132,"symbol":"mach_msg_overwrite","symbolLocation":536,"imageIndex":42},{"imageOffset":5836,"symbol":"mach_msg","symbolLocation":20,"imageIndex":42},{"imageOffset":588512,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":49},{"imageOffset":565256,"symbol":"__CFRunLoopRun","symbolLocation":1160,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":574876,"symbol":"fml::MessageLoopDarwin::Run()","symbolLocation":88,"imageIndex":40},{"imageOffset":545608,"symbol":"fml::MessageLoopImpl::DoRun()","symbolLocation":40,"imageIndex":40},{"imageOffset":569912,"symbol":"std::_fl::__function::__func<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0, std::_fl::allocator<fml::Thread::Thread(std::_fl::function<void (fml::Thread::ThreadConfig const&)> const&, fml::Thread::ThreadConfig const&)::$_0>, void ()>::operator()()","symbolLocation":184,"imageIndex":40},{"imageOffset":569156,"symbol":"fml::ThreadHandle::ThreadHandle(std::_fl::function<void ()>&&)::$_0::__invoke(void*)","symbolLocation":36,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699547,"name":"io.worker.1","threadState":{"x":[{"value":4},{"value":0},{"value":8448},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6135967224},{"value":0},{"value":256},{"value":1099511628034},{"value":1099511628034},{"value":256},{"value":0},{"value":1099511628032},{"value":305},{"value":212},{"value":0},{"value":4368405688},{"value":4368405752},{"value":6135967968},{"value":0},{"value":0},{"value":8448},{"value":8448},{"value":9472},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270168},"cpsr":{"value":1610612736},"fp":{"value":6135967344},"sp":{"value":6135967200},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31896,"symbol":"_pthread_cond_wait","symbolLocation":1192,"imageIndex":43},{"imageOffset":408284,"symbol":"std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&)","symbolLocation":24,"imageIndex":40},{"imageOffset":530296,"symbol":"fml::ConcurrentMessageLoop::WorkerMain()","symbolLocation":128,"imageIndex":40},{"imageOffset":532560,"symbol":"void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*)","symbolLocation":184,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699548,"name":"io.worker.2","threadState":{"x":[{"value":4},{"value":0},{"value":9216},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6136540664},{"value":0},{"value":256},{"value":1099511628034},{"value":1099511628034},{"value":256},{"value":0},{"value":1099511628032},{"value":305},{"value":109},{"value":0},{"value":4368405688},{"value":4368405752},{"value":6136541408},{"value":0},{"value":0},{"value":9216},{"value":9216},{"value":10240},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270168},"cpsr":{"value":1610612736},"fp":{"value":6136540784},"sp":{"value":6136540640},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31896,"symbol":"_pthread_cond_wait","symbolLocation":1192,"imageIndex":43},{"imageOffset":408284,"symbol":"std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&)","symbolLocation":24,"imageIndex":40},{"imageOffset":530296,"symbol":"fml::ConcurrentMessageLoop::WorkerMain()","symbolLocation":128,"imageIndex":40},{"imageOffset":532560,"symbol":"void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*)","symbolLocation":184,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699549,"name":"io.worker.3","threadState":{"x":[{"value":4},{"value":0},{"value":8704},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6137114104},{"value":0},{"value":256},{"value":1099511628034},{"value":1099511628034},{"value":256},{"value":0},{"value":1099511628032},{"value":305},{"value":127},{"value":0},{"value":4368405688},{"value":4368405752},{"value":6137114848},{"value":0},{"value":0},{"value":8704},{"value":8704},{"value":9728},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270168},"cpsr":{"value":1610612736},"fp":{"value":6137114224},"sp":{"value":6137114080},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31896,"symbol":"_pthread_cond_wait","symbolLocation":1192,"imageIndex":43},{"imageOffset":408284,"symbol":"std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&)","symbolLocation":24,"imageIndex":40},{"imageOffset":530296,"symbol":"fml::ConcurrentMessageLoop::WorkerMain()","symbolLocation":128,"imageIndex":40},{"imageOffset":532560,"symbol":"void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*)","symbolLocation":184,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699550,"name":"io.worker.4","threadState":{"x":[{"value":260},{"value":0},{"value":9216},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6137687544},{"value":0},{"value":256},{"value":1099511628034},{"value":1099511628034},{"value":256},{"value":0},{"value":1099511628032},{"value":305},{"value":19},{"value":0},{"value":4368405688},{"value":4368405752},{"value":6137688288},{"value":0},{"value":0},{"value":9216},{"value":9216},{"value":9984},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270168},"cpsr":{"value":1610612736},"fp":{"value":6137687664},"sp":{"value":6137687520},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31896,"symbol":"_pthread_cond_wait","symbolLocation":1192,"imageIndex":43},{"imageOffset":408284,"symbol":"std::_fl::condition_variable::wait(std::_fl::unique_lock<std::_fl::mutex>&)","symbolLocation":24,"imageIndex":40},{"imageOffset":530296,"symbol":"fml::ConcurrentMessageLoop::WorkerMain()","symbolLocation":128,"imageIndex":40},{"imageOffset":532560,"symbol":"void* std::_fl::__thread_proxy[abi:v15000]<std::_fl::tuple<std::_fl::unique_ptr<std::_fl::__thread_struct, std::_fl::default_delete<std::_fl::__thread_struct>>, fml::ConcurrentMessageLoop::ConcurrentMessageLoop(unsigned long)::$_0>>(void*)","symbolLocation":184,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699551,"name":"dart:io EventHandler","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":6138785048},{"value":16},{"value":6138784008},{"value":0},{"value":0},{"value":865000000},{"value":5},{"value":6443492832,"symbolLocation":284,"symbol":"clock_gettime_nsec_np"},{"value":0},{"value":0},{"value":2045},{"value":3206301750},{"value":3204202507},{"value":363},{"value":54},{"value":0},{"value":105553156153216},{"value":6138784008},{"value":67108864},{"value":2147483647},{"value":274877907},{"value":4294966296},{"value":1000000},{"value":4189580502},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4421723684},"cpsr":{"value":536870912},"fp":{"value":6138785648},"sp":{"value":6138783984},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355436164},"far":{"value":0}},"frames":[{"imageOffset":28292,"symbol":"kevent","symbolLocation":8,"imageIndex":42},{"imageOffset":6170148,"symbol":"dart::bin::EventHandlerImplementation::EventHandlerEntry(unsigned long)","symbolLocation":300,"imageIndex":40},{"imageOffset":6285488,"symbol":"dart::bin::ThreadStart(void*)","symbolLocation":88,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699552,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":77056},{"value":0},{"value":0},{"value":160},{"value":4},{"value":106384000},{"value":77057},{"value":0},{"value":512},{"value":2199023256066},{"value":2199023256066},{"value":512},{"value":0},{"value":2199023256064},{"value":305},{"value":171},{"value":0},{"value":4369450168},{"value":105553156168592},{"value":1},{"value":106384000},{"value":4},{"value":77056},{"value":77057},{"value":77312},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6139882048},"sp":{"value":6139881904},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699556,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":147},{"value":0},{"value":4366287528},{"value":105553156113968},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6140979776},"sp":{"value":6140979632},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699557,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":1792},{"value":0},{"value":0},{"value":160},{"value":61},{"value":0},{"value":1793},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":401},{"value":0},{"value":4368416120},{"value":105553156179120},{"value":1},{"value":0},{"value":61},{"value":1792},{"value":1793},{"value":2048},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6142077424},"sp":{"value":6142077280},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":6987720,"symbol":"dart::MutatorThreadPool::OnEnterIdleLocked(dart::MutexLocker*, dart::ThreadPool::Worker*)","symbolLocation":152,"imageIndex":40},{"imageOffset":8026240,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":124,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699558,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":69120},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":69121},{"value":0},{"value":512},{"value":2199023256066},{"value":2199023256066},{"value":512},{"value":0},{"value":2199023256064},{"value":305},{"value":310},{"value":0},{"value":4369450168},{"value":105553156140432},{"value":1},{"value":0},{"value":5},{"value":69120},{"value":69121},{"value":69376},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6143175232},"sp":{"value":6143175088},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699561,"frames":[{"imageOffset":18012,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":42},{"imageOffset":460252,"symbol":"nanosleep","symbolLocation":216,"imageIndex":45},{"imageOffset":459736,"symbol":"sleep","symbolLocation":48,"imageIndex":45},{"imageOffset":198148,"sourceLine":146,"sourceFile":"SentryCrashCachedData.c","symbol":"monitorCachedData","imageIndex":15,"symbolLocation":136},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":60},{"value":0},{"value":52},{"value":0},{"value":8320217884,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":637648},{"value":4367319040},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4367725390},{"value":0},{"value":6143750000},{"value":6143750016},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6443947484},"cpsr":{"value":1610612736},"fp":{"value":6143749984},"sp":{"value":6143749936},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355425884},"far":{"value":0}}},{"id":36699562,"name":"SentryCrash Exception Handler (Secondary)","threadState":{"x":[{"value":0},{"value":8589934595},{"value":103079220499},{"value":157243047710723},{"value":15483357102080},{"value":157243047673856},{"value":44},{"value":0},{"value":18446744073709550527},{"value":4355686400,"symbolLocation":0,"symbol":"_current_pid"},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551569},{"value":0},{"value":0},{"value":0},{"value":44},{"value":157243047673856},{"value":15483357102080},{"value":157243047710723},{"value":6144321472},{"value":103079220499},{"value":8589934595},{"value":8589934595},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":2147483648},"fp":{"value":6144321456},"sp":{"value":6144321376},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":189468,"symbol":"thread_suspend","symbolLocation":104,"imageIndex":42},{"imageOffset":281544,"sourceLine":305,"sourceFile":"SentryCrashMonitor_MachException.c","symbol":"handleExceptions","imageIndex":15,"symbolLocation":140},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699563,"name":"SentryCrash Exception Handler (Primary)","threadState":{"x":[{"value":268451845},{"value":17179869186},{"value":0},{"value":0},{"value":0},{"value":159442070929408},{"value":580},{"value":0},{"value":18446744073709550527},{"value":580},{"value":0},{"value":0},{"value":0},{"value":37123},{"value":580},{"value":0},{"value":18446744073709551569},{"value":0},{"value":0},{"value":0},{"value":580},{"value":159442070929408},{"value":0},{"value":0},{"value":6144896356},{"value":0},{"value":17179869186},{"value":17179869186},{"value":2}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":0},"fp":{"value":6144894656},"sp":{"value":6144894576},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":38132,"symbol":"mach_msg_overwrite","symbolLocation":536,"imageIndex":42},{"imageOffset":5836,"symbol":"mach_msg","symbolLocation":20,"imageIndex":42},{"imageOffset":281600,"sourceLine":313,"sourceFile":"SentryCrashMonitor_MachException.c","symbol":"handleExceptions","imageIndex":15,"symbolLocation":196},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699564,"name":"io.sentry.app-hang-tracker","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":400000000},{"value":0},{"value":0},{"value":8320217884,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":7},{"value":7},{"value":105553162621920},{"value":8320426792,"symbolLocation":0,"symbol":"OBJC_METACLASS_$_NSThread"},{"value":8320426792,"symbolLocation":0,"symbol":"OBJC_METACLASS_$_NSThread"},{"value":334},{"value":6458461140,"symbolLocation":0,"symbol":"+[NSThread sleepForTimeInterval:]"},{"value":0},{"value":0},{"value":6145468784},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6443947484},"cpsr":{"value":2684354560},"fp":{"value":6145468736},"sp":{"value":6145468688},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355425884},"far":{"value":0}},"frames":[{"imageOffset":18012,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":42},{"imageOffset":460252,"symbol":"nanosleep","symbolLocation":216,"imageIndex":45},{"imageOffset":7777392,"symbol":"+[NSThread sleepForTimeInterval:]","symbolLocation":156,"imageIndex":53},{"imageOffset":1012180,"sourceLine":10,"sourceFile":"SentryThreadWrapper.m","symbol":"-[SentryThreadWrapper sleepForTimeInterval:]","imageIndex":15,"symbolLocation":44},{"imageOffset":34092,"sourceLine":105,"sourceFile":"SentryANRTrackerV1.m","symbol":"-[SentryANRTrackerV1 detectANRs]","imageIndex":15,"symbolLocation":1112},{"imageOffset":7783128,"symbol":"__NSThread__start__","symbolLocation":720,"imageIndex":53},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699566,"name":"com.apple.NSURLConnectionLoader","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":272691768590336},{"value":0},{"value":272691768590336},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":2},{"value":0},{"value":0},{"value":0},{"value":63491},{"value":3072},{"value":0},{"value":18446744073709551569},{"value":2},{"value":0},{"value":4294967295},{"value":2},{"value":272691768590336},{"value":0},{"value":272691768590336},{"value":6146039096},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4355483360},"cpsr":{"value":0},"fp":{"value":6146038944},"sp":{"value":6146038864},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355412880},"far":{"value":0}},"frames":[{"imageOffset":5008,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":42},{"imageOffset":75488,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":42},{"imageOffset":38132,"symbol":"mach_msg_overwrite","symbolLocation":536,"imageIndex":42},{"imageOffset":5836,"symbol":"mach_msg","symbolLocation":20,"imageIndex":42},{"imageOffset":588512,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":49},{"imageOffset":565256,"symbol":"__CFRunLoopRun","symbolLocation":1160,"imageIndex":49},{"imageOffset":562948,"symbol":"CFRunLoopRunSpecific","symbolLocation":552,"imageIndex":49},{"imageOffset":2137316,"symbol":"+[__CFN_CoreSchedulingSetRunnable _run:]","symbolLocation":372,"imageIndex":54},{"imageOffset":7783128,"symbol":"__NSThread__start__","symbolLocation":720,"imageIndex":53},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699567,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":768},{"value":0},{"value":0},{"value":160},{"value":61},{"value":0},{"value":769},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":177},{"value":0},{"value":4367458088},{"value":105553156173680},{"value":1},{"value":0},{"value":61},{"value":768},{"value":769},{"value":1024},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6147140080},"sp":{"value":6147139936},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":6987720,"symbol":"dart::MutatorThreadPool::OnEnterIdleLocked(dart::MutexLocker*, dart::ThreadPool::Worker*)","symbolLocation":152,"imageIndex":40},{"imageOffset":8026240,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":124,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699568,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":768},{"value":0},{"value":0},{"value":160},{"value":3},{"value":742723000},{"value":769},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":3296018673},{"value":0},{"value":4367458088},{"value":105553156117520},{"value":1},{"value":742723000},{"value":3},{"value":768},{"value":769},{"value":1024},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6148237888},"sp":{"value":6148237744},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699570,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":13312},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":13313},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":165},{"value":0},{"value":4368474104},{"value":105553156170032},{"value":1},{"value":0},{"value":5},{"value":13312},{"value":13313},{"value":13568},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6149335616},"sp":{"value":6149335472},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699571,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":60672},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":60673},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":41},{"value":0},{"value":4368474104},{"value":105553156179216},{"value":1},{"value":0},{"value":5},{"value":60672},{"value":60673},{"value":60928},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6150433344},"sp":{"value":6150433200},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699572,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":298},{"value":0},{"value":4405097016},{"value":105553156142544},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6151531072},"sp":{"value":6151530928},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699611,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":118},{"value":0},{"value":4368474104},{"value":105553156341904},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12948367936},"sp":{"value":12948367792},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699612,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":157},{"value":0},{"value":4368474104},{"value":105553156342576},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12949465664},"sp":{"value":12949465520},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699613,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":143},{"value":0},{"value":4368474104},{"value":105553156342672},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12950563392},"sp":{"value":12950563248},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699614,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":161},{"value":0},{"value":4368474104},{"value":105553156342768},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12951661120},"sp":{"value":12951660976},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699615,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":205},{"value":0},{"value":4368474104},{"value":105553156342864},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12952758848},"sp":{"value":12952758704},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699616,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":4},{"value":999999000},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":127},{"value":0},{"value":4368474104},{"value":105553156342288},{"value":1},{"value":999999000},{"value":4},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12953856576},"sp":{"value":12953856432},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699617,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":104},{"value":0},{"value":4368474104},{"value":105553156342480},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12954954304},"sp":{"value":12954954160},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699618,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":84},{"value":0},{"value":4368474104},{"value":105553156344304},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12956052032},"sp":{"value":12956051888},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699619,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":145},{"value":0},{"value":4368474104},{"value":105553156345648},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12957149760},"sp":{"value":12957149616},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699620,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":48},{"value":0},{"value":4368474104},{"value":105553156344592},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12958247488},"sp":{"value":12958247344},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699621,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":159},{"value":0},{"value":4368474104},{"value":105553156345552},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12959345216},"sp":{"value":12959345072},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699622,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":62},{"value":0},{"value":4368474104},{"value":105553156345744},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12960442944},"sp":{"value":12960442800},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699623,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":159232},{"value":0},{"value":0},{"value":160},{"value":4},{"value":994355000},{"value":159233},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":66},{"value":0},{"value":4368474104},{"value":105553156345264},{"value":1},{"value":994355000},{"value":4},{"value":159232},{"value":159233},{"value":159488},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12963048000},"sp":{"value":12963047856},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699624,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":119},{"value":0},{"value":4368474104},{"value":105553156345456},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12964145728},"sp":{"value":12964145584},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699625,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":65},{"value":0},{"value":4368474104},{"value":105553156344880},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12965243456},"sp":{"value":12965243312},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699626,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":139},{"value":0},{"value":4368474104},{"value":105553156345840},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12966341184},"sp":{"value":12966341040},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699627,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":135},{"value":0},{"value":4368474104},{"value":105553156347184},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12967438912},"sp":{"value":12967438768},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699629,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":257},{"value":0},{"value":1536},{"value":6597069768194},{"value":6597069768194},{"value":1536},{"value":0},{"value":6597069768192},{"value":305},{"value":2},{"value":0},{"value":4368474104},{"value":105553156360784},{"value":1},{"value":0},{"value":5},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12969339456},"sp":{"value":12969339312},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699630,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":768},{"value":0},{"value":0},{"value":160},{"value":4},{"value":991988000},{"value":769},{"value":0},{"value":512},{"value":2199023256066},{"value":2199023256066},{"value":512},{"value":0},{"value":2199023256064},{"value":305},{"value":141},{"value":0},{"value":4369450168},{"value":105553156360880},{"value":1},{"value":991988000},{"value":4},{"value":768},{"value":769},{"value":1024},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12970437184},"sp":{"value":12970437040},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699631,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":160},{"value":4},{"value":991546000},{"value":257},{"value":0},{"value":512},{"value":2199023256066},{"value":2199023256066},{"value":512},{"value":0},{"value":2199023256064},{"value":305},{"value":396},{"value":0},{"value":4369450168},{"value":105553156360976},{"value":1},{"value":991546000},{"value":4},{"value":256},{"value":257},{"value":512},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12971534912},"sp":{"value":12971534768},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699632,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":57},{"value":0},{"value":4368409368},{"value":105553156329360},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12986542656},"sp":{"value":12986542512},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699633,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":278},{"value":0},{"value":4366884152},{"value":105553156326960},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6168947264},"sp":{"value":6168947120},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699634,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":331},{"value":0},{"value":4366906440},{"value":105553156332720},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":6170044992},"sp":{"value":6170044848},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699635,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":79},{"value":0},{"value":4369679480},{"value":105553156330800},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12885977664},"sp":{"value":12885977520},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699636,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":176},{"value":0},{"value":4366810264},{"value":105553156174928},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12887075392},"sp":{"value":12887075248},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699637,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":96},{"value":0},{"value":4366699544},{"value":105553156184880},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12888173120},"sp":{"value":12888172976},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699638,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":187},{"value":0},{"value":4366890120},{"value":105553156188048},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12903279168},"sp":{"value":12903279024},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699639,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":275},{"value":0},{"value":4366898280},{"value":105553156188528},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12904376896},"sp":{"value":12904376752},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699640,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":236},{"value":0},{"value":4366759016},{"value":105553156189008},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12905474624},"sp":{"value":12905474480},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699641,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":53},{"value":0},{"value":4366881432},{"value":105553156189488},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12906572352},"sp":{"value":12906572208},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699642,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":145},{"value":0},{"value":4366674488},{"value":105553156189968},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12909046336},"sp":{"value":12909046192},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699643,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":232},{"value":0},{"value":4366901000},{"value":105553156190448},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12974058048},"sp":{"value":12974057904},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699644,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":321},{"value":0},{"value":4366531832},{"value":105553156190928},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12975155776},"sp":{"value":12975155632},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699645,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":183},{"value":0},{"value":4366895560},{"value":105553156362896},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12976253504},"sp":{"value":12976253360},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699646,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":184},{"value":0},{"value":4366805864},{"value":105553156362032},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12977351232},"sp":{"value":12977351088},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699647,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":312},{"value":0},{"value":4366892840},{"value":105553156362608},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12978448960},"sp":{"value":12978448816},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699648,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":50},{"value":0},{"value":4366903720},{"value":105553156363280},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12979546688},"sp":{"value":12979546544},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699649,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":143},{"value":0},{"value":4366909160},{"value":105553156363664},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12980644416},"sp":{"value":12980644272},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]},{"id":36699650,"name":"DartWorker","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":5},{"value":0},{"value":1},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":233},{"value":0},{"value":4366886872},{"value":105553156364144},{"value":1},{"value":0},{"value":5},{"value":0},{"value":1},{"value":256},{"value":4452265984,"symbolLocation":5768,"symbol":"dart::Symbols::symbol_handles_"},{"value":1000}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4365270212},"cpsr":{"value":2684354560},"fp":{"value":12981742144},"sp":{"value":12981742000},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":4355426348},"far":{"value":0}},"frames":[{"imageOffset":18476,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":42},{"imageOffset":31940,"symbol":"_pthread_cond_wait","symbolLocation":1236,"imageIndex":43},{"imageOffset":6602800,"symbol":"dart::ConditionVariable::WaitMicros(dart::Mutex*, long long)","symbolLocation":112,"imageIndex":40},{"imageOffset":8026624,"symbol":"dart::ThreadPool::WorkerLoop(dart::ThreadPool::Worker*)","symbolLocation":508,"imageIndex":40},{"imageOffset":8026968,"symbol":"dart::ThreadPool::Worker::Main(unsigned long)","symbolLocation":116,"imageIndex":40},{"imageOffset":7730956,"symbol":"dart::ThreadStart(void*)","symbolLocation":204,"imageIndex":40},{"imageOffset":30456,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":43},{"imageOffset":10560,"symbol":"thread_start","symbolLocation":8,"imageIndex":43}]}],
  "usedImages" : [
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4345937920,
    "size" : 540672,
    "uuid" : "398a133c-9bcb-317f-a064-a40d3cea3c0f",
    "path" : "\/usr\/lib\/dyld",
    "name" : "dyld"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4342497280,
    "CFBundleShortVersionString" : "1.0.7",
    "CFBundleIdentifier" : "com.rayclub.app",
    "size" : 16384,
    "uuid" : "458c427c-c0d4-3206-b2ca-4eca21f9c066",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Runner",
    "name" : "Runner",
    "CFBundleVersion" : "13"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4344266752,
    "size" : 278528,
    "uuid" : "aca24c59-ce20-396e-8cae-200a0022fe6f",
    "path" : "\/Volumes\/VOLUME\/*\/dyld_sim",
    "name" : "dyld_sim"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4343169024,
    "size" : 114688,
    "uuid" : "aa2f815e-47c7-3cf8-8189-a1c25aa2b399",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Runner.debug.dylib",
    "name" : "Runner.debug.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4343889920,
    "CFBundleShortVersionString" : "1.7.6",
    "CFBundleIdentifier" : "org.cocoapods.AppAuth",
    "size" : 163840,
    "uuid" : "28071fab-5cca-3d4e-96dd-8d99c512901d",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/AppAuth.framework\/AppAuth",
    "name" : "AppAuth",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4345085952,
    "CFBundleShortVersionString" : "11.2.0",
    "CFBundleIdentifier" : "org.cocoapods.AppCheckCore",
    "size" : 147456,
    "uuid" : "46f5701d-d3e7-3fe7-8247-ea5fabf31930",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/AppCheckCore.framework\/AppCheckCore",
    "name" : "AppCheckCore",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4343496704,
    "CFBundleShortVersionString" : "2.4.0",
    "CFBundleIdentifier" : "org.cocoapods.FBLPromises",
    "size" : 81920,
    "uuid" : "a77385af-c81e-34f5-aa1a-e497e686c34c",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/FBLPromises.framework\/FBLPromises",
    "name" : "FBLPromises",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4347150336,
    "CFBundleShortVersionString" : "4.1.1",
    "CFBundleIdentifier" : "org.cocoapods.GTMAppAuth",
    "size" : 147456,
    "uuid" : "14723571-20a5-3db6-9d4f-41465771c2e7",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/GTMAppAuth.framework\/GTMAppAuth",
    "name" : "GTMAppAuth",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4348166144,
    "CFBundleShortVersionString" : "3.5.0",
    "CFBundleIdentifier" : "org.cocoapods.GTMSessionFetcher",
    "size" : 344064,
    "uuid" : "cf4eae98-f4f6-31be-9233-e87decce3567",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/GTMSessionFetcher.framework\/GTMSessionFetcher",
    "name" : "GTMSessionFetcher",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4347527168,
    "CFBundleShortVersionString" : "8.0.0",
    "CFBundleIdentifier" : "org.cocoapods.GoogleSignIn",
    "size" : 147456,
    "uuid" : "4d187979-dc7f-3dc1-904e-cf8e34db04ea",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/GoogleSignIn.framework\/GoogleSignIn",
    "name" : "GoogleSignIn",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4343021568,
    "CFBundleShortVersionString" : "8.1.0",
    "CFBundleIdentifier" : "org.cocoapods.GoogleUtilities",
    "size" : 49152,
    "uuid" : "78e59970-2a63-352b-9756-ef4d71bc4966",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/GoogleUtilities.framework\/GoogleUtilities",
    "name" : "GoogleUtilities",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4345692160,
    "CFBundleShortVersionString" : "2.2.0",
    "CFBundleIdentifier" : "org.cocoapods.Mantle",
    "size" : 114688,
    "uuid" : "b08d859d-554b-3afe-b7e1-3ad4df1917b8",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/Mantle.framework\/Mantle",
    "name" : "Mantle",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4342857728,
    "CFBundleShortVersionString" : "6.0.3",
    "CFBundleIdentifier" : "org.cocoapods.OrderedSet",
    "size" : 49152,
    "uuid" : "dad6e974-62ff-3867-8bef-e7bc2a3d7e2c",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/OrderedSet.framework\/OrderedSet",
    "name" : "OrderedSet",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4349853696,
    "CFBundleShortVersionString" : "5.21.0",
    "CFBundleIdentifier" : "org.cocoapods.SDWebImage",
    "size" : 524288,
    "uuid" : "19760ae8-d611-3e86-a724-80aede3e7fdd",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/SDWebImage.framework\/SDWebImage",
    "name" : "SDWebImage",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4345446400,
    "CFBundleShortVersionString" : "0.14.6",
    "CFBundleIdentifier" : "org.cocoapods.SDWebImageWebPCoder",
    "size" : 49152,
    "uuid" : "8c113a38-bc00-37fb-ba60-3de2971369f0",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/SDWebImageWebPCoder.framework\/SDWebImageWebPCoder",
    "name" : "SDWebImageWebPCoder",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4355850240,
    "CFBundleShortVersionString" : "8.46.0",
    "CFBundleIdentifier" : "org.cocoapods.Sentry",
    "size" : 2310144,
    "uuid" : "6cc0e6e8-8b3b-357c-a7c8-378e8c833fff",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/Sentry.framework\/Sentry",
    "name" : "Sentry",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4347871232,
    "CFBundleShortVersionString" : "0.0.2",
    "CFBundleIdentifier" : "org.cocoapods.app-links",
    "size" : 32768,
    "uuid" : "28885cae-dae5-364f-845f-ee5bf03cbbab",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/app_links.framework\/app_links",
    "name" : "app_links",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4348018688,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.app-tracking-transparency",
    "size" : 32768,
    "uuid" : "16decbe3-522a-3ae7-a6a7-b3c4bb1a4706",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/app_tracking_transparency.framework\/app_tracking_transparency",
    "name" : "app_tracking_transparency",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4348788736,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.connectivity-plus",
    "size" : 49152,
    "uuid" : "2eb9c138-e4b5-3fa6-a6d6-650b0d5f874f",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/connectivity_plus.framework\/connectivity_plus",
    "name" : "connectivity_plus",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4345593856,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.device-info-plus",
    "size" : 32768,
    "uuid" : "87289257-efdd-3d93-aca5-ce19528adbb4",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/device_info_plus.framework\/device_info_plus",
    "name" : "device_info_plus",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4349394944,
    "CFBundleShortVersionString" : "1.0.0",
    "CFBundleIdentifier" : "org.cocoapods.flutter-image-compress-common",
    "size" : 147456,
    "uuid" : "79dddc43-33af-3e30-8378-01a6afedadc3",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/flutter_image_compress_common.framework\/flutter_image_compress_common",
    "name" : "flutter_image_compress_common",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4360830976,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.flutter-inappwebview-ios",
    "size" : 1785856,
    "uuid" : "426cb5e9-393d-390d-9d8d-c3098fd91be6",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/flutter_inappwebview_ios.framework\/flutter_inappwebview_ios",
    "name" : "flutter_inappwebview_ios",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4343808000,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.flutter-keyboard-visibility",
    "size" : 16384,
    "uuid" : "70a42d32-7d4e-3d64-9099-6a17380663e1",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/flutter_keyboard_visibility.framework\/flutter_keyboard_visibility",
    "name" : "flutter_keyboard_visibility",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4349132800,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.flutter-local-notifications",
    "size" : 65536,
    "uuid" : "fbc84e44-c15e-3747-a060-08fdd250cbc2",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/flutter_local_notifications.framework\/flutter_local_notifications",
    "name" : "flutter_local_notifications",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4348952576,
    "CFBundleShortVersionString" : "2.4.3",
    "CFBundleIdentifier" : "org.cocoapods.flutter-native-splash",
    "size" : 16384,
    "uuid" : "31b3e28b-1aa4-3760-a64b-1ff179459ddd",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/flutter_native_splash.framework\/flutter_native_splash",
    "name" : "flutter_native_splash",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4351164416,
    "CFBundleShortVersionString" : "10.0.0",
    "CFBundleIdentifier" : "org.cocoapods.flutter-secure-storage-darwin",
    "size" : 81920,
    "uuid" : "2b358790-2f78-32f9-9d7e-fc81e9c3b677",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/flutter_secure_storage_darwin.framework\/flutter_secure_storage_darwin",
    "name" : "flutter_secure_storage_darwin",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4352147456,
    "CFBundleShortVersionString" : "12.2.0",
    "CFBundleIdentifier" : "org.cocoapods.health",
    "size" : 376832,
    "uuid" : "640a1db6-f241-32ea-a592-a097de310943",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/health.framework\/health",
    "name" : "health",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4351410176,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.image-picker-ios",
    "size" : 81920,
    "uuid" : "26f5577d-4190-3a07-b61f-bac2d445973b",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/image_picker_ios.framework\/image_picker_ios",
    "name" : "image_picker_ios",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4343709696,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.integration-test",
    "size" : 16384,
    "uuid" : "8ee5b8a5-90c5-3e2e-bad8-404a93a2e6e6",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/integration_test.framework\/integration_test",
    "name" : "integration_test",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4353884160,
    "CFBundleShortVersionString" : "1.5.0",
    "CFBundleIdentifier" : "org.cocoapods.libwebp",
    "size" : 688128,
    "uuid" : "61293783-b9ec-3648-9ec3-b2c238eb75cc",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/libwebp.framework\/libwebp",
    "name" : "libwebp",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4349296640,
    "CFBundleShortVersionString" : "0.4.5",
    "CFBundleIdentifier" : "org.cocoapods.package-info-plus",
    "size" : 16384,
    "uuid" : "a06c85c2-1707-3c48-b762-8097d6bebdaf",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/package_info_plus.framework\/package_info_plus",
    "name" : "package_info_plus",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4351623168,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.path-provider-foundation",
    "size" : 49152,
    "uuid" : "5bffadd2-1bc4-383d-bcf5-b683655b7cf5",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/path_provider_foundation.framework\/path_provider_foundation",
    "name" : "path_provider_foundation",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4352868352,
    "CFBundleShortVersionString" : "8.14.2",
    "CFBundleIdentifier" : "org.cocoapods.sentry-flutter",
    "size" : 147456,
    "uuid" : "b95ff537-dbc5-3f9a-9035-2c3649946cc4",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/sentry_flutter.framework\/sentry_flutter",
    "name" : "sentry_flutter",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4351033344,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.share-plus",
    "size" : 32768,
    "uuid" : "f67510a4-efb0-3750-a956-620ac5c6130f",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/share_plus.framework\/share_plus",
    "name" : "share_plus",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4353179648,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.shared-preferences-foundation",
    "size" : 81920,
    "uuid" : "9b15855f-7805-3fde-a8d5-3e9ce0dcd039",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/shared_preferences_foundation.framework\/shared_preferences_foundation",
    "name" : "shared_preferences_foundation",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4353409024,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.sign-in-with-apple",
    "size" : 65536,
    "uuid" : "c3657637-fa0a-37f9-b258-5450f204a99a",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/sign_in_with_apple.framework\/sign_in_with_apple",
    "name" : "sign_in_with_apple",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4354883584,
    "CFBundleShortVersionString" : "0.0.4",
    "CFBundleIdentifier" : "org.cocoapods.sqflite-darwin",
    "size" : 131072,
    "uuid" : "1934506b-b98c-39a6-b6e3-262944f442c9",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/sqflite_darwin.framework\/sqflite_darwin",
    "name" : "sqflite_darwin",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4350902272,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.uni-links",
    "size" : 16384,
    "uuid" : "5100a33f-bdfb-3239-80ff-4177a07e9f5f",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/uni_links.framework\/uni_links",
    "name" : "uni_links",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4353622016,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.url-launcher-ios",
    "size" : 81920,
    "uuid" : "9a6f911b-92fe-3749-ac05-8cb10fa37569",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/url_launcher_ios.framework\/url_launcher_ios",
    "name" : "url_launcher_ios",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4355178496,
    "CFBundleShortVersionString" : "0.0.1",
    "CFBundleIdentifier" : "org.cocoapods.video-player-avfoundation",
    "size" : 98304,
    "uuid" : "2b90b308-e60f-370a-bf52-3c8e244a4283",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/video_player_avfoundation.framework\/video_player_avfoundation",
    "name" : "video_player_avfoundation",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4415553536,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "io.flutter.flutter",
    "size" : 35897344,
    "uuid" : "4c4c449b-5555-3144-a1d8-b121c05741e4",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5\/data\/Containers\/Bundle\/Application\/D58B140C-81D8-491E-98B5-63E37828087E\/Runner.app\/Frameworks\/Flutter.framework\/Flutter",
    "name" : "Flutter",
    "CFBundleVersion" : "1.0"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4351787008,
    "size" : 32768,
    "uuid" : "44654135-5ba7-3ea2-b7ef-f77ad1cb1980",
    "path" : "\/usr\/lib\/system\/libsystem_platform.dylib",
    "name" : "libsystem_platform.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4355407872,
    "size" : 245760,
    "uuid" : "5ea2a242-9786-3af8-b8a9-7899ecc711c8",
    "path" : "\/usr\/lib\/system\/libsystem_kernel.dylib",
    "name" : "libsystem_kernel.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4365238272,
    "size" : 65536,
    "uuid" : "53372391-80ee-3a52-85d2-b0d39816a60b",
    "path" : "\/usr\/lib\/system\/libsystem_pthread.dylib",
    "name" : "libsystem_pthread.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4365156352,
    "size" : 49152,
    "uuid" : "a2df0cb8-60af-32a5-8c75-9274d09bdff8",
    "path" : "\/Volumes\/VOLUME\/*\/libobjc-trampolines.dylib",
    "name" : "libobjc-trampolines.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6443487232,
    "size" : 507892,
    "uuid" : "c2be3ea9-bf05-3c11-b0ff-90fbaad68c1c",
    "path" : "\/Volumes\/VOLUME\/*\/libsystem_c.dylib",
    "name" : "libsystem_c.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6445170688,
    "size" : 114688,
    "uuid" : "9addd5ea-5408-3940-802a-70436345aa2d",
    "path" : "\/Volumes\/VOLUME\/*\/libc++abi.dylib",
    "name" : "libc++abi.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6442876928,
    "size" : 245076,
    "uuid" : "a6716887-054e-32ee-8b87-a87811aa3599",
    "path" : "\/Volumes\/VOLUME\/*\/libobjc.A.dylib",
    "name" : "libobjc.A.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6443995136,
    "size" : 282624,
    "uuid" : "ef0492a6-8ca5-38f0-97bb-df9bdb54c17a",
    "path" : "\/Volumes\/VOLUME\/*\/libdispatch.dylib",
    "name" : "libdispatch.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6446174208,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.CoreFoundation",
    "size" : 3989504,
    "uuid" : "6fc1e779-5846-3275-bf66-955738404cf6",
    "path" : "\/Volumes\/VOLUME\/*\/CoreFoundation.framework\/CoreFoundation",
    "name" : "CoreFoundation",
    "CFBundleVersion" : "3301"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6717181952,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.GraphicsServices",
    "size" : 36864,
    "uuid" : "3126e74d-fd21-3b05-9124-3b2fcf5db07a",
    "path" : "\/Volumes\/VOLUME\/*\/GraphicsServices.framework\/GraphicsServices",
    "name" : "GraphicsServices",
    "CFBundleVersion" : "1.0"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6523031552,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.UIKitCore",
    "size" : 30674944,
    "uuid" : "e83e0347-27d7-34bd-b0d3-51666dfdfd76",
    "path" : "\/Volumes\/VOLUME\/*\/UIKitCore.framework\/UIKitCore",
    "name" : "UIKitCore",
    "CFBundleVersion" : "8306"
  },
  {
    "size" : 0,
    "source" : "A",
    "base" : 0,
    "uuid" : "00000000-0000-0000-0000-000000000000"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6450683904,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.Foundation",
    "size" : 12832768,
    "uuid" : "cf6b28c4-9795-362a-b563-7b1b8c116282",
    "path" : "\/Volumes\/VOLUME\/*\/Foundation.framework\/Foundation",
    "name" : "Foundation",
    "CFBundleVersion" : "3301"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6517948416,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.CFNetwork",
    "size" : 3678208,
    "uuid" : "4a0921b7-6bd8-3dd0-a7b0-17d82dbbc75a",
    "path" : "\/Volumes\/VOLUME\/*\/CFNetwork.framework\/CFNetwork",
    "name" : "CFNetwork",
    "CFBundleVersion" : "3826.400.120"
  }
],
  "sharedCache" : {
  "base" : 6442450944,
  "size" : 3881598976,
  "uuid" : "b36d709c-a4c4-31cd-86a6-db467edf11b1"
},
  "vmSummary" : "ReadOnly portion of Libraries: Total=1.6G resident=0K(0%) swapped_out_or_unallocated=1.6G(100%)\nWritable regions: Total=2.2G written=2195K(0%) resident=2195K(0%) swapped_out=0K(0%) unallocated=2.2G(100%)\n\n                                VIRTUAL   REGION \nREGION TYPE                        SIZE    COUNT (non-coalesced) \n===========                     =======  ======= \nActivity Tracing                   256K        1 \nColorSync                          192K        5 \nFoundation                          16K        1 \nIOSurface                         34.7M        4 \nKernel Alloc Once                   32K        1 \nMALLOC                             1.9G       69 \nMALLOC guard page                  288K       18 \nMach message                        16K        1 \nSQLite page cache                  128K        1 \nSTACK GUARD                       57.1M       70 \nStack                             73.6M       70 \nVM_ALLOCATE                      189.2M      490 \n__DATA                            32.1M      814 \n__DATA_CONST                      87.2M      835 \n__DATA_DIRTY                       107K       12 \n__FONT_DATA                        2352        1 \n__LINKEDIT                       705.6M       46 \n__OBJC_RW                         2703K        1 \n__TEXT                           914.0M      849 \n__TPRO_CONST                       580K        3 \ndyld private memory                2.5G        9 \nlibnetwork                         128K        8 \nmapped file                      144.7M       15 \nowned unmapped memory               80K        1 \npage table in kernel              2195K        1 \nshared memory                       16K        1 \n===========                     =======  ======= \nTOTAL                              6.6G     3327 \n",
  "legacyInfo" : {
  "threadTriggered" : {
    "queue" : "com.apple.main-thread"
  }
},
  "logWritingSignature" : "1a7384247995935a2e6ac28916dd8dd55277d361",
  "trialInfo" : {
  "rollouts" : [
    {
      "rolloutId" : "6425c75e4327780c10cc4252",
      "factorPackIds" : {
        "SIRI_HOME_AUTOMATION_INTENT_SELECTION_CACHE" : "642600a457e7664b1698eb32"
      },
      "deploymentId" : 240000004
    },
    {
      "rolloutId" : "67648e5334a82511f4acf879",
      "factorPackIds" : {

      },
      "deploymentId" : 240000008
    }
  ],
  "experiments" : [

  ]
}
}

Model: Mac16,7, BootROM 11881.81.4, proc 14:10:4 processors, 48 GB, SMC 
Graphics: Apple M4 Pro, Apple M4 Pro, Built-In
Display: Color LCD, 3456 x 2234 Retina, Main, MirrorOff, Online
Memory Module: LPDDR5, Hynix
AirPort: spairport_wireless_card_type_wifi (0x14E4, 0x4388), wl0: Oct 31 2024 06:19:10 version 23.10.900.20.41.51.176 FWID 01-be2c8114
IO80211_driverkit-1345.10 "IO80211_driverkit-1345.10" Dec 14 2024 17:47:07
AirPort: 
Bluetooth: Version (null), 0 services, 0 devices, 0 incoming serial ports
Network Service: Wi-Fi, AirPort, en0
USB Device: USB31Bus
USB Device: USB31Bus
USB Device: USB31Bus
Thunderbolt Bus: MacBook Pro, Apple Inc.
Thunderbolt Bus: MacBook Pro, Apple Inc.
Thunderbolt Bus: MacBook Pro, Apple Inc.
