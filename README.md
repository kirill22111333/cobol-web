# COBOL WEB FRAMEWORK
A simple web framework for developing COBOL web applications.

## Run with docker

#### Pull image:
``` console
$ docker pull kirull1/cobol-web:latest
```

#### Create container(interactive):
``` console
$ docker run -it -p 8000:8000 kirull1/cobol-web:latest
```

#### Create simple program:
Choose the example you are interested in. (for example "send-text")
``` console
$ cd examples/send-text
```

Run the executable file.
``` console
$ ./main
```

## Build
In order to build the project, you need to run the command:
```console
$ make default
```
After a successful build of the project, the created folder "obj" will contain the object file "lib.o".

To add a framework to your program:
```console
$ cobc -x your_main_file.cbl ... lib.o
```

## Examples
A large number of examples are provided in the `./examples/` directory. Each example can be compiled with `make` and run.

To build examples, run the command:
```console
$ make example
```
After the build is completed, executable files will be created in the folders with examples.
