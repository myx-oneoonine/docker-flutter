# Docker Flutter Environment

A comprehensive Docker environment for Flutter development with FVM (Flutter Version Manager) support, designed for development workflows and CI/CD pipelines.

## Features

- ✅ Flutter Version Manager (FVM) support
- ✅ Makefile execution support
- ✅ Configurable Flutter version via build args
- ✅ Source code mounting support
- ✅ Interactive shell access
- ✅ Direct Flutter command execution
- ✅ GitHub Actions compatibility
- ✅ Multi-platform support (linux/amd64, linux/arm64)

## Building the Image

### Basic Build

```bash
# Build with default Flutter version (stable)
docker buildx build -t flutter-dev .

# Build with specific Flutter version
docker buildx build --build-arg FLUTTER_VERSION=3.16.0 -t flutter-dev:3.16.0 .

# Build with latest Flutter version
docker buildx build --build-arg FLUTTER_VERSION=beta -t flutter-dev:beta .
```

### Multi-platform Build

```bash
# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg FLUTTER_VERSION=stable \
  -t flutter-dev:latest .

# Build and push to registry
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg FLUTTER_VERSION=stable \
  -t your-registry/flutter-dev:latest \
  --push .
```

## Usage Examples

### 1. Interactive Shell Access

```bash
# Run interactive shell
docker run -it --rm flutter-dev sh

# Run bash shell
docker run -it --rm flutter-dev bash
```

### 2. Direct Flutter Commands

```bash
# Check Flutter version
docker run --rm flutter-dev flutter --version

# Create new Flutter project
docker run --rm -v $(pwd):/workspace flutter-dev flutter create my_app

# Run Flutter doctor
docker run --rm flutter-dev flutter doctor
```

### 3. Makefile Execution

```bash
# Mount your project and run make commands
docker run --rm -v $(pwd):/workspace flutter-dev make gen_all

# For projects in subdirectories
docker run --rm -v $(pwd):/workspace flutter-dev sh -c "cd tdac && make gen_all"

# Interactive make development
docker run -it --rm -v $(pwd):/workspace flutter-dev bash
# Inside container: cd your-project && make your-target
```

### 4. Project Development Workflow

```bash
# Mount your Flutter project and work interactively
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  flutter-dev bash

# Run specific Flutter commands on your mounted project
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  flutter-dev flutter pub get

docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  flutter-dev flutter test
```

### 5. FVM Commands

```bash
# List available Flutter versions
docker run --rm flutter-dev fvm releases

# Check current Flutter version managed by FVM
docker run --rm flutter-dev fvm flutter --version

# Use different Flutter version (if pre-installed)
docker run --rm flutter-dev fvm use 3.16.0
```

## GitHub Actions Integration

### Basic Usage

```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build Flutter Docker image
      run: |
        docker buildx build \
          --build-arg FLUTTER_VERSION=stable \
          -t flutter-dev .
    
    - name: Run Flutter tests
      run: |
        docker run --rm \
          -v ${{ github.workspace }}:/workspace \
          -w /workspace \
          flutter-dev flutter test
    
    - name: Build Flutter app
      run: |
        docker run --rm \
          -v ${{ github.workspace }}:/workspace \
          -w /workspace \
          flutter-dev flutter build web
```

### Matrix Strategy with Multiple Flutter Versions

```yaml
name: Flutter Multi-Version CI

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        flutter-version: [stable, beta, '3.16.0']
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build Flutter Docker image
      run: |
        docker buildx build \
          --build-arg FLUTTER_VERSION=${{ matrix.flutter-version }} \
          -t flutter-dev:${{ matrix.flutter-version }} .
    
    - name: Run tests with Flutter ${{ matrix.flutter-version }}
      run: |
        docker run --rm \
          -v ${{ github.workspace }}:/workspace \
          -w /workspace \
          flutter-dev:${{ matrix.flutter-version }} flutter test
```

### Pre-built Image Usage

If you push the image to a registry, you can use it directly:

```yaml
name: Flutter CI with Pre-built Image

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: your-registry/flutter-dev:latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Run makefile targets
      run: make gen_all
```

## Environment Variables

The following environment variables are available in the container:

