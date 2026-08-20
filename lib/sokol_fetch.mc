// sokol_fetch


when os(linux) || os(macos) || os(ios) {
struct _sfetch_FILE;
/*
    sfetch_log_item_t

    Log items are defined via X-Macros, and expanded to an
    enum 'sfetch_log_item', and in debug mode only,
    corresponding strings.

    Used as parameter in the logging callback.
*/
enum sfetch_log_item_t {
    SFETCH_LOGITEM_OK = 0,
    SFETCH_LOGITEM_MALLOC_FAILED = 1,
    SFETCH_LOGITEM_FILE_PATH_UTF8_DECODING_FAILED = 2,
    SFETCH_LOGITEM_SEND_QUEUE_FULL = 3,
    SFETCH_LOGITEM_REQUEST_CHANNEL_INDEX_TOO_BIG = 4,
    SFETCH_LOGITEM_REQUEST_PATH_IS_NULL = 5,
    SFETCH_LOGITEM_REQUEST_PATH_TOO_LONG = 6,
    SFETCH_LOGITEM_REQUEST_CALLBACK_MISSING = 7,
    SFETCH_LOGITEM_REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE = 8,
    SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL = 9,
    SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT = 10,
    SFETCH_LOGITEM_REQUEST_USERDATA_SIZE_TOO_BIG = 11,
    SFETCH_LOGITEM_CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS = 12,
    SFETCH_LOGITEM_REQUEST_POOL_EXHAUSTED = 13,
}

/* error codes */
enum sfetch_error_t {
    SFETCH_ERROR_NO_ERROR = 0,
    SFETCH_ERROR_FILE_NOT_FOUND = 1,
    SFETCH_ERROR_NO_BUFFER = 2,
    SFETCH_ERROR_BUFFER_TOO_SMALL = 3,
    SFETCH_ERROR_UNEXPECTED_EOF = 4,
    SFETCH_ERROR_INVALID_HTTP_STATUS = 5,
    SFETCH_ERROR_CANCELLED = 6,
    SFETCH_ERROR_JS_OTHER = 7,
}

/* a request goes through the following states, ping-ponging between IO and user thread */
enum _sfetch_state_t {
    _SFETCH_STATE_INITIAL = 0,
    _SFETCH_STATE_ALLOCATED = 1,
    _SFETCH_STATE_DISPATCHED = 2,
    _SFETCH_STATE_FETCHING = 3,
    _SFETCH_STATE_FETCHED = 4,
    _SFETCH_STATE_PAUSED = 5,
    _SFETCH_STATE_FAILED = 6,
}

type pthread_t = void*;
type FILE = _sfetch_FILE;
/* file handle abstraction */
type _sfetch_file_handle_t = void*;
type _sfetch_thread_func_t = fn(void*): void*;
struct pthread_mutex_t {
    u8[72] opaque;
}

struct pthread_cond_t {
    u8[96] opaque;
}

struct pthread_mutexattr_t {
    u8[8] opaque;
}

struct pthread_condattr_t {
    u8[8] opaque;
}

/*
    sfetch_logger_t

    Used in sfetch_desc_t to provide a custom logging and error reporting
    callback to sokol-fetch.
*/
struct sfetch_logger_t {
    fn(u8*, u32, u32, u8*, u32, u8*, void*): void func;
    void* user_data;
}

/*
    sfetch_range_t

    A pointer-size pair struct to pass memory ranges into and out of sokol-fetch.
    When initialized from a value type (array or struct) you can use the
    SFETCH_RANGE() helper macro to build an sfetch_range_t struct.
*/
struct sfetch_range_t {
    void* ptr;
    u64 size;
}

// disabling this for every includer isn't great, but the warnings are also quite pointless
/*
    sfetch_allocator_t

    Used in sfetch_desc_t to provide custom memory-alloc and -free functions
    to sokol_fetch.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct sfetch_allocator_t {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

/* configuration values for sfetch_setup() */
struct sfetch_desc_t {
    u32 max_requests;
    u32 num_channels;
    u32 num_lanes;
    sfetch_allocator_t allocator;
    sfetch_logger_t logger;
}

/* a request handle to identify an active fetch request, returned by sfetch_send() */
struct sfetch_handle_t {
    u32 id;
}

/* the response struct passed to the response callback */
struct sfetch_response_t {
    sfetch_handle_t handle;
    bool dispatched;
    bool fetched;
    bool paused;
    bool finished;
    bool failed;
    bool cancelled;
    sfetch_error_t error_code;
    u32 channel;
    u32 lane;
    u8* path;
    void* user_data;
    u32 data_offset;
    sfetch_range_t data;
    sfetch_range_t buffer;
}

/* request parameters passed to sfetch_send() */
struct sfetch_request_t {
    u32 channel;
    u8* path;
    fn(sfetch_response_t*): void callback;
    u32 chunk_size;
    sfetch_range_t buffer;
    sfetch_range_t user_data;
}

// ███████ ████████ ██████  ██    ██  ██████ ████████ ███████
// ██         ██    ██   ██ ██    ██ ██         ██    ██
// ███████    ██    ██████  ██    ██ ██         ██    ███████
//      ██    ██    ██   ██ ██    ██ ██         ██         ██
// ███████    ██    ██   ██  ██████   ██████    ██    ███████
//
// >>structs
struct _sfetch_path_t {
    u8[1024] buf;
}

/* a thread with incoming and outgoing message queue syncing */
struct _sfetch_thread_t {
    void* thread;
    pthread_cond_t incoming_cond;
    pthread_mutex_t incoming_mutex;
    pthread_mutex_t outgoing_mutex;
    pthread_mutex_t running_mutex;
    pthread_mutex_t stop_mutex;
    bool stop_requested;
    bool valid;
}

/* user-side per-request state */
struct _sfetch_item_user_t {
    bool pause;
    bool cont;
    bool cancel;
    u32 fetched_offset;
    u32 fetched_size;
    sfetch_error_t error_code;
    bool finished;
    u64 user_data_size;
    u64[16] user_data;
}

/* thread-side per-request state */
struct _sfetch_item_thread_t {
    u32 fetched_offset;
    u32 fetched_size;
    sfetch_error_t error_code;
    bool failed;
    bool finished;
    _sfetch_file_handle_t file_handle;
    u32 content_size;
}

/* an internal request item */
struct _sfetch_item_t {
    sfetch_handle_t handle;
    _sfetch_state_t state;
    u32 channel;
    u32 lane;
    u32 chunk_size;
    fn(sfetch_response_t*): void callback;
    sfetch_range_t buffer;
    _sfetch_item_thread_t thread;
    _sfetch_item_user_t user;
    _sfetch_path_t path;
}

/* a pool of internal per-request items */
struct _sfetch_pool_t {
    u32 size;
    u32 free_top;
    _sfetch_item_t* items;
    u32* free_slots;
    u32* gen_ctrs;
    bool valid;
}

/* a ringbuffer for pool-slot ids */
struct _sfetch_ring_t {
    u32 head;
    u32 tail;
    u32 num;
    u32* buf;
}

struct _sfetch_channel_t {
    _sfetch_t* ctx;
    _sfetch_ring_t free_lanes;
    _sfetch_ring_t user_sent;
    _sfetch_ring_t user_incoming;
    _sfetch_ring_t user_outgoing;
    _sfetch_ring_t thread_incoming;
    _sfetch_ring_t thread_outgoing;
    _sfetch_thread_t thread;
    fn(_sfetch_t*, u32): void request_handler;
    bool valid;
}

/* the sfetch global state */
struct _sfetch_t {
    bool setup;
    bool valid;
    bool in_callback;
    sfetch_desc_t desc;
    _sfetch_pool_t pool;
    _sfetch_channel_t[16] chn;
}

/*
    sokol_fetch.h -- asynchronous data loading/streaming

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_FETCH_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)             - your own assert macro (default: assert(c))
    SOKOL_UNREACHABLE()         - a guard macro for unreachable code (default: assert(false))
    SOKOL_FETCH_API_DECL        - public function declaration prefix (default: extern)
    SOKOL_API_DECL              - same as SOKOL_FETCH_API_DECL
    SOKOL_API_IMPL              - public function implementation prefix (default: -)
    SFETCH_MAX_PATH             - max length of UTF-8 filesystem path / URL (default: 1024 bytes)
    SFETCH_MAX_USERDATA_UINT64  - max size of embedded userdata in number of uint64_t, userdata
                                  will be copied into an 8-byte aligned memory region associated
                                  with each in-flight request, default value is 16 (== 128 bytes)
    SFETCH_MAX_CHANNELS         - max number of IO channels (default is 16, also see sfetch_desc_t.num_channels)

    If sokol_fetch.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_FETCH_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    NOTE: The following documentation talks a lot about "IO threads". Actual
    threads are only used on platforms where threads are available. The web
    version (emscripten/wasm) doesn't use POSIX-style threads, but instead
    asynchronous Javascript calls chained together by callbacks. The actual
    source code differences between the two approaches have been kept to
    a minimum though.

    FEATURE OVERVIEW
    ================

    - Asynchronously load complete files, or stream files incrementally via
      HTTP (on web platform), or the local file system (on native platforms)

    - Request / response-callback model, user code sends a request
      to initiate a file-load, sokol_fetch.h calls the response callback
      on the same thread when data is ready or user-code needs
      to respond otherwise

    - Not limited to the main-thread or a single thread: A sokol-fetch
      "context" can live on any thread, and multiple contexts
      can operate side-by-side on different threads.

    - Memory management for data buffers is under full control of user code.
      sokol_fetch.h won't allocate memory after it has been setup.

    - Automatic rate-limiting guarantees that only a maximum number of
      requests is processed at any one time, allowing a zero-allocation
      model, where all data is streamed into fixed-size, pre-allocated
      buffers.

    - Active Requests can be paused, continued and cancelled from anywhere
      in the user-thread which sent this request.


    TL;DR EXAMPLE CODE
    ==================
    This is the most-simple example code to load a single data file with a
    known maximum size:

    (1) initialize sokol-fetch with default parameters (but NOTE that the
        default setup parameters provide a safe-but-slow "serialized"
        operation). In order to see any logging output in case of errors
        you should always provide a logging function
        (such as 'slog_func' from sokol_log.h):

        sfetch_setup(&(sfetch_desc_t){ .logger.func = slog_func });

    (2) send a fetch-request to load a file from the current directory
        into a buffer big enough to hold the entire file content:

        static uint8_t buf[MAX_FILE_SIZE];

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer = {
                .ptr = buf,
                .size = sizeof(buf)
            }
        });

        If 'buf' is a value (e.g. an array or struct item), the .buffer item can
        be initialized with the SFETCH_RANGE() helper macro:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer = SFETCH_RANGE(buf)
        });

    (3) write a 'response-callback' function, this will be called whenever
        the user-code must respond to state changes of the request
        (most importantly when data has been loaded):

        void response_callback(const sfetch_response_t* response) {
            if (response->fetched) {
                // data has been loaded, and is available via the
                // sfetch_range_t struct item 'data':
                const void* ptr = response->data.ptr;
                size_t num_bytes = response->data.size;
            }
            if (response->finished) {
                // the 'finished'-flag is the catch-all flag for when the request
                // is finished, no matter if loading was successful or failed,
                // so any cleanup-work should happen here...
                ...
                if (response->failed) {
                    // 'failed' is true in (addition to 'finished') if something
                    // went wrong (file doesn't exist, or less bytes could be
                    // read from the file than expected)
                }
            }
        }

    (4) pump the sokol-fetch message queues, and invoke response callbacks
        by calling:

        sfetch_dowork();

        In an event-driven app this should be called in the event loop. If you
        use sokol-app this would be in your frame_cb function.

    (5) finally, call sfetch_shutdown() at the end of the application:

    There's many other loading-scenarios, for instance one doesn't have to
    provide a buffer upfront, this can also happen in the response callback.

    Or it's possible to stream huge files into small fixed-size buffer,
    complete with pausing and continuing the download.

    It's also possible to improve the 'pipeline throughput' by fetching
    multiple files in parallel, but at the same time limit the maximum
    number of requests that can be 'in-flight'.

    For how this all works, please read the following documentation sections :)


    API DOCUMENTATION
    =================

    void sfetch_setup(const sfetch_desc_t* desc)
    --------------------------------------------
    First call sfetch_setup(const sfetch_desc_t*) on any thread before calling
    any other sokol-fetch functions on the same thread.

    sfetch_setup() takes a pointer to an sfetch_desc_t struct with setup
    parameters. Parameters which should use their default values must
    be zero-initialized:

        - max_requests (uint32_t):
            The maximum number of requests that can be alive at any time, the
            default is 128.

        - num_channels (uint32_t):
            The number of "IO channels" used to parallelize and prioritize
            requests, the default is 1.

        - num_lanes (uint32_t):
            The number of "lanes" on a single channel. Each request which is
            currently 'inflight' on a channel occupies one lane until the
            request is finished. This is used for automatic rate-limiting
            (search below for CHANNELS AND LANES for more details). The
            default number of lanes is 1.

    For example, to setup sokol-fetch for max 1024 active requests, 4 channels,
    and 8 lanes per channel in C99:

        sfetch_setup(&(sfetch_desc_t){
            .max_requests = 1024,
            .num_channels = 4,
            .num_lanes = 8
        });

    sfetch_setup() is the only place where sokol-fetch will allocate memory.

    NOTE that the default setup parameters of 1 channel and 1 lane per channel
    has a very poor 'pipeline throughput' since this essentially serializes
    IO requests (a new request will only be processed when the last one has
    finished), and since each request needs at least one roundtrip between
    the user- and IO-thread the throughput will be at most one request per
    frame. Search for LATENCY AND THROUGHPUT below for more information on
    how to increase throughput.

    NOTE that you can call sfetch_setup() on multiple threads, each thread
    will get its own thread-local sokol-fetch instance, which will work
    independently from sokol-fetch instances on other threads.

    void sfetch_shutdown(void)
    --------------------------
    Call sfetch_shutdown() at the end of the application to stop any
    IO threads and free all memory that was allocated in sfetch_setup().

    sfetch_handle_t sfetch_send(const sfetch_request_t* request)
    ------------------------------------------------------------
    Call sfetch_send() to start loading data, the function takes a pointer to an
    sfetch_request_t struct with request parameters and returns a
    sfetch_handle_t identifying the request for later calls. At least
    a path/URL and callback must be provided:

        sfetch_handle_t h = sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback
        });

    sfetch_send() will return an invalid handle if no request can be allocated
    from the internal pool because all available request items are 'in-flight'.

    The sfetch_request_t struct contains the following parameters (optional
    parameters that are not provided must be zero-initialized):

        - path (const char*, required)
            Pointer to an UTF-8 encoded C string describing the filesystem
            path or HTTP URL. The string will be copied into an internal data
            structure, and passed "as is" (apart from any required
            encoding-conversions) to fopen(), CreateFileW() or
            the html fetch API call. The maximum length of the string is defined by
            the SFETCH_MAX_PATH configuration define, the default is 1024 bytes
            including the 0-terminator byte.

        - callback (sfetch_callback_t, required)
            Pointer to a response-callback function which is called when the
            request needs "user code attention". Search below for REQUEST
            STATES AND THE RESPONSE CALLBACK for detailed information about
            handling responses in the response callback.

        - channel (uint32_t, optional)
            Index of the IO channel where the request should be processed.
            Channels are used to parallelize and prioritize requests relative
            to each other. Search below for CHANNELS AND LANES for more
            information. The default channel is 0.

        - chunk_size (uint32_t, optional)
            The chunk_size member is used for streaming data incrementally
            in small chunks. After 'chunk_size' bytes have been loaded into
            to the streaming buffer, the response callback will be called
            with the buffer containing the fetched data for the current chunk.
            If chunk_size is 0 (the default), than the whole file will be loaded.
            Please search below for CHUNK SIZE AND HTTP COMPRESSION for
            important information how streaming works if the web server
            is serving compressed data.

        - buffer (sfetch_range_t)
            This is a optional pointer/size pair describing a chunk of memory where
            data will be loaded into (if no buffer is provided upfront, this
            must happen in the response callback). If a buffer is provided,
            it must be big enough to either hold the entire file (if chunk_size
            is zero), or the *uncompressed* data for one downloaded chunk
            (if chunk_size is > 0).

        - user_data (sfetch_range_t)
            The user_data ptr/size range struct describe an optional POD blob
            (plain-old-data) associated with the request which will be copied(!)
            into an internal memory block. The maximum default size of this
            memory block is 128 bytes (but can be overridden by defining
            SFETCH_MAX_USERDATA_UINT64 before including the notification, note
            that this define is in "number of uint64_t", not number of bytes).
            The user-data block is 8-byte aligned, and will be copied via
            memcpy() (so don't put any C++ "smart members" in there).

    NOTE that request handles are strictly thread-local and only unique
    within the thread the handle was created on, and all function calls
    involving a request handle must happen on that same thread.

    bool sfetch_handle_valid(sfetch_handle_t request)
    -------------------------------------------------
    This checks if the provided request handle is valid, and is associated with
    a currently active request. It will return false if:

        - sfetch_send() returned an invalid handle because it couldn't allocate
          a new request from the internal request pool (because they're all
          in flight)
        - the request associated with the handle is no longer alive (because
          it either finished successfully, or the request failed for some
          reason)

    void sfetch_dowork(void)
    ------------------------
    Call sfetch_dowork(void) in regular intervals (for instance once per frame)
    on the same thread as sfetch_setup() to "turn the gears". If you are sending
    requests but never hear back from them in the response callback function, then
    the most likely reason is that you forgot to add the call to sfetch_dowork()
    in the per-frame function.

    sfetch_dowork() roughly performs the following work:

        - any new requests that have been sent with sfetch_send() since the
        last call to sfetch_dowork() will be dispatched to their IO channels
        and assigned a free lane. If all lanes on that channel are occupied
        by requests 'in flight', incoming requests must wait until
        a lane becomes available

        - for all new requests which have been enqueued on a channel which
        don't already have a buffer assigned the response callback will be
        called with (response->dispatched == true) so that the response
        callback can inspect the dynamically assigned lane and bind a buffer
        to the request (search below for CHANNELS AND LANE for more info)

        - a state transition from "user side" to "IO thread side" happens for
        each new request that has been dispatched to a channel.

        - requests dispatched to a channel are either forwarded into that
        channel's worker thread (on native platforms), or cause an HTTP
        request to be sent via an asynchronous fetch() call (on the web
        platform)

        - for all requests which have finished their current IO operation a
        state transition from "IO thread side" to "user side" happens,
        and the response callback is called so that the fetched data
        can be processed.

        - requests which are completely finished (either because the entire
        file content has been loaded, or they are in the FAILED state) are
        freed (this just changes their state in the 'request pool', no actual
        memory is freed)

        - requests which are not yet finished are fed back into the
        'incoming' queue of their channel, and the cycle starts again, this
        only happens for requests which perform data streaming (not load
        the entire file at once).

    void sfetch_cancel(sfetch_handle_t request)
    -------------------------------------------
    This cancels a request in the next sfetch_dowork() call and invokes the
    response callback with (response.failed == true) and (response.finished
    == true) to give user-code a chance to do any cleanup work for the
    request. If sfetch_cancel() is called for a request that is no longer
    alive, nothing bad will happen (the call will simply do nothing).

    void sfetch_pause(sfetch_handle_t request)
    ------------------------------------------
    This pauses an active request in the next sfetch_dowork() call and puts
    it into the PAUSED state. For all requests in PAUSED state, the response
    callback will be called in each call to sfetch_dowork() to give user-code
    a chance to CONTINUE the request (by calling sfetch_continue()). Pausing
    a request makes sense for dynamic rate-limiting in streaming scenarios
    (like video/audio streaming with a fixed number of streaming buffers. As
    soon as all available buffers are filled with download data, downloading
    more data must be prevented to allow video/audio playback to catch up and
    free up empty buffers for new download data.

    void sfetch_continue(sfetch_handle_t request)
    ---------------------------------------------
    Continues a paused request, counterpart to the sfetch_pause() function.

    void sfetch_bind_buffer(sfetch_handle_t request, sfetch_range_t buffer)
    ----------------------------------------------------------------------------------------
    This "binds" a new buffer (as pointer/size pair) to an active request. The
    function *must* be called from inside the response-callback, and there
    must not already be another buffer bound.

    void* sfetch_unbind_buffer(sfetch_handle_t request)
    ---------------------------------------------------
    This removes the current buffer binding from the request and returns
    a pointer to the previous buffer (useful if the buffer was dynamically
    allocated and it must be freed).

    sfetch_unbind_buffer() *must* be called from inside the response callback.

    The usual code sequence to bind a different buffer in the response
    callback might look like this:

        void response_callback(const sfetch_response_t* response) {
            if (response.fetched) {
                ...
                // switch to a different buffer (in the FETCHED state it is
                // guaranteed that the request has a buffer, otherwise it
                // would have gone into the FAILED state
                void* old_buf_ptr = sfetch_unbind_buffer(response.handle);
                free(old_buf_ptr);
                void* new_buf_ptr = malloc(new_buf_size);
                sfetch_bind_buffer(response.handle, new_buf_ptr, new_buf_size);
            }
            if (response.finished) {
                // unbind and free the currently associated buffer,
                // the buffer pointer could be null if the request has failed
                // NOTE that it is legal to call free() with a nullptr,
                // this happens if the request failed to open its file
                // and never goes into the OPENED state
                void* buf_ptr = sfetch_unbind_buffer(response.handle);
                free(buf_ptr);
            }
        }

    sfetch_desc_t sfetch_desc(void)
    -------------------------------
    sfetch_desc() returns a copy of the sfetch_desc_t struct passed to
    sfetch_setup(), with zero-initialized values replaced with
    their default values.

    int sfetch_max_userdata_bytes(void)
    -----------------------------------
    This returns the value of the SFETCH_MAX_USERDATA_UINT64 config
    define, but in number of bytes (so SFETCH_MAX_USERDATA_UINT64*8).

    int sfetch_max_path(void)
    -------------------------
    Returns the value of the SFETCH_MAX_PATH config define.


    REQUEST STATES AND THE RESPONSE CALLBACK
    ========================================
    A request goes through a number of states during its lifetime. Depending
    on the current state of a request, it will be 'owned' either by the
    "user-thread" (where the request was sent) or an IO thread.

    You can think of a request as "ping-ponging" between the IO thread and
    user thread, any actual IO work is done on the IO thread, while
    invocations of the response-callback happen on the user-thread.

    All state transitions and callback invocations happen inside the
    sfetch_dowork() function.

    An active request goes through the following states:

    ALLOCATED (user-thread)

        The request has been allocated in sfetch_send() and is
        waiting to be dispatched into its IO channel. When this
        happens, the request will transition into the DISPATCHED state.

    DISPATCHED (IO thread)

        The request has been dispatched into its IO channel, and a
        lane has been assigned to the request.

        If a buffer was provided in sfetch_send() the request will
        immediately transition into the FETCHING state and start loading
        data into the buffer.

        If no buffer was provided in sfetch_send(), the response
        callback will be called with (response->dispatched == true),
        so that the response callback can bind a buffer to the
        request. Binding the buffer in the response callback makes
        sense if the buffer isn't dynamically allocated, but instead
        a pre-allocated buffer must be selected from the request's
        channel and lane.

        Note that it isn't possible to get a file size in the response callback
        which would help with allocating a buffer of the right size, this is
        because it isn't possible in HTTP to query the file size before the
        entire file is downloaded (...when the web server serves files compressed).

        If opening the file failed, the request will transition into
        the FAILED state with the error code SFETCH_ERROR_FILE_NOT_FOUND.

    FETCHING (IO thread)

        While a request is in the FETCHING state, data will be loaded into
        the user-provided buffer.

        If no buffer was provided, the request will go into the FAILED
        state with the error code SFETCH_ERROR_NO_BUFFER.

        If a buffer was provided, but it is too small to contain the
        fetched data, the request will go into the FAILED state with
        error code SFETCH_ERROR_BUFFER_TOO_SMALL.

        If less data can be read from the file than expected, the request
        will go into the FAILED state with error code SFETCH_ERROR_UNEXPECTED_EOF.

        If loading data into the provided buffer works as expected, the
        request will go into the FETCHED state.

    FETCHED (user thread)

        The request goes into the FETCHED state either when the entire file
        has been loaded into the provided buffer (when request.chunk_size == 0),
        or a chunk has been loaded (and optionally decompressed) into the
        buffer (when request.chunk_size > 0).

        The response callback will be called so that the user-code can
        process the loaded data using the following sfetch_response_t struct members:

            - data.ptr: pointer to the start of fetched data
            - data.size: the number of bytes in the provided buffer
            - data_offset: the byte offset of the loaded data chunk in the
              overall file (this is only set to a non-zero value in a streaming
              scenario)

        Once all file data has been loaded, the 'finished' flag will be set
        in the response callback's sfetch_response_t argument.

        After the user callback returns, and all file data has been loaded
        (response.finished flag is set) the request has reached its end-of-life
        and will be recycled.

        Otherwise, if there's still data to load (because streaming was
        requested by providing a non-zero request.chunk_size), the request
        will switch back to the FETCHING state to load the next chunk of data.

        Note that it is ok to associate a different buffer or buffer-size
        with the request by calling sfetch_bind_buffer() in the response-callback.

        To check in the response callback for the FETCHED state, and
        independently whether the request is finished:

            void response_callback(const sfetch_response_t* response) {
                if (response->fetched) {
                    // request is in FETCHED state, the loaded data is available
                    // in .data.ptr, and the number of bytes that have been
                    // loaded in .data.size:
                    const void* data = response->data.ptr;
                    size_t num_bytes = response->data.size;
                }
                if (response->finished) {
                    // the finished flag is set either when all data
                    // has been loaded, the request has been cancelled,
                    // or the file operation has failed, this is where
                    // any required per-request cleanup work should happen
                }
            }


    FAILED (user thread)

        A request will transition into the FAILED state in the following situations:

            - if the file doesn't exist or couldn't be opened for other
              reasons (SFETCH_ERROR_FILE_NOT_FOUND)
            - if no buffer is associated with the request in the FETCHING state
              (SFETCH_ERROR_NO_BUFFER)
            - if the provided buffer is too small to hold the entire file
              (if request.chunk_size == 0), or the (potentially decompressed)
              partial data chunk (SFETCH_ERROR_BUFFER_TOO_SMALL)
            - if less bytes could be read from the file then expected
              (SFETCH_ERROR_UNEXPECTED_EOF)
            - if a request has been cancelled via sfetch_cancel()
              (SFETCH_ERROR_CANCELLED)

        The response callback will be called once after a request goes into
        the FAILED state, with the 'response->finished' and
        'response->failed' flags set to true.

        This gives the user-code a chance to cleanup any resources associated
        with the request.

        To check for the failed state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->failed) {
                    // specifically check for the failed state...
                }
                // or you can do a catch-all check via the finished-flag:
                if (response->finished) {
                    if (response->failed) {
                        // if more detailed error handling is needed:
                        switch (response->error_code) {
                            ...
                        }
                    }
                }
            }

    PAUSED (user thread)

        A request will transition into the PAUSED state after user-code
        calls the function sfetch_pause() on the request's handle. Usually
        this happens from within the response-callback in streaming scenarios
        when the data streaming needs to wait for a data decoder (like
        a video/audio player) to catch up.

        While a request is in PAUSED state, the response-callback will be
        called in each sfetch_dowork(), so that the user-code can either
        continue the request by calling sfetch_continue(), or cancel
        the request by calling sfetch_cancel().

        When calling sfetch_continue() on a paused request, the request will
        transition into the FETCHING state. Otherwise if sfetch_cancel() is
        called, the request will switch into the FAILED state.

        To check for the PAUSED state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->paused) {
                    // we can check here whether the request should
                    // continue to load data:
                    if (should_continue(response->handle)) {
                        sfetch_continue(response->handle);
                    }
                }
            }


    CHUNK SIZE AND HTTP COMPRESSION
    ===============================
    TL;DR: for streaming scenarios, the provided chunk-size must be smaller
    than the provided buffer-size because the web server may decide to
    serve the data compressed and the chunk-size must be given in 'compressed
    bytes' while the buffer receives 'uncompressed bytes'. It's not possible
    in HTTP to query the uncompressed size for a compressed download until
    that download has finished.

    With vanilla HTTP, it is not possible to query the actual size of a file
    without downloading the entire file first (the Content-Length response
    header only provides the compressed size). Furthermore, for HTTP
    range-requests, the range is given on the compressed data, not the
    uncompressed data. So if the web server decides to serve the data
    compressed, the content-length and range-request parameters don't
    correspond to the uncompressed data that's arriving in the sokol-fetch
    buffers, and there's no way from JS or WASM to either force uncompressed
    downloads (e.g. by setting the Accept-Encoding field), or access the
    compressed data.

    This has some implications for sokol_fetch.h, most notably that buffers
    can't be provided in the exactly right size, because that size can't
    be queried from HTTP before the data is actually downloaded.

    When downloading whole files at once, it is basically expected that you
    know the maximum files size upfront through other means (for instance
    through a separate meta-data-file which contains the file sizes and
    other meta-data for each file that needs to be loaded).

    For streaming downloads the situation is a bit more complicated. These
    use HTTP range-requests, and those ranges are defined on the (potentially)
    compressed data which the JS/WASM side doesn't have access to. However,
    the JS/WASM side only ever sees the uncompressed data, and it's not possible
    to query the uncompressed size of a range request before that range request
    has finished.

    If the provided buffer is too small to contain the uncompressed data,
    the request will fail with error code SFETCH_ERROR_BUFFER_TOO_SMALL.


    CHANNELS AND LANES
    ==================
    Channels and lanes are (somewhat artificial) concepts to manage
    parallelization, prioritization and rate-limiting.

    Channels can be used to parallelize message processing for better 'pipeline
    throughput', and to prioritize requests: user-code could reserve one
    channel for streaming downloads which need to run in parallel to other
    requests, another channel for "regular" downloads and yet another
    high-priority channel which would only be used for small files which need
    to start loading immediately.

    Each channel comes with its own IO thread and message queues for pumping
    messages in and out of the thread. The channel where a request is
    processed is selected manually when sending a message:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback,
            .channel = 2
        });

    The number of channels is configured at startup in sfetch_setup() and
    cannot be changed afterwards.

    Channels are completely separate from each other, and a request will
    never "hop" from one channel to another.

    Each channel consists of a fixed number of "lanes" for automatic rate
    limiting:

    When a request is sent to a channel via sfetch_send(), a "free lane" will
    be picked and assigned to the request. The request will occupy this lane
    for its entire life time (also while it is paused). If all lanes of a
    channel are currently occupied, new requests will wait until a
    lane becomes unoccupied.

    Since the number of channels and lanes is known upfront, it is guaranteed
    that there will never be more than "num_channels * num_lanes" requests
    in flight at any one time.

    This guarantee eliminates unexpected load- and memory-spikes when
    many requests are sent in very short time, and it allows to pre-allocate
    a fixed number of memory buffers which can be reused for the entire
    "lifetime" of a sokol-fetch context.

    In the most simple scenario - when a maximum file size is known - buffers
    can be statically allocated like this:

        uint8_t buffer[NUM_CHANNELS][NUM_LANES][MAX_FILE_SIZE];

    Then in the user callback pick a buffer by channel and lane,
    and associate it with the request like this:

        void response_callback(const sfetch_response_t* response) {
            if (response->dispatched) {
                void* ptr = buffer[response->channel][response->lane];
                sfetch_bind_buffer(response->handle, ptr, MAX_FILE_SIZE);
            }
            ...
        }


    NOTES ON OPTIMIZING PIPELINE LATENCY AND THROUGHPUT
    ===================================================
    With the default configuration of 1 channel and 1 lane per channel,
    sokol_fetch.h will appear to have a shockingly bad loading performance
    if several files are loaded.

    This has two reasons:

        (1) all parallelization when loading data has been disabled. A new
        request will only be processed, when the last request has finished.

        (2) every invocation of the response-callback adds one frame of latency
        to the request, because callbacks will only be called from within
        sfetch_dowork()

    sokol-fetch takes a few shortcuts to improve step (2) and reduce
    the 'inherent latency' of a request:

        - if a buffer is provided upfront, the response-callback won't be
        called in the DISPATCHED state, but start right with the FETCHED state
        where data has already been loaded into the buffer

        - there is no separate CLOSED state where the callback is invoked
        separately when loading has finished (or the request has failed),
        instead the finished and failed flags will be set as part of
        the last FETCHED invocation

    This means providing a big-enough buffer to fit the entire file is the
    best case, the response callback will only be called once, ideally in
    the next frame (or two calls to sfetch_dowork()).

    If no buffer is provided upfront, one frame of latency is added because
    the response callback needs to be invoked in the DISPATCHED state so that
    the user code can bind a buffer.

    This means the best case for a request without an upfront-provided
    buffer is 2 frames (or 3 calls to sfetch_dowork()).

    That's about what can be done to improve the latency for a single request,
    but the really important step is to improve overall throughput. If you
    need to load thousands of files you don't want that to be completely
    serialized.

    The most important action to increase throughput is to increase the
    number of lanes per channel. This defines how many requests can be
    'in flight' on a single channel at the same time. The guiding decision
    factor for how many lanes you can "afford" is the memory size you want
    to set aside for buffers. Each lane needs its own buffer so that
    the data loaded for one request doesn't scribble over the data
    loaded for another request.

    Here's a simple example of sending 4 requests without upfront buffer
    on a channel with 1, 2 and 4 lanes, each line is one frame:

        1 LANE (8 frames):
            Lane 0:
            -------------
            REQ 0 DISPATCHED
            REQ 0 FETCHED
            REQ 1 DISPATCHED
            REQ 1 FETCHED
            REQ 2 DISPATCHED
            REQ 2 FETCHED
            REQ 3 DISPATCHED
            REQ 3 FETCHED

    Note how the request don't overlap, so they can all use the same buffer.

        2 LANES (4 frames):
            Lane 0:             Lane 1:
            ------------------------------------
            REQ 0 DISPATCHED    REQ 1 DISPATCHED
            REQ 0 FETCHED       REQ 1 FETCHED
            REQ 2 DISPATCHED    REQ 3 DISPATCHED
            REQ 2 FETCHED       REQ 3 FETCHED

    This reduces the overall time to 4 frames, but now you need 2 buffers so
    that requests don't scribble over each other.

        4 LANES (2 frames):
            Lane 0:             Lane 1:             Lane 2:             Lane 3:
            ----------------------------------------------------------------------------
            REQ 0 DISPATCHED    REQ 1 DISPATCHED    REQ 2 DISPATCHED    REQ 3 DISPATCHED
            REQ 0 FETCHED       REQ 1 FETCHED       REQ 2 FETCHED       REQ 3 FETCHED

    Now we're down to the same 'best-case' latency as sending a single
    request.

    Apart from the memory requirements for the streaming buffers (which is
    under your control), you can be generous with the number of lanes,
    they don't add any processing overhead.

    The last option for tweaking latency and throughput is channels. Each
    channel works independently from other channels, so while one
    channel is busy working through a large number of requests (or one
    very long streaming download), you can set aside a high-priority channel
    for requests that need to start as soon as possible.

    On platforms with threading support, each channel runs on its own
    thread, but this is mainly an implementation detail to work around
    the traditional blocking file IO functions, not for performance reasons.


    MEMORY ALLOCATION OVERRIDE
    ==========================
    You can override the memory allocation functions at initialization time
    like this:

        void* my_alloc(size_t size, void* user_data) {
            return malloc(size);
        }

        void my_free(void* ptr, void* user_data) {
            free(ptr);
        }

        ...
            sfetch_setup(&(sfetch_desc_t){
                // ...
                .allocator = {
                    .alloc_fn = my_alloc,
                    .free_fn = my_free,
                    .user_data = ...,
                }
            });
        ...

    If no overrides are provided, malloc and free will be used.

    This only affects memory allocation calls done by sokol_fetch.h
    itself though, not any allocations in OS libraries.

    Memory allocation will only happen on the same thread where sfetch_setup()
    was called, so you don't need to worry about thread-safety.


    ERROR REPORTING AND LOGGING
    ===========================
    To get any logging information at all you need to provide a logging callback in the setup call,
    the easiest way is to use sokol_log.h:

        #include "sokol_log.h"

        sfetch_setup(&(sfetch_desc_t){
            // ...
            .logger.func = slog_func
        });

    To override logging with your own callback, first write a logging function like this:

        void my_log(const char* tag,                // e.g. 'sfetch'
                    uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
                    uint32_t log_item_id,           // SFETCH_LOGITEM_*
                    const char* message_or_null,    // a message string, may be nullptr in release mode
                    uint32_t line_nr,               // line number in sokol_fetch.h
                    const char* filename_or_null,   // source filename, may be nullptr in release mode
                    void* user_data)
        {
            ...
        }

    ...and then setup sokol-fetch like this:

        sfetch_setup(&(sfetch_desc_t){
            .logger = {
                .func = my_log,
                .user_data = my_user_data,
            }
        });

    The provided logging function must be reentrant (e.g. be callable from
    different threads).

    If you don't want to provide your own custom logger it is highly recommended to use
    the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
    errors.


    FUTURE PLANS / V2.0 IDEA DUMP
    =============================
    - An optional polling API (as alternative to callback API)
    - Move buffer-management into the API? The "manual management"
      can be quite tricky especially for dynamic allocation scenarios,
      API support for buffer management would simplify cases like
      preventing that requests scribble over each other's buffers, or
      an automatic garbage collection for dynamically allocated buffers,
      or automatically falling back to dynamic allocation if static
      buffers aren't big enough.
    - Pluggable request handlers to load data from other "sources"
      (especially HTTP downloads on native platforms via e.g. libcurl
      would be useful)
    - I'm currently not happy how the user-data block is handled, this
      should getting and updating the user-data should be wrapped by
      API functions (similar to bind/unbind buffer)


    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2019 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
// ██ ███    ███ ██████  ██      ███████ ███    ███ ███████ ███    ██ ████████  █████  ████████ ██  ██████  ███    ██
// ██ ████  ████ ██   ██ ██      ██      ████  ████ ██      ████   ██    ██    ██   ██    ██    ██ ██    ██ ████   ██
// ██ ██ ████ ██ ██████  ██      █████   ██ ████ ██ █████   ██ ██  ██    ██    ███████    ██    ██ ██    ██ ██ ██  ██
// ██ ██  ██  ██ ██      ██      ██      ██  ██  ██ ██      ██  ██ ██    ██    ██   ██    ██    ██ ██    ██ ██  ██ ██
// ██ ██      ██ ██      ███████ ███████ ██      ██ ███████ ██   ████    ██    ██   ██    ██    ██  ██████  ██   ████
//
// >>implementation
when !(defined(SOKOL_DEBUG)) {
}
private {
_sfetch_t* _sfetch;
// ██       ██████   ██████   ██████  ██ ███    ██  ██████
// ██      ██    ██ ██       ██       ██ ████   ██ ██
// ██      ██    ██ ██   ███ ██   ███ ██ ██ ██  ██ ██   ███
// ██      ██    ██ ██    ██ ██    ██ ██ ██  ██ ██ ██    ██
// ███████  ██████   ██████   ██████  ██ ██   ████  ██████
//
// >>logging
u8*[14] _sfetch_log_messages = {
    "OK: Ok", "MALLOC_FAILED: memory allocation failed",
    "FILE_PATH_UTF8_DECODING_FAILED: failed converting file path from UTF8 to wide",
    "SEND_QUEUE_FULL: send queue full (adjust via sfetch_desc_t.max_requests)",
    "REQUEST_CHANNEL_INDEX_TOO_BIG: channel index too big (adjust via sfetch_desc_t.num_channels)",
    "REQUEST_PATH_IS_NULL: file path is nullptr (sfetch_request_t.path)",
    "REQUEST_PATH_TOO_LONG: file path is too long (SFETCH_MAX_PATH)",
    "REQUEST_CALLBACK_MISSING: no callback provided (sfetch_request_t.callback)",
    "REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE: chunk size is greater buffer size (sfetch_request_t.chunk_size vs .buffer.size)",
    "REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL: user data ptr is set but user data size is null (sfetch_request_t.user_data.ptr vs .size)",
    "REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT: user data ptr is null but size is not (sfetch_request_t.user_data.ptr vs .size)",
    "REQUEST_USERDATA_SIZE_TOO_BIG: user data size too big (see SFETCH_MAX_USERDATA_UINT64)",
    "CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS: clamping num channels to SFETCH_MAX_CHANNELS",
    "REQUEST_POOL_EXHAUSTED: request pool exhausted (tweak via sfetch_desc_t.max_requests)",
};

void _sfetch_log(sfetch_log_item_t log_item, u32 log_level, u32 line_nr) {
    if _sfetch.desc.logger.func != null {
        u8* filename = "sokol_fetch.h";
        u8* message = _sfetch_log_messages[log_item];
        _sfetch.desc.logger.func("sfetch", log_level, cast(u32, log_item), message, line_nr, filename, _sfetch.desc.logger.user_data);
    } else {
        if log_level == 0 {
            abort();
        }
    }
}

// ███    ███ ███████ ███    ███  ██████  ██████  ██    ██
// ████  ████ ██      ████  ████ ██    ██ ██   ██  ██  ██
// ██ ████ ██ █████   ██ ████ ██ ██    ██ ██████    ████
// ██  ██  ██ ██      ██  ██  ██ ██    ██ ██   ██    ██
// ██      ██ ███████ ██      ██  ██████  ██   ██    ██
//
// >>memory
void _sfetch_clear(void* ptr, u64 size) {
    memset(ptr, 0, size);
}

void* _sfetch_malloc_with_allocator(sfetch_allocator_t* allocator, u64 size) {
    void* ptr;
    if allocator.alloc_fn != null {
        ptr = allocator.alloc_fn(size, allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    if null == ptr {
        _sfetch_log(SFETCH_LOGITEM_MALLOC_FAILED, 0, 1376);
    }
    return ptr;
}

void* _sfetch_malloc(u64 size) {
    return _sfetch_malloc_with_allocator(&_sfetch.desc.allocator, size);
}

void* _sfetch_malloc_clear(u64 size) {
    void* ptr = _sfetch_malloc(size);
    _sfetch_clear(ptr, size);
    return ptr;
}

void _sfetch_free(void* ptr) {
    if _sfetch.desc.allocator.free_fn != null {
        _sfetch.desc.allocator.free_fn(ptr, _sfetch.desc.allocator.user_data);
    } else {
        free(ptr);
    }
}

_sfetch_t* _sfetch_ctx() {
    return _sfetch;
}

void _sfetch_path_copy(_sfetch_path_t* dst, u8* src) {
    if src && strlen(src) < 1024 {
        strncpy(dst.buf, src, cast(u64, 1024));
        dst.buf[1024 - 1] = 0;
    } else {
        _sfetch_clear(dst.buf, 1024);
    }
}

_sfetch_path_t _sfetch_path_make(u8* str_var) {
    noinit _sfetch_path_t res;
    _sfetch_path_copy(&res, str_var);
    return res;
}

// ███    ███ ███████ ███████ ███████  █████   ██████  ███████      ██████  ██    ██ ███████ ██    ██ ███████
// ████  ████ ██      ██      ██      ██   ██ ██       ██          ██    ██ ██    ██ ██      ██    ██ ██
// ██ ████ ██ █████   ███████ ███████ ███████ ██   ███ █████       ██    ██ ██    ██ █████   ██    ██ █████
// ██  ██  ██ ██           ██      ██ ██   ██ ██    ██ ██          ██ ▄▄ ██ ██    ██ ██      ██    ██ ██
// ██      ██ ███████ ███████ ███████ ██   ██  ██████  ███████      ██████   ██████  ███████  ██████  ███████
//                                                                     ▀▀
// >>message queue
u32 _sfetch_ring_wrap(_sfetch_ring_t* rb, u32 i) {
    return i % rb.num;
}

void _sfetch_ring_discard(_sfetch_ring_t* rb) {
    if rb.buf != null {
        _sfetch_free(rb.buf);
        rb.buf = null;
    }
    rb.head = 0;
    rb.tail = 0;
    rb.num = 0;
}

bool _sfetch_ring_init(_sfetch_ring_t* rb, u32 num_slots) {
    rb.head = 0;
    rb.tail = 0;
    rb.num = num_slots + 1;
    var queue_size = cast(u64, rb.num * sizeof(sfetch_handle_t));
    rb.buf = cast(u32*, _sfetch_malloc_clear(queue_size));
    if rb.buf != null {
        return true;
    } else {
        _sfetch_ring_discard(rb);
        return false;
    }
}

bool _sfetch_ring_full(_sfetch_ring_t* rb) {
    return _sfetch_ring_wrap(rb, rb.head + 1) == rb.tail;
}

bool _sfetch_ring_empty(_sfetch_ring_t* rb) {
    return rb.head == rb.tail;
}

u32 _sfetch_ring_count(_sfetch_ring_t* rb) {
    u32 count;
    if rb.head >= rb.tail {
        count = rb.head - rb.tail;
    } else {
        count = rb.head + rb.num - rb.tail;
    }
    return count;
}

void _sfetch_ring_enqueue(_sfetch_ring_t* rb, u32 slot_id) {
    rb.buf[rb.head] = slot_id;
    rb.head = _sfetch_ring_wrap(rb, rb.head + 1);
}

u32 _sfetch_ring_dequeue(_sfetch_ring_t* rb) {
    u32 slot_id = rb.buf[rb.tail];
    rb.tail = _sfetch_ring_wrap(rb, rb.tail + 1);
    return slot_id;
}

u32 _sfetch_ring_peek(_sfetch_ring_t* rb, u32 index) {
    u32 rb_index = _sfetch_ring_wrap(rb, rb.tail + index);
    return rb.buf[rb_index];
}

// ██████  ███████  ██████  ██    ██ ███████ ███████ ████████     ██████   ██████   ██████  ██
// ██   ██ ██      ██    ██ ██    ██ ██      ██         ██        ██   ██ ██    ██ ██    ██ ██
// ██████  █████   ██    ██ ██    ██ █████   ███████    ██        ██████  ██    ██ ██    ██ ██
// ██   ██ ██      ██ ▄▄ ██ ██    ██ ██           ██    ██        ██      ██    ██ ██    ██ ██
// ██   ██ ███████  ██████   ██████  ███████ ███████    ██        ██       ██████   ██████  ███████
//                     ▀▀
// >>request pool
u32 _sfetch_make_id(u32 index, u32 gen_ctr) {
    return gen_ctr << 16 | index & 0xFFFF;
}

sfetch_handle_t _sfetch_make_handle(u32 slot_id) {
    noinit sfetch_handle_t h;
    h.id = slot_id;
    return h;
}

u32 _sfetch_slot_index(u32 slot_id) {
    return slot_id & 0xFFFF;
}

void _sfetch_item_init(_sfetch_item_t* item, u32 slot_id, sfetch_request_t* request) {
    _sfetch_clear(item, cast(u64, sizeof(_sfetch_item_t)));
    item.handle.id = slot_id;
    item.state = _SFETCH_STATE_INITIAL;
    item.channel = request.channel;
    item.chunk_size = request.chunk_size;
    item.lane = 0xFFFFFFFF;
    item.callback = request.callback;
    item.buffer = request.buffer;
    item.path = _sfetch_path_make(request.path);
    item.thread.file_handle = null;
    if request.user_data.ptr && request.user_data.size > 0 && request.user_data.size <= cast(u64, 16 * 8) {
        item.user.user_data_size = request.user_data.size;
        memcpy(item.user.user_data, request.user_data.ptr, request.user_data.size);
    }
}

void _sfetch_item_discard(_sfetch_item_t* item) {
    _sfetch_clear(item, cast(u64, sizeof(_sfetch_item_t)));
}

void _sfetch_pool_discard(_sfetch_pool_t* pool) {
    if pool.free_slots != null {
        _sfetch_free(pool.free_slots);
        pool.free_slots = null;
    }
    if pool.gen_ctrs != null {
        _sfetch_free(pool.gen_ctrs);
        pool.gen_ctrs = null;
    }
    if pool.items != null {
        _sfetch_free(pool.items);
        pool.items = null;
    }
    pool.size = 0;
    pool.free_top = 0;
    pool.valid = false;
}

bool _sfetch_pool_init(_sfetch_pool_t* pool, u32 num_items) {
    pool.size = num_items + 1;
    pool.free_top = 0;
    var items_size = cast(u64, pool.size * sizeof(_sfetch_item_t));
    pool.items = cast(_sfetch_item_t*, _sfetch_malloc_clear(items_size));
    var gen_ctrs_size = cast(u64, sizeof(u32) * pool.size);
    pool.gen_ctrs = cast(u32*, _sfetch_malloc_clear(gen_ctrs_size));
    var free_slots_size = cast(u64, num_items * sizeof(i32));
    pool.free_slots = cast(u32*, _sfetch_malloc_clear(free_slots_size));
    if pool.items && pool.free_slots {
        for u32 i = pool.size - 1; i >= 1; i-- {
            pool.free_slots[pool.free_top++] = i;
        }
        pool.valid = true;
    } else {
        _sfetch_pool_discard(pool);
    }
    return pool.valid;
}

u32 _sfetch_pool_item_alloc(_sfetch_pool_t* pool, sfetch_request_t* request) {
    if pool.free_top > 0 {
        u32 slot_index = pool.free_slots[--pool.free_top];
        u32 slot_id = _sfetch_make_id(slot_index, ++pool.gen_ctrs[slot_index]);
        _sfetch_item_init(&pool.items[slot_index], slot_id, request);
        pool.items[slot_index].state = _SFETCH_STATE_ALLOCATED;
        return slot_id;
    } else {
        return _sfetch_make_id(0, 0);
    }
}

void _sfetch_pool_item_free(_sfetch_pool_t* pool, u32 slot_id) {
    u32 slot_index = _sfetch_slot_index(slot_id);
    for u32 i = 0; i < pool.free_top; i++ {
    }
    _sfetch_item_discard(&pool.items[slot_index]);
    pool.free_slots[pool.free_top++] = slot_index;
}

/* return pointer to item by handle without matching id check */
_sfetch_item_t* _sfetch_pool_item_at(_sfetch_pool_t* pool, u32 slot_id) {
    u32 slot_index = _sfetch_slot_index(slot_id);
    return &pool.items[slot_index];
}

/* return pointer to item by handle with matching id check */
_sfetch_item_t* _sfetch_pool_item_lookup(_sfetch_pool_t* pool, u32 slot_id) {
    if 0 != slot_id {
        _sfetch_item_t* item = _sfetch_pool_item_at(pool, slot_id);
        if item.handle.id == slot_id {
            return item;
        }
    }
    return null;
}

// ██████   ██████  ███████ ██ ██   ██
// ██   ██ ██    ██ ██      ██  ██ ██
// ██████  ██    ██ ███████ ██   ███
// ██      ██    ██      ██ ██  ██ ██
// ██       ██████  ███████ ██ ██   ██
//
// >>posix
_sfetch_file_handle_t _sfetch_file_open(_sfetch_path_t* path) {
    return fopen(path.buf, "rb");
}

void _sfetch_file_close(_sfetch_file_handle_t h) {
    fclose(h);
}

bool _sfetch_file_handle_valid(_sfetch_file_handle_t h) {
    return h != null;
}

u32 _sfetch_file_size(_sfetch_file_handle_t h) {
    fseek(h, 0, 2);
    i64 fpos = ftell(h);
    return cast(u32, fpos);
}

bool _sfetch_file_read(_sfetch_file_handle_t h, u32 offset, u32 num_bytes, void* ptr) {
    fseek(h, cast(i64, offset), 0);
    return num_bytes == fread(ptr, cast(u64, 1), cast(u64, num_bytes), h);
}

bool _sfetch_thread_init(_sfetch_thread_t* thread, _sfetch_thread_func_t thread_func, void* thread_arg) {
    noinit pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutex_init(&thread.incoming_mutex, &attr);
    pthread_mutexattr_destroy(&attr);
    pthread_mutexattr_init(&attr);
    pthread_mutex_init(&thread.outgoing_mutex, &attr);
    pthread_mutexattr_destroy(&attr);
    pthread_mutexattr_init(&attr);
    pthread_mutex_init(&thread.running_mutex, &attr);
    pthread_mutexattr_destroy(&attr);
    pthread_mutexattr_init(&attr);
    pthread_mutex_init(&thread.stop_mutex, &attr);
    pthread_mutexattr_destroy(&attr);
    noinit pthread_condattr_t cond_attr;
    pthread_condattr_init(&cond_attr);
    pthread_cond_init(&thread.incoming_cond, &cond_attr);
    pthread_condattr_destroy(&cond_attr);
    pthread_mutex_lock(&thread.running_mutex);
    i32 res = pthread_create(&thread.thread, null, thread_func, thread_arg);
    thread.valid = 0 == res;
    pthread_mutex_unlock(&thread.running_mutex);
    return thread.valid;
}

void _sfetch_thread_request_stop(_sfetch_thread_t* thread) {
    pthread_mutex_lock(&thread.stop_mutex);
    thread.stop_requested = true;
    pthread_mutex_unlock(&thread.stop_mutex);
}

bool _sfetch_thread_stop_requested(_sfetch_thread_t* thread) {
    pthread_mutex_lock(&thread.stop_mutex);
    bool stop_requested = thread.stop_requested;
    pthread_mutex_unlock(&thread.stop_mutex);
    return stop_requested;
}

void _sfetch_thread_join(_sfetch_thread_t* thread) {
    if thread.valid != 0 {
        pthread_mutex_lock(&thread.incoming_mutex);
        _sfetch_thread_request_stop(thread);
        pthread_cond_signal(&thread.incoming_cond);
        pthread_mutex_unlock(&thread.incoming_mutex);
        pthread_join(thread.thread, null);
        thread.valid = false;
    }
    pthread_mutex_destroy(&thread.stop_mutex);
    pthread_mutex_destroy(&thread.running_mutex);
    pthread_mutex_destroy(&thread.incoming_mutex);
    pthread_mutex_destroy(&thread.outgoing_mutex);
    pthread_cond_destroy(&thread.incoming_cond);
}

/* called when the thread-func is entered, this blocks the thread func until
   the _sfetch_thread_t object is fully initialized
*/
void _sfetch_thread_entered(_sfetch_thread_t* thread) {
    pthread_mutex_lock(&thread.running_mutex);
}

/* called by the thread-func right before it is left */
void _sfetch_thread_leaving(_sfetch_thread_t* thread) {
    pthread_mutex_unlock(&thread.running_mutex);
}

void _sfetch_thread_enqueue_incoming(_sfetch_thread_t* thread, _sfetch_ring_t* incoming, _sfetch_ring_t* src) {
    if _sfetch_ring_empty(src) == 0 {
        pthread_mutex_lock(&thread.incoming_mutex);
        while !_sfetch_ring_full(incoming) && !_sfetch_ring_empty(src) {
            _sfetch_ring_enqueue(incoming, _sfetch_ring_dequeue(src));
        }
        pthread_cond_signal(&thread.incoming_cond);
        pthread_mutex_unlock(&thread.incoming_mutex);
    }
}

u32 _sfetch_thread_dequeue_incoming(_sfetch_thread_t* thread, _sfetch_ring_t* incoming) {
    pthread_mutex_lock(&thread.incoming_mutex);
    while _sfetch_ring_empty(incoming) && !thread.stop_requested {
        pthread_cond_wait(&thread.incoming_cond, &thread.incoming_mutex);
    }
    u32 item = 0;
    if thread.stop_requested == 0 {
        item = _sfetch_ring_dequeue(incoming);
    }
    pthread_mutex_unlock(&thread.incoming_mutex);
    return item;
}

void _sfetch_thread_enqueue_outgoing(_sfetch_thread_t* thread, _sfetch_ring_t* outgoing, u32 item) {
    pthread_mutex_lock(&thread.outgoing_mutex);
    if _sfetch_ring_full(outgoing) == 0 {
        _sfetch_ring_enqueue(outgoing, item);
    }
    pthread_mutex_unlock(&thread.outgoing_mutex);
}

void _sfetch_thread_dequeue_outgoing(_sfetch_thread_t* thread, _sfetch_ring_t* outgoing, _sfetch_ring_t* dst) {
    pthread_mutex_lock(&thread.outgoing_mutex);
    while !_sfetch_ring_full(dst) && !_sfetch_ring_empty(outgoing) {
        _sfetch_ring_enqueue(dst, _sfetch_ring_dequeue(outgoing));
    }
    pthread_mutex_unlock(&thread.outgoing_mutex);
}

// ██     ██ ██ ███    ██ ██████   ██████  ██     ██ ███████
// ██     ██ ██ ████   ██ ██   ██ ██    ██ ██     ██ ██
// ██  █  ██ ██ ██ ██  ██ ██   ██ ██    ██ ██  █  ██ ███████
// ██ ███ ██ ██ ██  ██ ██ ██   ██ ██    ██ ██ ███ ██      ██
//  ███ ███  ██ ██   ████ ██████   ██████   ███ ███  ███████
//
// >>windows
//  ██████ ██   ██  █████  ███    ██ ███    ██ ███████ ██      ███████
// ██      ██   ██ ██   ██ ████   ██ ████   ██ ██      ██      ██
// ██      ███████ ███████ ██ ██  ██ ██ ██  ██ █████   ██      ███████
// ██      ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██           ██
//  ██████ ██   ██ ██   ██ ██   ████ ██   ████ ███████ ███████ ███████
//
// >>channels
/* per-channel request handler for native platforms accessing the local filesystem */
void _sfetch_request_handler(_sfetch_t* ctx, u32 slot_id) {
    _sfetch_state_t state;
    _sfetch_path_t* path;
    _sfetch_item_thread_t* thread;
    sfetch_range_t* buffer;
    u32 chunk_size;
    {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item == null {
            return;
        }
        state = item.state;
        path = &item.path;
        thread = &item.thread;
        buffer = &item.buffer;
        chunk_size = item.chunk_size;
    }
    if thread.failed != 0 {
        return;
    }
    if state == _SFETCH_STATE_FETCHING {
        if buffer.ptr == null || buffer.size == 0 {
            thread.error_code = SFETCH_ERROR_NO_BUFFER;
            thread.failed = true;
        } else {
            if _sfetch_file_handle_valid(thread.file_handle) == 0 {
                thread.file_handle = _sfetch_file_open(path);
                if _sfetch_file_handle_valid(thread.file_handle) != 0 {
                    thread.content_size = _sfetch_file_size(thread.file_handle);
                } else {
                    thread.error_code = SFETCH_ERROR_FILE_NOT_FOUND;
                    thread.failed = true;
                }
            }
            if thread.failed == 0 {
                u32 read_offset = 0;
                u32 bytes_to_read = 0;
                if chunk_size == 0 {
                    if thread.content_size <= buffer.size {
                        bytes_to_read = thread.content_size;
                        read_offset = 0;
                    } else {
                        thread.error_code = SFETCH_ERROR_BUFFER_TOO_SMALL;
                        thread.failed = true;
                    }
                } else {
                    if chunk_size <= buffer.size {
                        bytes_to_read = chunk_size;
                        read_offset = thread.fetched_offset;
                        if read_offset + bytes_to_read > thread.content_size {
                            bytes_to_read = thread.content_size - read_offset;
                        }
                    } else {
                        thread.error_code = SFETCH_ERROR_BUFFER_TOO_SMALL;
                        thread.failed = true;
                    }
                }
                if thread.failed == 0 {
                    if _sfetch_file_read(thread.file_handle, read_offset, bytes_to_read, buffer.ptr) != 0 {
                        thread.fetched_size = bytes_to_read;
                        thread.fetched_offset += bytes_to_read;
                    } else {
                        thread.error_code = SFETCH_ERROR_UNEXPECTED_EOF;
                        thread.failed = true;
                    }
                }
            }
        }
        if thread.failed || thread.fetched_offset == thread.content_size {
            if _sfetch_file_handle_valid(thread.file_handle) != 0 {
                _sfetch_file_close(thread.file_handle);
                thread.file_handle = null;
            }
            thread.finished = true;
        }
    }
}

void* _sfetch_channel_thread_func(void* arg) {
    var chn = cast(_sfetch_channel_t*, arg);
    _sfetch_thread_entered(&chn.thread);
    while _sfetch_thread_stop_requested(&chn.thread) == 0 {
        u32 slot_id = _sfetch_thread_dequeue_incoming(&chn.thread, &chn.thread_incoming);
        if _sfetch_thread_stop_requested(&chn.thread) == 0 {
            chn.request_handler(chn.ctx, slot_id);
            _sfetch_thread_enqueue_outgoing(&chn.thread, &chn.thread_outgoing, slot_id);
        }
    }
    _sfetch_thread_leaving(&chn.thread);
    return null;
}

void _sfetch_channel_discard(_sfetch_channel_t* chn) {
    if chn.valid != 0 {
        _sfetch_thread_join(&chn.thread);
    }
    _sfetch_ring_discard(&chn.thread_incoming);
    _sfetch_ring_discard(&chn.thread_outgoing);
    _sfetch_ring_discard(&chn.free_lanes);
    _sfetch_ring_discard(&chn.user_sent);
    _sfetch_ring_discard(&chn.user_incoming);
    _sfetch_ring_discard(&chn.user_outgoing);
    _sfetch_ring_discard(&chn.free_lanes);
    chn.valid = false;
}

bool _sfetch_channel_init(_sfetch_channel_t* chn, _sfetch_t* ctx, u32 num_items, u32 num_lanes, fn(_sfetch_t*, u32): void request_handler) {
    bool valid = true;
    chn.request_handler = request_handler;
    chn.ctx = ctx;
    valid &= _sfetch_ring_init(&chn.free_lanes, num_lanes);
    for u32 lane = 0; lane < num_lanes; lane++ {
        _sfetch_ring_enqueue(&chn.free_lanes, lane);
    }
    valid &= _sfetch_ring_init(&chn.user_sent, num_items);
    valid &= _sfetch_ring_init(&chn.user_incoming, num_lanes);
    valid &= _sfetch_ring_init(&chn.user_outgoing, num_lanes);
    valid &= _sfetch_ring_init(&chn.thread_incoming, num_lanes);
    valid &= _sfetch_ring_init(&chn.thread_outgoing, num_lanes);
    if valid != 0 {
        chn.valid = true;
        _sfetch_thread_init(&chn.thread, _sfetch_channel_thread_func, chn);
        return true;
    } else {
        _sfetch_channel_discard(chn);
        return false;
    }
}

/* put a request into the channels sent-queue, this is where all new requests
   are stored until a lane becomes free.
*/
bool _sfetch_channel_send(_sfetch_channel_t* chn, u32 slot_id) {
    if _sfetch_ring_full(&chn.user_sent) == 0 {
        _sfetch_ring_enqueue(&chn.user_sent, slot_id);
        return true;
    } else {
        _sfetch_log(SFETCH_LOGITEM_SEND_QUEUE_FULL, 1, 1377);
        return false;
    }
}

void _sfetch_invoke_response_callback(_sfetch_item_t* item) {
    noinit sfetch_response_t response;
    _sfetch_clear(&response, cast(u64, sizeof(response)));
    response.handle = item.handle;
    response.dispatched = item.state == _SFETCH_STATE_DISPATCHED;
    response.fetched = item.state == _SFETCH_STATE_FETCHED;
    response.paused = item.state == _SFETCH_STATE_PAUSED;
    response.finished = item.user.finished;
    response.failed = item.state == _SFETCH_STATE_FAILED;
    response.cancelled = item.user.cancel;
    response.error_code = item.user.error_code;
    response.channel = item.channel;
    response.lane = item.lane;
    response.path = item.path.buf;
    response.user_data = item.user.user_data;
    response.data_offset = item.user.fetched_offset - item.user.fetched_size;
    response.data.ptr = item.buffer.ptr;
    response.data.size = item.user.fetched_size;
    response.buffer = item.buffer;
    item.callback(&response);
}

void _sfetch_cancel_item(_sfetch_item_t* item) {
    item.state = _SFETCH_STATE_FAILED;
    item.user.finished = true;
    item.user.error_code = SFETCH_ERROR_CANCELLED;
}

/* per-frame channel stuff: move requests in and out of the IO threads, call response callbacks */
void _sfetch_channel_dowork(_sfetch_channel_t* chn, _sfetch_pool_t* pool) {
    u32 num_sent = _sfetch_ring_count(&chn.user_sent);
    u32 avail_lanes = _sfetch_ring_count(&chn.free_lanes);
    u32 num_move = num_sent < avail_lanes ? num_sent : avail_lanes;
    for u32 i = 0; i < num_move; i++ {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_sent);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
            _sfetch_invoke_response_callback(item);
            _sfetch_pool_item_free(pool, slot_id);
            continue;
        }
        item.state = _SFETCH_STATE_DISPATCHED;
        item.lane = _sfetch_ring_dequeue(&chn.free_lanes);
        if null == item.buffer.ptr {
            _sfetch_invoke_response_callback(item);
        }
        _sfetch_ring_enqueue(&chn.user_incoming, slot_id);
    }
    u32 num_incoming = _sfetch_ring_count(&chn.user_incoming);
    for u32 i = 0; i < num_incoming; i++ {
        u32 slot_id = _sfetch_ring_peek(&chn.user_incoming, i);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        if item.user.pause != 0 {
            item.state = _SFETCH_STATE_PAUSED;
            item.user.pause = false;
        }
        if item.user.cont != 0 {
            if item.state == _SFETCH_STATE_PAUSED {
                item.state = _SFETCH_STATE_FETCHED;
            }
            item.user.cont = false;
        }
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
        }
        switch item.state {
            case _SFETCH_STATE_DISPATCHED, _SFETCH_STATE_FETCHED: {
                item.state = _SFETCH_STATE_FETCHING;
            }
            default: {
            }
        }
    }
    _sfetch_thread_enqueue_incoming(&chn.thread, &chn.thread_incoming, &chn.user_incoming);
    _sfetch_thread_dequeue_outgoing(&chn.thread, &chn.thread_outgoing, &chn.user_outgoing);
    while _sfetch_ring_empty(&chn.user_outgoing) == 0 {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_outgoing);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        item.user.fetched_offset = item.thread.fetched_offset;
        item.user.fetched_size = item.thread.fetched_size;
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
        } else {
            item.user.error_code = item.thread.error_code;
        }
        if item.thread.finished != 0 {
            item.user.finished = true;
        }
        if item.thread.failed != 0 {
            item.state = _SFETCH_STATE_FAILED;
        } else if item.state == _SFETCH_STATE_FETCHING {
            item.state = _SFETCH_STATE_FETCHED;
        }
        _sfetch_invoke_response_callback(item);
        if item.user.finished != 0 {
            _sfetch_ring_enqueue(&chn.free_lanes, item.lane);
            _sfetch_pool_item_free(pool, slot_id);
        } else {
            _sfetch_ring_enqueue(&chn.user_incoming, slot_id);
        }
    }
}

