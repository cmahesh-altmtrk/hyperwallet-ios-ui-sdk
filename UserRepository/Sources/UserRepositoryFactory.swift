//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// Class contains methods to get an instance of user repository
public final class UserRepositoryFactory {
    private static var instance: UserRepositoryFactory?
    private let remoteUserRepository: UserRepository

    /// Returns the previously initialized instance of the RepositoryFactory object
    public static var shared: UserRepositoryFactory {
        guard let instance = instance else {
            self.instance = UserRepositoryFactory()
            return self.instance!
        }
        return instance
    }

    /// Clears the UserRepositoryFactory singleton instance.
    public static func clearInstance() {
        instance = nil
    }

    private init() {
        remoteUserRepository = RemoteUserRepository()
    }

    /// Gets an instance of user repository.
    ///
    /// - Returns: The UserRepository
    public func userRepository() -> UserRepository {
        return remoteUserRepository
    }
}
