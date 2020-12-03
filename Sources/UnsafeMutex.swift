//
//  Copyright © 2020 Andreas Grosam.
//  Licensed under the Apache License, Version 2.0.
//

import Foundation

final class Mutex {
    private var unsafeMutex: pthread_mutex_t = pthread_mutex_t()

    init() {
        var attr = pthread_mutexattr_t()
        guard pthread_mutexattr_init(&attr) == 0 else {
            preconditionFailure()
        }
        pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_NORMAL))
        guard pthread_mutex_init(&self.unsafeMutex, &attr) == 0 else {
            preconditionFailure()
        }
        pthread_mutexattr_destroy(&attr)
    }

    final func lock() {
        _ = pthread_mutex_lock(&self.unsafeMutex)
    }

    final func unlock() {
        _ = pthread_mutex_unlock(&self.unsafeMutex)
    }

    deinit {
        assert(pthread_mutex_trylock(&self.unsafeMutex) == 0 && pthread_mutex_unlock(&self.unsafeMutex) == 0, "deinitialization of a locked mutex results in undefined behavior!")
        pthread_mutex_destroy(&self.unsafeMutex)
    }
}