bool _sfetch_validate_request(_sfetch_t* ctx, sfetch_request_t* req) {
    if req.channel >= ctx.desc.num_channels {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CHANNEL_INDEX_TOO_BIG, 1, 1377);
        return false;
    }
    if req.path == null {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_PATH_IS_NULL, 1, 1377);
        return false;
    }
    if strlen(req.path) >= cast(u64, 1024 - 1) {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_PATH_TOO_LONG, 1, 1377);
        return false;
    }
    if req.callback == null {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CALLBACK_MISSING, 1, 1377);
        return false;
    }
    if req.chunk_size > req.buffer.size {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE, 1, 1377);
        return false;
    }
    if req.user_data.ptr && req.user_data.size == 0 {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL, 1, 1377);
        return false;
    }
    if !req.user_data.ptr && req.user_data.size > 0 {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT, 1, 1377);
        return false;
    }
    if req.user_data.size > cast(u64, 16 * sizeof(u64)) {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_SIZE_TOO_BIG, 1, 1377);
        return false;
    }
    return true;
}

sfetch_desc_t _sfetch_desc_defaults(sfetch_desc_t* desc) {
    sfetch_desc_t res = *desc;
    res.max_requests = cast(u32, desc.max_requests == 0 ? 128 : desc.max_requests);
    res.num_channels = cast(u32, desc.num_channels == 0 ? 1 : desc.num_channels);
    res.num_lanes = cast(u32, desc.num_lanes == 0 ? 1 : desc.num_lanes);
    return res;
}
}

