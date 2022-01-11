# SQLCipher(SQLite3) V4.5.0 library for windows X64

This package help you bundle SQLCipher(SQLite3) library to your apps.

He was originally developed to use with [SQLite3 with SQLCipher](https://github.com/simolus3/sqlite3.dart/tree/master/sqlcipher_flutter_libs).

## Dependencies

To work, SQLCipher needs work with OpenSSL 64 bits libraries (libcrypto-1_1-x64.dll and libssl-1_1-x64.dll). </br>
These libraries are automatically pasted near the main Flutter_program.exe. to be dynamically linked with sqlcipher.dll</br></br>

You can also paste these two DLLs into a Windows PATH directory of your choice.

## How to use with SQLite3 package

Add an override for windows and give it the `openSQLCipherOnWindows` function provided by the package:

```Dart
    import 'package:sqlite3/open.dart';
    import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';


    open.overrideFor(OperatingSystem.windows, openSQLCipherOnWindows);
```

## Errors

If you encounted some errors at runtime:

- ensure you are on a 64 bit Windows version.</br>
- Use [Process Monitor](https://docs.microsoft.com/en-us/sysinternals/downloads/procmon) to find details about your error (like a dll not found for example).

## Next

Today, this is a package, it could be better to move it to a plugin to avoid embedding DLLs ont other OS projects.</br>
Unfortunately, I'm not familiar with Flutter Windows Plugin and ignore how to create a plugin with my 3 embedded DLLs.</br>
You're welcome to make a pull request.
