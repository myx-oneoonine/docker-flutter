# Example Makefile for Flutter projects in Docker
# This demonstrates how to use makefiles with the Docker Flutter environment

.PHONY: init gen_all clean build test doctor help

# Initialize Flutter project
init:
	@echo "🚀 Initializing Flutter project..."
	@flutter create . --project-name example_app 2>/dev/null || echo "Project already exists"
	@flutter pub get

# Generate all code (example for code generation)
gen_all:
	@echo "🔨 Generating code..."
	@echo "Flutter version: $$(flutter --version | head -1)"
	@echo "Current user: $$(whoami)"
	@echo "Working directory: $$(pwd)"
	@flutter pub get
	@echo "✅ Code generation completed"

# Build the Flutter app
build:
	@echo "🏗️  Building Flutter app..."
	@flutter build web --release

# Run tests
test:
	@echo "🧪 Running Flutter tests..."
	@flutter test

# Check Flutter doctor
doctor:
	@echo "🩺 Running Flutter doctor..."
	@flutter doctor

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@flutter clean

# Show help
help:
	@echo "Available targets:"
	@echo "  init     - Initialize Flutter project"
	@echo "  gen_all  - Generate all code"
	@echo "  build    - Build Flutter app"
	@echo "  test     - Run tests"
	@echo "  doctor   - Run Flutter doctor"
	@echo "  clean    - Clean build artifacts"