// ██████  ██    ██ ██████  ██      ██  ██████
// ██   ██ ██    ██ ██   ██ ██      ██ ██
// ██████  ██    ██ ██████  ██      ██ ██
// ██      ██    ██ ██   ██ ██      ██ ██
// ██       ██████  ██████  ███████ ██  ██████
//
// >>public
void sfetch_setup(sfetch_desc_t* desc_) {
    sfetch_desc_t desc = _sfetch_desc_defaults(desc_);
    _sfetch = cast(_sfetch_t*, _sfetch_malloc_with_allocator(&desc.allocator, cast(u64, sizeof(_sfetch_t))));
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_clear(ctx, cast(u64, sizeof(_sfetch_t)));
    ctx.desc = desc;
    ctx.setup = true;
    ctx.valid = true;
    if ctx.desc.num_channels > 16 {
        ctx.desc.num_channels = 16;
        _sfetch_log(SFETCH_LOGITEM_CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS, 2, 1378);
    }
    ctx.valid &= _sfetch_pool_init(&ctx.pool, ctx.desc.max_requests);
    for u32 i = 0; i < ctx.desc.num_channels; i++ {
        ctx.valid &= _sfetch_channel_init(&ctx.chn[i], ctx, ctx.desc.max_requests, ctx.desc.num_lanes, cast(fn(_sfetch_t*, u32): void, _sfetch_request_handler));
    }
}

void sfetch_shutdown() {
    _sfetch_t* ctx = _sfetch_ctx();
    ctx.valid = false;
    for u32 i = 0; i < ctx.desc.num_channels; i++ {
        if ctx.chn[i].valid != 0 {
            _sfetch_channel_discard(&ctx.chn[i]);
        }
    }
    _sfetch_pool_discard(&ctx.pool);
    ctx.setup = false;
    _sfetch_free(ctx);
    _sfetch = null;
}

bool sfetch_valid() {
    _sfetch_t* ctx = _sfetch_ctx();
    return ctx && ctx.valid;
}

sfetch_desc_t sfetch_desc() {
    _sfetch_t* ctx = _sfetch_ctx();
    return ctx.desc;
}

i32 sfetch_max_userdata_bytes() {
    return 16 * 8;
}

i32 sfetch_max_path() {
    return 1024;
}

bool sfetch_handle_valid(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    if h.id == 0 {
        return false;
    }
    return null != _sfetch_pool_item_lookup(&ctx.pool, h.id);
}

sfetch_handle_t sfetch_send(sfetch_request_t* request) {
    _sfetch_t* ctx = _sfetch_ctx();
    sfetch_handle_t invalid_handle = _sfetch_make_handle(0);
    if ctx.valid == 0 {
        return invalid_handle;
    }
    if _sfetch_validate_request(ctx, request) == 0 {
        return invalid_handle;
    }
    u32 slot_id = _sfetch_pool_item_alloc(&ctx.pool, request);
    if 0 == slot_id {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_POOL_EXHAUSTED, 2, 1378);
        return invalid_handle;
    }
    if _sfetch_channel_send(&ctx.chn[request.channel], slot_id) == 0 {
        _sfetch_pool_item_free(&ctx.pool, slot_id);
        return invalid_handle;
    }
    return _sfetch_make_handle(slot_id);
}

void sfetch_dowork() {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx.valid == 0 {
        return;
    }
    ctx.in_callback = true;
    for i32 pass = 0; pass < 2; pass++ {
        for u32 chn_index = 0; chn_index < ctx.desc.num_channels; chn_index++ {
            _sfetch_channel_dowork(&ctx.chn[chn_index], &ctx.pool);
        }
    }
    ctx.in_callback = false;
}

void sfetch_bind_buffer(sfetch_handle_t h, sfetch_range_t buffer) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.buffer = buffer;
    }
}

void* sfetch_unbind_buffer(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        var prev_buf_ptr = item.buffer.ptr;
        item.buffer.ptr = null;
        item.buffer.size = 0;
        return prev_buf_ptr;
    } else {
        return null;
    }
}

void sfetch_pause(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.pause = true;
        item.user.cont = false;
    }
}

void sfetch_continue(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.cont = true;
        item.user.pause = false;
    }
}

void sfetch_cancel(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.cont = false;
        item.user.pause = false;
        item.user.cancel = true;
    }
}

}

