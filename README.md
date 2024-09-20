# Tagion Dart API plugin

## Key Concepts:

This guide provides an overview of how to use key components within the Tagion Dart API.
Current project is a Dart wrapper on top of the [Tagion API](https://github.com/tagion/tagion/tree/master/src/lib-api/tagion/api).

**API is divided into 5 modules:**
- **Basic module**: Handles the runtime of the API. It must be initialized and started before interacting with other modules.
- **Crypto module**: Manages cryptographic operations like keypair generation and device pin decryption using a `SecureNet` pointer.
- **Hibon module**: Represents hierarchical data structures that can be manipulated and converted into document buffers.
- **Document module**: A structured data format created from a `Hibon` buffer, allowing for data retrieval and manipulation.
- **HiRPC module**: Allows for the creation of signed requests, ensuring secure interactions with external systems.

## Getting Started

### Clone and run as a standalone project.

1. Clone the [project](https://gitlab.com/decard/tagion_dart_api)
2. Navigate to an example folder with a test app:

```
cd example
```
3. Launch an emulator

```
emulator -avd my_emulator
```
4. Connect the Emulator to Flutter
- Run `flutter devices` to ensure that Flutter recognizes the running emulator.

```
2 connected devices:

my_emulator • emulator • android-x86 • Android 11 (API 30) (emulator)
Chrome (web) • chrome • web-javascript • Google Chrome 128.0.6613.85
```
5. Launch the test app by using `flutter run` command.

### Run integration tests

```
/// Running emulator is needed.
cd example
flutter test integration_test/entry_point_integration_test.dart
```

### Run unit tests

```
/// Run it from a project root folder.
flutter test
```
## Binaries download

TODO: Add a description how to download binaries.

## Usage

This documentation provides examples of how to use key classes and methods within the Tagion Dart API. Each example demonstrates the basic workflow and object instantiation process, along with detailed descriptions of methods and usage patterns.

### Example 1: Creating and Managing a Basic Object

The `Basic` object is essential for managing the runtime of the API. Before you can interact with any other modules, the `Basic` object must be instantiated, and its runtime must be explicitly started. The runtime management involves two key methods: `startDRuntime()` and `stopDRuntime()`. You must ensure that the runtime is running while using other API functionalities and that it is stopped once the operations are complete.

```
IBasic basic = Basic.init();

// Start the D runtime to enable other modules.
basic.startDRuntime();

// After finishing, stop the runtime to free resources.
basic.stopDRuntime();
```

### Example 2: Generating Keypair and Decrypting Device Pin with Crypto Object

The `Crypto` object provides cryptographic operations that allow for generating a new keypair and decrypting an existing device pin. In this example, after instantiating a `Crypto` object (assuming the `Basic` object has already started the runtime), a `SecureNet` pointer is created to store the cryptographic information. The pointer can then be used to generate a new keypair or decrypt an existing encrypted pin.

It is crucial to retain the `SecureNet` pointer throughout the lifetime of the application, as it holds vital cryptographic information that is required for signing and other cryptographic operations.

```
ICrypto crypto = Crypto.init();

Pointer<SecureNet> secureNetPtr = malloc<SecureNet>();

// Generate a new keypair with a passphrase, pincode, salt, and SecureNet pointer.
// The result is encrypted devicePin data.
Uint8List devicePinData = crypto.generateKeypair('differ portion age fame', '123456', 'salt', secureNetPtr);

// Sign data using the SecureNet pointer and pass it along to cryptographic functions.
Uint8List signedData = crypto.sign(dataToSign, secureNetPtr);

// ---

// Decrypt the devicePin data using the pincode and SecureNet pointer.
crypto.decryptDevicePin('123456', devicePinData, secureNetPtr);
```

### Example 3: Creating and Managing a Hibon Object

The `Hibon` object is used to represent and manage hierarchical data structures. It is important to first call the `create()` method before adding any data to the `Hibon` object. Data can be added as key-value pairs or as nested `Hibon` objects ([also supports other types](https://ddoc.tagion.org/tagion.api.hibon.html)). The hierarchical structure of `Hibon` allows the user to create complex, nested data objects.

Once the data is structured, you can obtain a document buffer representing the `Hibon`, which can later be used to create a document.

```
IHibon hibon = Hibon.init();

// Create a new Hibon structure before adding data to it.
hibon.create();

// Add a key-value pair to the Hibon object.
hibon.addString('key', 'value');

// Create another nested Hibon object and add it to the main Hibon.
IHibon innerHibon = Hibon.init();
innerHibon.create();
innerHibon.addString('innerKey', 'innerValue');

// Add the nested Hibon object to the main Hibon by a key.
hibon.addHibonByKey('inner', innerHibon);

// Obtain the Hibon object as a document buffer.
// This buffer can be used for creating a document or other operations.
hibon.getAsDocumentBuffer();
```

### Example 4: Creating a Document from Hibon Buffer

Once you have a `Hibon` object, you can use it to create a `Document` object. The document is essentially a structured representation of the data, which allows further interaction through methods that retrieve specific elements by key. The retrieved elements can return either string values or nested sub-documents.

```
// Create a Document object from a Hibon buffer.
// The buffer is obtained from the Hibon object by calling the getAsDocumentBuffer method.
IDocument document = Document.init(hibon.getAsDocumentBuffer());

// Retrieve an element from the document by its key.
IDocumentElement element = document.getElementByKey('key');

// Get the string value of the document element.
element.getString();

// Retrieve a sub-document from the document element, if the element represents a nested structure.
element.getSubDocument();
```

### Example 5: Creating a Signed Request with HiRPC

The `HiRPC` object allows you to create signed requests for secure communication with the system. This example shows how to generate a signed HiRPC request using a method name, a `SecureNet` pointer, an optional document buffer, and an optional deriver. The document buffer can be obtained from a `Hibon` object using the `getAsDocumentBuffer()` method.

```
IHiRPC hiRPC = TagionHiRPC.init();

// Create a signed HiRPC request using a method name, SecureNet pointer, and optional document buffer/deriver.
// This method returns a signed request as a Uint8List, ready for transmission.
Uint8List signedRequest = hiRPC.createSignedRequest("method", secureNetPtr, docBuffer, deriver);
```