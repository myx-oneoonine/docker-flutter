# Support Script Documentation

## Overview

The `support.sh` script (aka "Bob") is a comprehensive helper tool for the Docker Flutter development environment. It provides convenient commands to manage Docker containers, run Flutter commands, and work with example projects.

## Features

- 🐳 Docker container management
- 🎯 Flutter command execution in containerized environment
- 📁 Example project management with Makefile support
- 🐚 Interactive shell access
- 🧪 Testing and debugging tools
- 🧹 Cleanup utilities

## Usage

```bash
./support.sh <task> [<..args>]
```

## Available Commands

### Core Commands

- **`init`** - Initialize Docker Flutter development environment and examples
- **`build`** - Build Docker Flutter image with optional build args
- **`shell`** - Run interactive shell in Docker Flutter environment
- **`test`** - Run tests for Docker Flutter environment
- **`clean`** - Clean Docker images and containers

### Development Commands

- **`flutter <args>`** - Run flutter commands in Docker environment
- **`docker <command>`** - Run arbitrary docker commands with the Flutter environment
- **`examples <make_target>`** - Helper for example Flutter project tasks

## Examples

```bash
# Initialize the development environment
./support.sh init

# Start an interactive shell
./support.sh shell

# Check Flutter version
./support.sh flutter --version

# Run make commands in the example project
./support.sh examples help
./support.sh examples gen_all
./support.sh examples init

# Run custom Docker commands
./support.sh docker "ls -la"
./support.sh docker "which make"

# Build with custom arguments
./support.sh build --build-arg FLUTTER_VERSION=stable

# Clean up resources
./support.sh clean
```

## Example Project

The script includes an example Flutter project with a Makefile located at `examples/flutter-project/`. This demonstrates how to integrate makefiles with the Docker Flutter environment, similar to the original script's `tdac` and `shared` directory structure.

Available example project targets:
- `init` - Initialize Flutter project
- `gen_all` - Generate all code
- `build` - Build Flutter app
- `test` - Run tests
- `doctor` - Run Flutter doctor
- `clean` - Clean build artifacts

## ASCII Art

The script features "Bob" ASCII art that displays when running commands, maintaining the fun and friendly character of the original script.

## Integration

This support script is designed to work seamlessly with the existing Docker Flutter environment infrastructure, including:
- Dockerfile configuration
- Existing test scripts (test.sh, test-pipeline.sh)
- GitHub Actions workflows
- Documentation in README.md