when os(wasm) {
/*
    sfetch_log_item_t

    Log items are defined via X-Macros, and expanded to an
    enum 'sfetch_log_item', and in debug mode only,
    corresponding strings.

    Used as parameter in the logging callback.
*/
enum sfetch_log_item_t {
    SFETCH_LOGITEM_OK = 0,
    SFETCH_LOGITEM_MALLOC_FAILED = 1,
    SFETCH_LOGITEM_FILE_PATH_UTF8_DECODING_FAILED = 2,
    SFETCH_LOGITEM_SEND_QUEUE_FULL = 3,
    SFETCH_LOGITEM_REQUEST_CHANNEL_INDEX_TOO_BIG = 4,
    SFETCH_LOGITEM_REQUEST_PATH_IS_NULL = 5,
    SFETCH_LOGITEM_REQUEST_PATH_TOO_LONG = 6,
    SFETCH_LOGITEM_REQUEST_CALLBACK_MISSING = 7,
    SFETCH_LOGITEM_REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE = 8,
    SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL = 9,
    SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT = 10,
    SFETCH_LOGITEM_REQUEST_USERDATA_SIZE_TOO_BIG = 11,
    SFETCH_LOGITEM_CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS = 12,
    SFETCH_LOGITEM_REQUEST_POOL_EXHAUSTED = 13,
}

/* error codes */
enum sfetch_error_t {
    SFETCH_ERROR_NO_ERROR = 0,
    SFETCH_ERROR_FILE_NOT_FOUND = 1,
    SFETCH_ERROR_NO_BUFFER = 2,
    SFETCH_ERROR_BUFFER_TOO_SMALL = 3,
    SFETCH_ERROR_UNEXPECTED_EOF = 4,
    SFETCH_ERROR_INVALID_HTTP_STATUS = 5,
    SFETCH_ERROR_CANCELLED = 6,
    SFETCH_ERROR_JS_OTHER = 7,
}

/* a request goes through the following states, ping-ponging between IO and user thread */
enum _sfetch_state_t {
    _SFETCH_STATE_INITIAL = 0,
    _SFETCH_STATE_ALLOCATED = 1,
    _SFETCH_STATE_DISPATCHED = 2,
    _SFETCH_STATE_FETCHING = 3,
    _SFETCH_STATE_FETCHED = 4,
    _SFETCH_STATE_PAUSED = 5,
    _SFETCH_STATE_FAILED = 6,
}

/*
    sfetch_logger_t

    Used in sfetch_desc_t to provide a custom logging and error reporting
    callback to sokol-fetch.
*/
struct sfetch_logger_t {
    fn(u8*, u32, u32, u8*, u32, u8*, void*): void func;
    void* user_data;
}

/*
    sfetch_range_t

    A pointer-size pair struct to pass memory ranges into and out of sokol-fetch.
    When initialized from a value type (array or struct) you can use the
    SFETCH_RANGE() helper macro to build an sfetch_range_t struct.
*/
struct sfetch_range_t {
    void* ptr;
    u64 size;
}

// disabling this for every includer isn't great, but the warnings are also quite pointless
/*
    sfetch_allocator_t

    Used in sfetch_desc_t to provide custom memory-alloc and -free functions
    to sokol_fetch.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct sfetch_allocator_t {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

/* configuration values for sfetch_setup() */
struct sfetch_desc_t {
    u32 max_requests;
    u32 num_channels;
    u32 num_lanes;
    sfetch_allocator_t allocator;
    sfetch_logger_t logger;
}

/* a request handle to identify an active fetch request, returned by sfetch_send() */
struct sfetch_handle_t {
    u32 id;
}

/* the response struct passed to the response callback */
struct sfetch_response_t {
    sfetch_handle_t handle;
    bool dispatched;
    bool fetched;
    bool paused;
    bool finished;
    bool failed;
    bool cancelled;
    sfetch_error_t error_code;
    u32 channel;
    u32 lane;
    u8* path;
    void* user_data;
    u32 data_offset;
    sfetch_range_t data;
    sfetch_range_t buffer;
}

/* request parameters passed to sfetch_send() */
struct sfetch_request_t {
    u32 channel;
    u8* path;
    fn(sfetch_response_t*): void callback;
    u32 chunk_size;
    sfetch_range_t buffer;
    sfetch_range_t user_data;
}

// ███████ ████████ ██████  ██    ██  ██████ ████████ ███████
// ██         ██    ██   ██ ██    ██ ██         ██    ██
// ███████    ██    ██████  ██    ██ ██         ██    ███████
//      ██    ██    ██   ██ ██    ██ ██         ██         ██
// ███████    ██    ██   ██  ██████   ██████    ██    ███████
//
// >>structs
struct _sfetch_path_t {
    u8[1024] buf;
}

/* a thread with incoming and outgoing message queue syncing */
/* file handle abstraction */
/* user-side per-request state */
struct _sfetch_item_user_t {
    bool pause;
    bool cont;
    bool cancel;
    u32 fetched_offset;
    u32 fetched_size;
    sfetch_error_t error_code;
    bool finished;
    u64 user_data_size;
    u64[16] user_data;
}

/* thread-side per-request state */
struct _sfetch_item_thread_t {
    u32 fetched_offset;
    u32 fetched_size;
    sfetch_error_t error_code;
    bool failed;
    bool finished;
    u32 http_range_offset;
    u32 content_size;
}

/* an internal request item */
struct _sfetch_item_t {
    sfetch_handle_t handle;
    _sfetch_state_t state;
    u32 channel;
    u32 lane;
    u32 chunk_size;
    fn(sfetch_response_t*): void callback;
    sfetch_range_t buffer;
    _sfetch_item_thread_t thread;
    _sfetch_item_user_t user;
    _sfetch_path_t path;
}

/* a pool of internal per-request items */
struct _sfetch_pool_t {
    u32 size;
    u32 free_top;
    _sfetch_item_t* items;
    u32* free_slots;
    u32* gen_ctrs;
    bool valid;
}

/* a ringbuffer for pool-slot ids */
struct _sfetch_ring_t {
    u32 head;
    u32 tail;
    u32 num;
    u32* buf;
}

struct _sfetch_channel_t {
    _sfetch_t* ctx;
    _sfetch_ring_t free_lanes;
    _sfetch_ring_t user_sent;
    _sfetch_ring_t user_incoming;
    _sfetch_ring_t user_outgoing;
    fn(_sfetch_t*, u32): void request_handler;
    bool valid;
}

/* the sfetch global state */
struct _sfetch_t {
    bool setup;
    bool valid;
    bool in_callback;
    sfetch_desc_t desc;
    _sfetch_pool_t pool;
    _sfetch_channel_t[16] chn;
}

/*
    sokol_fetch.h -- asynchronous data loading/streaming

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_FETCH_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)             - your own assert macro (default: assert(c))
    SOKOL_UNREACHABLE()         - a guard macro for unreachable code (default: assert(false))
    SOKOL_FETCH_API_DECL        - public function declaration prefix (default: extern)
    SOKOL_API_DECL              - same as SOKOL_FETCH_API_DECL
    SOKOL_API_IMPL              - public function implementation prefix (default: -)
    SFETCH_MAX_PATH             - max length of UTF-8 filesystem path / URL (default: 1024 bytes)
    SFETCH_MAX_USERDATA_UINT64  - max size of embedded userdata in number of uint64_t, userdata
                                  will be copied into an 8-byte aligned memory region associated
                                  with each in-flight request, default value is 16 (== 128 bytes)
    SFETCH_MAX_CHANNELS         - max number of IO channels (default is 16, also see sfetch_desc_t.num_channels)

    If sokol_fetch.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_FETCH_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    NOTE: The following documentation talks a lot about "IO threads". Actual
    threads are only used on platforms where threads are available. The web
    version (emscripten/wasm) doesn't use POSIX-style threads, but instead
    asynchronous Javascript calls chained together by callbacks. The actual
    source code differences between the two approaches have been kept to
    a minimum though.

    FEATURE OVERVIEW
    ================

    - Asynchronously load complete files, or stream files incrementally via
      HTTP (on web platform), or the local file system (on native platforms)

    - Request / response-callback model, user code sends a request
      to initiate a file-load, sokol_fetch.h calls the response callback
      on the same thread when data is ready or user-code needs
      to respond otherwise

    - Not limited to the main-thread or a single thread: A sokol-fetch
      "context" can live on any thread, and multiple contexts
      can operate side-by-side on different threads.

    - Memory management for data buffers is under full control of user code.
      sokol_fetch.h won't allocate memory after it has been setup.

    - Automatic rate-limiting guarantees that only a maximum number of
      requests is processed at any one time, allowing a zero-allocation
      model, where all data is streamed into fixed-size, pre-allocated
      buffers.

    - Active Requests can be paused, continued and cancelled from anywhere
      in the user-thread which sent this request.


    TL;DR EXAMPLE CODE
    ==================
    This is the most-simple example code to load a single data file with a
    known maximum size:

    (1) initialize sokol-fetch with default parameters (but NOTE that the
        default setup parameters provide a safe-but-slow "serialized"
        operation). In order to see any logging output in case of errors
        you should always provide a logging function
        (such as 'slog_func' from sokol_log.h):

        sfetch_setup(&(sfetch_desc_t){ .logger.func = slog_func });

    (2) send a fetch-request to load a file from the current directory
        into a buffer big enough to hold the entire file content:

        static uint8_t buf[MAX_FILE_SIZE];

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer = {
                .ptr = buf,
                .size = sizeof(buf)
            }
        });

        If 'buf' is a value (e.g. an array or struct item), the .buffer item can
        be initialized with the SFETCH_RANGE() helper macro:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer = SFETCH_RANGE(buf)
        });

    (3) write a 'response-callback' function, this will be called whenever
        the user-code must respond to state changes of the request
        (most importantly when data has been loaded):

        void response_callback(const sfetch_response_t* response) {
            if (response->fetched) {
                // data has been loaded, and is available via the
                // sfetch_range_t struct item 'data':
                const void* ptr = response->data.ptr;
                size_t num_bytes = response->data.size;
            }
            if (response->finished) {
                // the 'finished'-flag is the catch-all flag for when the request
                // is finished, no matter if loading was successful or failed,
                // so any cleanup-work should happen here...
                ...
                if (response->failed) {
                    // 'failed' is true in (addition to 'finished') if something
                    // went wrong (file doesn't exist, or less bytes could be
                    // read from the file than expected)
                }
            }
        }

    (4) pump the sokol-fetch message queues, and invoke response callbacks
        by calling:

        sfetch_dowork();

        In an event-driven app this should be called in the event loop. If you
        use sokol-app this would be in your frame_cb function.

    (5) finally, call sfetch_shutdown() at the end of the application:

    There's many other loading-scenarios, for instance one doesn't have to
    provide a buffer upfront, this can also happen in the response callback.

    Or it's possible to stream huge files into small fixed-size buffer,
    complete with pausing and continuing the download.

    It's also possible to improve the 'pipeline throughput' by fetching
    multiple files in parallel, but at the same time limit the maximum
    number of requests that can be 'in-flight'.

    For how this all works, please read the following documentation sections :)


    API DOCUMENTATION
    =================

    void sfetch_setup(const sfetch_desc_t* desc)
    --------------------------------------------
    First call sfetch_setup(const sfetch_desc_t*) on any thread before calling
    any other sokol-fetch functions on the same thread.

    sfetch_setup() takes a pointer to an sfetch_desc_t struct with setup
    parameters. Parameters which should use their default values must
    be zero-initialized:

        - max_requests (uint32_t):
            The maximum number of requests that can be alive at any time, the
            default is 128.

        - num_channels (uint32_t):
            The number of "IO channels" used to parallelize and prioritize
            requests, the default is 1.

        - num_lanes (uint32_t):
            The number of "lanes" on a single channel. Each request which is
            currently 'inflight' on a channel occupies one lane until the
            request is finished. This is used for automatic rate-limiting
            (search below for CHANNELS AND LANES for more details). The
            default number of lanes is 1.

    For example, to setup sokol-fetch for max 1024 active requests, 4 channels,
    and 8 lanes per channel in C99:

        sfetch_setup(&(sfetch_desc_t){
            .max_requests = 1024,
            .num_channels = 4,
            .num_lanes = 8
        });

    sfetch_setup() is the only place where sokol-fetch will allocate memory.

    NOTE that the default setup parameters of 1 channel and 1 lane per channel
    has a very poor 'pipeline throughput' since this essentially serializes
    IO requests (a new request will only be processed when the last one has
    finished), and since each request needs at least one roundtrip between
    the user- and IO-thread the throughput will be at most one request per
    frame. Search for LATENCY AND THROUGHPUT below for more information on
    how to increase throughput.

    NOTE that you can call sfetch_setup() on multiple threads, each thread
    will get its own thread-local sokol-fetch instance, which will work
    independently from sokol-fetch instances on other threads.

    void sfetch_shutdown(void)
    --------------------------
    Call sfetch_shutdown() at the end of the application to stop any
    IO threads and free all memory that was allocated in sfetch_setup().

    sfetch_handle_t sfetch_send(const sfetch_request_t* request)
    ------------------------------------------------------------
    Call sfetch_send() to start loading data, the function takes a pointer to an
    sfetch_request_t struct with request parameters and returns a
    sfetch_handle_t identifying the request for later calls. At least
    a path/URL and callback must be provided:

        sfetch_handle_t h = sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback
        });

    sfetch_send() will return an invalid handle if no request can be allocated
    from the internal pool because all available request items are 'in-flight'.

    The sfetch_request_t struct contains the following parameters (optional
    parameters that are not provided must be zero-initialized):

        - path (const char*, required)
            Pointer to an UTF-8 encoded C string describing the filesystem
            path or HTTP URL. The string will be copied into an internal data
            structure, and passed "as is" (apart from any required
            encoding-conversions) to fopen(), CreateFileW() or
            the html fetch API call. The maximum length of the string is defined by
            the SFETCH_MAX_PATH configuration define, the default is 1024 bytes
            including the 0-terminator byte.

        - callback (sfetch_callback_t, required)
            Pointer to a response-callback function which is called when the
            request needs "user code attention". Search below for REQUEST
            STATES AND THE RESPONSE CALLBACK for detailed information about
            handling responses in the response callback.

        - channel (uint32_t, optional)
            Index of the IO channel where the request should be processed.
            Channels are used to parallelize and prioritize requests relative
            to each other. Search below for CHANNELS AND LANES for more
            information. The default channel is 0.

        - chunk_size (uint32_t, optional)
            The chunk_size member is used for streaming data incrementally
            in small chunks. After 'chunk_size' bytes have been loaded into
            to the streaming buffer, the response callback will be called
            with the buffer containing the fetched data for the current chunk.
            If chunk_size is 0 (the default), than the whole file will be loaded.
            Please search below for CHUNK SIZE AND HTTP COMPRESSION for
            important information how streaming works if the web server
            is serving compressed data.

        - buffer (sfetch_range_t)
            This is a optional pointer/size pair describing a chunk of memory where
            data will be loaded into (if no buffer is provided upfront, this
            must happen in the response callback). If a buffer is provided,
            it must be big enough to either hold the entire file (if chunk_size
            is zero), or the *uncompressed* data for one downloaded chunk
            (if chunk_size is > 0).

        - user_data (sfetch_range_t)
            The user_data ptr/size range struct describe an optional POD blob
            (plain-old-data) associated with the request which will be copied(!)
            into an internal memory block. The maximum default size of this
            memory block is 128 bytes (but can be overridden by defining
            SFETCH_MAX_USERDATA_UINT64 before including the notification, note
            that this define is in "number of uint64_t", not number of bytes).
            The user-data block is 8-byte aligned, and will be copied via
            memcpy() (so don't put any C++ "smart members" in there).

    NOTE that request handles are strictly thread-local and only unique
    within the thread the handle was created on, and all function calls
    involving a request handle must happen on that same thread.

    bool sfetch_handle_valid(sfetch_handle_t request)
    -------------------------------------------------
    This checks if the provided request handle is valid, and is associated with
    a currently active request. It will return false if:

        - sfetch_send() returned an invalid handle because it couldn't allocate
          a new request from the internal request pool (because they're all
          in flight)
        - the request associated with the handle is no longer alive (because
          it either finished successfully, or the request failed for some
          reason)

    void sfetch_dowork(void)
    ------------------------
    Call sfetch_dowork(void) in regular intervals (for instance once per frame)
    on the same thread as sfetch_setup() to "turn the gears". If you are sending
    requests but never hear back from them in the response callback function, then
    the most likely reason is that you forgot to add the call to sfetch_dowork()
    in the per-frame function.

    sfetch_dowork() roughly performs the following work:

        - any new requests that have been sent with sfetch_send() since the
        last call to sfetch_dowork() will be dispatched to their IO channels
        and assigned a free lane. If all lanes on that channel are occupied
        by requests 'in flight', incoming requests must wait until
        a lane becomes available

        - for all new requests which have been enqueued on a channel which
        don't already have a buffer assigned the response callback will be
        called with (response->dispatched == true) so that the response
        callback can inspect the dynamically assigned lane and bind a buffer
        to the request (search below for CHANNELS AND LANE for more info)

        - a state transition from "user side" to "IO thread side" happens for
        each new request that has been dispatched to a channel.

        - requests dispatched to a channel are either forwarded into that
        channel's worker thread (on native platforms), or cause an HTTP
        request to be sent via an asynchronous fetch() call (on the web
        platform)

        - for all requests which have finished their current IO operation a
        state transition from "IO thread side" to "user side" happens,
        and the response callback is called so that the fetched data
        can be processed.

        - requests which are completely finished (either because the entire
        file content has been loaded, or they are in the FAILED state) are
        freed (this just changes their state in the 'request pool', no actual
        memory is freed)

        - requests which are not yet finished are fed back into the
        'incoming' queue of their channel, and the cycle starts again, this
        only happens for requests which perform data streaming (not load
        the entire file at once).

    void sfetch_cancel(sfetch_handle_t request)
    -------------------------------------------
    This cancels a request in the next sfetch_dowork() call and invokes the
    response callback with (response.failed == true) and (response.finished
    == true) to give user-code a chance to do any cleanup work for the
    request. If sfetch_cancel() is called for a request that is no longer
    alive, nothing bad will happen (the call will simply do nothing).

    void sfetch_pause(sfetch_handle_t request)
    ------------------------------------------
    This pauses an active request in the next sfetch_dowork() call and puts
    it into the PAUSED state. For all requests in PAUSED state, the response
    callback will be called in each call to sfetch_dowork() to give user-code
    a chance to CONTINUE the request (by calling sfetch_continue()). Pausing
    a request makes sense for dynamic rate-limiting in streaming scenarios
    (like video/audio streaming with a fixed number of streaming buffers. As
    soon as all available buffers are filled with download data, downloading
    more data must be prevented to allow video/audio playback to catch up and
    free up empty buffers for new download data.

    void sfetch_continue(sfetch_handle_t request)
    ---------------------------------------------
    Continues a paused request, counterpart to the sfetch_pause() function.

    void sfetch_bind_buffer(sfetch_handle_t request, sfetch_range_t buffer)
    ----------------------------------------------------------------------------------------
    This "binds" a new buffer (as pointer/size pair) to an active request. The
    function *must* be called from inside the response-callback, and there
    must not already be another buffer bound.

    void* sfetch_unbind_buffer(sfetch_handle_t request)
    ---------------------------------------------------
    This removes the current buffer binding from the request and returns
    a pointer to the previous buffer (useful if the buffer was dynamically
    allocated and it must be freed).

    sfetch_unbind_buffer() *must* be called from inside the response callback.

    The usual code sequence to bind a different buffer in the response
    callback might look like this:

        void response_callback(const sfetch_response_t* response) {
            if (response.fetched) {
                ...
                // switch to a different buffer (in the FETCHED state it is
                // guaranteed that the request has a buffer, otherwise it
                // would have gone into the FAILED state
                void* old_buf_ptr = sfetch_unbind_buffer(response.handle);
                free(old_buf_ptr);
                void* new_buf_ptr = malloc(new_buf_size);
                sfetch_bind_buffer(response.handle, new_buf_ptr, new_buf_size);
            }
            if (response.finished) {
                // unbind and free the currently associated buffer,
                // the buffer pointer could be null if the request has failed
                // NOTE that it is legal to call free() with a nullptr,
                // this happens if the request failed to open its file
                // and never goes into the OPENED state
                void* buf_ptr = sfetch_unbind_buffer(response.handle);
                free(buf_ptr);
            }
        }

    sfetch_desc_t sfetch_desc(void)
    -------------------------------
    sfetch_desc() returns a copy of the sfetch_desc_t struct passed to
    sfetch_setup(), with zero-initialized values replaced with
    their default values.

    int sfetch_max_userdata_bytes(void)
    -----------------------------------
    This returns the value of the SFETCH_MAX_USERDATA_UINT64 config
    define, but in number of bytes (so SFETCH_MAX_USERDATA_UINT64*8).

    int sfetch_max_path(void)
    -------------------------
    Returns the value of the SFETCH_MAX_PATH config define.


    REQUEST STATES AND THE RESPONSE CALLBACK
    ========================================
    A request goes through a number of states during its lifetime. Depending
    on the current state of a request, it will be 'owned' either by the
    "user-thread" (where the request was sent) or an IO thread.

    You can think of a request as "ping-ponging" between the IO thread and
    user thread, any actual IO work is done on the IO thread, while
    invocations of the response-callback happen on the user-thread.

    All state transitions and callback invocations happen inside the
    sfetch_dowork() function.

    An active request goes through the following states:

    ALLOCATED (user-thread)

        The request has been allocated in sfetch_send() and is
        waiting to be dispatched into its IO channel. When this
        happens, the request will transition into the DISPATCHED state.

    DISPATCHED (IO thread)

        The request has been dispatched into its IO channel, and a
        lane has been assigned to the request.

        If a buffer was provided in sfetch_send() the request will
        immediately transition into the FETCHING state and start loading
        data into the buffer.

        If no buffer was provided in sfetch_send(), the response
        callback will be called with (response->dispatched == true),
        so that the response callback can bind a buffer to the
        request. Binding the buffer in the response callback makes
        sense if the buffer isn't dynamically allocated, but instead
        a pre-allocated buffer must be selected from the request's
        channel and lane.

        Note that it isn't possible to get a file size in the response callback
        which would help with allocating a buffer of the right size, this is
        because it isn't possible in HTTP to query the file size before the
        entire file is downloaded (...when the web server serves files compressed).

        If opening the file failed, the request will transition into
        the FAILED state with the error code SFETCH_ERROR_FILE_NOT_FOUND.

    FETCHING (IO thread)

        While a request is in the FETCHING state, data will be loaded into
        the user-provided buffer.

        If no buffer was provided, the request will go into the FAILED
        state with the error code SFETCH_ERROR_NO_BUFFER.

        If a buffer was provided, but it is too small to contain the
        fetched data, the request will go into the FAILED state with
        error code SFETCH_ERROR_BUFFER_TOO_SMALL.

        If less data can be read from the file than expected, the request
        will go into the FAILED state with error code SFETCH_ERROR_UNEXPECTED_EOF.

        If loading data into the provided buffer works as expected, the
        request will go into the FETCHED state.

    FETCHED (user thread)

        The request goes into the FETCHED state either when the entire file
        has been loaded into the provided buffer (when request.chunk_size == 0),
        or a chunk has been loaded (and optionally decompressed) into the
        buffer (when request.chunk_size > 0).

        The response callback will be called so that the user-code can
        process the loaded data using the following sfetch_response_t struct members:

            - data.ptr: pointer to the start of fetched data
            - data.size: the number of bytes in the provided buffer
            - data_offset: the byte offset of the loaded data chunk in the
              overall file (this is only set to a non-zero value in a streaming
              scenario)

        Once all file data has been loaded, the 'finished' flag will be set
        in the response callback's sfetch_response_t argument.

        After the user callback returns, and all file data has been loaded
        (response.finished flag is set) the request has reached its end-of-life
        and will be recycled.

        Otherwise, if there's still data to load (because streaming was
        requested by providing a non-zero request.chunk_size), the request
        will switch back to the FETCHING state to load the next chunk of data.

        Note that it is ok to associate a different buffer or buffer-size
        with the request by calling sfetch_bind_buffer() in the response-callback.

        To check in the response callback for the FETCHED state, and
        independently whether the request is finished:

            void response_callback(const sfetch_response_t* response) {
                if (response->fetched) {
                    // request is in FETCHED state, the loaded data is available
                    // in .data.ptr, and the number of bytes that have been
                    // loaded in .data.size:
                    const void* data = response->data.ptr;
                    size_t num_bytes = response->data.size;
                }
                if (response->finished) {
                    // the finished flag is set either when all data
                    // has been loaded, the request has been cancelled,
                    // or the file operation has failed, this is where
                    // any required per-request cleanup work should happen
                }
            }


    FAILED (user thread)

        A request will transition into the FAILED state in the following situations:

            - if the file doesn't exist or couldn't be opened for other
              reasons (SFETCH_ERROR_FILE_NOT_FOUND)
            - if no buffer is associated with the request in the FETCHING state
              (SFETCH_ERROR_NO_BUFFER)
            - if the provided buffer is too small to hold the entire file
              (if request.chunk_size == 0), or the (potentially decompressed)
              partial data chunk (SFETCH_ERROR_BUFFER_TOO_SMALL)
            - if less bytes could be read from the file then expected
              (SFETCH_ERROR_UNEXPECTED_EOF)
            - if a request has been cancelled via sfetch_cancel()
              (SFETCH_ERROR_CANCELLED)

        The response callback will be called once after a request goes into
        the FAILED state, with the 'response->finished' and
        'response->failed' flags set to true.

        This gives the user-code a chance to cleanup any resources associated
        with the request.

        To check for the failed state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->failed) {
                    // specifically check for the failed state...
                }
                // or you can do a catch-all check via the finished-flag:
                if (response->finished) {
                    if (response->failed) {
                        // if more detailed error handling is needed:
                        switch (response->error_code) {
                            ...
                        }
                    }
                }
            }

    PAUSED (user thread)

        A request will transition into the PAUSED state after user-code
        calls the function sfetch_pause() on the request's handle. Usually
        this happens from within the response-callback in streaming scenarios
        when the data streaming needs to wait for a data decoder (like
        a video/audio player) to catch up.

        While a request is in PAUSED state, the response-callback will be
        called in each sfetch_dowork(), so that the user-code can either
        continue the request by calling sfetch_continue(), or cancel
        the request by calling sfetch_cancel().

        When calling sfetch_continue() on a paused request, the request will
        transition into the FETCHING state. Otherwise if sfetch_cancel() is
        called, the request will switch into the FAILED state.

        To check for the PAUSED state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->paused) {
                    // we can check here whether the request should
                    // continue to load data:
                    if (should_continue(response->handle)) {
                        sfetch_continue(response->handle);
                    }
                }
            }


    CHUNK SIZE AND HTTP COMPRESSION
    ===============================
    TL;DR: for streaming scenarios, the provided chunk-size must be smaller
    than the provided buffer-size because the web server may decide to
    serve the data compressed and the chunk-size must be given in 'compressed
    bytes' while the buffer receives 'uncompressed bytes'. It's not possible
    in HTTP to query the uncompressed size for a compressed download until
    that download has finished.

    With vanilla HTTP, it is not possible to query the actual size of a file
    without downloading the entire file first (the Content-Length response
    header only provides the compressed size). Furthermore, for HTTP
    range-requests, the range is given on the compressed data, not the
    uncompressed data. So if the web server decides to serve the data
    compressed, the content-length and range-request parameters don't
    correspond to the uncompressed data that's arriving in the sokol-fetch
    buffers, and there's no way from JS or WASM to either force uncompressed
    downloads (e.g. by setting the Accept-Encoding field), or access the
    compressed data.

    This has some implications for sokol_fetch.h, most notably that buffers
    can't be provided in the exactly right size, because that size can't
    be queried from HTTP before the data is actually downloaded.

    When downloading whole files at once, it is basically expected that you
    know the maximum files size upfront through other means (for instance
    through a separate meta-data-file which contains the file sizes and
    other meta-data for each file that needs to be loaded).

    For streaming downloads the situation is a bit more complicated. These
    use HTTP range-requests, and those ranges are defined on the (potentially)
    compressed data which the JS/WASM side doesn't have access to. However,
    the JS/WASM side only ever sees the uncompressed data, and it's not possible
    to query the uncompressed size of a range request before that range request
    has finished.

    If the provided buffer is too small to contain the uncompressed data,
    the request will fail with error code SFETCH_ERROR_BUFFER_TOO_SMALL.


    CHANNELS AND LANES
    ==================
    Channels and lanes are (somewhat artificial) concepts to manage
    parallelization, prioritization and rate-limiting.

    Channels can be used to parallelize message processing for better 'pipeline
    throughput', and to prioritize requests: user-code could reserve one
    channel for streaming downloads which need to run in parallel to other
    requests, another channel for "regular" downloads and yet another
    high-priority channel which would only be used for small files which need
    to start loading immediately.

    Each channel comes with its own IO thread and message queues for pumping
    messages in and out of the thread. The channel where a request is
    processed is selected manually when sending a message:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback,
            .channel = 2
        });

    The number of channels is configured at startup in sfetch_setup() and
    cannot be changed afterwards.

    Channels are completely separate from each other, and a request will
    never "hop" from one channel to another.

    Each channel consists of a fixed number of "lanes" for automatic rate
    limiting:

    When a request is sent to a channel via sfetch_send(), a "free lane" will
    be picked and assigned to the request. The request will occupy this lane
    for its entire life time (also while it is paused). If all lanes of a
    channel are currently occupied, new requests will wait until a
    lane becomes unoccupied.

    Since the number of channels and lanes is known upfront, it is guaranteed
    that there will never be more than "num_channels * num_lanes" requests
    in flight at any one time.

    This guarantee eliminates unexpected load- and memory-spikes when
    many requests are sent in very short time, and it allows to pre-allocate
    a fixed number of memory buffers which can be reused for the entire
    "lifetime" of a sokol-fetch context.

    In the most simple scenario - when a maximum file size is known - buffers
    can be statically allocated like this:

        uint8_t buffer[NUM_CHANNELS][NUM_LANES][MAX_FILE_SIZE];

    Then in the user callback pick a buffer by channel and lane,
    and associate it with the request like this:

        void response_callback(const sfetch_response_t* response) {
            if (response->dispatched) {
                void* ptr = buffer[response->channel][response->lane];
                sfetch_bind_buffer(response->handle, ptr, MAX_FILE_SIZE);
            }
            ...
        }


    NOTES ON OPTIMIZING PIPELINE LATENCY AND THROUGHPUT
    ===================================================
    With the default configuration of 1 channel and 1 lane per channel,
    sokol_fetch.h will appear to have a shockingly bad loading performance
    if several files are loaded.

    This has two reasons:

        (1) all parallelization when loading data has been disabled. A new
        request will only be processed, when the last request has finished.

        (2) every invocation of the response-callback adds one frame of latency
        to the request, because callbacks will only be called from within
        sfetch_dowork()

    sokol-fetch takes a few shortcuts to improve step (2) and reduce
    the 'inherent latency' of a request:

        - if a buffer is provided upfront, the response-callback won't be
        called in the DISPATCHED state, but start right with the FETCHED state
        where data has already been loaded into the buffer

        - there is no separate CLOSED state where the callback is invoked
        separately when loading has finished (or the request has failed),
        instead the finished and failed flags will be set as part of
        the last FETCHED invocation

    This means providing a big-enough buffer to fit the entire file is the
    best case, the response callback will only be called once, ideally in
    the next frame (or two calls to sfetch_dowork()).

    If no buffer is provided upfront, one frame of latency is added because
    the response callback needs to be invoked in the DISPATCHED state so that
    the user code can bind a buffer.

    This means the best case for a request without an upfront-provided
    buffer is 2 frames (or 3 calls to sfetch_dowork()).

    That's about what can be done to improve the latency for a single request,
    but the really important step is to improve overall throughput. If you
    need to load thousands of files you don't want that to be completely
    serialized.

    The most important action to increase throughput is to increase the
    number of lanes per channel. This defines how many requests can be
    'in flight' on a single channel at the same time. The guiding decision
    factor for how many lanes you can "afford" is the memory size you want
    to set aside for buffers. Each lane needs its own buffer so that
    the data loaded for one request doesn't scribble over the data
    loaded for another request.

    Here's a simple example of sending 4 requests without upfront buffer
    on a channel with 1, 2 and 4 lanes, each line is one frame:

        1 LANE (8 frames):
            Lane 0:
            -------------
            REQ 0 DISPATCHED
            REQ 0 FETCHED
            REQ 1 DISPATCHED
            REQ 1 FETCHED
            REQ 2 DISPATCHED
            REQ 2 FETCHED
            REQ 3 DISPATCHED
            REQ 3 FETCHED

    Note how the request don't overlap, so they can all use the same buffer.

        2 LANES (4 frames):
            Lane 0:             Lane 1:
            ------------------------------------
            REQ 0 DISPATCHED    REQ 1 DISPATCHED
            REQ 0 FETCHED       REQ 1 FETCHED
            REQ 2 DISPATCHED    REQ 3 DISPATCHED
            REQ 2 FETCHED       REQ 3 FETCHED

    This reduces the overall time to 4 frames, but now you need 2 buffers so
    that requests don't scribble over each other.

        4 LANES (2 frames):
            Lane 0:             Lane 1:             Lane 2:             Lane 3:
            ----------------------------------------------------------------------------
            REQ 0 DISPATCHED    REQ 1 DISPATCHED    REQ 2 DISPATCHED    REQ 3 DISPATCHED
            REQ 0 FETCHED       REQ 1 FETCHED       REQ 2 FETCHED       REQ 3 FETCHED

    Now we're down to the same 'best-case' latency as sending a single
    request.

    Apart from the memory requirements for the streaming buffers (which is
    under your control), you can be generous with the number of lanes,
    they don't add any processing overhead.

    The last option for tweaking latency and throughput is channels. Each
    channel works independently from other channels, so while one
    channel is busy working through a large number of requests (or one
    very long streaming download), you can set aside a high-priority channel
    for requests that need to start as soon as possible.

    On platforms with threading support, each channel runs on its own
    thread, but this is mainly an implementation detail to work around
    the traditional blocking file IO functions, not for performance reasons.


    MEMORY ALLOCATION OVERRIDE
    ==========================
    You can override the memory allocation functions at initialization time
    like this:

        void* my_alloc(size_t size, void* user_data) {
            return malloc(size);
        }

        void my_free(void* ptr, void* user_data) {
            free(ptr);
        }

        ...
            sfetch_setup(&(sfetch_desc_t){
                // ...
                .allocator = {
                    .alloc_fn = my_alloc,
                    .free_fn = my_free,
                    .user_data = ...,
                }
            });
        ...

    If no overrides are provided, malloc and free will be used.

    This only affects memory allocation calls done by sokol_fetch.h
    itself though, not any allocations in OS libraries.

    Memory allocation will only happen on the same thread where sfetch_setup()
    was called, so you don't need to worry about thread-safety.


    ERROR REPORTING AND LOGGING
    ===========================
    To get any logging information at all you need to provide a logging callback in the setup call,
    the easiest way is to use sokol_log.h:

        #include "sokol_log.h"

        sfetch_setup(&(sfetch_desc_t){
            // ...
            .logger.func = slog_func
        });

    To override logging with your own callback, first write a logging function like this:

        void my_log(const char* tag,                // e.g. 'sfetch'
                    uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
                    uint32_t log_item_id,           // SFETCH_LOGITEM_*
                    const char* message_or_null,    // a message string, may be nullptr in release mode
                    uint32_t line_nr,               // line number in sokol_fetch.h
                    const char* filename_or_null,   // source filename, may be nullptr in release mode
                    void* user_data)
        {
            ...
        }

    ...and then setup sokol-fetch like this:

        sfetch_setup(&(sfetch_desc_t){
            .logger = {
                .func = my_log,
                .user_data = my_user_data,
            }
        });

    The provided logging function must be reentrant (e.g. be callable from
    different threads).

    If you don't want to provide your own custom logger it is highly recommended to use
    the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
    errors.


    FUTURE PLANS / V2.0 IDEA DUMP
    =============================
    - An optional polling API (as alternative to callback API)
    - Move buffer-management into the API? The "manual management"
      can be quite tricky especially for dynamic allocation scenarios,
      API support for buffer management would simplify cases like
      preventing that requests scribble over each other's buffers, or
      an automatic garbage collection for dynamically allocated buffers,
      or automatically falling back to dynamic allocation if static
      buffers aren't big enough.
    - Pluggable request handlers to load data from other "sources"
      (especially HTTP downloads on native platforms via e.g. libcurl
      would be useful)
    - I'm currently not happy how the user-data block is handled, this
      should getting and updating the user-data should be wrapped by
      API functions (similar to bind/unbind buffer)


    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2019 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
// ██ ███    ███ ██████  ██      ███████ ███    ███ ███████ ███    ██ ████████  █████  ████████ ██  ██████  ███    ██
// ██ ████  ████ ██   ██ ██      ██      ████  ████ ██      ████   ██    ██    ██   ██    ██    ██ ██    ██ ████   ██
// ██ ██ ████ ██ ██████  ██      █████   ██ ████ ██ █████   ██ ██  ██    ██    ███████    ██    ██ ██    ██ ██ ██  ██
// ██ ██  ██  ██ ██      ██      ██      ██  ██  ██ ██      ██  ██ ██    ██    ██   ██    ██    ██ ██    ██ ██  ██ ██
// ██ ██      ██ ██      ███████ ███████ ██      ██ ███████ ██   ████    ██    ██   ██    ██    ██  ██████  ██   ████
//
// >>implementation
when !(defined(SOKOL_DEBUG)) {
}
private {
_sfetch_t* _sfetch;
// ██       ██████   ██████   ██████  ██ ███    ██  ██████
// ██      ██    ██ ██       ██       ██ ████   ██ ██
// ██      ██    ██ ██   ███ ██   ███ ██ ██ ██  ██ ██   ███
// ██      ██    ██ ██    ██ ██    ██ ██ ██  ██ ██ ██    ██
// ███████  ██████   ██████   ██████  ██ ██   ████  ██████
//
// >>logging
u8*[14] _sfetch_log_messages = {
    "OK: Ok", "MALLOC_FAILED: memory allocation failed",
    "FILE_PATH_UTF8_DECODING_FAILED: failed converting file path from UTF8 to wide",
    "SEND_QUEUE_FULL: send queue full (adjust via sfetch_desc_t.max_requests)",
    "REQUEST_CHANNEL_INDEX_TOO_BIG: channel index too big (adjust via sfetch_desc_t.num_channels)",
    "REQUEST_PATH_IS_NULL: file path is nullptr (sfetch_request_t.path)",
    "REQUEST_PATH_TOO_LONG: file path is too long (SFETCH_MAX_PATH)",
    "REQUEST_CALLBACK_MISSING: no callback provided (sfetch_request_t.callback)",
    "REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE: chunk size is greater buffer size (sfetch_request_t.chunk_size vs .buffer.size)",
    "REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL: user data ptr is set but user data size is null (sfetch_request_t.user_data.ptr vs .size)",
    "REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT: user data ptr is null but size is not (sfetch_request_t.user_data.ptr vs .size)",
    "REQUEST_USERDATA_SIZE_TOO_BIG: user data size too big (see SFETCH_MAX_USERDATA_UINT64)",
    "CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS: clamping num channels to SFETCH_MAX_CHANNELS",
    "REQUEST_POOL_EXHAUSTED: request pool exhausted (tweak via sfetch_desc_t.max_requests)",
};

void _sfetch_log(sfetch_log_item_t log_item, u32 log_level, u32 line_nr) {
    if _sfetch.desc.logger.func != null {
        u8* filename = "sokol_fetch.h";
        u8* message = _sfetch_log_messages[log_item];
        _sfetch.desc.logger.func("sfetch", log_level, cast(u32, log_item), message, line_nr, filename, _sfetch.desc.logger.user_data);
    } else {
        if log_level == 0 {
            abort();
        }
    }
}

// ███    ███ ███████ ███    ███  ██████  ██████  ██    ██
// ████  ████ ██      ████  ████ ██    ██ ██   ██  ██  ██
// ██ ████ ██ █████   ██ ████ ██ ██    ██ ██████    ████
// ██  ██  ██ ██      ██  ██  ██ ██    ██ ██   ██    ██
// ██      ██ ███████ ██      ██  ██████  ██   ██    ██
//
// >>memory
void _sfetch_clear(void* ptr, u64 size) {
    memset(ptr, 0, size);
}

void* _sfetch_malloc_with_allocator(sfetch_allocator_t* allocator, u64 size) {
    void* ptr;
    if allocator.alloc_fn != null {
        ptr = allocator.alloc_fn(size, allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    if null == ptr {
        _sfetch_log(SFETCH_LOGITEM_MALLOC_FAILED, 0, 1376);
    }
    return ptr;
}

void* _sfetch_malloc(u64 size) {
    return _sfetch_malloc_with_allocator(&_sfetch.desc.allocator, size);
}

void* _sfetch_malloc_clear(u64 size) {
    void* ptr = _sfetch_malloc(size);
    _sfetch_clear(ptr, size);
    return ptr;
}

void _sfetch_free(void* ptr) {
    if _sfetch.desc.allocator.free_fn != null {
        _sfetch.desc.allocator.free_fn(ptr, _sfetch.desc.allocator.user_data);
    } else {
        free(ptr);
    }
}

_sfetch_t* _sfetch_ctx() {
    return _sfetch;
}

void _sfetch_path_copy(_sfetch_path_t* dst, u8* src) {
    if src && strlen(src) < 1024 {
        strncpy(dst.buf, src, cast(u64, 1024));
        dst.buf[1024 - 1] = 0;
    } else {
        _sfetch_clear(dst.buf, 1024);
    }
}

_sfetch_path_t _sfetch_path_make(u8* str_var) {
    noinit _sfetch_path_t res;
    _sfetch_path_copy(&res, str_var);
    return res;
}

// ███    ███ ███████ ███████ ███████  █████   ██████  ███████      ██████  ██    ██ ███████ ██    ██ ███████
// ████  ████ ██      ██      ██      ██   ██ ██       ██          ██    ██ ██    ██ ██      ██    ██ ██
// ██ ████ ██ █████   ███████ ███████ ███████ ██   ███ █████       ██    ██ ██    ██ █████   ██    ██ █████
// ██  ██  ██ ██           ██      ██ ██   ██ ██    ██ ██          ██ ▄▄ ██ ██    ██ ██      ██    ██ ██
// ██      ██ ███████ ███████ ███████ ██   ██  ██████  ███████      ██████   ██████  ███████  ██████  ███████
//                                                                     ▀▀
// >>message queue
u32 _sfetch_ring_wrap(_sfetch_ring_t* rb, u32 i) {
    return i % rb.num;
}

void _sfetch_ring_discard(_sfetch_ring_t* rb) {
    if rb.buf != null {
        _sfetch_free(rb.buf);
        rb.buf = null;
    }
    rb.head = 0;
    rb.tail = 0;
    rb.num = 0;
}

bool _sfetch_ring_init(_sfetch_ring_t* rb, u32 num_slots) {
    rb.head = 0;
    rb.tail = 0;
    rb.num = num_slots + 1;
    var queue_size = cast(u64, rb.num * sizeof(sfetch_handle_t));
    rb.buf = cast(u32*, _sfetch_malloc_clear(queue_size));
    if rb.buf != null {
        return true;
    } else {
        _sfetch_ring_discard(rb);
        return false;
    }
}

bool _sfetch_ring_full(_sfetch_ring_t* rb) {
    return _sfetch_ring_wrap(rb, rb.head + 1) == rb.tail;
}

bool _sfetch_ring_empty(_sfetch_ring_t* rb) {
    return rb.head == rb.tail;
}

u32 _sfetch_ring_count(_sfetch_ring_t* rb) {
    u32 count;
    if rb.head >= rb.tail {
        count = rb.head - rb.tail;
    } else {
        count = rb.head + rb.num - rb.tail;
    }
    return count;
}

void _sfetch_ring_enqueue(_sfetch_ring_t* rb, u32 slot_id) {
    rb.buf[rb.head] = slot_id;
    rb.head = _sfetch_ring_wrap(rb, rb.head + 1);
}

u32 _sfetch_ring_dequeue(_sfetch_ring_t* rb) {
    u32 slot_id = rb.buf[rb.tail];
    rb.tail = _sfetch_ring_wrap(rb, rb.tail + 1);
    return slot_id;
}

u32 _sfetch_ring_peek(_sfetch_ring_t* rb, u32 index) {
    u32 rb_index = _sfetch_ring_wrap(rb, rb.tail + index);
    return rb.buf[rb_index];
}

// ██████  ███████  ██████  ██    ██ ███████ ███████ ████████     ██████   ██████   ██████  ██
// ██   ██ ██      ██    ██ ██    ██ ██      ██         ██        ██   ██ ██    ██ ██    ██ ██
// ██████  █████   ██    ██ ██    ██ █████   ███████    ██        ██████  ██    ██ ██    ██ ██
// ██   ██ ██      ██ ▄▄ ██ ██    ██ ██           ██    ██        ██      ██    ██ ██    ██ ██
// ██   ██ ███████  ██████   ██████  ███████ ███████    ██        ██       ██████   ██████  ███████
//                     ▀▀
// >>request pool
u32 _sfetch_make_id(u32 index, u32 gen_ctr) {
    return gen_ctr << 16 | index & 0xFFFF;
}

sfetch_handle_t _sfetch_make_handle(u32 slot_id) {
    noinit sfetch_handle_t h;
    h.id = slot_id;
    return h;
}

u32 _sfetch_slot_index(u32 slot_id) {
    return slot_id & 0xFFFF;
}

void _sfetch_item_init(_sfetch_item_t* item, u32 slot_id, sfetch_request_t* request) {
    _sfetch_clear(item, cast(u64, sizeof(_sfetch_item_t)));
    item.handle.id = slot_id;
    item.state = _SFETCH_STATE_INITIAL;
    item.channel = request.channel;
    item.chunk_size = request.chunk_size;
    item.lane = 0xFFFFFFFF;
    item.callback = request.callback;
    item.buffer = request.buffer;
    item.path = _sfetch_path_make(request.path);
    if request.user_data.ptr && request.user_data.size > 0 && request.user_data.size <= cast(u64, 16 * 8) {
        item.user.user_data_size = request.user_data.size;
        memcpy(item.user.user_data, request.user_data.ptr, request.user_data.size);
    }
}

void _sfetch_item_discard(_sfetch_item_t* item) {
    _sfetch_clear(item, cast(u64, sizeof(_sfetch_item_t)));
}

void _sfetch_pool_discard(_sfetch_pool_t* pool) {
    if pool.free_slots != null {
        _sfetch_free(pool.free_slots);
        pool.free_slots = null;
    }
    if pool.gen_ctrs != null {
        _sfetch_free(pool.gen_ctrs);
        pool.gen_ctrs = null;
    }
    if pool.items != null {
        _sfetch_free(pool.items);
        pool.items = null;
    }
    pool.size = 0;
    pool.free_top = 0;
    pool.valid = false;
}

bool _sfetch_pool_init(_sfetch_pool_t* pool, u32 num_items) {
    pool.size = num_items + 1;
    pool.free_top = 0;
    var items_size = cast(u64, pool.size * sizeof(_sfetch_item_t));
    pool.items = cast(_sfetch_item_t*, _sfetch_malloc_clear(items_size));
    var gen_ctrs_size = cast(u64, sizeof(u32) * pool.size);
    pool.gen_ctrs = cast(u32*, _sfetch_malloc_clear(gen_ctrs_size));
    var free_slots_size = cast(u64, num_items * sizeof(i32));
    pool.free_slots = cast(u32*, _sfetch_malloc_clear(free_slots_size));
    if pool.items && pool.free_slots {
        for u32 i = pool.size - 1; i >= 1; i-- {
            pool.free_slots[pool.free_top++] = i;
        }
        pool.valid = true;
    } else {
        _sfetch_pool_discard(pool);
    }
    return pool.valid;
}

u32 _sfetch_pool_item_alloc(_sfetch_pool_t* pool, sfetch_request_t* request) {
    if pool.free_top > 0 {
        u32 slot_index = pool.free_slots[--pool.free_top];
        u32 slot_id = _sfetch_make_id(slot_index, ++pool.gen_ctrs[slot_index]);
        _sfetch_item_init(&pool.items[slot_index], slot_id, request);
        pool.items[slot_index].state = _SFETCH_STATE_ALLOCATED;
        return slot_id;
    } else {
        return _sfetch_make_id(0, 0);
    }
}

void _sfetch_pool_item_free(_sfetch_pool_t* pool, u32 slot_id) {
    u32 slot_index = _sfetch_slot_index(slot_id);
    for u32 i = 0; i < pool.free_top; i++ {
    }
    _sfetch_item_discard(&pool.items[slot_index]);
    pool.free_slots[pool.free_top++] = slot_index;
}

/* return pointer to item by handle without matching id check */
_sfetch_item_t* _sfetch_pool_item_at(_sfetch_pool_t* pool, u32 slot_id) {
    u32 slot_index = _sfetch_slot_index(slot_id);
    return &pool.items[slot_index];
}

/* return pointer to item by handle with matching id check */
_sfetch_item_t* _sfetch_pool_item_lookup(_sfetch_pool_t* pool, u32 slot_id) {
    if 0 != slot_id {
        _sfetch_item_t* item = _sfetch_pool_item_at(pool, slot_id);
        if item.handle.id == slot_id {
            return item;
        }
    }
    return null;
}
}