- `PATH`: Includes Flutter, Dart, and FVM binaries
- `FLUTTER_ROOT`: Points to the Flutter SDK location managed by FVM
- `PUB_CACHE`: Dart package cache location

## Volumes and Working Directory

- **Default working directory**: `/workspace`
- **Recommended mount point**: `/workspace`
- **User**: `flutter` (non-root user with sudo access)

## Troubleshooting

### Permission Issues

If you encounter permission issues when mounting volumes, use one of these solutions:

**Option 1: Match user IDs (Recommended)**
```bash
# Check your user ID
echo "Your UID: $(id -u), GID: $(id -g)"

# Run with matching user ID
docker run --rm -v $(pwd):/workspace \
  --user $(id -u):$(id -g) \
  flutter-dev-test flutter pub get
```

**Option 2: Use with proper ownership**
```bash
# Change ownership of your project directory
sudo chown -R 1000:1000 your-project-directory

# Then run normally
docker run --rm -v $(pwd):/workspace \
  flutter-dev-test flutter pub get
```

**Option 3: Create the project from within the container**
```bash
# Create a new Flutter project
docker run --rm -v $(pwd):/workspace \
  --user $(id -u):$(id -g) \
  flutter-dev-test flutter create my_app
```

### FVM Issues

```bash
# Check FVM status
docker run --rm flutter-dev fvm list

# Verify Flutter installation
docker run --rm flutter-dev fvm flutter doctor -v
```

### Make Command Issues

```bash
# Ensure Makefile has proper line endings (Unix style)
# Check if make is available
docker run --rm flutter-dev which make

# Run make with verbose output
docker run --rm -v $(pwd):/workspace flutter-dev make -n your-target
```

## Building Custom Images

You can extend this image for specific project needs:

```dockerfile
FROM your-registry/flutter-dev:latest

# Install additional tools
USER root
RUN apt-get update && apt-get install -y your-tools
USER flutter

# Pre-install project dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Set up project-specific environment
ENV YOUR_PROJECT_VAR=value
```

## Supported Platforms

- `linux/amd64`
- `linux/arm64`

## Testing

This repository includes a comprehensive test script that validates all documented examples:

```bash
# Run all tests to verify functionality
./test.sh
```

The test script validates:
- Flutter installation and version checking
- Makefile execution support
- FVM installation and activation
- Volume mounting and permissions
- Project creation and dependency management
- Build arguments and multi-platform support

## DockerHub Pipelines

This repository includes two automated CI/CD pipelines that build and push Docker images to DockerHub.

### 1. Automated Pipeline (dockerhub-pipeline.yml)

**Features:**
- Automated builds on push to main branch and pull requests
- Manual workflow dispatch with configurable Flutter version
- Docker login with credentials from GitHub secrets
- Multi-tag support (version-specific and latest)
- Image testing with volume mounts
- Automated push to DockerHub registry

### 2. Manual Flutter Build Pipeline (manual-flutter-build.yml)

**Features:**
- Dedicated manual-only workflow for custom Flutter versions
- Required Flutter version input with validation
- Enhanced testing including `flutter doctor` verification
- Dual tagging: version-specific and manual-prefixed tags
- Detailed build summary and reporting

### Setup

1. Add `DOCKER_SECRET` to your GitHub repository secrets with your DockerHub password
2. The automated pipeline will build and push images tagged as:
   - `myx4play/flutter:stable` (or specified version)
   - `myx4play/flutter:latest`
3. The manual pipeline will build and push images tagged as:
   - `myx4play/flutter:{version}` (e.g., `myx4play/flutter:3.24.0`)
   - `myx4play/flutter:manual-{version}` (e.g., `myx4play/flutter:manual-3.24.0`)

### Manual Triggers

**Automated Pipeline:**
1. Go to Actions → "Build and Push Flutter Docker Image to DockerHub"
2. Click "Run workflow"
3. Enter the desired Flutter version (default: stable)

**Manual Build Pipeline:**
1. Go to Actions → "Manual Flutter Build and Push"
2. Click "Run workflow"
3. Enter the required Flutter version (e.g., stable, beta, 3.24.0, 3.22.0)

### Testing Pipeline Locally

```bash
# Test all pipeline steps locally
./test-pipeline.sh
```

## License

This project is open source and available under the [MIT License](LICENSE).