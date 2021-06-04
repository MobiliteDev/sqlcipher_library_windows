library sqlite3_library_windows;

import 'dart:ffi' show DynamicLibrary;
import 'dart:io' show Platform, File;

///relative path to
const assets_package_dir =
    'data\\flutter_assets\\packages\\sqlcipher_library_windows\\assets';

///relative path to SQLCipher library file
const sqlcipher_windows_dll = 'sqlcipher.dll';

///relative path to OpenSSL library 1
const openssl_lib_crypto_dll = 'libcrypto-1_1-x64.dll';

///relative path to OpenSSL library 2
const openssl_lib_ssl_dll = 'libssl-1_1-x64.dll';

///This function open SQLCipher in memory and return the associated DynamicLibrary.
///Return null if app fail to open SQLCipher.
///set useOpenSSLEmbededDlls to false if you prefer let Windows searching DLLs on the system
DynamicLibrary openSQLCipherOnWindows({bool useOpenSSLEmbededDlls = true}) {
  late DynamicLibrary library;
  String sep = Platform.pathSeparator;
  String exeDirPath = File(Platform.resolvedExecutable).parent.path;
  print('executableDirectoryPath: $exeDirPath');

  String packageAssetsDirPath =
      exeDirPath + Platform.pathSeparator + assets_package_dir;
  print('packageAssetsDirectoryPath: $packageAssetsDirPath');

  //OpenSSL libcryptoxxx.dll FullPath  destination
  String libCryptoDllDestFullPath = exeDirPath + sep + openssl_lib_crypto_dll;
  //OpenSSL libsslxxx.dll FullPath  destination
  String libSSLDllDestFullPath = exeDirPath + sep + openssl_lib_ssl_dll;

  //OpenSSL libcryptoxxx.dll FullPath  source
  String libCyptoDllSourceFullPath =
      packageAssetsDirPath + sep + openssl_lib_crypto_dll;
  //OpenSSL libsslxxx.dll FullPath  source
  String libSSLDllSourceFullPath =
      packageAssetsDirPath + sep + openssl_lib_ssl_dll;

  //Chek if it is needed to copy DLLs in another directory that my_app.exe could use when executing
  if (useOpenSSLEmbededDlls) {
    bool needToCopy = false;
    //Check if one of destination libraries does not exists
    if (File(libCryptoDllDestFullPath).existsSync() == false ||
        File(libSSLDllDestFullPath).existsSync() == false) {
      //Re sync both libraries
      needToCopy = true;
    } else if (File(libCryptoDllDestFullPath).existsSync() == true ||
        File(libSSLDllDestFullPath).existsSync() == true) {
      //Check if sizes are differents
      needToCopy = (File(libCryptoDllDestFullPath).lengthSync() !=
              File(libCyptoDllSourceFullPath).lengthSync()) ||
          (File(libSSLDllDestFullPath).lengthSync() !=
              File(libSSLDllSourceFullPath).lengthSync());
    }
    //Copy DLLs
    if (needToCopy) {
      File(libCyptoDllSourceFullPath).copySync(libCryptoDllDestFullPath);
      print(_yellow(
          '$openssl_lib_crypto_dll: copied from $libCyptoDllSourceFullPath to $libCryptoDllDestFullPath'));
      File(libSSLDllSourceFullPath).copySync(libSSLDllDestFullPath);
      print(_yellow(
          '$openssl_lib_ssl_dll: copied from $libSSLDllSourceFullPath to $libSSLDllDestFullPath'));
    }
  }

  //Now load the SQLCipher DLL
  try {
    String sqliteLibraryPath =
        packageAssetsDirPath + sep + sqlcipher_windows_dll;
    print('SQLCipherLibraryPath: $sqliteLibraryPath');

    library = DynamicLibrary.open(sqliteLibraryPath);

    print(_yellow("SQLCipher successfully loaded"));
  } catch (e) {
    try {
      print(e);
      print(_red("Failed to load SQLCipher from library file, "
          "trying loading from system..."));

      library = DynamicLibrary.open('sqlcipher.dll');

      print(_yellow("SQLCipher successfully loaded"));
    } catch (e) {
      print(e);
      print(_red("Fail to load SQLCipher."));
    }
  }
  return library;
}

String _red(String string) => '\x1B[31m$string\x1B[0m';

String _yellow(String string) => '\x1B[32m$string\x1B[0m';