// ██████   ██████  ███████ ██ ██   ██
// ██   ██ ██    ██ ██      ██  ██ ██
// ██████  ██    ██ ███████ ██   ███
// ██      ██    ██      ██ ██  ██ ██
// ██       ██████  ███████ ██ ██   ██
//
// >>posix
// ██     ██ ██ ███    ██ ██████   ██████  ██     ██ ███████
// ██     ██ ██ ████   ██ ██   ██ ██    ██ ██     ██ ██
// ██  █  ██ ██ ██ ██  ██ ██   ██ ██    ██ ██  █  ██ ███████
// ██ ███ ██ ██ ██  ██ ██ ██   ██ ██    ██ ██ ███ ██      ██
//  ███ ███  ██ ██   ████ ██████   ██████   ███ ███  ███████
//
// >>windows
//  ██████ ██   ██  █████  ███    ██ ███    ██ ███████ ██      ███████
// ██      ██   ██ ██   ██ ████   ██ ████   ██ ██      ██      ██
// ██      ███████ ███████ ██ ██  ██ ██ ██  ██ █████   ██      ███████
// ██      ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██           ██
//  ██████ ██   ██ ██   ██ ██   ████ ██   ████ ███████ ███████ ███████
//
// >>channels
/* per-channel request handler for native platforms accessing the local filesystem */
/* if bytes_to_read != 0, a range-request will be sent, otherwise a normal request */
/*=== emscripten specific C helper functions =================================*/
void _sfetch_emsc_send_get_request(u32 slot_id, _sfetch_item_t* item) {
    if item.buffer.ptr == null || item.buffer.size == 0 {
        item.thread.error_code = SFETCH_ERROR_NO_BUFFER;
        item.thread.failed = true;
    } else {
        u32 offset = 0;
        u32 bytes_to_read = 0;
        if item.chunk_size > 0 {
            bytes_to_read = item.thread.content_size - item.thread.http_range_offset;
            if bytes_to_read > item.chunk_size {
                bytes_to_read = item.chunk_size;
            }
            offset = item.thread.http_range_offset;
        }
        sfetch_js_send_get_request(slot_id, item.path.buf, offset, bytes_to_read, item.buffer.ptr, item.buffer.size);
    }
}

/* called by JS when an initial HEAD request finished successfully (only when streaming chunks) */
void _sfetch_emsc_head_response(u32 slot_id, u32 content_length) {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx && ctx.valid {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item != null {
            item.thread.content_size = content_length;
            _sfetch_emsc_send_get_request(slot_id, item);
        }
    }
}

/* called by JS when a followup GET request finished successfully */
void _sfetch_emsc_get_response(u32 slot_id, u32 range_fetched_size, u32 content_fetched_size) {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx && ctx.valid {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item != null {
            item.thread.fetched_size = content_fetched_size;
            item.thread.fetched_offset += content_fetched_size;
            item.thread.http_range_offset += range_fetched_size;
            if item.chunk_size == 0 {
                item.thread.finished = true;
            } else if item.thread.http_range_offset >= item.thread.content_size {
                item.thread.finished = true;
            }
            _sfetch_ring_enqueue(&ctx.chn[item.channel].user_outgoing, slot_id);
        }
    }
}

/* called by JS when an error occurred */
void _sfetch_emsc_failed_http_status(u32 slot_id, u32 http_status) {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx && ctx.valid {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item != null {
            if http_status == 404 {
                item.thread.error_code = SFETCH_ERROR_FILE_NOT_FOUND;
            } else {
                item.thread.error_code = SFETCH_ERROR_INVALID_HTTP_STATUS;
            }
            item.thread.failed = true;
            item.thread.finished = true;
            _sfetch_ring_enqueue(&ctx.chn[item.channel].user_outgoing, slot_id);
        }
    }
}

void _sfetch_emsc_failed_buffer_too_small(u32 slot_id) {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx && ctx.valid {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item != null {
            item.thread.error_code = SFETCH_ERROR_BUFFER_TOO_SMALL;
            item.thread.failed = true;
            item.thread.finished = true;
            _sfetch_ring_enqueue(&ctx.chn[item.channel].user_outgoing, slot_id);
        }
    }
}

void _sfetch_emsc_failed_other(u32 slot_id) {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx && ctx.valid {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item != null {
            item.thread.error_code = SFETCH_ERROR_JS_OTHER;
            item.thread.failed = true;
            item.thread.finished = true;
            _sfetch_ring_enqueue(&ctx.chn[item.channel].user_outgoing, slot_id);
        }
    }
}

private {
void _sfetch_request_handler(_sfetch_t* ctx, u32 slot_id) {
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
    if item == null {
        return;
    }
    if item.state == _SFETCH_STATE_FETCHING {
        if item.chunk_size > 0 && item.thread.content_size == 0 {
            sfetch_js_send_head_request(slot_id, item.path.buf);
        } else {
            _sfetch_emsc_send_get_request(slot_id, item);
        }
    } else {
        _sfetch_ring_enqueue(&ctx.chn[item.channel].user_outgoing, slot_id);
    }
    if item.thread.failed != 0 {
        item.thread.finished = true;
    }
}

void _sfetch_channel_discard(_sfetch_channel_t* chn) {
    _sfetch_ring_discard(&chn.free_lanes);
    _sfetch_ring_discard(&chn.user_sent);
    _sfetch_ring_discard(&chn.user_incoming);
    _sfetch_ring_discard(&chn.user_outgoing);
    _sfetch_ring_discard(&chn.free_lanes);
    chn.valid = false;
}

bool _sfetch_channel_init(_sfetch_channel_t* chn, _sfetch_t* ctx, u32 num_items, u32 num_lanes, fn(_sfetch_t*, u32): void request_handler) {
    bool valid = true;
    chn.request_handler = request_handler;
    chn.ctx = ctx;
    valid &= _sfetch_ring_init(&chn.free_lanes, num_lanes);
    for u32 lane = 0; lane < num_lanes; lane++ {
        _sfetch_ring_enqueue(&chn.free_lanes, lane);
    }
    valid &= _sfetch_ring_init(&chn.user_sent, num_items);
    valid &= _sfetch_ring_init(&chn.user_incoming, num_lanes);
    valid &= _sfetch_ring_init(&chn.user_outgoing, num_lanes);
    if valid != 0 {
        chn.valid = true;
        return true;
    } else {
        _sfetch_channel_discard(chn);
        return false;
    }
}

/* put a request into the channels sent-queue, this is where all new requests
   are stored until a lane becomes free.
*/
bool _sfetch_channel_send(_sfetch_channel_t* chn, u32 slot_id) {
    if _sfetch_ring_full(&chn.user_sent) == 0 {
        _sfetch_ring_enqueue(&chn.user_sent, slot_id);
        return true;
    } else {
        _sfetch_log(SFETCH_LOGITEM_SEND_QUEUE_FULL, 1, 1377);
        return false;
    }
}

void _sfetch_invoke_response_callback(_sfetch_item_t* item) {
    noinit sfetch_response_t response;
    _sfetch_clear(&response, cast(u64, sizeof(response)));
    response.handle = item.handle;
    response.dispatched = item.state == _SFETCH_STATE_DISPATCHED;
    response.fetched = item.state == _SFETCH_STATE_FETCHED;
    response.paused = item.state == _SFETCH_STATE_PAUSED;
    response.finished = item.user.finished;
    response.failed = item.state == _SFETCH_STATE_FAILED;
    response.cancelled = item.user.cancel;
    response.error_code = item.user.error_code;
    response.channel = item.channel;
    response.lane = item.lane;
    response.path = item.path.buf;
    response.user_data = item.user.user_data;
    response.data_offset = item.user.fetched_offset - item.user.fetched_size;
    response.data.ptr = item.buffer.ptr;
    response.data.size = item.user.fetched_size;
    response.buffer = item.buffer;
    item.callback(&response);
}

void _sfetch_cancel_item(_sfetch_item_t* item) {
    item.state = _SFETCH_STATE_FAILED;
    item.user.finished = true;
    item.user.error_code = SFETCH_ERROR_CANCELLED;
}

/* per-frame channel stuff: move requests in and out of the IO threads, call response callbacks */
void _sfetch_channel_dowork(_sfetch_channel_t* chn, _sfetch_pool_t* pool) {
    u32 num_sent = _sfetch_ring_count(&chn.user_sent);
    u32 avail_lanes = _sfetch_ring_count(&chn.free_lanes);
    u32 num_move = num_sent < avail_lanes ? num_sent : avail_lanes;
    for u32 i = 0; i < num_move; i++ {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_sent);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
            _sfetch_invoke_response_callback(item);
            _sfetch_pool_item_free(pool, slot_id);
            continue;
        }
        item.state = _SFETCH_STATE_DISPATCHED;
        item.lane = _sfetch_ring_dequeue(&chn.free_lanes);
        if null == item.buffer.ptr {
            _sfetch_invoke_response_callback(item);
        }
        _sfetch_ring_enqueue(&chn.user_incoming, slot_id);
    }
    u32 num_incoming = _sfetch_ring_count(&chn.user_incoming);
    for u32 i = 0; i < num_incoming; i++ {
        u32 slot_id = _sfetch_ring_peek(&chn.user_incoming, i);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        if item.user.pause != 0 {
            item.state = _SFETCH_STATE_PAUSED;
            item.user.pause = false;
        }
        if item.user.cont != 0 {
            if item.state == _SFETCH_STATE_PAUSED {
                item.state = _SFETCH_STATE_FETCHED;
            }
            item.user.cont = false;
        }
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
        }
        switch item.state {
            case _SFETCH_STATE_DISPATCHED, _SFETCH_STATE_FETCHED: {
                item.state = _SFETCH_STATE_FETCHING;
            }
            default: {
            }
        }
    }
    while _sfetch_ring_empty(&chn.user_incoming) == 0 {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_incoming);
        _sfetch_request_handler(chn.ctx, slot_id);
    }
    while _sfetch_ring_empty(&chn.user_outgoing) == 0 {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_outgoing);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        item.user.fetched_offset = item.thread.fetched_offset;
        item.user.fetched_size = item.thread.fetched_size;
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
        } else {
            item.user.error_code = item.thread.error_code;
        }
        if item.thread.finished != 0 {
            item.user.finished = true;
        }
        if item.thread.failed != 0 {
            item.state = _SFETCH_STATE_FAILED;
        } else if item.state == _SFETCH_STATE_FETCHING {
            item.state = _SFETCH_STATE_FETCHED;
        }
        _sfetch_invoke_response_callback(item);
        if item.user.finished != 0 {
            _sfetch_ring_enqueue(&chn.free_lanes, item.lane);
            _sfetch_pool_item_free(pool, slot_id);
        } else {
            _sfetch_ring_enqueue(&chn.user_incoming, slot_id);
        }
    }
}

bool _sfetch_validate_request(_sfetch_t* ctx, sfetch_request_t* req) {
    if req.channel >= ctx.desc.num_channels {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CHANNEL_INDEX_TOO_BIG, 1, 1377);
        return false;
    }
    if req.path == null {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_PATH_IS_NULL, 1, 1377);
        return false;
    }
    if strlen(req.path) >= cast(u64, 1024 - 1) {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_PATH_TOO_LONG, 1, 1377);
        return false;
    }
    if req.callback == null {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CALLBACK_MISSING, 1, 1377);
        return false;
    }
    if req.chunk_size > req.buffer.size {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE, 1, 1377);
        return false;
    }
    if req.user_data.ptr && req.user_data.size == 0 {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL, 1, 1377);
        return false;
    }
    if !req.user_data.ptr && req.user_data.size > 0 {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT, 1, 1377);
        return false;
    }
    if req.user_data.size > cast(u64, 16 * sizeof(u64)) {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_SIZE_TOO_BIG, 1, 1377);
        return false;
    }
    return true;
}

sfetch_desc_t _sfetch_desc_defaults(sfetch_desc_t* desc) {
    sfetch_desc_t res = *desc;
    res.max_requests = cast(u32, desc.max_requests == 0 ? 128 : desc.max_requests);
    res.num_channels = cast(u32, desc.num_channels == 0 ? 1 : desc.num_channels);
    res.num_lanes = cast(u32, desc.num_lanes == 0 ? 1 : desc.num_lanes);
    return res;
}
}

// ██████  ██    ██ ██████  ██      ██  ██████
// ██   ██ ██    ██ ██   ██ ██      ██ ██
// ██████  ██    ██ ██████  ██      ██ ██
// ██      ██    ██ ██   ██ ██      ██ ██
// ██       ██████  ██████  ███████ ██  ██████
//
// >>public
void sfetch_setup(sfetch_desc_t* desc_) {
    sfetch_desc_t desc = _sfetch_desc_defaults(desc_);
    _sfetch = cast(_sfetch_t*, _sfetch_malloc_with_allocator(&desc.allocator, cast(u64, sizeof(_sfetch_t))));
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_clear(ctx, cast(u64, sizeof(_sfetch_t)));
    ctx.desc = desc;
    ctx.setup = true;
    ctx.valid = true;
    if ctx.desc.num_channels > 16 {
        ctx.desc.num_channels = 16;
        _sfetch_log(SFETCH_LOGITEM_CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS, 2, 1378);
    }
    ctx.valid &= _sfetch_pool_init(&ctx.pool, ctx.desc.max_requests);
    for u32 i = 0; i < ctx.desc.num_channels; i++ {
        ctx.valid &= _sfetch_channel_init(&ctx.chn[i], ctx, ctx.desc.max_requests, ctx.desc.num_lanes, cast(fn(_sfetch_t*, u32): void, _sfetch_request_handler));
    }
}

void sfetch_shutdown() {
    _sfetch_t* ctx = _sfetch_ctx();
    ctx.valid = false;
    for u32 i = 0; i < ctx.desc.num_channels; i++ {
        if ctx.chn[i].valid != 0 {
            _sfetch_channel_discard(&ctx.chn[i]);
        }
    }
    _sfetch_pool_discard(&ctx.pool);
    ctx.setup = false;
    _sfetch_free(ctx);
    _sfetch = null;
}

bool sfetch_valid() {
    _sfetch_t* ctx = _sfetch_ctx();
    return ctx && ctx.valid;
}

sfetch_desc_t sfetch_desc() {
    _sfetch_t* ctx = _sfetch_ctx();
    return ctx.desc;
}

i32 sfetch_max_userdata_bytes() {
    return 16 * 8;
}

i32 sfetch_max_path() {
    return 1024;
}

bool sfetch_handle_valid(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    if h.id == 0 {
        return false;
    }
    return null != _sfetch_pool_item_lookup(&ctx.pool, h.id);
}

sfetch_handle_t sfetch_send(sfetch_request_t* request) {
    _sfetch_t* ctx = _sfetch_ctx();
    sfetch_handle_t invalid_handle = _sfetch_make_handle(0);
    if ctx.valid == 0 {
        return invalid_handle;
    }
    if _sfetch_validate_request(ctx, request) == 0 {
        return invalid_handle;
    }
    u32 slot_id = _sfetch_pool_item_alloc(&ctx.pool, request);
    if 0 == slot_id {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_POOL_EXHAUSTED, 2, 1378);
        return invalid_handle;
    }
    if _sfetch_channel_send(&ctx.chn[request.channel], slot_id) == 0 {
        _sfetch_pool_item_free(&ctx.pool, slot_id);
        return invalid_handle;
    }
    return _sfetch_make_handle(slot_id);
}

void sfetch_dowork() {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx.valid == 0 {
        return;
    }
    ctx.in_callback = true;
    for i32 pass = 0; pass < 2; pass++ {
        for u32 chn_index = 0; chn_index < ctx.desc.num_channels; chn_index++ {
            _sfetch_channel_dowork(&ctx.chn[chn_index], &ctx.pool);
        }
    }
    ctx.in_callback = false;
}

void sfetch_bind_buffer(sfetch_handle_t h, sfetch_range_t buffer) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.buffer = buffer;
    }
}

void* sfetch_unbind_buffer(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        var prev_buf_ptr = item.buffer.ptr;
        item.buffer.ptr = null;
        item.buffer.size = 0;
        return prev_buf_ptr;
    } else {
        return null;
    }
}

void sfetch_pause(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.pause = true;
        item.user.cont = false;
    }
}

void sfetch_continue(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.cont = true;
        item.user.pause = false;
    }
}

void sfetch_cancel(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.cont = false;
        item.user.pause = false;
        item.user.cancel = true;
    }
}

}

when os(windows) {
enum __enum_PROCESS_DPI_UNAWARE {
    PROCESS_DPI_UNAWARE = 0,
    PROCESS_SYSTEM_DPI_AWARE = 1,
    PROCESS_PER_MONITOR_DPI_AWARE = 2,
    MDT_EFFECTIVE_DPI = 0,
    MDT_ANGULAR_DPI = 1,
    MDT_RAW_DPI = 2,
}

/*
    sfetch_log_item_t

    Log items are defined via X-Macros, and expanded to an
    enum 'sfetch_log_item', and in debug mode only,
    corresponding strings.

    Used as parameter in the logging callback.
*/
enum sfetch_log_item_t {
    SFETCH_LOGITEM_OK = 0,
    SFETCH_LOGITEM_MALLOC_FAILED = 1,
    SFETCH_LOGITEM_FILE_PATH_UTF8_DECODING_FAILED = 2,
    SFETCH_LOGITEM_SEND_QUEUE_FULL = 3,
    SFETCH_LOGITEM_REQUEST_CHANNEL_INDEX_TOO_BIG = 4,
    SFETCH_LOGITEM_REQUEST_PATH_IS_NULL = 5,
    SFETCH_LOGITEM_REQUEST_PATH_TOO_LONG = 6,
    SFETCH_LOGITEM_REQUEST_CALLBACK_MISSING = 7,
    SFETCH_LOGITEM_REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE = 8,
    SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL = 9,
    SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT = 10,
    SFETCH_LOGITEM_REQUEST_USERDATA_SIZE_TOO_BIG = 11,
    SFETCH_LOGITEM_CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS = 12,
    SFETCH_LOGITEM_REQUEST_POOL_EXHAUSTED = 13,
}

/* error codes */
enum sfetch_error_t {
    SFETCH_ERROR_NO_ERROR = 0,
    SFETCH_ERROR_FILE_NOT_FOUND = 1,
    SFETCH_ERROR_NO_BUFFER = 2,
    SFETCH_ERROR_BUFFER_TOO_SMALL = 3,
    SFETCH_ERROR_UNEXPECTED_EOF = 4,
    SFETCH_ERROR_INVALID_HTTP_STATUS = 5,
    SFETCH_ERROR_CANCELLED = 6,
    SFETCH_ERROR_JS_OTHER = 7,
}

/* a request goes through the following states, ping-ponging between IO and user thread */
enum _sfetch_state_t {
    _SFETCH_STATE_INITIAL = 0,
    _SFETCH_STATE_ALLOCATED = 1,
    _SFETCH_STATE_DISPATCHED = 2,
    _SFETCH_STATE_FETCHING = 3,
    _SFETCH_STATE_FETCHED = 4,
    _SFETCH_STATE_PAUSED = 5,
    _SFETCH_STATE_FAILED = 6,
}

type PROCESS_DPI_AWARENESS = i32;
type MONITOR_DPI_TYPE = i32;
type BOOL = i32;
type BYTE = u8;
type WORD = u16;
type DWORD = u32;
type UINT = u32;
type INT = i32;
type LONG = i32;
type ULONG = u32;
type LONGLONG = i64;
type ULONGLONG = u64;
type SHORT = i16;
type USHORT = u16;
type CHAR = u8;
type UCHAR = u8;
type WCHAR = u16;
type FLOAT = f32;
type HRESULT = i32;
type ATOM = u16;
type UINT_PTR = u64;
type INT_PTR = i64;
type ULONG_PTR = u64;
type LONG_PTR = i64;
type DWORD_PTR = u64;
type SIZE_T = u64;
type SSIZE_T = i64;
type WPARAM = u64;
type LPARAM = i64;
type LRESULT = i64;
type HANDLE = void*;
type HWND = void*;
type HDC = void*;
type HGLRC = void*;
type HINSTANCE = void*;
type HMODULE = void*;
type HMENU = void*;
type HICON = void*;
type HCURSOR = void*;
type HBRUSH = void*;
type HMONITOR = void*;
type HDROP = void*;
type HBITMAP = void*;
type HGDIOBJ = void*;
type HKL = void*;
type HRAWINPUT = void*;
type HLOCAL = void*;
type FARPROC = void*;
type PROC = void*;
type PVOID = void*;
type LPVOID = void*;
type LPCVOID = void*;
type LPSTR = u8*;
type LPCSTR = u8*;
type LPWSTR = WCHAR*;
type LPCWSTR = WCHAR*;
type PCWSTR = WCHAR*;
type LPBYTE = BYTE*;
type LPDWORD = DWORD*;
type LPWORD = WORD*;
type LPLONG = LONG*;
type LPINT = i32*;
type LPUINT = UINT*;
type LPUNKNOWN = void*;
type WNDPROC = fn(HWND, UINT, WPARAM, LPARAM): LRESULT;
type LPRECT = RECT*;
type errno_t = i32;
type handle_type = i64;
type DPI_AWARENESS_CONTEXT_T = void*;
type LPVOID = void*;
type LPTHREAD_START_ROUTINE = fn(LPVOID): DWORD;
/* file handle abstraction */
type _sfetch_file_handle_t = HANDLE;
type _sfetch_thread_func_t = LPTHREAD_START_ROUTINE;
struct LARGE_INTEGER {
    i64 QuadPart;
}

struct POINT {
    LONG x;
    LONG y;
}

struct POINTL {
    LONG x;
    LONG y;
}

struct RECT {
    LONG left;
    LONG top;
    LONG right;
    LONG bottom;
}

struct SIZE {
    WORD cx;
    WORD cy;
}

struct MSG {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
}

struct WNDCLASSW {
    UINT style;
    WNDPROC lpfnWndProc;
    i32 cbClsExtra;
    i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
}

struct WNDCLASSEXW {
    UINT cbSize;
    UINT style;
    WNDPROC lpfnWndProc;
    i32 cbClsExtra;
    i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
    HICON hIconSm;
}

struct PIXELFORMATDESCRIPTOR {
    WORD nSize;
    WORD nVersion;
    DWORD dwFlags;
    BYTE iPixelType;
    BYTE cColorBits;
    BYTE cRedBits;
    BYTE cRedShift;
    BYTE cGreenBits;
    BYTE cGreenShift;
    BYTE cBlueBits;
    BYTE cBlueShift;
    BYTE cAlphaBits;
    BYTE cAlphaShift;
    BYTE cAccumBits;
    BYTE cAccumRedBits;
    BYTE cAccumGreenBits;
    BYTE cAccumBlueBits;
    BYTE cAccumAlphaBits;
    BYTE cDepthBits;
    BYTE cStencilBits;
    BYTE cAuxBuffers;
    BYTE iLayerType;
    BYTE bReserved;
    DWORD dwLayerMask;
    DWORD dwVisibleMask;
    DWORD dwDamageMask;
}

struct TRACKMOUSEEVENT {
    DWORD cbSize;
    DWORD dwFlags;
    HWND hwndTrack;
    DWORD dwHoverTime;
}

struct CURSORINFO {
    DWORD cbSize;
    DWORD flags;
    HCURSOR hCursor;
    POINT ptScreenPos;
}

struct MONITORINFO {
    DWORD cbSize;
    RECT rcMonitor;
    RECT rcWork;
    DWORD dwFlags;
}

struct SIZEL {
    LONG cx;
    LONG cy;
}

struct WINDOWPLACEMENT_STUB {
    DWORD style;
    DWORD dwExtendedStyle;
    DWORD cdxStyle;
    LONG x;
    LONG y;
    LONG cx;
    LONG cy;
}

struct DEVMODEW {
    LONG dmType;
    DWORD dmFields;
    DWORD dmPelsWidth;
    DWORD dmPelsHeight;
    DWORD dmBitsPerPel;
    DWORD dmDisplayFrequency;
}

struct OSVERSIONINFOW {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
}

struct RAWINPUTHEADER {
    DWORD dwType;
    DWORD dwSize;
    HANDLE hDevice;
    WPARAM wParam;
}

struct RAWINPUTDEVICE {
    USHORT usUsagePage;
    USHORT usUsage;
    DWORD dwFlags;
    HWND hwndTarget;
}

struct RAWMOUSE {
    USHORT usFlags;
    ULONG _pad_buttons;
    ULONG ulRawButtons;
    LONG lLastX;
    LONG lLastY;
    ULONG ulExtraInformation;
}

struct RAWINPUT {
    RAWINPUTHEADER header;
    struct {
        RAWMOUSE mouse;
    } data;
}

struct SYSTEM_INFO {
    DWORD dwOemId;
    DWORD dwPageSize;
    LPVOID lpMinimumApplicationAddress;
    LPVOID lpMaximumApplicationAddress;
    DWORD_PTR dwActiveProcessorMask;
    DWORD dwNumberOfProcessors;
    DWORD dwProcessorType;
    DWORD dwAllocationGranularity;
    WORD wProcessorLevel;
    WORD wProcessorRevision;
}

struct CRITICAL_SECTION {
    PVOID DebugInfo;
    LONG LockCount;
    LONG RecursionCount;
    HANDLE OwningThread;
    HANDLE LockSemaphore;
    ULONG_PTR SpinCount;
}

struct BITMAPV5HEADER {
    DWORD bV5Size;
    LONG bV5Width;
    LONG bV5Height;
    WORD bV5Planes;
    WORD bV5BitCount;
    DWORD bV5Compression;
    DWORD bV5SizeImage;
    LONG bV5XPelsPerMeter;
    LONG bV5YPelsPerMeter;
    DWORD bV5ClrUsed;
    DWORD bV5ClrImportant;
    DWORD bV5RedMask;
    DWORD bV5GreenMask;
    DWORD bV5BlueMask;
    DWORD bV5AlphaMask;
}

struct BITMAPINFO {
    DWORD _unused;
}

struct ICONINFO {
    BOOL fIcon;
    DWORD xHotspot;
    DWORD yHotspot;
    HBITMAP hbmMask;
    HBITMAP hbmColor;
}

/*
    sfetch_logger_t

    Used in sfetch_desc_t to provide a custom logging and error reporting
    callback to sokol-fetch.
*/
struct sfetch_logger_t {
    fn(u8*, u32, u32, u8*, u32, u8*, void*): void func;
    void* user_data;
}

/*
    sfetch_range_t

    A pointer-size pair struct to pass memory ranges into and out of sokol-fetch.
    When initialized from a value type (array or struct) you can use the
    SFETCH_RANGE() helper macro to build an sfetch_range_t struct.
*/
struct sfetch_range_t {
    void* ptr;
    u64 size;
}

// disabling this for every includer isn't great, but the warnings are also quite pointless
/*
    sfetch_allocator_t

    Used in sfetch_desc_t to provide custom memory-alloc and -free functions
    to sokol_fetch.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct sfetch_allocator_t {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

/* configuration values for sfetch_setup() */
struct sfetch_desc_t {
    u32 max_requests;
    u32 num_channels;
    u32 num_lanes;
    sfetch_allocator_t allocator;
    sfetch_logger_t logger;
}

/* a request handle to identify an active fetch request, returned by sfetch_send() */
struct sfetch_handle_t {
    u32 id;
}

/* the response struct passed to the response callback */
struct sfetch_response_t {
    sfetch_handle_t handle;
    bool dispatched;
    bool fetched;
    bool paused;
    bool finished;
    bool failed;
    bool cancelled;
    sfetch_error_t error_code;
    u32 channel;
    u32 lane;
    u8* path;
    void* user_data;
    u32 data_offset;
    sfetch_range_t data;
    sfetch_range_t buffer;
}

/* request parameters passed to sfetch_send() */
struct sfetch_request_t {
    u32 channel;
    u8* path;
    fn(sfetch_response_t*): void callback;
    u32 chunk_size;
    sfetch_range_t buffer;
    sfetch_range_t user_data;
}

// ███████ ████████ ██████  ██    ██  ██████ ████████ ███████
// ██         ██    ██   ██ ██    ██ ██         ██    ██
// ███████    ██    ██████  ██    ██ ██         ██    ███████
//      ██    ██    ██   ██ ██    ██ ██         ██         ██
// ███████    ██    ██   ██  ██████   ██████    ██    ███████
//
// >>structs
struct _sfetch_path_t {
    u8[1024] buf;
}

/* a thread with incoming and outgoing message queue syncing */
struct _sfetch_thread_t {
    HANDLE thread;
    HANDLE incoming_event;
    CRITICAL_SECTION incoming_critsec;
    CRITICAL_SECTION outgoing_critsec;
    CRITICAL_SECTION running_critsec;
    CRITICAL_SECTION stop_critsec;
    bool stop_requested;
    bool valid;
}

/* user-side per-request state */
struct _sfetch_item_user_t {
    bool pause;
    bool cont;
    bool cancel;
    u32 fetched_offset;
    u32 fetched_size;
    sfetch_error_t error_code;
    bool finished;
    u64 user_data_size;
    u64[16] user_data;
}

/* thread-side per-request state */
struct _sfetch_item_thread_t {
    u32 fetched_offset;
    u32 fetched_size;
    sfetch_error_t error_code;
    bool failed;
    bool finished;
    _sfetch_file_handle_t file_handle;
    u32 content_size;
}

/* an internal request item */
struct _sfetch_item_t {
    sfetch_handle_t handle;
    _sfetch_state_t state;
    u32 channel;
    u32 lane;
    u32 chunk_size;
    fn(sfetch_response_t*): void callback;
    sfetch_range_t buffer;
    _sfetch_item_thread_t thread;
    _sfetch_item_user_t user;
    _sfetch_path_t path;
}

/* a pool of internal per-request items */
struct _sfetch_pool_t {
    u32 size;
    u32 free_top;
    _sfetch_item_t* items;
    u32* free_slots;
    u32* gen_ctrs;
    bool valid;
}

/* a ringbuffer for pool-slot ids */
struct _sfetch_ring_t {
    u32 head;
    u32 tail;
    u32 num;
    u32* buf;
}

struct _sfetch_channel_t {
    _sfetch_t* ctx;
    _sfetch_ring_t free_lanes;
    _sfetch_ring_t user_sent;
    _sfetch_ring_t user_incoming;
    _sfetch_ring_t user_outgoing;
    _sfetch_ring_t thread_incoming;
    _sfetch_ring_t thread_outgoing;
    _sfetch_thread_t thread;
    fn(_sfetch_t*, u32): void request_handler;
    bool valid;
}

/* the sfetch global state */
struct _sfetch_t {
    bool setup;
    bool valid;
    bool in_callback;
    sfetch_desc_t desc;
    _sfetch_pool_t pool;
    _sfetch_channel_t[16] chn;
}

/*
    sokol_fetch.h -- asynchronous data loading/streaming

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_FETCH_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)             - your own assert macro (default: assert(c))
    SOKOL_UNREACHABLE()         - a guard macro for unreachable code (default: assert(false))
    SOKOL_FETCH_API_DECL        - public function declaration prefix (default: extern)
    SOKOL_API_DECL              - same as SOKOL_FETCH_API_DECL
    SOKOL_API_IMPL              - public function implementation prefix (default: -)
    SFETCH_MAX_PATH             - max length of UTF-8 filesystem path / URL (default: 1024 bytes)
    SFETCH_MAX_USERDATA_UINT64  - max size of embedded userdata in number of uint64_t, userdata
                                  will be copied into an 8-byte aligned memory region associated
                                  with each in-flight request, default value is 16 (== 128 bytes)
    SFETCH_MAX_CHANNELS         - max number of IO channels (default is 16, also see sfetch_desc_t.num_channels)

    If sokol_fetch.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_FETCH_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    NOTE: The following documentation talks a lot about "IO threads". Actual
    threads are only used on platforms where threads are available. The web
    version (emscripten/wasm) doesn't use POSIX-style threads, but instead
    asynchronous Javascript calls chained together by callbacks. The actual
    source code differences between the two approaches have been kept to
    a minimum though.

    FEATURE OVERVIEW
    ================

    - Asynchronously load complete files, or stream files incrementally via
      HTTP (on web platform), or the local file system (on native platforms)

    - Request / response-callback model, user code sends a request
      to initiate a file-load, sokol_fetch.h calls the response callback
      on the same thread when data is ready or user-code needs
      to respond otherwise

    - Not limited to the main-thread or a single thread: A sokol-fetch
      "context" can live on any thread, and multiple contexts
      can operate side-by-side on different threads.

    - Memory management for data buffers is under full control of user code.
      sokol_fetch.h won't allocate memory after it has been setup.

    - Automatic rate-limiting guarantees that only a maximum number of
      requests is processed at any one time, allowing a zero-allocation
      model, where all data is streamed into fixed-size, pre-allocated
      buffers.

    - Active Requests can be paused, continued and cancelled from anywhere
      in the user-thread which sent this request.


    TL;DR EXAMPLE CODE
    ==================
    This is the most-simple example code to load a single data file with a
    known maximum size:

    (1) initialize sokol-fetch with default parameters (but NOTE that the
        default setup parameters provide a safe-but-slow "serialized"
        operation). In order to see any logging output in case of errors
        you should always provide a logging function
        (such as 'slog_func' from sokol_log.h):

        sfetch_setup(&(sfetch_desc_t){ .logger.func = slog_func });

    (2) send a fetch-request to load a file from the current directory
        into a buffer big enough to hold the entire file content:

        static uint8_t buf[MAX_FILE_SIZE];

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer = {
                .ptr = buf,
                .size = sizeof(buf)
            }
        });

        If 'buf' is a value (e.g. an array or struct item), the .buffer item can
        be initialized with the SFETCH_RANGE() helper macro:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer = SFETCH_RANGE(buf)
        });

    (3) write a 'response-callback' function, this will be called whenever
        the user-code must respond to state changes of the request
        (most importantly when data has been loaded):

        void response_callback(const sfetch_response_t* response) {
            if (response->fetched) {
                // data has been loaded, and is available via the
                // sfetch_range_t struct item 'data':
                const void* ptr = response->data.ptr;
                size_t num_bytes = response->data.size;
            }
            if (response->finished) {
                // the 'finished'-flag is the catch-all flag for when the request
                // is finished, no matter if loading was successful or failed,
                // so any cleanup-work should happen here...
                ...
                if (response->failed) {
                    // 'failed' is true in (addition to 'finished') if something
                    // went wrong (file doesn't exist, or less bytes could be
                    // read from the file than expected)
                }
            }
        }

    (4) pump the sokol-fetch message queues, and invoke response callbacks
        by calling:

        sfetch_dowork();

        In an event-driven app this should be called in the event loop. If you
        use sokol-app this would be in your frame_cb function.

    (5) finally, call sfetch_shutdown() at the end of the application:

    There's many other loading-scenarios, for instance one doesn't have to
    provide a buffer upfront, this can also happen in the response callback.

    Or it's possible to stream huge files into small fixed-size buffer,
    complete with pausing and continuing the download.

    It's also possible to improve the 'pipeline throughput' by fetching
    multiple files in parallel, but at the same time limit the maximum
    number of requests that can be 'in-flight'.

    For how this all works, please read the following documentation sections :)


    API DOCUMENTATION
    =================

    void sfetch_setup(const sfetch_desc_t* desc)
    --------------------------------------------
    First call sfetch_setup(const sfetch_desc_t*) on any thread before calling
    any other sokol-fetch functions on the same thread.

    sfetch_setup() takes a pointer to an sfetch_desc_t struct with setup
    parameters. Parameters which should use their default values must
    be zero-initialized:

        - max_requests (uint32_t):
            The maximum number of requests that can be alive at any time, the
            default is 128.

        - num_channels (uint32_t):
            The number of "IO channels" used to parallelize and prioritize
            requests, the default is 1.

        - num_lanes (uint32_t):
            The number of "lanes" on a single channel. Each request which is
            currently 'inflight' on a channel occupies one lane until the
            request is finished. This is used for automatic rate-limiting
            (search below for CHANNELS AND LANES for more details). The
            default number of lanes is 1.

    For example, to setup sokol-fetch for max 1024 active requests, 4 channels,
    and 8 lanes per channel in C99:

        sfetch_setup(&(sfetch_desc_t){
            .max_requests = 1024,
            .num_channels = 4,
            .num_lanes = 8
        });

    sfetch_setup() is the only place where sokol-fetch will allocate memory.

    NOTE that the default setup parameters of 1 channel and 1 lane per channel
    has a very poor 'pipeline throughput' since this essentially serializes
    IO requests (a new request will only be processed when the last one has
    finished), and since each request needs at least one roundtrip between
    the user- and IO-thread the throughput will be at most one request per
    frame. Search for LATENCY AND THROUGHPUT below for more information on
    how to increase throughput.

    NOTE that you can call sfetch_setup() on multiple threads, each thread
    will get its own thread-local sokol-fetch instance, which will work
    independently from sokol-fetch instances on other threads.

    void sfetch_shutdown(void)
    --------------------------
    Call sfetch_shutdown() at the end of the application to stop any
    IO threads and free all memory that was allocated in sfetch_setup().

    sfetch_handle_t sfetch_send(const sfetch_request_t* request)
    ------------------------------------------------------------
    Call sfetch_send() to start loading data, the function takes a pointer to an
    sfetch_request_t struct with request parameters and returns a
    sfetch_handle_t identifying the request for later calls. At least
    a path/URL and callback must be provided:

        sfetch_handle_t h = sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback
        });

    sfetch_send() will return an invalid handle if no request can be allocated
    from the internal pool because all available request items are 'in-flight'.

    The sfetch_request_t struct contains the following parameters (optional
    parameters that are not provided must be zero-initialized):

        - path (const char*, required)
            Pointer to an UTF-8 encoded C string describing the filesystem
            path or HTTP URL. The string will be copied into an internal data
            structure, and passed "as is" (apart from any required
            encoding-conversions) to fopen(), CreateFileW() or
            the html fetch API call. The maximum length of the string is defined by
            the SFETCH_MAX_PATH configuration define, the default is 1024 bytes
            including the 0-terminator byte.

        - callback (sfetch_callback_t, required)
            Pointer to a response-callback function which is called when the
            request needs "user code attention". Search below for REQUEST
            STATES AND THE RESPONSE CALLBACK for detailed information about
            handling responses in the response callback.

        - channel (uint32_t, optional)
            Index of the IO channel where the request should be processed.
            Channels are used to parallelize and prioritize requests relative
            to each other. Search below for CHANNELS AND LANES for more
            information. The default channel is 0.

        - chunk_size (uint32_t, optional)
            The chunk_size member is used for streaming data incrementally
            in small chunks. After 'chunk_size' bytes have been loaded into
            to the streaming buffer, the response callback will be called
            with the buffer containing the fetched data for the current chunk.
            If chunk_size is 0 (the default), than the whole file will be loaded.
            Please search below for CHUNK SIZE AND HTTP COMPRESSION for
            important information how streaming works if the web server
            is serving compressed data.

        - buffer (sfetch_range_t)
            This is a optional pointer/size pair describing a chunk of memory where
            data will be loaded into (if no buffer is provided upfront, this
            must happen in the response callback). If a buffer is provided,
            it must be big enough to either hold the entire file (if chunk_size
            is zero), or the *uncompressed* data for one downloaded chunk
            (if chunk_size is > 0).

        - user_data (sfetch_range_t)
            The user_data ptr/size range struct describe an optional POD blob
            (plain-old-data) associated with the request which will be copied(!)
            into an internal memory block. The maximum default size of this
            memory block is 128 bytes (but can be overridden by defining
            SFETCH_MAX_USERDATA_UINT64 before including the notification, note
            that this define is in "number of uint64_t", not number of bytes).
            The user-data block is 8-byte aligned, and will be copied via
            memcpy() (so don't put any C++ "smart members" in there).

    NOTE that request handles are strictly thread-local and only unique
    within the thread the handle was created on, and all function calls
    involving a request handle must happen on that same thread.

    bool sfetch_handle_valid(sfetch_handle_t request)
    -------------------------------------------------
    This checks if the provided request handle is valid, and is associated with
    a currently active request. It will return false if:

        - sfetch_send() returned an invalid handle because it couldn't allocate
          a new request from the internal request pool (because they're all
          in flight)
        - the request associated with the handle is no longer alive (because
          it either finished successfully, or the request failed for some
          reason)

    void sfetch_dowork(void)
    ------------------------
    Call sfetch_dowork(void) in regular intervals (for instance once per frame)
    on the same thread as sfetch_setup() to "turn the gears". If you are sending
    requests but never hear back from them in the response callback function, then
    the most likely reason is that you forgot to add the call to sfetch_dowork()
    in the per-frame function.

    sfetch_dowork() roughly performs the following work:

        - any new requests that have been sent with sfetch_send() since the
        last call to sfetch_dowork() will be dispatched to their IO channels
        and assigned a free lane. If all lanes on that channel are occupied
        by requests 'in flight', incoming requests must wait until
        a lane becomes available

        - for all new requests which have been enqueued on a channel which
        don't already have a buffer assigned the response callback will be
        called with (response->dispatched == true) so that the response
        callback can inspect the dynamically assigned lane and bind a buffer
        to the request (search below for CHANNELS AND LANE for more info)

        - a state transition from "user side" to "IO thread side" happens for
        each new request that has been dispatched to a channel.

        - requests dispatched to a channel are either forwarded into that
        channel's worker thread (on native platforms), or cause an HTTP
        request to be sent via an asynchronous fetch() call (on the web
        platform)

        - for all requests which have finished their current IO operation a
        state transition from "IO thread side" to "user side" happens,
        and the response callback is called so that the fetched data
        can be processed.

        - requests which are completely finished (either because the entire
        file content has been loaded, or they are in the FAILED state) are
        freed (this just changes their state in the 'request pool', no actual
        memory is freed)

        - requests which are not yet finished are fed back into the
        'incoming' queue of their channel, and the cycle starts again, this
        only happens for requests which perform data streaming (not load
        the entire file at once).

    void sfetch_cancel(sfetch_handle_t request)
    -------------------------------------------
    This cancels a request in the next sfetch_dowork() call and invokes the
    response callback with (response.failed == true) and (response.finished
    == true) to give user-code a chance to do any cleanup work for the
    request. If sfetch_cancel() is called for a request that is no longer
    alive, nothing bad will happen (the call will simply do nothing).

    void sfetch_pause(sfetch_handle_t request)
    ------------------------------------------
    This pauses an active request in the next sfetch_dowork() call and puts
    it into the PAUSED state. For all requests in PAUSED state, the response
    callback will be called in each call to sfetch_dowork() to give user-code
    a chance to CONTINUE the request (by calling sfetch_continue()). Pausing
    a request makes sense for dynamic rate-limiting in streaming scenarios
    (like video/audio streaming with a fixed number of streaming buffers. As
    soon as all available buffers are filled with download data, downloading
    more data must be prevented to allow video/audio playback to catch up and
    free up empty buffers for new download data.

    void sfetch_continue(sfetch_handle_t request)
    ---------------------------------------------
    Continues a paused request, counterpart to the sfetch_pause() function.

    void sfetch_bind_buffer(sfetch_handle_t request, sfetch_range_t buffer)
    ----------------------------------------------------------------------------------------
    This "binds" a new buffer (as pointer/size pair) to an active request. The
    function *must* be called from inside the response-callback, and there
    must not already be another buffer bound.

    void* sfetch_unbind_buffer(sfetch_handle_t request)
    ---------------------------------------------------
    This removes the current buffer binding from the request and returns
    a pointer to the previous buffer (useful if the buffer was dynamically
    allocated and it must be freed).

    sfetch_unbind_buffer() *must* be called from inside the response callback.

    The usual code sequence to bind a different buffer in the response
    callback might look like this:

        void response_callback(const sfetch_response_t* response) {
            if (response.fetched) {
                ...
                // switch to a different buffer (in the FETCHED state it is
                // guaranteed that the request has a buffer, otherwise it
                // would have gone into the FAILED state
                void* old_buf_ptr = sfetch_unbind_buffer(response.handle);
                free(old_buf_ptr);
                void* new_buf_ptr = malloc(new_buf_size);
                sfetch_bind_buffer(response.handle, new_buf_ptr, new_buf_size);
            }
            if (response.finished) {
                // unbind and free the currently associated buffer,
                // the buffer pointer could be null if the request has failed
                // NOTE that it is legal to call free() with a nullptr,
                // this happens if the request failed to open its file
                // and never goes into the OPENED state
                void* buf_ptr = sfetch_unbind_buffer(response.handle);
                free(buf_ptr);
            }
        }

    sfetch_desc_t sfetch_desc(void)
    -------------------------------
    sfetch_desc() returns a copy of the sfetch_desc_t struct passed to
    sfetch_setup(), with zero-initialized values replaced with
    their default values.

    int sfetch_max_userdata_bytes(void)
    -----------------------------------
    This returns the value of the SFETCH_MAX_USERDATA_UINT64 config
    define, but in number of bytes (so SFETCH_MAX_USERDATA_UINT64*8).

    int sfetch_max_path(void)
    -------------------------
    Returns the value of the SFETCH_MAX_PATH config define.


    REQUEST STATES AND THE RESPONSE CALLBACK
    ========================================
    A request goes through a number of states during its lifetime. Depending
    on the current state of a request, it will be 'owned' either by the
    "user-thread" (where the request was sent) or an IO thread.

    You can think of a request as "ping-ponging" between the IO thread and
    user thread, any actual IO work is done on the IO thread, while
    invocations of the response-callback happen on the user-thread.

    All state transitions and callback invocations happen inside the
    sfetch_dowork() function.

    An active request goes through the following states:

    ALLOCATED (user-thread)

        The request has been allocated in sfetch_send() and is
        waiting to be dispatched into its IO channel. When this
        happens, the request will transition into the DISPATCHED state.

    DISPATCHED (IO thread)

        The request has been dispatched into its IO channel, and a
        lane has been assigned to the request.

        If a buffer was provided in sfetch_send() the request will
        immediately transition into the FETCHING state and start loading
        data into the buffer.

        If no buffer was provided in sfetch_send(), the response
        callback will be called with (response->dispatched == true),
        so that the response callback can bind a buffer to the
        request. Binding the buffer in the response callback makes
        sense if the buffer isn't dynamically allocated, but instead
        a pre-allocated buffer must be selected from the request's
        channel and lane.

        Note that it isn't possible to get a file size in the response callback
        which would help with allocating a buffer of the right size, this is
        because it isn't possible in HTTP to query the file size before the
        entire file is downloaded (...when the web server serves files compressed).

        If opening the file failed, the request will transition into
        the FAILED state with the error code SFETCH_ERROR_FILE_NOT_FOUND.

    FETCHING (IO thread)

        While a request is in the FETCHING state, data will be loaded into
        the user-provided buffer.

        If no buffer was provided, the request will go into the FAILED
        state with the error code SFETCH_ERROR_NO_BUFFER.

        If a buffer was provided, but it is too small to contain the
        fetched data, the request will go into the FAILED state with
        error code SFETCH_ERROR_BUFFER_TOO_SMALL.

        If less data can be read from the file than expected, the request
        will go into the FAILED state with error code SFETCH_ERROR_UNEXPECTED_EOF.

        If loading data into the provided buffer works as expected, the
        request will go into the FETCHED state.

    FETCHED (user thread)

        The request goes into the FETCHED state either when the entire file
        has been loaded into the provided buffer (when request.chunk_size == 0),
        or a chunk has been loaded (and optionally decompressed) into the
        buffer (when request.chunk_size > 0).

        The response callback will be called so that the user-code can
        process the loaded data using the following sfetch_response_t struct members:

            - data.ptr: pointer to the start of fetched data
            - data.size: the number of bytes in the provided buffer
            - data_offset: the byte offset of the loaded data chunk in the
              overall file (this is only set to a non-zero value in a streaming
              scenario)

        Once all file data has been loaded, the 'finished' flag will be set
        in the response callback's sfetch_response_t argument.

        After the user callback returns, and all file data has been loaded
        (response.finished flag is set) the request has reached its end-of-life
        and will be recycled.

        Otherwise, if there's still data to load (because streaming was
        requested by providing a non-zero request.chunk_size), the request
        will switch back to the FETCHING state to load the next chunk of data.

        Note that it is ok to associate a different buffer or buffer-size
        with the request by calling sfetch_bind_buffer() in the response-callback.

        To check in the response callback for the FETCHED state, and
        independently whether the request is finished:

            void response_callback(const sfetch_response_t* response) {
                if (response->fetched) {
                    // request is in FETCHED state, the loaded data is available
                    // in .data.ptr, and the number of bytes that have been
                    // loaded in .data.size:
                    const void* data = response->data.ptr;
                    size_t num_bytes = response->data.size;
                }
                if (response->finished) {
                    // the finished flag is set either when all data
                    // has been loaded, the request has been cancelled,
                    // or the file operation has failed, this is where
                    // any required per-request cleanup work should happen
                }
            }


    FAILED (user thread)

        A request will transition into the FAILED state in the following situations:

            - if the file doesn't exist or couldn't be opened for other
              reasons (SFETCH_ERROR_FILE_NOT_FOUND)
            - if no buffer is associated with the request in the FETCHING state
              (SFETCH_ERROR_NO_BUFFER)
            - if the provided buffer is too small to hold the entire file
              (if request.chunk_size == 0), or the (potentially decompressed)
              partial data chunk (SFETCH_ERROR_BUFFER_TOO_SMALL)
            - if less bytes could be read from the file then expected
              (SFETCH_ERROR_UNEXPECTED_EOF)
            - if a request has been cancelled via sfetch_cancel()
              (SFETCH_ERROR_CANCELLED)

        The response callback will be called once after a request goes into
        the FAILED state, with the 'response->finished' and
        'response->failed' flags set to true.

        This gives the user-code a chance to cleanup any resources associated
        with the request.

        To check for the failed state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->failed) {
                    // specifically check for the failed state...
                }
                // or you can do a catch-all check via the finished-flag:
                if (response->finished) {
                    if (response->failed) {
                        // if more detailed error handling is needed:
                        switch (response->error_code) {
                            ...
                        }
                    }
                }
            }

    PAUSED (user thread)

        A request will transition into the PAUSED state after user-code
        calls the function sfetch_pause() on the request's handle. Usually
        this happens from within the response-callback in streaming scenarios
        when the data streaming needs to wait for a data decoder (like
        a video/audio player) to catch up.

        While a request is in PAUSED state, the response-callback will be
        called in each sfetch_dowork(), so that the user-code can either
        continue the request by calling sfetch_continue(), or cancel
        the request by calling sfetch_cancel().

        When calling sfetch_continue() on a paused request, the request will
        transition into the FETCHING state. Otherwise if sfetch_cancel() is
        called, the request will switch into the FAILED state.

        To check for the PAUSED state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->paused) {
                    // we can check here whether the request should
                    // continue to load data:
                    if (should_continue(response->handle)) {
                        sfetch_continue(response->handle);
                    }
                }
            }


    CHUNK SIZE AND HTTP COMPRESSION
    ===============================
    TL;DR: for streaming scenarios, the provided chunk-size must be smaller
    than the provided buffer-size because the web server may decide to
    serve the data compressed and the chunk-size must be given in 'compressed
    bytes' while the buffer receives 'uncompressed bytes'. It's not possible
    in HTTP to query the uncompressed size for a compressed download until
    that download has finished.

    With vanilla HTTP, it is not possible to query the actual size of a file
    without downloading the entire file first (the Content-Length response
    header only provides the compressed size). Furthermore, for HTTP
    range-requests, the range is given on the compressed data, not the
    uncompressed data. So if the web server decides to serve the data
    compressed, the content-length and range-request parameters don't
    correspond to the uncompressed data that's arriving in the sokol-fetch
    buffers, and there's no way from JS or WASM to either force uncompressed
    downloads (e.g. by setting the Accept-Encoding field), or access the
    compressed data.

    This has some implications for sokol_fetch.h, most notably that buffers
    can't be provided in the exactly right size, because that size can't
    be queried from HTTP before the data is actually downloaded.

    When downloading whole files at once, it is basically expected that you
    know the maximum files size upfront through other means (for instance
    through a separate meta-data-file which contains the file sizes and
    other meta-data for each file that needs to be loaded).

    For streaming downloads the situation is a bit more complicated. These
    use HTTP range-requests, and those ranges are defined on the (potentially)
    compressed data which the JS/WASM side doesn't have access to. However,
    the JS/WASM side only ever sees the uncompressed data, and it's not possible
    to query the uncompressed size of a range request before that range request
    has finished.

    If the provided buffer is too small to contain the uncompressed data,
    the request will fail with error code SFETCH_ERROR_BUFFER_TOO_SMALL.


    CHANNELS AND LANES
    ==================
    Channels and lanes are (somewhat artificial) concepts to manage
    parallelization, prioritization and rate-limiting.

    Channels can be used to parallelize message processing for better 'pipeline
    throughput', and to prioritize requests: user-code could reserve one
    channel for streaming downloads which need to run in parallel to other
    requests, another channel for "regular" downloads and yet another
    high-priority channel which would only be used for small files which need
    to start loading immediately.

    Each channel comes with its own IO thread and message queues for pumping
    messages in and out of the thread. The channel where a request is
    processed is selected manually when sending a message:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback,
            .channel = 2
        });

    The number of channels is configured at startup in sfetch_setup() and
    cannot be changed afterwards.

    Channels are completely separate from each other, and a request will
    never "hop" from one channel to another.

    Each channel consists of a fixed number of "lanes" for automatic rate
    limiting:

    When a request is sent to a channel via sfetch_send(), a "free lane" will
    be picked and assigned to the request. The request will occupy this lane
    for its entire life time (also while it is paused). If all lanes of a
    channel are currently occupied, new requests will wait until a
    lane becomes unoccupied.

    Since the number of channels and lanes is known upfront, it is guaranteed
    that there will never be more than "num_channels * num_lanes" requests
    in flight at any one time.

    This guarantee eliminates unexpected load- and memory-spikes when
    many requests are sent in very short time, and it allows to pre-allocate
    a fixed number of memory buffers which can be reused for the entire
    "lifetime" of a sokol-fetch context.

    In the most simple scenario - when a maximum file size is known - buffers
    can be statically allocated like this:

        uint8_t buffer[NUM_CHANNELS][NUM_LANES][MAX_FILE_SIZE];

    Then in the user callback pick a buffer by channel and lane,
    and associate it with the request like this:

        void response_callback(const sfetch_response_t* response) {
            if (response->dispatched) {
                void* ptr = buffer[response->channel][response->lane];
                sfetch_bind_buffer(response->handle, ptr, MAX_FILE_SIZE);
            }
            ...
        }


    NOTES ON OPTIMIZING PIPELINE LATENCY AND THROUGHPUT
    ===================================================
    With the default configuration of 1 channel and 1 lane per channel,
    sokol_fetch.h will appear to have a shockingly bad loading performance
    if several files are loaded.

    This has two reasons:

        (1) all parallelization when loading data has been disabled. A new
        request will only be processed, when the last request has finished.

        (2) every invocation of the response-callback adds one frame of latency
        to the request, because callbacks will only be called from within
        sfetch_dowork()

    sokol-fetch takes a few shortcuts to improve step (2) and reduce
    the 'inherent latency' of a request:

        - if a buffer is provided upfront, the response-callback won't be
        called in the DISPATCHED state, but start right with the FETCHED state
        where data has already been loaded into the buffer

        - there is no separate CLOSED state where the callback is invoked
        separately when loading has finished (or the request has failed),
        instead the finished and failed flags will be set as part of
        the last FETCHED invocation

    This means providing a big-enough buffer to fit the entire file is the
    best case, the response callback will only be called once, ideally in
    the next frame (or two calls to sfetch_dowork()).

    If no buffer is provided upfront, one frame of latency is added because
    the response callback needs to be invoked in the DISPATCHED state so that
    the user code can bind a buffer.

    This means the best case for a request without an upfront-provided
    buffer is 2 frames (or 3 calls to sfetch_dowork()).

    That's about what can be done to improve the latency for a single request,
    but the really important step is to improve overall throughput. If you
    need to load thousands of files you don't want that to be completely
    serialized.

    The most important action to increase throughput is to increase the
    number of lanes per channel. This defines how many requests can be
    'in flight' on a single channel at the same time. The guiding decision
    factor for how many lanes you can "afford" is the memory size you want
    to set aside for buffers. Each lane needs its own buffer so that
    the data loaded for one request doesn't scribble over the data
    loaded for another request.

    Here's a simple example of sending 4 requests without upfront buffer
    on a channel with 1, 2 and 4 lanes, each line is one frame:

        1 LANE (8 frames):
            Lane 0:
            -------------
            REQ 0 DISPATCHED
            REQ 0 FETCHED
            REQ 1 DISPATCHED
            REQ 1 FETCHED
            REQ 2 DISPATCHED
            REQ 2 FETCHED
            REQ 3 DISPATCHED
            REQ 3 FETCHED

    Note how the request don't overlap, so they can all use the same buffer.

        2 LANES (4 frames):
            Lane 0:             Lane 1:
            ------------------------------------
            REQ 0 DISPATCHED    REQ 1 DISPATCHED
            REQ 0 FETCHED       REQ 1 FETCHED
            REQ 2 DISPATCHED    REQ 3 DISPATCHED
            REQ 2 FETCHED       REQ 3 FETCHED

    This reduces the overall time to 4 frames, but now you need 2 buffers so
    that requests don't scribble over each other.

        4 LANES (2 frames):
            Lane 0:             Lane 1:             Lane 2:             Lane 3:
            ----------------------------------------------------------------------------
            REQ 0 DISPATCHED    REQ 1 DISPATCHED    REQ 2 DISPATCHED    REQ 3 DISPATCHED
            REQ 0 FETCHED       REQ 1 FETCHED       REQ 2 FETCHED       REQ 3 FETCHED

    Now we're down to the same 'best-case' latency as sending a single
    request.

    Apart from the memory requirements for the streaming buffers (which is
    under your control), you can be generous with the number of lanes,
    they don't add any processing overhead.

    The last option for tweaking latency and throughput is channels. Each
    channel works independently from other channels, so while one
    channel is busy working through a large number of requests (or one
    very long streaming download), you can set aside a high-priority channel
    for requests that need to start as soon as possible.

    On platforms with threading support, each channel runs on its own
    thread, but this is mainly an implementation detail to work around
    the traditional blocking file IO functions, not for performance reasons.


    MEMORY ALLOCATION OVERRIDE
    ==========================
    You can override the memory allocation functions at initialization time
    like this:

        void* my_alloc(size_t size, void* user_data) {
            return malloc(size);
        }

        void my_free(void* ptr, void* user_data) {
            free(ptr);
        }

        ...
            sfetch_setup(&(sfetch_desc_t){
                // ...
                .allocator = {
                    .alloc_fn = my_alloc,
                    .free_fn = my_free,
                    .user_data = ...,
                }
            });
        ...

    If no overrides are provided, malloc and free will be used.

    This only affects memory allocation calls done by sokol_fetch.h
    itself though, not any allocations in OS libraries.

    Memory allocation will only happen on the same thread where sfetch_setup()
    was called, so you don't need to worry about thread-safety.


    ERROR REPORTING AND LOGGING
    ===========================
    To get any logging information at all you need to provide a logging callback in the setup call,
    the easiest way is to use sokol_log.h:

        #include "sokol_log.h"

        sfetch_setup(&(sfetch_desc_t){
            // ...
            .logger.func = slog_func
        });

    To override logging with your own callback, first write a logging function like this:

        void my_log(const char* tag,                // e.g. 'sfetch'
                    uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
                    uint32_t log_item_id,           // SFETCH_LOGITEM_*
                    const char* message_or_null,    // a message string, may be nullptr in release mode
                    uint32_t line_nr,               // line number in sokol_fetch.h
                    const char* filename_or_null,   // source filename, may be nullptr in release mode
                    void* user_data)
        {
            ...
        }

    ...and then setup sokol-fetch like this:

        sfetch_setup(&(sfetch_desc_t){
            .logger = {
                .func = my_log,
                .user_data = my_user_data,
            }
        });

    The provided logging function must be reentrant (e.g. be callable from
    different threads).

    If you don't want to provide your own custom logger it is highly recommended to use
    the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
    errors.


    FUTURE PLANS / V2.0 IDEA DUMP
    =============================
    - An optional polling API (as alternative to callback API)
    - Move buffer-management into the API? The "manual management"
      can be quite tricky especially for dynamic allocation scenarios,
      API support for buffer management would simplify cases like
      preventing that requests scribble over each other's buffers, or
      an automatic garbage collection for dynamically allocated buffers,
      or automatically falling back to dynamic allocation if static
      buffers aren't big enough.
    - Pluggable request handlers to load data from other "sources"
      (especially HTTP downloads on native platforms via e.g. libcurl
      would be useful)
    - I'm currently not happy how the user-data block is handled, this
      should getting and updating the user-data should be wrapped by
      API functions (similar to bind/unbind buffer)


    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2019 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
// ██ ███    ███ ██████  ██      ███████ ███    ███ ███████ ███    ██ ████████  █████  ████████ ██  ██████  ███    ██
// ██ ████  ████ ██   ██ ██      ██      ████  ████ ██      ████   ██    ██    ██   ██    ██    ██ ██    ██ ████   ██
// ██ ██ ████ ██ ██████  ██      █████   ██ ████ ██ █████   ██ ██  ██    ██    ███████    ██    ██ ██    ██ ██ ██  ██
// ██ ██  ██  ██ ██      ██      ██      ██  ██  ██ ██      ██  ██ ██    ██    ██   ██    ██    ██ ██    ██ ██  ██ ██
// ██ ██      ██ ██      ███████ ███████ ██      ██ ███████ ██   ████    ██    ██   ██    ██    ██  ██████  ██   ████
//
// >>implementation
when !(defined(SOKOL_DEBUG)) {
}
private {
_sfetch_t* _sfetch;
// ██       ██████   ██████   ██████  ██ ███    ██  ██████
// ██      ██    ██ ██       ██       ██ ████   ██ ██
// ██      ██    ██ ██   ███ ██   ███ ██ ██ ██  ██ ██   ███
// ██      ██    ██ ██    ██ ██    ██ ██ ██  ██ ██ ██    ██
// ███████  ██████   ██████   ██████  ██ ██   ████  ██████
//
// >>logging
u8*[14] _sfetch_log_messages = {
    "OK: Ok", "MALLOC_FAILED: memory allocation failed",
    "FILE_PATH_UTF8_DECODING_FAILED: failed converting file path from UTF8 to wide",
    "SEND_QUEUE_FULL: send queue full (adjust via sfetch_desc_t.max_requests)",
    "REQUEST_CHANNEL_INDEX_TOO_BIG: channel index too big (adjust via sfetch_desc_t.num_channels)",
    "REQUEST_PATH_IS_NULL: file path is nullptr (sfetch_request_t.path)",
    "REQUEST_PATH_TOO_LONG: file path is too long (SFETCH_MAX_PATH)",
    "REQUEST_CALLBACK_MISSING: no callback provided (sfetch_request_t.callback)",
    "REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE: chunk size is greater buffer size (sfetch_request_t.chunk_size vs .buffer.size)",
    "REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL: user data ptr is set but user data size is null (sfetch_request_t.user_data.ptr vs .size)",
    "REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT: user data ptr is null but size is not (sfetch_request_t.user_data.ptr vs .size)",
    "REQUEST_USERDATA_SIZE_TOO_BIG: user data size too big (see SFETCH_MAX_USERDATA_UINT64)",
    "CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS: clamping num channels to SFETCH_MAX_CHANNELS",
    "REQUEST_POOL_EXHAUSTED: request pool exhausted (tweak via sfetch_desc_t.max_requests)",
};

void _sfetch_log(sfetch_log_item_t log_item, u32 log_level, u32 line_nr) {
    if _sfetch.desc.logger.func != null {
        u8* filename = "sokol_fetch.h";
        u8* message = _sfetch_log_messages[log_item];
        _sfetch.desc.logger.func("sfetch", log_level, cast(u32, log_item), message, line_nr, filename, _sfetch.desc.logger.user_data);
    } else {
        if log_level == 0 {
            abort();
        }
    }
}

// ███    ███ ███████ ███    ███  ██████  ██████  ██    ██
// ████  ████ ██      ████  ████ ██    ██ ██   ██  ██  ██
// ██ ████ ██ █████   ██ ████ ██ ██    ██ ██████    ████
// ██  ██  ██ ██      ██  ██  ██ ██    ██ ██   ██    ██
// ██      ██ ███████ ██      ██  ██████  ██   ██    ██
//
// >>memory
void _sfetch_clear(void* ptr, u64 size) {
    memset(ptr, 0, size);
}

void* _sfetch_malloc_with_allocator(sfetch_allocator_t* allocator, u64 size) {
    void* ptr;
    if allocator.alloc_fn != null {
        ptr = allocator.alloc_fn(size, allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    if null == ptr {
        _sfetch_log(SFETCH_LOGITEM_MALLOC_FAILED, 0, 1376);
    }
    return ptr;
}

void* _sfetch_malloc(u64 size) {
    return _sfetch_malloc_with_allocator(&_sfetch.desc.allocator, size);
}

void* _sfetch_malloc_clear(u64 size) {
    void* ptr = _sfetch_malloc(size);
    _sfetch_clear(ptr, size);
    return ptr;
}

void _sfetch_free(void* ptr) {
    if _sfetch.desc.allocator.free_fn != null {
        _sfetch.desc.allocator.free_fn(ptr, _sfetch.desc.allocator.user_data);
    } else {
        free(ptr);
    }
}

_sfetch_t* _sfetch_ctx() {
    return _sfetch;
}

void _sfetch_path_copy(_sfetch_path_t* dst, u8* src) {
    if src && strlen(src) < 1024 {
        strncpy_s(dst.buf, 1024, src, 1024 - 1);
        dst.buf[1024 - 1] = 0;
    } else {
        _sfetch_clear(dst.buf, 1024);
    }
}

_sfetch_path_t _sfetch_path_make(u8* str_var) {
    noinit _sfetch_path_t res;
    _sfetch_path_copy(&res, str_var);
    return res;
}

// ███    ███ ███████ ███████ ███████  █████   ██████  ███████      ██████  ██    ██ ███████ ██    ██ ███████
// ████  ████ ██      ██      ██      ██   ██ ██       ██          ██    ██ ██    ██ ██      ██    ██ ██
// ██ ████ ██ █████   ███████ ███████ ███████ ██   ███ █████       ██    ██ ██    ██ █████   ██    ██ █████
// ██  ██  ██ ██           ██      ██ ██   ██ ██    ██ ██          ██ ▄▄ ██ ██    ██ ██      ██    ██ ██
// ██      ██ ███████ ███████ ███████ ██   ██  ██████  ███████      ██████   ██████  ███████  ██████  ███████
//                                                                     ▀▀
// >>message queue
u32 _sfetch_ring_wrap(_sfetch_ring_t* rb, u32 i) {
    return i % rb.num;
}

void _sfetch_ring_discard(_sfetch_ring_t* rb) {
    if rb.buf != null {
        _sfetch_free(rb.buf);
        rb.buf = null;
    }
    rb.head = 0;
    rb.tail = 0;
    rb.num = 0;
}

bool _sfetch_ring_init(_sfetch_ring_t* rb, u32 num_slots) {
    rb.head = 0;
    rb.tail = 0;
    rb.num = num_slots + 1;
    var queue_size = cast(u64, rb.num * sizeof(sfetch_handle_t));
    rb.buf = cast(u32*, _sfetch_malloc_clear(queue_size));
    if rb.buf != null {
        return true;
    } else {
        _sfetch_ring_discard(rb);
        return false;
    }
}

bool _sfetch_ring_full(_sfetch_ring_t* rb) {
    return _sfetch_ring_wrap(rb, rb.head + 1) == rb.tail;
}

bool _sfetch_ring_empty(_sfetch_ring_t* rb) {
    return rb.head == rb.tail;
}

u32 _sfetch_ring_count(_sfetch_ring_t* rb) {
    u32 count;
    if rb.head >= rb.tail {
        count = rb.head - rb.tail;
    } else {
        count = rb.head + rb.num - rb.tail;
    }
    return count;
}

void _sfetch_ring_enqueue(_sfetch_ring_t* rb, u32 slot_id) {
    rb.buf[rb.head] = slot_id;
    rb.head = _sfetch_ring_wrap(rb, rb.head + 1);
}

u32 _sfetch_ring_dequeue(_sfetch_ring_t* rb) {
    u32 slot_id = rb.buf[rb.tail];
    rb.tail = _sfetch_ring_wrap(rb, rb.tail + 1);
    return slot_id;
}

u32 _sfetch_ring_peek(_sfetch_ring_t* rb, u32 index) {
    u32 rb_index = _sfetch_ring_wrap(rb, rb.tail + index);
    return rb.buf[rb_index];
}

// ██████  ███████  ██████  ██    ██ ███████ ███████ ████████     ██████   ██████   ██████  ██
// ██   ██ ██      ██    ██ ██    ██ ██      ██         ██        ██   ██ ██    ██ ██    ██ ██
// ██████  █████   ██    ██ ██    ██ █████   ███████    ██        ██████  ██    ██ ██    ██ ██
// ██   ██ ██      ██ ▄▄ ██ ██    ██ ██           ██    ██        ██      ██    ██ ██    ██ ██
// ██   ██ ███████  ██████   ██████  ███████ ███████    ██        ██       ██████   ██████  ███████
//                     ▀▀
// >>request pool
u32 _sfetch_make_id(u32 index, u32 gen_ctr) {
    return gen_ctr << 16 | index & 0xFFFF;
}

sfetch_handle_t _sfetch_make_handle(u32 slot_id) {
    noinit sfetch_handle_t h;
    h.id = slot_id;
    return h;
}

u32 _sfetch_slot_index(u32 slot_id) {
    return slot_id & 0xFFFF;
}

void _sfetch_item_init(_sfetch_item_t* item, u32 slot_id, sfetch_request_t* request) {
    _sfetch_clear(item, cast(u64, sizeof(_sfetch_item_t)));
    item.handle.id = slot_id;
    item.state = _SFETCH_STATE_INITIAL;
    item.channel = request.channel;
    item.chunk_size = request.chunk_size;
    item.lane = 0xFFFFFFFF;
    item.callback = request.callback;
    item.buffer = request.buffer;
    item.path = _sfetch_path_make(request.path);
    item.thread.file_handle = cast(HANDLE, -1);
    if request.user_data.ptr && request.user_data.size > 0 && request.user_data.size <= cast(u64, 16 * 8) {
        item.user.user_data_size = request.user_data.size;
        memcpy(item.user.user_data, request.user_data.ptr, request.user_data.size);
    }
}

void _sfetch_item_discard(_sfetch_item_t* item) {
    _sfetch_clear(item, cast(u64, sizeof(_sfetch_item_t)));
}

void _sfetch_pool_discard(_sfetch_pool_t* pool) {
    if pool.free_slots != null {
        _sfetch_free(pool.free_slots);
        pool.free_slots = null;
    }
    if pool.gen_ctrs != null {
        _sfetch_free(pool.gen_ctrs);
        pool.gen_ctrs = null;
    }
    if pool.items != null {
        _sfetch_free(pool.items);
        pool.items = null;
    }
    pool.size = 0;
    pool.free_top = 0;
    pool.valid = false;
}

bool _sfetch_pool_init(_sfetch_pool_t* pool, u32 num_items) {
    pool.size = num_items + 1;
    pool.free_top = 0;
    var items_size = cast(u64, pool.size * sizeof(_sfetch_item_t));
    pool.items = cast(_sfetch_item_t*, _sfetch_malloc_clear(items_size));
    var gen_ctrs_size = cast(u64, sizeof(u32) * pool.size);
    pool.gen_ctrs = cast(u32*, _sfetch_malloc_clear(gen_ctrs_size));
    var free_slots_size = cast(u64, num_items * sizeof(i32));
    pool.free_slots = cast(u32*, _sfetch_malloc_clear(free_slots_size));
    if pool.items && pool.free_slots {
        for u32 i = pool.size - 1; i >= 1; i-- {
            pool.free_slots[pool.free_top++] = i;
        }
        pool.valid = true;
    } else {
        _sfetch_pool_discard(pool);
    }
    return pool.valid;
}

u32 _sfetch_pool_item_alloc(_sfetch_pool_t* pool, sfetch_request_t* request) {
    if pool.free_top > 0 {
        u32 slot_index = pool.free_slots[--pool.free_top];
        u32 slot_id = _sfetch_make_id(slot_index, ++pool.gen_ctrs[slot_index]);
        _sfetch_item_init(&pool.items[slot_index], slot_id, request);
        pool.items[slot_index].state = _SFETCH_STATE_ALLOCATED;
        return slot_id;
    } else {
        return _sfetch_make_id(0, 0);
    }
}

void _sfetch_pool_item_free(_sfetch_pool_t* pool, u32 slot_id) {
    u32 slot_index = _sfetch_slot_index(slot_id);
    for u32 i = 0; i < pool.free_top; i++ {
    }
    _sfetch_item_discard(&pool.items[slot_index]);
    pool.free_slots[pool.free_top++] = slot_index;
}

/* return pointer to item by handle without matching id check */
_sfetch_item_t* _sfetch_pool_item_at(_sfetch_pool_t* pool, u32 slot_id) {
    u32 slot_index = _sfetch_slot_index(slot_id);
    return &pool.items[slot_index];
}

/* return pointer to item by handle with matching id check */
_sfetch_item_t* _sfetch_pool_item_lookup(_sfetch_pool_t* pool, u32 slot_id) {
    if 0 != slot_id {
        _sfetch_item_t* item = _sfetch_pool_item_at(pool, slot_id);
        if item.handle.id == slot_id {
            return item;
        }
    }
    return null;
}

// ██████   ██████  ███████ ██ ██   ██
// ██   ██ ██    ██ ██      ██  ██ ██
// ██████  ██    ██ ███████ ██   ███
// ██      ██    ██      ██ ██  ██ ██
// ██       ██████  ███████ ██ ██   ██
//
// >>posix
// ██     ██ ██ ███    ██ ██████   ██████  ██     ██ ███████
// ██     ██ ██ ████   ██ ██   ██ ██    ██ ██     ██ ██
// ██  █  ██ ██ ██ ██  ██ ██   ██ ██    ██ ██  █  ██ ███████
// ██ ███ ██ ██ ██  ██ ██ ██   ██ ██    ██ ██ ███ ██      ██
//  ███ ███  ██ ██   ████ ██████   ██████   ███ ███  ███████
//
// >>windows
bool _sfetch_win32_utf8_to_wide(u8* src, u16* dst, i32 dst_num_bytes) {
    _sfetch_clear(dst, cast(u64, dst_num_bytes));
    i32 dst_chars = dst_num_bytes / cast(i32, sizeof(u16));
    i32 dst_needed = MultiByteToWideChar(65001, 0, src, -1, null, 0);
    if dst_needed > 0 && dst_needed < dst_chars {
        MultiByteToWideChar(65001, 0, src, -1, dst, dst_chars);
        return true;
    } else {
        return false;
    }
}

_sfetch_file_handle_t _sfetch_file_open(_sfetch_path_t* path) {
    noinit u16[1024] w_path;
    if _sfetch_win32_utf8_to_wide(path.buf, w_path, cast(i32, sizeof(w_path))) == 0 {
        _sfetch_log(SFETCH_LOGITEM_FILE_PATH_UTF8_DECODING_FAILED, 1, 1377);
        return null;
    }
    _sfetch_file_handle_t h = CreateFileW(w_path, 0x80000000, 1, null, 3, cast(DWORD, 0x80 | 0x08000000), null);
    return h;
}

void _sfetch_file_close(_sfetch_file_handle_t h) {
    CloseHandle(h);
}

bool _sfetch_file_handle_valid(_sfetch_file_handle_t h) {
    return h != cast(HANDLE, -1);
}

u32 _sfetch_file_size(_sfetch_file_handle_t h) {
    return GetFileSize(h, null);
}

bool _sfetch_file_read(_sfetch_file_handle_t h, u32 offset, u32 num_bytes, void* ptr) {
    noinit LARGE_INTEGER offset_li;
    offset_li.QuadPart = cast(i64, offset);
    BOOL seek_res = SetFilePointerEx(h, offset_li, null, 0);
    if seek_res != 0 {
        DWORD bytes_read = 0;
        BOOL read_res = ReadFile(h, ptr, cast(DWORD, num_bytes), &bytes_read, null);
        return read_res && bytes_read == num_bytes;
    } else {
        return false;
    }
}

bool _sfetch_thread_init(_sfetch_thread_t* thread, _sfetch_thread_func_t thread_func, void* thread_arg) {
    thread.incoming_event = CreateEventA(null, 0, 0, null);
    InitializeCriticalSection(&thread.incoming_critsec);
    InitializeCriticalSection(&thread.outgoing_critsec);
    InitializeCriticalSection(&thread.running_critsec);
    InitializeCriticalSection(&thread.stop_critsec);
    EnterCriticalSection(&thread.running_critsec);
    var stack_size = cast(SIZE_T, 512 * 1024);
    thread.thread = CreateThread(null, cast(u64, stack_size), thread_func, thread_arg, 0, null);
    thread.valid = null != thread.thread;
    LeaveCriticalSection(&thread.running_critsec);
    return thread.valid;
}

void _sfetch_thread_request_stop(_sfetch_thread_t* thread) {
    EnterCriticalSection(&thread.stop_critsec);
    thread.stop_requested = true;
    LeaveCriticalSection(&thread.stop_critsec);
}

bool _sfetch_thread_stop_requested(_sfetch_thread_t* thread) {
    EnterCriticalSection(&thread.stop_critsec);
    bool stop_requested = thread.stop_requested;
    LeaveCriticalSection(&thread.stop_critsec);
    return stop_requested;
}

void _sfetch_thread_join(_sfetch_thread_t* thread) {
    if thread.valid != 0 {
        EnterCriticalSection(&thread.incoming_critsec);
        _sfetch_thread_request_stop(thread);
        BOOL set_event_res = SetEvent(thread.incoming_event);
        ignore set_event_res;
        LeaveCriticalSection(&thread.incoming_critsec);
        _sfetch_win32_wait(thread.thread, cast(DWORD, 0xFFFFFFFF));
        CloseHandle(thread.thread);
        thread.valid = false;
    }
    CloseHandle(thread.incoming_event);
    DeleteCriticalSection(&thread.stop_critsec);
    DeleteCriticalSection(&thread.running_critsec);
    DeleteCriticalSection(&thread.outgoing_critsec);
    DeleteCriticalSection(&thread.incoming_critsec);
}

void _sfetch_thread_entered(_sfetch_thread_t* thread) {
    EnterCriticalSection(&thread.running_critsec);
}

/* called by the thread-func right before it is left */
void _sfetch_thread_leaving(_sfetch_thread_t* thread) {
    LeaveCriticalSection(&thread.running_critsec);
}

void _sfetch_thread_enqueue_incoming(_sfetch_thread_t* thread, _sfetch_ring_t* incoming, _sfetch_ring_t* src) {
    if _sfetch_ring_empty(src) == 0 {
        EnterCriticalSection(&thread.incoming_critsec);
        while !_sfetch_ring_full(incoming) && !_sfetch_ring_empty(src) {
            _sfetch_ring_enqueue(incoming, _sfetch_ring_dequeue(src));
        }
        LeaveCriticalSection(&thread.incoming_critsec);
        BOOL set_event_res = SetEvent(thread.incoming_event);
        ignore set_event_res;
    }
}

u32 _sfetch_thread_dequeue_incoming(_sfetch_thread_t* thread, _sfetch_ring_t* incoming) {
    EnterCriticalSection(&thread.incoming_critsec);
    while _sfetch_ring_empty(incoming) && !thread.stop_requested {
        LeaveCriticalSection(&thread.incoming_critsec);
        _sfetch_win32_wait(thread.incoming_event, cast(DWORD, 0xFFFFFFFF));
        EnterCriticalSection(&thread.incoming_critsec);
    }
    u32 item = 0;
    if thread.stop_requested == 0 {
        item = _sfetch_ring_dequeue(incoming);
    }
    LeaveCriticalSection(&thread.incoming_critsec);
    return item;
}

void _sfetch_thread_enqueue_outgoing(_sfetch_thread_t* thread, _sfetch_ring_t* outgoing, u32 item) {
    EnterCriticalSection(&thread.outgoing_critsec);
    if _sfetch_ring_full(outgoing) == 0 {
        _sfetch_ring_enqueue(outgoing, item);
    }
    LeaveCriticalSection(&thread.outgoing_critsec);
}

void _sfetch_thread_dequeue_outgoing(_sfetch_thread_t* thread, _sfetch_ring_t* outgoing, _sfetch_ring_t* dst) {
    EnterCriticalSection(&thread.outgoing_critsec);
    while !_sfetch_ring_full(dst) && !_sfetch_ring_empty(outgoing) {
        _sfetch_ring_enqueue(dst, _sfetch_ring_dequeue(outgoing));
    }
    LeaveCriticalSection(&thread.outgoing_critsec);
}

//  ██████ ██   ██  █████  ███    ██ ███    ██ ███████ ██      ███████
// ██      ██   ██ ██   ██ ████   ██ ████   ██ ██      ██      ██
// ██      ███████ ███████ ██ ██  ██ ██ ██  ██ █████   ██      ███████
// ██      ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██           ██
//  ██████ ██   ██ ██   ██ ██   ████ ██   ████ ███████ ███████ ███████
//
// >>channels
/* per-channel request handler for native platforms accessing the local filesystem */
void _sfetch_request_handler(_sfetch_t* ctx, u32 slot_id) {
    _sfetch_state_t state;
    _sfetch_path_t* path;
    _sfetch_item_thread_t* thread;
    sfetch_range_t* buffer;
    u32 chunk_size;
    {
        _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, slot_id);
        if item == null {
            return;
        }
        state = item.state;
        path = &item.path;
        thread = &item.thread;
        buffer = &item.buffer;
        chunk_size = item.chunk_size;
    }
    if thread.failed != 0 {
        return;
    }
    if state == _SFETCH_STATE_FETCHING {
        if buffer.ptr == null || buffer.size == 0 {
            thread.error_code = SFETCH_ERROR_NO_BUFFER;
            thread.failed = true;
        } else {
            if _sfetch_file_handle_valid(thread.file_handle) == 0 {
                thread.file_handle = _sfetch_file_open(path);
                if _sfetch_file_handle_valid(thread.file_handle) != 0 {
                    thread.content_size = _sfetch_file_size(thread.file_handle);
                } else {
                    thread.error_code = SFETCH_ERROR_FILE_NOT_FOUND;
                    thread.failed = true;
                }
            }
            if thread.failed == 0 {
                u32 read_offset = 0;
                u32 bytes_to_read = 0;
                if chunk_size == 0 {
                    if thread.content_size <= buffer.size {
                        bytes_to_read = thread.content_size;
                        read_offset = 0;
                    } else {
                        thread.error_code = SFETCH_ERROR_BUFFER_TOO_SMALL;
                        thread.failed = true;
                    }
                } else {
                    if chunk_size <= buffer.size {
                        bytes_to_read = chunk_size;
                        read_offset = thread.fetched_offset;
                        if read_offset + bytes_to_read > thread.content_size {
                            bytes_to_read = thread.content_size - read_offset;
                        }
                    } else {
                        thread.error_code = SFETCH_ERROR_BUFFER_TOO_SMALL;
                        thread.failed = true;
                    }
                }
                if thread.failed == 0 {
                    if _sfetch_file_read(thread.file_handle, read_offset, bytes_to_read, buffer.ptr) != 0 {
                        thread.fetched_size = bytes_to_read;
                        thread.fetched_offset += bytes_to_read;
                    } else {
                        thread.error_code = SFETCH_ERROR_UNEXPECTED_EOF;
                        thread.failed = true;
                    }
                }
            }
        }
        if thread.failed || thread.fetched_offset == thread.content_size {
            if _sfetch_file_handle_valid(thread.file_handle) != 0 {
                _sfetch_file_close(thread.file_handle);
                thread.file_handle = cast(HANDLE, -1);
            }
            thread.finished = true;
        }
    }
}

DWORD _sfetch_channel_thread_func(LPVOID arg) {
    var chn = cast(_sfetch_channel_t*, arg);
    _sfetch_thread_entered(&chn.thread);
    while _sfetch_thread_stop_requested(&chn.thread) == 0 {
        u32 slot_id = _sfetch_thread_dequeue_incoming(&chn.thread, &chn.thread_incoming);
        if _sfetch_thread_stop_requested(&chn.thread) == 0 {
            chn.request_handler(chn.ctx, slot_id);
            _sfetch_thread_enqueue_outgoing(&chn.thread, &chn.thread_outgoing, slot_id);
        }
    }
    _sfetch_thread_leaving(&chn.thread);
    return 0;
}

void _sfetch_channel_discard(_sfetch_channel_t* chn) {
    if chn.valid != 0 {
        _sfetch_thread_join(&chn.thread);
    }
    _sfetch_ring_discard(&chn.thread_incoming);
    _sfetch_ring_discard(&chn.thread_outgoing);
    _sfetch_ring_discard(&chn.free_lanes);
    _sfetch_ring_discard(&chn.user_sent);
    _sfetch_ring_discard(&chn.user_incoming);
    _sfetch_ring_discard(&chn.user_outgoing);
    _sfetch_ring_discard(&chn.free_lanes);
    chn.valid = false;
}

bool _sfetch_channel_init(_sfetch_channel_t* chn, _sfetch_t* ctx, u32 num_items, u32 num_lanes, fn(_sfetch_t*, u32): void request_handler) {
    bool valid = true;
    chn.request_handler = request_handler;
    chn.ctx = ctx;
    valid &= _sfetch_ring_init(&chn.free_lanes, num_lanes);
    for u32 lane = 0; lane < num_lanes; lane++ {
        _sfetch_ring_enqueue(&chn.free_lanes, lane);
    }
    valid &= _sfetch_ring_init(&chn.user_sent, num_items);
    valid &= _sfetch_ring_init(&chn.user_incoming, num_lanes);
    valid &= _sfetch_ring_init(&chn.user_outgoing, num_lanes);
    valid &= _sfetch_ring_init(&chn.thread_incoming, num_lanes);
    valid &= _sfetch_ring_init(&chn.thread_outgoing, num_lanes);
    if valid != 0 {
        chn.valid = true;
        _sfetch_thread_init(&chn.thread, _sfetch_channel_thread_func, chn);
        return true;
    } else {
        _sfetch_channel_discard(chn);
        return false;
    }
}

/* put a request into the channels sent-queue, this is where all new requests
   are stored until a lane becomes free.
*/
bool _sfetch_channel_send(_sfetch_channel_t* chn, u32 slot_id) {
    if _sfetch_ring_full(&chn.user_sent) == 0 {
        _sfetch_ring_enqueue(&chn.user_sent, slot_id);
        return true;
    } else {
        _sfetch_log(SFETCH_LOGITEM_SEND_QUEUE_FULL, 1, 1377);
        return false;
    }
}

void _sfetch_invoke_response_callback(_sfetch_item_t* item) {
    noinit sfetch_response_t response;
    _sfetch_clear(&response, cast(u64, sizeof(response)));
    response.handle = item.handle;
    response.dispatched = item.state == _SFETCH_STATE_DISPATCHED;
    response.fetched = item.state == _SFETCH_STATE_FETCHED;
    response.paused = item.state == _SFETCH_STATE_PAUSED;
    response.finished = item.user.finished;
    response.failed = item.state == _SFETCH_STATE_FAILED;
    response.cancelled = item.user.cancel;
    response.error_code = item.user.error_code;
    response.channel = item.channel;
    response.lane = item.lane;
    response.path = item.path.buf;
    response.user_data = item.user.user_data;
    response.data_offset = item.user.fetched_offset - item.user.fetched_size;
    response.data.ptr = item.buffer.ptr;
    response.data.size = item.user.fetched_size;
    response.buffer = item.buffer;
    item.callback(&response);
}

void _sfetch_cancel_item(_sfetch_item_t* item) {
    item.state = _SFETCH_STATE_FAILED;
    item.user.finished = true;
    item.user.error_code = SFETCH_ERROR_CANCELLED;
}

/* per-frame channel stuff: move requests in and out of the IO threads, call response callbacks */
void _sfetch_channel_dowork(_sfetch_channel_t* chn, _sfetch_pool_t* pool) {
    u32 num_sent = _sfetch_ring_count(&chn.user_sent);
    u32 avail_lanes = _sfetch_ring_count(&chn.free_lanes);
    u32 num_move = num_sent < avail_lanes ? num_sent : avail_lanes;
    for u32 i = 0; i < num_move; i++ {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_sent);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
            _sfetch_invoke_response_callback(item);
            _sfetch_pool_item_free(pool, slot_id);
            continue;
        }
        item.state = _SFETCH_STATE_DISPATCHED;
        item.lane = _sfetch_ring_dequeue(&chn.free_lanes);
        if null == item.buffer.ptr {
            _sfetch_invoke_response_callback(item);
        }
        _sfetch_ring_enqueue(&chn.user_incoming, slot_id);
    }
    u32 num_incoming = _sfetch_ring_count(&chn.user_incoming);
    for u32 i = 0; i < num_incoming; i++ {
        u32 slot_id = _sfetch_ring_peek(&chn.user_incoming, i);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        if item.user.pause != 0 {
            item.state = _SFETCH_STATE_PAUSED;
            item.user.pause = false;
        }
        if item.user.cont != 0 {
            if item.state == _SFETCH_STATE_PAUSED {
                item.state = _SFETCH_STATE_FETCHED;
            }
            item.user.cont = false;
        }
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
        }
        switch item.state {
            case _SFETCH_STATE_DISPATCHED, _SFETCH_STATE_FETCHED: {
                item.state = _SFETCH_STATE_FETCHING;
            }
            default: {
            }
        }
    }
    _sfetch_thread_enqueue_incoming(&chn.thread, &chn.thread_incoming, &chn.user_incoming);
    _sfetch_thread_dequeue_outgoing(&chn.thread, &chn.thread_outgoing, &chn.user_outgoing);
    while _sfetch_ring_empty(&chn.user_outgoing) == 0 {
        u32 slot_id = _sfetch_ring_dequeue(&chn.user_outgoing);
        _sfetch_item_t* item = _sfetch_pool_item_lookup(pool, slot_id);
        item.user.fetched_offset = item.thread.fetched_offset;
        item.user.fetched_size = item.thread.fetched_size;
        if item.user.cancel != 0 {
            _sfetch_cancel_item(item);
        } else {
            item.user.error_code = item.thread.error_code;
        }
        if item.thread.finished != 0 {
            item.user.finished = true;
        }
        if item.thread.failed != 0 {
            item.state = _SFETCH_STATE_FAILED;
        } else if item.state == _SFETCH_STATE_FETCHING {
            item.state = _SFETCH_STATE_FETCHED;
        }
        _sfetch_invoke_response_callback(item);
        if item.user.finished != 0 {
            _sfetch_ring_enqueue(&chn.free_lanes, item.lane);
            _sfetch_pool_item_free(pool, slot_id);
        } else {
            _sfetch_ring_enqueue(&chn.user_incoming, slot_id);
        }
    }
}

bool _sfetch_validate_request(_sfetch_t* ctx, sfetch_request_t* req) {
    if req.channel >= ctx.desc.num_channels {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CHANNEL_INDEX_TOO_BIG, 1, 1377);
        return false;
    }
    if req.path == null {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_PATH_IS_NULL, 1, 1377);
        return false;
    }
    if strlen(req.path) >= cast(u64, 1024 - 1) {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_PATH_TOO_LONG, 1, 1377);
        return false;
    }
    if req.callback == null {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CALLBACK_MISSING, 1, 1377);
        return false;
    }
    if req.chunk_size > req.buffer.size {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE, 1, 1377);
        return false;
    }
    if req.user_data.ptr && req.user_data.size == 0 {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL, 1, 1377);
        return false;
    }
    if !req.user_data.ptr && req.user_data.size > 0 {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT, 1, 1377);
        return false;
    }
    if req.user_data.size > cast(u64, 16 * sizeof(u64)) {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_USERDATA_SIZE_TOO_BIG, 1, 1377);
        return false;
    }
    return true;
}

sfetch_desc_t _sfetch_desc_defaults(sfetch_desc_t* desc) {
    sfetch_desc_t res = *desc;
    res.max_requests = cast(u32, desc.max_requests == 0 ? 128 : desc.max_requests);
    res.num_channels = cast(u32, desc.num_channels == 0 ? 1 : desc.num_channels);
    res.num_lanes = cast(u32, desc.num_lanes == 0 ? 1 : desc.num_lanes);
    return res;
}
}

// ██████  ██    ██ ██████  ██      ██  ██████
// ██   ██ ██    ██ ██   ██ ██      ██ ██
// ██████  ██    ██ ██████  ██      ██ ██
// ██      ██    ██ ██   ██ ██      ██ ██
// ██       ██████  ██████  ███████ ██  ██████
//
// >>public
void sfetch_setup(sfetch_desc_t* desc_) {
    sfetch_desc_t desc = _sfetch_desc_defaults(desc_);
    _sfetch = cast(_sfetch_t*, _sfetch_malloc_with_allocator(&desc.allocator, cast(u64, sizeof(_sfetch_t))));
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_clear(ctx, cast(u64, sizeof(_sfetch_t)));
    ctx.desc = desc;
    ctx.setup = true;
    ctx.valid = true;
    if ctx.desc.num_channels > 16 {
        ctx.desc.num_channels = 16;
        _sfetch_log(SFETCH_LOGITEM_CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS, 2, 1378);
    }
    ctx.valid &= _sfetch_pool_init(&ctx.pool, ctx.desc.max_requests);
    for u32 i = 0; i < ctx.desc.num_channels; i++ {
        ctx.valid &= _sfetch_channel_init(&ctx.chn[i], ctx, ctx.desc.max_requests, ctx.desc.num_lanes, cast(fn(_sfetch_t*, u32): void, _sfetch_request_handler));
    }
}

void sfetch_shutdown() {
    _sfetch_t* ctx = _sfetch_ctx();
    ctx.valid = false;
    for u32 i = 0; i < ctx.desc.num_channels; i++ {
        if ctx.chn[i].valid != 0 {
            _sfetch_channel_discard(&ctx.chn[i]);
        }
    }
    _sfetch_pool_discard(&ctx.pool);
    ctx.setup = false;
    _sfetch_free(ctx);
    _sfetch = null;
}

bool sfetch_valid() {
    _sfetch_t* ctx = _sfetch_ctx();
    return ctx && ctx.valid;
}

sfetch_desc_t sfetch_desc() {
    _sfetch_t* ctx = _sfetch_ctx();
    return ctx.desc;
}

i32 sfetch_max_userdata_bytes() {
    return 16 * 8;
}

i32 sfetch_max_path() {
    return 1024;
}

bool sfetch_handle_valid(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    if h.id == 0 {
        return false;
    }
    return null != _sfetch_pool_item_lookup(&ctx.pool, h.id);
}

sfetch_handle_t sfetch_send(sfetch_request_t* request) {
    _sfetch_t* ctx = _sfetch_ctx();
    sfetch_handle_t invalid_handle = _sfetch_make_handle(0);
    if ctx.valid == 0 {
        return invalid_handle;
    }
    if _sfetch_validate_request(ctx, request) == 0 {
        return invalid_handle;
    }
    u32 slot_id = _sfetch_pool_item_alloc(&ctx.pool, request);
    if 0 == slot_id {
        _sfetch_log(SFETCH_LOGITEM_REQUEST_POOL_EXHAUSTED, 2, 1378);
        return invalid_handle;
    }
    if _sfetch_channel_send(&ctx.chn[request.channel], slot_id) == 0 {
        _sfetch_pool_item_free(&ctx.pool, slot_id);
        return invalid_handle;
    }
    return _sfetch_make_handle(slot_id);
}

void sfetch_dowork() {
    _sfetch_t* ctx = _sfetch_ctx();
    if ctx.valid == 0 {
        return;
    }
    ctx.in_callback = true;
    for i32 pass = 0; pass < 2; pass++ {
        for u32 chn_index = 0; chn_index < ctx.desc.num_channels; chn_index++ {
            _sfetch_channel_dowork(&ctx.chn[chn_index], &ctx.pool);
        }
    }
    ctx.in_callback = false;
}

void sfetch_bind_buffer(sfetch_handle_t h, sfetch_range_t buffer) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.buffer = buffer;
    }
}

void* sfetch_unbind_buffer(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        var prev_buf_ptr = item.buffer.ptr;
        item.buffer.ptr = null;
        item.buffer.size = 0;
        return prev_buf_ptr;
    } else {
        return null;
    }
}

void sfetch_pause(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.pause = true;
        item.user.cont = false;
    }
}

void sfetch_continue(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.cont = true;
        item.user.pause = false;
    }
}

void sfetch_cancel(sfetch_handle_t h) {
    _sfetch_t* ctx = _sfetch_ctx();
    _sfetch_item_t* item = _sfetch_pool_item_lookup(&ctx.pool, h.id);
    if item != null {
        item.user.cont = false;
        item.user.pause = false;
        item.user.cancel = true;
    }
}

}

// sokol_fetch: Win32 runtime externs for the transpiled module
// (threading, events, file IO). Concatenated AFTER the module so the
// unit's HANDLE / DWORD / CRITICAL_SECTION / LARGE_INTEGER /
// LPTHREAD_START_ROUTINE types are already declared.

when os(windows) {
    extern "kernel32.dll" {
        i32 MultiByteToWideChar(u32 cp, DWORD flags, u8* src, i32 cbMulti, u16* dst, i32 cchWide);
        HANDLE CreateFileW(u16* name, DWORD access, DWORD share, void* sa, DWORD disp, DWORD flags, HANDLE tmpl);
        i32 CloseHandle(HANDLE h);
        DWORD GetFileSize(HANDLE h, DWORD* hi);
        i32 SetFilePointerEx(HANDLE h, LARGE_INTEGER dist, LARGE_INTEGER* newp, DWORD method);
        i32 ReadFile(HANDLE h, void* buf, DWORD n, DWORD* got, void* ovl);
        HANDLE CreateEventA(void* sa, i32 manual, i32 initial, u8* name);
        i32 SetEvent(HANDLE ev);
        // i64 handle on purpose: matches lib/file.mc's declaration of
        // the same import (cross-module extern signatures must agree)
        u32 WaitForSingleObject(i64 h, u32 ms);
        void InitializeCriticalSection(CRITICAL_SECTION* cs);
        void DeleteCriticalSection(CRITICAL_SECTION* cs);
        void EnterCriticalSection(CRITICAL_SECTION* cs);
        void LeaveCriticalSection(CRITICAL_SECTION* cs);
        HANDLE CreateThread(void* sa, u64 stack, LPTHREAD_START_ROUTINE start, void* arg, DWORD flags, DWORD* tid);
    }

    // the prelude macros WaitForSingleObject call sites onto this
    u32 _sfetch_win32_wait(HANDLE h, u32 ms) {
        return WaitForSingleObject(cast(i64, h), ms);
    }
}

// The wasm arm makes two calls out to JS instead. Their EM_JS bodies
// are blanked out of the vendored header; ext/sokol_wasm_host.js
// answers on the "fetch" import module and calls the responses back.
when os(wasm) {
    extern "fetch" {
        void sfetch_js_send_head_request(u32 slot_id, u8* path_cstr);
        // buf_size is the sfetch_range_t field's u64, not the header's
        // uint32_t parameter: the call site passes it straight through
        // and minc will not narrow implicitly. It reaches JS as a BigInt.
        void sfetch_js_send_get_request(u32 slot_id, u8* path_cstr, u32 offset,
                                        u32 bytes_to_read, void* buf_ptr, u64 buf_size);
    }

    // The responses JS calls back on. transminc emits the header's
    // helpers as plain functions and has no way to mark one `export`,
    // so these thin wrappers carry the keyword; the host calls them by
    // these names.
    export void sfetch_emsc_head_response(u32 slot_id, u32 content_length) {
        _sfetch_emsc_head_response(slot_id, content_length);
    }
    export void sfetch_emsc_get_response(u32 slot_id, u32 range_fetched_size, u32 content_fetched_size) {
        _sfetch_emsc_get_response(slot_id, range_fetched_size, content_fetched_size);
    }
    export void sfetch_emsc_failed_http_status(u32 slot_id, u32 http_status) {
        _sfetch_emsc_failed_http_status(slot_id, http_status);
    }
    export void sfetch_emsc_failed_buffer_too_small(u32 slot_id) {
        _sfetch_emsc_failed_buffer_too_small(slot_id);
    }
    export void sfetch_emsc_failed_other(u32 slot_id) {
        _sfetch_emsc_failed_other(slot_id);
    }
}

when os(linux) || os(macos) || os(ios) {

import thread;
import file;
import str;

private {
    // pthread_mutex_t is 72 bytes, Mutex is 64; pthread_cond_t is 96,
    // Semaphore is 80. Both blobs are the larger of the pair, so the
    // reinterpret is in bounds. Kept as functions rather than inline
    // casts so the pairing is stated once.
    Mutex* _sfetch_mtx(pthread_mutex_t* m) { return cast(Mutex*, m); }
    Semaphore* _sfetch_sem(pthread_cond_t* c) { return cast(Semaphore*, c); }
}

// --- mutex ----------------------------------------------------------
// The attr calls carry nothing sokol uses (it initializes and destroys
// a default attr around every init), so they are accepted and dropped.

i32 pthread_mutexattr_init(pthread_mutexattr_t* attr) { ignore attr; return 0; }
i32 pthread_mutexattr_destroy(pthread_mutexattr_t* attr) { ignore attr; return 0; }

i32 pthread_mutex_init(pthread_mutex_t* m, pthread_mutexattr_t* attr) {
    ignore attr;
    mutex_init(_sfetch_mtx(m));
    return 0;
}

i32 pthread_mutex_destroy(pthread_mutex_t* m) {
    mutex_destroy(_sfetch_mtx(m));
    return 0;
}

i32 pthread_mutex_lock(pthread_mutex_t* m) {
    mutex_lock(_sfetch_mtx(m));
    return 0;
}

i32 pthread_mutex_unlock(pthread_mutex_t* m) {
    mutex_unlock(_sfetch_mtx(m));
    return 0;
}

// --- condition variable ---------------------------------------------
// Stood up on a counting semaphore. sokol uses the one classic shape:
//
//     lock(m); while (queue empty && !stop) cond_wait(c, m); ...; unlock(m)
//     lock(m); enqueue; cond_signal(c); unlock(m)
//
// A signal that lands between the unlock and the wait is not lost; it
// increments the count and the wait returns at once. The reverse
// (surplus counts from several signals) only costs an extra trip round
// the caller's while-loop, which re-tests the predicate. A condvar's
// atomic unlock-and-wait is not needed for that shape.

i32 pthread_condattr_init(pthread_condattr_t* attr) { ignore attr; return 0; }
i32 pthread_condattr_destroy(pthread_condattr_t* attr) { ignore attr; return 0; }

i32 pthread_cond_init(pthread_cond_t* c, pthread_condattr_t* attr) {
    ignore attr;
    sem_init(_sfetch_sem(c), 0);
    return 0;
}

i32 pthread_cond_destroy(pthread_cond_t* c) {
    sem_destroy(_sfetch_sem(c));
    return 0;
}

i32 pthread_cond_signal(pthread_cond_t* c) {
    sem_signal(_sfetch_sem(c));
    return 0;
}

i32 pthread_cond_wait(pthread_cond_t* c, pthread_mutex_t* m) {
    mutex_unlock(_sfetch_mtx(m));
    sem_wait(_sfetch_sem(c));
    mutex_lock(_sfetch_mtx(m));
    return 0;
}

// --- thread ---------------------------------------------------------

// pthread_t is one pointer-sized slot holding the minc Thread handle,
// so the struct field is a plain void* and &field is where the handle
// goes.
i32 pthread_create(void** t, void* attr, _sfetch_thread_func_t start, void* arg) {
    ignore attr;
    // minc's entry point returns void; sokol's returns void* and the
    // value is never read (pthread_join is passed a null retval).
    thread_create(cast(Thread*, t), cast(fn(void*): void, start), arg);
    return 0;
}

i32 pthread_join(void* t, void** retval) {
    ignore retval;
    thread_join(cast(Thread*, &t));
    return 0;
}

// --- file -----------------------------------------------------------
// minc has open/read/close but no seek, so the handle carries its own
// position and skips forward by reading. sokol reads a request's chunks
// at monotonically increasing offsets, so the skip is normally zero and
// never runs backwards; a backward seek reopens, which is correct but
// slow, and nothing in sokol_fetch does it.

private {
    struct _SfetchFile {
        i32 used;      // 0 free, 1 taken; claimed with atomic_cas
        i32 _pad;
        i64 fd;
        i64 pos;
        i64 size;
        u8[1024] path;
    }

    // A handful of open files at a time, one per lane, and sokol bounds
    // lanes per channel. Static so no allocator is involved on the IO
    // threads, and claimed with a CAS so several of them can open at
    // once without a lock of our own.
    _SfetchFile[16] _sfetch_files;

    i64 _sfetch_skip(_SfetchFile* f, i64 want) {
        noinit u8[4096] scratch;
        while f.pos < want {
            i64 n = want - f.pos;
            if n > 4096 { n = 4096; }
            i32 got = read(f.fd, scratch, cast(i32, n));
            if got <= 0 { return f.pos; }
            f.pos = f.pos + cast(i64, got);
        }
        return f.pos;
    }
}

_sfetch_file_handle_t fopen(u8* path, u8* mode) {
    ignore mode;
    _SfetchFile* slot = null;
    for i32 i = 0; i < 16; i++ {
        if atomic_cas(&_sfetch_files[i].used, 0, 1) {
            slot = &_sfetch_files[i];
            break;
        }
    }
    if slot == null { return null; }

    i64 fd = open(path, 0);
    if fd < 0 {
        atomic_store(&slot.used, 0);
        return null;
    }
    slot.fd = fd;
    slot.pos = 0;
    i32 n = 0;
    while *(path + n) != 0 && n < 1023 {
        slot.path[n] = *(path + n);
        n = n + 1;
    }
    slot.path[n] = cast(u8, 0);
    FileStamp st = file_stamp(str_from(path, n));
    slot.size = st.ok ? st.size : cast(i64, 0);
    return cast(_sfetch_file_handle_t, slot);
}

i32 fclose(_sfetch_file_handle_t h) {
    if h == null { return 0; }
    _SfetchFile* f = cast(_SfetchFile*, h);
    close(f.fd);
    f.fd = 0;
    // Released last: the slot is reusable the moment this lands.
    atomic_store(&f.used, 0);
    return 0;
}

// SEEK_SET = 0, SEEK_END = 2. sokol only uses those two.
i32 fseek(_sfetch_file_handle_t h, i64 offset, i32 whence) {
    if h == null { return -1; }
    _SfetchFile* f = cast(_SfetchFile*, h);
    i64 want = whence == 2 ? f.size : offset;
    if want < f.pos {
        // Rewind by reopening; the fd has no seek of its own.
        close(f.fd);
        f.fd = open(f.path, 0);
        f.pos = 0;
        if f.fd < 0 { return -1; }
    }
    _sfetch_skip(f, want);
    return f.pos == want ? 0 : -1;
}

i64 ftell(_sfetch_file_handle_t h) {
    if h == null { return -1; }
    return cast(_SfetchFile*, h).pos;
}

u64 fread(void* ptr, u64 size, u64 count, _sfetch_file_handle_t h) {
    if h == null { return cast(u64, 0); }
    _SfetchFile* f = cast(_SfetchFile*, h);
    i64 want = cast(i64, size * count);
    i64 done = 0;
    while done < want {
        i32 got = read(f.fd, cast(u8*, ptr) + done, cast(i32, want - done));
        if got <= 0 { break; }
        done = done + cast(i64, got);
        f.pos = f.pos + cast(i64, got);
    }
    return size == 0 ? cast(u64, 0) : cast(u64, done) / size;
}

}

